# harpoon.el

🚀 Minimal, project-aware file bookmarking for Emacs. Inspired by [harpoon.nvim](https://github.com/ThePrimeagen/harpoon).

## Why?

Yes, there are other bookmarking plugins for Emacs. But this one exists because:

1. Just because.
2. Why not.
3. Unlike many others, it **does not store anything inside your **``** directory**, meaning your bookmarks survive `git checkout branch` — no more losing state across branches.
   - Project-specific bookmarks require [Projectile](https://github.com/bbatsov/projectile).
   - Outside of any project, bookmarks are saved to a **global fallback file**.
4. It's minimal: under 200 lines of Emacs Lisp. Zero dependencies.
5. Includes harpoon-next / harpoon-prev functions for fast cycling like in harpoon.nvim.
6. Bookmarks are searchable through minibuffer using your existing file selection tools (e.g. counsel with fzf), making navigation fast and intuitive.

## Features

- 🔖 Project-aware or global file bookmarking
- 🧭 Simple jumping between files
- 🧼 Clean, minimal UI
- ⚡ Fast, stateful file cycling

### Manual

Clone and add to your `load-path`:

```elisp
(add-to-list 'load-path "/path/to/harpoon.el")
(require 'harpoon)
```

## Usage

- `M-x harpoon-add` – Add current file
- `M-x harpoon-remove` – Remove current file
- `M-x harpoon-open-menu` – Fuzzy-select and open file
- `M-x harpoon-next` / `harpoon-prev` – Cycle through files
- `M-x harpoon-clear` – Clear bookmarks
- `M-x harpoon-go-to-[1-9]` – Jump to nth bookmark

## Example Configuration (Evil + which-key)

```elisp
(spc-leader
  "h" '(:ignore t :wk "help & harpoon")
  "h a" '(harpoon-add :wk "add to harpoon")
  "h c" '(harpoon-clear :wk "harboon clear")
  "h l" '(harpoon-open-menu :wk "list & open")
  "h d" '(harpoon-remove-from-menu :wk "remove from list")
  "h e" '(harpoon-edit :wk "harpoon edit")

  "h n" '(harpoon-next :wk "next file")
  "h p" '(harpoon-prev :wk "previous file")

  "h 1" '(harpoon-go-to-1 :wk "1")
  "h 2" '(harpoon-go-to-2 :wk "2")
  "h 3" '(harpoon-go-to-3 :wk "3")
  "h 4" '(harpoon-go-to-4 :wk "4")
  "h 5" '(harpoon-go-to-5 :wk "5")
  "h 6" '(harpoon-go-to-6 :wk "6")
  "h 7" '(harpoon-go-to-7 :wk "7")
  "h 8" '(harpoon-go-to-8 :wk "8")
  "h 9" '(harpoon-go-to-9 :wk "9"))
```

## Configuration

Enable project-local mode (default is `t`):

```elisp
(setq harpoon-project-scope-enabled t)
```

## License

Unlicense

