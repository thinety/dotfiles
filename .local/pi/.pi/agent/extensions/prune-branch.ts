import type {
  ExtensionAPI,
  ExtensionCommandContext,
  FileEntry,
  SessionEntry,
  SessionTreeNode,
} from "@earendil-works/pi-coding-agent";
import {
  parseSessionEntries,
  TreeSelectorComponent,
} from "@earendil-works/pi-coding-agent";
import { constants } from "fs";
import * as fs from "fs/promises";

interface TreeNode {
  entry: SessionEntry;
  children: TreeNode[];
}

/**
 * Traverses subtree via DFS to collect all descendant IDs in O(N).
 */
function collectDescendantIds(startNode: TreeNode, outSet: Set<string>): void {
  outSet.add(startNode.entry.id);
  for (const child of startNode.children) {
    collectDescendantIds(child, outSet);
  }
}

/**
 * Extracts a short summary for confirmation prompts using TypeScript type discrimination.
 */
function getEntrySummary(entry: SessionEntry): string {
  switch (entry.type) {
    case "session_info":
      return entry.name ? `[session] "${entry.name}"` : "[session]";
    case "message": {
      const msg = entry.message;
      const role = msg.role;
      let text = "";
      if ("content" in msg) {
        if (typeof msg.content === "string") {
          text = msg.content;
        } else if (Array.isArray(msg.content)) {
          text = msg.content
            .filter((c): c is { type: "text"; text: string } => c.type === "text" && Boolean(c.text))
            .map((c) => c.text)
            .join(" ");
        }
      }
      const clean = text.replace(/\s+/g, " ").trim();
      const short = clean ? `"${clean.slice(0, 50)}${clean.length > 50 ? "…" : ""}"` : "";
      return `[${role}] ${short}`;
    }
    default:
      return `[${entry.type}]`;
  }
}

type CustomResult =
  | { action: "prune"; entryId: string }
  | { action: "cancel" };

export default function (pi: ExtensionAPI) {
  pi.registerCommand("prune", {
    description: "Navigate session tree using native TUI and press Enter to prune that branch",
    handler: async (_args: string, ctx: ExtensionCommandContext) => {
      // Get session tree via typed ExtensionCommandContext
      const tree: SessionTreeNode[] = ctx.sessionManager.getTree();
      const currentLeafId = ctx.sessionManager.getLeafId();

      // Open native TreeSelectorComponent directly; pressing Enter triggers prune action
      const result = await ctx.ui.custom<CustomResult>((tui, _theme, _keybindings, done) => {
        return new TreeSelectorComponent(
          tree,
          currentLeafId,
          tui.terminal.rows,
          (id: string) => done({ action: "prune", entryId: id }),
          () => done({ action: "cancel" }),
          undefined,
          undefined,
          "default"
        );
      });

      if (!result || result.action !== "prune") {
        ctx.ui.notify("Cancelled.", "info");
        return;
      }
      const targetId = result.entryId;

      const sessionPath = ctx.sessionManager.getSessionFile();
      if (!sessionPath) {
        ctx.ui.notify("No active session file found.", "error");
        return;
      }

      // Read and parse file
      const fileContent = await fs.readFile(sessionPath, "utf8");
      const fileEntries: FileEntry[] = parseSessionEntries(fileContent);
      const sessionEntries: SessionEntry[] = fileEntries.filter((e): e is SessionEntry => e.type !== "session");

      // Build adjacency map in O(N)
      const nodeMap = new Map<string, TreeNode>();
      for (const entry of sessionEntries) {
        nodeMap.set(entry.id, { entry, children: [] });
      }
      for (const entry of sessionEntries) {
        const node = nodeMap.get(entry.id)!;
        if (!entry.parentId) continue;
        const parent = nodeMap.get(entry.parentId);
        if (!parent) continue;
        parent.children.push(node);
      }

      const targetNode = nodeMap.get(targetId);
      if (!targetNode) {
        ctx.ui.notify("Could not find selected entry in session file.", "error");
        return;
      }

      // DFS to collect all descendant IDs in O(N)
      const toDelete = new Set<string>();
      collectDescendantIds(targetNode, toDelete);

      const summary = getEntrySummary(targetNode.entry);

      // Confirm deletion
      const confirm = await ctx.ui.confirm(
        "Confirm Deletion",
        `Permanently delete ${toDelete.size} entry(ies) starting at:\n${summary}?`
      );
      if (!confirm) {
        ctx.ui.notify("Prune aborted.", "info");
        return;
      }

      // Destination leaf after reload
      const isCurrentInsideDeleted = currentLeafId !== null && toDelete.has(currentLeafId);
      const targetParentId = targetNode.entry.parentId ?? null;
      const desiredTargetId = isCurrentInsideDeleted ? targetParentId : currentLeafId;

      // Backup and write clean session JSONL asynchronously
      const backupPath = `${sessionPath}.bak`;
      await fs.copyFile(sessionPath, backupPath);

      const remainingEntries = fileEntries.filter((e) => !toDelete.has(e.id));
      const updatedContent = remainingEntries.map((e) => JSON.stringify(e)).join("\n") + "\n";
      await fs.writeFile(sessionPath, updatedContent, "utf8");

      // Reload session from disk using typed switchSession API and navigate to desiredTargetId
      await ctx.switchSession(sessionPath, {
        withSession: async (ctx) => {
          if (desiredTargetId) {
            await ctx.navigateTree(desiredTargetId, { summarize: false });
          }
        },
      });
    },
  });
}
