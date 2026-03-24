import type { Plugin } from "@opencode-ai/plugin"

/**
 * Git Commit Guard Plugin
 * 
 * Blocks all `git commit` commands to prevent accidental commits without GPG signing.
 * This is a defense-in-depth measure complementing the permission config.
 * 
 * Reason: This machine requires GPG-signed commits, but opencode sessions have no TTY access.
 * GPG will fail with: "gpg: cannot open '/dev/tty': No such device or address"
 * 
 * Users must commit manually in their own terminal where GPG + TTY work.
 */
export const GitCommitGuardPlugin: Plugin = async ({ client }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "bash") {
        const rawCommand = output?.args?.command
        if (typeof rawCommand !== "string") return
        const command = rawCommand.toLowerCase().trim()
        
        // Block any form of git commit
        if (command.startsWith("git commit")) {
          const errorMessage = `
🚫 BLOCKED: git commit is not allowed in opencode sessions.

REASON: This machine requires GPG-signed commits, but opencode sessions have no TTY access.
        GPG will fail with: "gpg: cannot open '/dev/tty': No such device or address"

SOLUTION: Commit manually in your own terminal where GPG + TTY work.

ALLOWED GIT OPERATIONS:
  ✅ git add, git status, git diff, git log, git stash
  ✅ git branch, git checkout, git merge, git rebase
  ❌ git commit (use your terminal)
  ❌ git push (use your terminal)

For details, load the git skill: skill(name="git")
          `
          throw new Error(errorMessage.trim())
        }
        
        await client.app.log({
          body: {
            service: "git-commit-guard-plugin",
            level: "info",
            message: `Git command allowed: ${command.substring(0, 50)}...`,
          }
        })
      }
    }
  }
}
