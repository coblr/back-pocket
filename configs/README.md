# Configs

Shared dotfiles and application configs, synced across machines via symlinks.

## Setup

### Prerequisites

1. Clone this repo using the `github-personal` SSH host alias:
   ```bash
   git clone git@github-personal:coblr/back-pocket.git
   ```

2. Your `~/.ssh/config` needs entries for both work and personal GitHub accounts.
   See the SSH section below.

### Install

```bash
cd back-pocket/main/configs
chmod +x install.sh
./install.sh
```

This creates symlinks from the standard config locations (`~/.config/nvim`, `~/.tmux.conf`, etc.)
to this repo. Edits in either location are the same file.

### Machine-specific config

Work-specific environment variables, aliases, and paths go in `~/.zshrc.local` (not tracked).
The shared `.zshrc` sources this file at the end if it exists.

Example things that go in `.zshrc.local`:
- AWS credentials/region
- GitHub token exports for private registries
- Project-specific aliases (e.g. pnpm filter shortcuts)

Similarly, Claude Code machine-specific settings go in `~/.claude/settings.local.json` (not tracked).
It merges on top of the synced `settings.json` at runtime.

Example things that go in `settings.local.json`:
- `env` block (AWS profile, OTEL/telemetry endpoints and tokens)
- `awsAuthRefresh` command
- MCP permissions for tools only installed on this machine (e.g. Atlassian, Slack)
- Machine-specific plugins and marketplaces

## What's included

| Directory    | Symlinks to              | What it is                          |
|--------------|--------------------------|-------------------------------------|
| `nvim/`      | `~/.config/nvim`         | Full Neovim config (NvChad-based)   |
| `ghostty/`   | `~/.config/ghostty`      | Terminal theme + transparency        |
| `oh-my-posh/`| `~/.config/oh-my-posh`   | Shell prompt theme                  |
| `tmux/`      | `~/.tmux.conf`           | Tmux configuration                  |
| `zsh/`       | `~/.zshrc`               | Shared shell config + worktree helpers |
| `claude/`    | `~/.claude/CLAUDE.md`, `settings.json`, `statusline.sh` | Claude Code global config |

## Tested versions

These configs were built/tested against the following versions. Older versions
may work but aren't guaranteed.

| Tool        | Version |
|-------------|---------|
| Neovim      | 0.11.5  |
| tmux        | 3.6a    |
| Ghostty     | 1.3.1   |
| oh-my-posh  | 27.6.0  |
| zsh         | 5.9     |

## SSH setup (multi-account GitHub)

To push/pull this repo from a machine that uses a different (e.g. work) GitHub account,
add a personal SSH key and host alias:

```
# ~/.ssh/config

Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

Host github-personal
  HostName github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_personal
```

Then set the repo-level git identity:
```bash
git config user.name "your-username"
git config user.email "your-email"
```
