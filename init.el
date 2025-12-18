;;; init.el --- Main Emacs Configuration File -*- lexical-binding: t -*-
;;
;; Author: nomike
;; Description: Personal Emacs configuration with support for multiple languages,
;;              LSP, org-mode, and various development tools
;;
;;; Commentary:
;; This configuration sets up Emacs for software development with:
;; - Language support (Rust, Python, C/C++, JavaScript, etc.)
;; - LSP integration for code intelligence
;; - Git integration via Magit
;; - Custom UI tweaks (tab-line, treemacs, themes)
;; - PDF viewing and note-taking capabilities
;;
;;; Code:

                                        ;(customize-set-variable 'lsp-treemacs-theme "Iconless")

;; Load nerd-icons for file/folder icons in UI
(require 'nerd-icons)

;;; Tab Bar and Tab Line Configuration
;;
;; TODO: Fixme
;; Commented out as this breaks magit and others
;; Error message: *ERROR*: Symbol's value as variable is void: tab-bar-history-mode

;; ;; Disable tab-bar
;; (tab-bar-mode -1)
;; (keymap-set ctl-x-map "t" nil)
;; (setq tab-prefix-map nil)
;; (makunbound 'tab-prefix-map)
;; (unload-feature 'tab-bar)

;; Configure tab-line for buffer tabs within a window
;; (see https://amitp.blogspot.com/2020/06/emacs-prettier-tab-line.html)

;; Ensure tab-line is loaded before configuring faces
(require 'tab-line)

;; Customize tab-line appearance with custom colors and fonts
(set-face-attribute 'tab-line nil ;; Background behind all tabs
                    :background "gray40"
                    :foreground "gray60" :distant-foreground "gray50"
                    :family "Fira Sans Condensed" :height 1.0 :box nil)
(set-face-attribute 'tab-line-tab nil ;; Active tab in a non-selected window
                    :inherit 'tab-line
                    :foreground "gray70" :background "gray90" :box nil)
(set-face-attribute 'tab-line-tab-current nil ;; Active tab in the currently selected window
                    :background "#b34cb3" :foreground "white" :box nil)
(set-face-attribute 'tab-line-tab-inactive nil ;; Inactive/background tabs
                    :background "gray80" :foreground "black" :box nil)
(set-face-attribute 'tab-line-highlight nil ;; Tab appearance on mouseover
                    :background "white" :foreground 'unspecified)

;; Use powerline to create stylish wave-shaped tab separators
(require 'powerline)
(defvar my/tab-height 22) ;; Height of the tab line in pixels
(defvar my/tab-left (powerline-wave-right 'tab-line nil my/tab-height)) ;; Left wave separator
(defvar my/tab-right (powerline-wave-left nil 'tab-line my/tab-height)) ;; Right wave separator

;; Custom function to format tab names with powerline wave separators
(defun my/tab-line-tab-name-buffer (buffer &optional _buffers)
  "Format BUFFER name with powerline wave decorations."
  (powerline-render (list my/tab-left
                          (format " %s  " (buffer-name buffer))
                          my/tab-right)))

;; Apply custom tab name formatting and hide the new/close buttons
(setq tab-line-tab-name-function #'my/tab-line-tab-name-buffer)
(setq tab-line-new-button-show nil) ;; Don't show the "new tab" button
(setq tab-line-close-button-show nil) ;; Don't show "close" buttons on tabs


;;; Global Editor Settings

;; Enable smooth pixel-level scrolling (Emacs 29+)
(pixel-scroll-precision-mode 1)

;; Automatically reload files when they change on disk
(global-auto-revert-mode 1)

;;; disable byte compilation would be: (setq load-suffixes '(".el"))

;; Configure backup file handling to avoid cluttering the file system
(setq
 backup-by-copying t      ; Don't clobber symlinks; copy files instead
 backup-directory-alist
 '(("." . "~/backup/"))   ; Store all backup files in ~/backup/ directory
 delete-old-versions t    ; Automatically delete old backup versions
 kept-new-versions 6      ; Keep 6 newest versions
 kept-old-versions 2      ; Keep 2 oldest versions
 version-control t)       ; Use version numbers for backups

;; Indentation Configuration
;; Don't use tabs to indent (by default).
;; Note: Major modes and minor modes are allowed to locally change the indent-tabs-mode variable, and a lot of them do.
                                        ;(setq-default indent-tabs-mode nil)

;; Make TAB key attempt completion if indentation is correct
(setq tab-always-indent 'complete)
                                        ; <https://github.com/thread314/intuitive-tab-line-mode>
                                        ;(global-tab-line-mode 1)

;;; LSP and Treemacs Integration
;; Load LSP integration with treemacs (file explorer)
(require 'lsp-treemacs)

;;; Variable Pitch Font Mode Hooks
;; Enable variable-pitch (proportional) fonts for better readability in certain modes
(add-hook 'org-mode-hook 'variable-pitch-mode)       ;; Org documents look better with proportional fonts
(add-hook 'rustic-mode-hook 'variable-pitch-mode)    ;; Rust code
                                        ;  (add-hook 'rust-ts-mode-hook 'variable-pitch-mode)
(add-hook 'treemacs-mode-hook 'variable-pitch-mode)  ;; File explorer
(add-hook 'nxml-mode-hook 'variable-pitch-mode)      ;; XML files
(add-hook 'emacs-lisp-mode-hook 'variable-pitch-mode) ;; Emacs Lisp code
(add-hook 'js-mode-hook 'variable-pitch-mode)        ;; JavaScript
(add-hook 'css-mode-hook 'variable-pitch-mode)       ;; CSS stylesheets
(add-hook 'html-mode-hook 'variable-pitch-mode)      ;; HTML files
(add-hook 'mhtml-mode-hook 'variable-pitch-mode)     ;; Multi-mode HTML
                                        ; (add-hook 'python-mode-hook 'variable-pitch-mode)
                                        ;(dolist (mode '(scheme-mode-hook term-mode-hook))  ; org-mode-hook term-mode-hook eshell-mode-hook treemacs-mode-hook
                                        ;  (add-hook mode
                                        ;    (lambda ()
                                        ;      (display-line-numbers-mode 0))))

;;; UI Tweaks
;; Disable the graphical toolbar (use menu bar and key bindings instead)
(tool-bar-mode -1)

;; Enable prettify-symbols globally (e.g., display lambda as λ)
(global-prettify-symbols-mode 1)

                                        ; (use-package pyvenv
                                        ;   :ensure nil
                                        ;   :config
                                        ;   (pyvenv-mode nil))

;;; CUA Mode Configuration
;; CUA mode provides familiar C-x/C-c/C-v keybindings for cut/copy/paste

(cua-mode t) ; Enable CUA mode (don't forget wakib-keys compatibility)
(setq cua-auto-tabify-rectangles nil) ;; Don't convert spaces to tabs after rectangle operations
(transient-mark-mode 1) ;; Only show the region when it's actively highlighted
(setq cua-keep-region-after-copy t) ;; Keep region active after copying (standard Windows behavior)
(define-key global-map (kbd "C-y") #'undo-redo) ;; Bind C-y to redo

;;; Virtual Word Wrapping
;; Wrap lines at word boundaries instead of character boundaries
(setq-default word-wrap t)

;;; Package Management
;; Initialize the package system for installing and managing extensions
(require 'package)
(package-initialize)

;;; Language-Specific Package Configuration

;; Rust language support
(use-package rust-mode
  :custom
  (rust-format-on-save t)) ;; Automatically format Rust code on save

;; Projectile for project management (find files, grep, etc.)
(use-package projectile
  :config
  (projectile-mode +1)) ;; Enable projectile globally

;; Python virtual environment support
(use-package pyvenv
  :ensure nil
  :config
  (pyvenv-mode nil)) ;; Disabled by default

;;; Magit Configuration Notes
;; "git-commit-* unavailable" workaround

					;(require 'magit)
					;(kill-buffer "*scratch*")
					;(setq magit-status-buffer-switch-function 'switch-to-buffer)
					;(call-interactively 'magit-status)
					;(require 'magit-status)
					; FIXME: (magit-status)

;;; Git Integration and Version Control

					;(with-eval-after-load 'geiser-guile
					;  (add-to-list 'geiser-guile-load-path "~/src/guix"))

;; Display glyphless characters (e.g., control characters) with special indicators
;; (probably cargo-culted from somewhere)
(update-glyphless-char-display 'glyphless-char-display-control '((format-control . empty-box) (no-font . empty-box)))

;; Highlight glyphless characters with purple background for visibility
;; See https://emacs.stackexchange.com/questions/65108
(set-face-background 'glyphless-char "purple")

;; Load built-in version control support
(require 'vc)

;; Enable diff-hl mode to show git diff indicators in the fringe
(global-diff-hl-mode 1)
;; Integrate diff-hl with magit for automatic updates
(add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

                                        ; '(cua-mode t)

;;; Custom Variables
;; This section is automatically managed by Emacs' customize interface
;; Manual edits should be done carefully to avoid breaking the structure
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-command "lualatex -shell-escape")
 '(LaTeX-electric-left-right-brace t)
 '(TeX-engine 'luatex)
 '(back-button-no-wrap t)
 '(buffer-env-safe-files
   '(("/home/nomike/coding/guix/manifest.scm"
      . "0b387290e9851813debd81b6e3aa5099f0f17fad1fade821ca1f0928262e56c4")
     ("/home/dannym/src/latex-ex/manifest.scm"
      . "5200b8ce405410acc7ad0e4baf5bfaa85b0160bff5815265a305bdc9a7fb70ed")))
 '(custom-enabled-themes '(modus-vivendi-tinted))
 '(custom-safe-themes
   '("6bf350570e023cd6e5b4337a6571c0325cec3f575963ac7de6832803df4d210a"
     "937401a2e532f2c8c881b6b3f20d9d4b6b9405bccf72ea6289c9d3f4507eb1ab"
     "a75aff58f0d5bbf230e5d1a02169ac2fbf45c930f816f3a21563304d5140d245"
     "7b602fe4a324dc18877dde647eb6f2ff9352566ce16d0b888bfcb870d0abfd70"
     "d41229b2ff1e9929d0ea3b4fde9ed4c1e0775993df9d998a3cdf37f2358d386b"
     "712dda0818312c175a60d94ba676b404fc815f8c7e6c080c9b4061596c60a1db"
     "fbf73690320aa26f8daffdd1210ef234ed1b0c59f3d001f342b9c0bbf49f531c"
     "faf642d1511fb0cb9b8634b2070a097656bdb5d88522657370eeeb11baea4a1c"
     "2e7dc2838b7941ab9cabaa3b6793286e5134f583c04bde2fba2f4e20f2617cf7"
     "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26"
     default))
 '(dtrt-indent-global-mode t)
 '(elfeed-feeds
   '("https://the-dam.org/rss.xml"
     ("http://planet.emacslife.com/atom.xml" emacs)
     "https://lwn.net/headlines/rss"
     "https://subscribe.fivefilters.org/?url=http%3A%2F%2Fftr.fivefilters.net%2Fmakefulltextfeed.php%3Furl%3Dhttps%253A%252F%252Fhnrss.org%252Ffrontpage%26max%3D3%26links%3Dpreserve"
     "https://subscribe.fivefilters.org/?url=http%3A%2F%2Fftr.fivefilters.net%2Fmakefulltextfeed.php%3Furl%3Dhttps%253A%252F%252Fwww.nature.com%252Fnmat%252Fcurrent_issue%252Frss%252F%26max%3D3%26links%3Dpreserve"
     "https://subscribe.fivefilters.org/?url=http%3A%2F%2Fftr.fivefilters.net%2Fmakefulltextfeed.php%3Furl%3Dhttps%253A%252F%252Fwww.nature.com%252Fnphys%252Fcurrent_issue%252Frss%252F%26max%3D3%26links%3Dpreserve"
     "https://semianalysis.substack.com/feed"
     "https://slow-journalism.com/blog/feed"
     "http://ftr.fivefilters.net/makefulltextfeed.php?url=https%3A%2F%2Ffeeds.arstechnica.com%2Farstechnica%2Ffeatures&max=3"))
 '(format-all-debug nil)
 '(format-all-show-errors 'errors)
 '(frame-background-mode 'light)
 '(grep-command "rg -nS --no-heading ")
 '(ignored-local-variable-values
   '((eval with-eval-after-load 'git-commit
           (add-to-list 'git-commit-trailers "Change-Id"))
     (eval progn (require 'lisp-mode)
           (defun emacs27-lisp-fill-paragraph (&optional justify)
             (interactive "P")
             (or (fill-comment-paragraph justify)
                 (let
                     ((paragraph-start
                       (concat paragraph-start
                               "\\|\\s-*\\([(;\"]\\|\\s-:\\|`(\\|#'(\\)"))
                      (paragraph-separate
                       (concat paragraph-separate
                               "\\|\\s-*\".*[,\\.]$"))
                      (fill-column
                       (if
                           (and
                            (integerp emacs-lisp-docstring-fill-column)
                            (derived-mode-p 'emacs-lisp-mode))
                           emacs-lisp-docstring-fill-column
                         fill-column)))
                   (fill-paragraph justify))
                 t))
           (setq-local fill-paragraph-function
                       #'emacs27-lisp-fill-paragraph))
     (geiser-repl-per-project-p . t)
     (eval with-eval-after-load 'yasnippet
           (let
               ((guix-yasnippets
                 (expand-file-name "etc/snippets/yas"
                                   (locate-dominating-file
                                    default-directory ".dir-locals.el"))))
             (unless (member guix-yasnippets yas-snippet-dirs)
               (add-to-list 'yas-snippet-dirs guix-yasnippets)
               (yas-reload-all))))
     (eval with-eval-after-load 'tempel
           (if (stringp tempel-path)
               (setq tempel-path (list tempel-path)))
           (let
               ((guix-tempel-snippets
                 (concat
                  (expand-file-name "etc/snippets/tempel"
                                    (locate-dominating-file
                                     default-directory
                                     ".dir-locals.el"))
                  "/*.eld")))
             (unless (member guix-tempel-snippets tempel-path)
               (add-to-list 'tempel-path guix-tempel-snippets))))
     (eval setq-local guix-directory
           (locate-dominating-file default-directory ".dir-locals.el"))
     (eval add-to-list 'completion-ignored-extensions ".go")
     (eval modify-syntax-entry 43 "'")
     (eval modify-syntax-entry 36 "'")
     (eval modify-syntax-entry 126 "'")
     (geiser-guile-binary "guix" "repl") (geiser-insert-actual-lambda)))
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(kiwix-default-browser-function 'eww-browse-url t)
 '(kiwix-server-type 'kiwix-serve-local)
 '(kiwix-zim-dir "~/.local/zim")
 '(large-file-warning-threshold 100000000)
 '(line-move-visual nil)
 '(lsp-rust-analyzer-rustc-source
   "/usr/local/rustup/toolchains/nightly-2024-08-03-x86_64-unknown-linux-musl/lib/rustlib/rustc-src/rust/compiler/rustc/Cargo.toml")
 '(lsp-treemacs-theme "Iconless")
 '(mediainfo-mode-file-regexp
   "\\.\\(?:3gp\\|a\\(?:iff\\|vi\\)\\|flac\\|jpg\\|jpeg\\|png\\|gif\\|m\\(?:4a\\|kv\\|ov\\|p[34g]\\)\\|o\\(?:gg\\|pus\\)\\|vob\\|w\\(?:av\\|ebm\\|mv\\)\\)\\'")
 '(mouse-autoselect-window nil)
 '(mu4e-compose-switch nil)
 '(org-export-exclude-tags '("confidential"))
 '(org-export-select-tags '("public"))
 '(org-format-latex-options
   '(:foreground default :background default :scale 0.5 :html-foreground
                 "Black" :html-background "Transparent" :html-scale
                 1.0 :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")))
 '(org-id-link-to-org-use-id 'use-existing)
 '(org-latex-packages-alist
   '(("" "braket" t nil) ("" "esint" t nil) ("" "units" t nil)
     ("" "unicode-math" t nil)))
 '(org-msg-convert-citation t)
 '(org-msg-greeting-fmt "Hello%s,")
 '(org-msg-posting-style nil)
 '(org-noter-always-create-frame nil)
 '(org-noter-auto-save-last-location t)
 '(org-noter-notes-search-path '("~/doc/org-roam"))
 '(org-preview-latex-default-process 'dvisvgm)
 '(org-replace-disputed-keys t)
 '(org-startup-folded 'content)
 '(org-startup-with-inline-images t)
 '(org-sticky-header-always-show-header t)
 '(org-sticky-header-full-path 'reversed)
 '(org-support-shift-select t)
 '(package-selected-packages nil)
 '(safe-local-variable-values
   '((eval with-eval-after-load 'git-commit
           (add-to-list 'git-commit-trailers "Change-Id"))))
 '(smtpmail-smtp-server "w0062d1b.kasserver.com" t)
 '(smtpmail-smtp-service 25 t)
 '(spacious-padding-subtle-mode-line t)
 '(spacious-padding-widths
   '(:internal-border-width 0 :header-line-width 4 :mode-line-width 6
                            :tab-width 5 :right-divider-width 10
                            :scroll-bar-width 8 :fringe-width 12))
 '(tab-line-close-tab-function 'kill-buffer)
 '(tool-bar-style 'image)
 '(vertico-preselect 'prompt)
 '(xref-search-program 'ripgrep))
;;; Custom Face Configuration
;; Font and appearance settings managed by Emacs customize
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Noto Sans Mono" :foundry "GOOG" :slant normal :weight regular :height 110 :width normal))))
 '(lsp-ui-sideline-global ((t (:family "Dijkstra Italic" :italic t :weight regular :height 0.8))))
 '(tab-line ((t (:height 0.9 :foreground "black" :background "grey85" :inherit variable-pitch)))))

;;; Font and UI Adjustments
;; Set default font size (height in 1/10pt, so 110 = 11pt)
(set-face-attribute 'default nil :height 110)

;; Adjust toolbar button spacing (horizontal . vertical)
(setq tool-bar-button-margin (cons 7 1))

;;; Treemacs Configuration
;; Make single-click expand/collapse folders in treemacs
(with-eval-after-load 'treemacs
  (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))

					;(treemacs-git-mode 'simple)

;;; Tree-sitter Configuration
;; Tree-sitter provides fast, incremental parsing for syntax highlighting and navigation
;; `M-x combobulate' (or `C-c o o') to start using Combobulate
(use-package treesit
  :preface
  ;; Tree-sitter enabled major modes are distinct from their ordinary counterparts.
  ;; You can remap major modes with `major-mode-remap-alist'.
  ;; Note: This does *not* extend to hooks! Make sure you migrate them also.
					; See also https://github.com/renzmann/treesit-auto/blob/main/treesit-auto.el
  ;; Map traditional major modes to their tree-sitter equivalents
  (dolist (mapping '((sh-mode . bash-ts-mode)
                                        ;(csharp-mode . csharp-ts-mode) ; doesn't work
                     (c-mode . c-ts-mode)
                     (clojure-mode . clojure-ts-mode)
                     (css-mode . css-ts-mode)
                     (go-mode . go-ts-mode) ; doesn't work
                     (go-mod-mode . go-mod-ts-mode) ; doesn't work
					;((mhtml-mode sgml-mode) . html-ts-mode) ; isn't found
                                        ;(mhtml-mode . html-ts-mode) ; isn't found
                     (java-mode . java-ts-mode)
                     (javascript-mode . js-ts-mode)
                     (js-json-mode . json-ts-mode)
                                        ; no redirect--so I can use C-M-x. (python-mode . python-ts-mode)
                                        ;(rust-mode . rust-ts-mode)
                     (typescript-mode . tsx-ts-mode) ; or typescript-ts-mode
					;(js-mode . js-ts-mode)
                     (yaml-mode . yaml-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))

  :config
  ;; Add Guix profile path for tree-sitter grammars
  (setq treesit-extra-load-path (list "~/.guix-home/profile/lib/tree-sitter/"))
  ;; Prompt before auto-installing missing grammars
  (setq treesit-auto-install 'prompt)
                                        ;					  (require 'tree-sitter-langs)
                                        ;					  (global-tree-sitter-mode)
                                        ;					  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)


					; no (mp-setup-install-grammars)
  ;; Do not forget to customize Combobulate to your liking:
  ;;
  ;;  M-x customize-group RET combobulate RET
  ;;
                                        ; (use-package combobulate
                                        ;   ;; Optional, but recommended.
                                        ;   ;;
                                        ;   ;; You can manually enable Combobulate with `M-x
                                        ;   ;; combobulate-mode'.
                                        ;   :commands combobulate-mode ; XXX
                                        ;   :hook ( ;(python-ts-mode . combobulate-mode)
                                        ;          (js-ts-mode . combobulate-mode)
                                        ;          (css-ts-mode . combobulate-mode)
                                        ; 				;(html-ts-mode . combobulate-mode)
                                        ;          (yaml-ts-mode . combobulate-mode)
                                        ;          (typescript-ts-mode . combobulate-mode)
                                        ;          (tsx-ts-mode . combobulate-mode)
                                        ;          (rust . combobulate-mode))
                                        ;   ;; Amend this to the directory where you keep Combobulate's source
                                        ;   ;; code.
                                        ;   :load-path ("~/.emacs.d/combobulate"))
  )

                                        ; (add-hook 'scheme-mode-hook
                                        ;           (lambda ()
                                        ;             "Prettify Guile"
                                        ;             (push '("lambda*" . "λ*") prettify-symbols-alist)
                                        ;             (push '("lambda" . "λ") prettify-symbols-alist)
                                        ;             ))

                                        ; (add-hook 'python-mode-hook
                                        ;           (lambda ()
                                        ;             "Prettify Python"
                                        ;             (push '("in" . "∈") prettify-symbols-alist)
                                        ;             (push '("True" . "⊨") prettify-symbols-alist)
                                        ;             (push '("False" . "⊭") prettify-symbols-alist)
                                        ;             (push '("is" . "≡") prettify-symbols-alist)
                                        ;             (push '("is not" . "≢") prettify-symbols-alist)
                                        ;             (push '("__add__" . "+") prettify-symbols-alist)
                                        ;             (push '("__sub__" . "-") prettify-symbols-alist)
                                        ;             (push '("__mul__" . "*") prettify-symbols-alist)
                                        ;             (push '("__mod__" . "%") prettify-symbols-alist)
                                        ;             (push '("__truediv__" . "/") prettify-symbols-alist)
                                        ;             (push '("__floordiv__" . "//") prettify-symbols-alist)
                                        ;             (push '("__gt__" . ">") prettify-symbols-alist)
                                        ;             (push '("__ge__" . ">=") prettify-symbols-alist)
                                        ;             (push '("__lt__" . "<") prettify-symbols-alist)
                                        ;             (push '("__le__" . "<=") prettify-symbols-alist)
                                        ;             (push '("__eq__" . "==") prettify-symbols-alist)
                                        ;             (push '("__ne__" . "!=") prettify-symbols-alist)
                                        ;             (push '("issubset" . "⊆") prettify-symbols-alist)
                                        ;             (push '("issuperset" . "⊇") prettify-symbols-alist)
                                        ; 					; U+2264 less than or equal ≤
                                        ; 					; U+2265 greater than or equal ≥
                                        ; 					; U+2216 set minus ∖
                                        ; 					; U+2229 intersection ∩
                                        ; 					; U+222A union ∪
                                        ; 					; TODO __or__ __pos__ __pow__ __r*__ __trunc__ __lshift__
                                        ; 					; TODO __xor__ __and__ __or__
                                        ; 					; TOOD __neg__
                                        ;             )
                                        ;             )

					; rust-format-buffer C-c C-f
					;(setq rust-format-on-save t)

					; TODO: html-mode-hook which un-awfuls <mi> etc
                                        ; (add-hook 'rust-mode-hook
                                        ;           (lambda ()
                                        ;             "Prettify Rust"
                                        ;             (push '("add" . "+") prettify-symbols-alist)
                                        ;             (push '("sub" . "-") prettify-symbols-alist)
                                        ;             (push '("mul" . "*") prettify-symbols-alist)
                                        ;             (push '("div" . "/") prettify-symbols-alist)
                                        ;             (push '("not" . "!") prettify-symbols-alist)
                                        ;             (push '("gt" . ">") prettify-symbols-alist)
                                        ;             (push '("ge" . ">=") prettify-symbols-alist)
                                        ;             (push '("lt" . "<") prettify-symbols-alist)
                                        ;             (push '("le" . "<=") prettify-symbols-alist)
                                        ;             (push '("eq" . "==") prettify-symbols-alist)
                                        ;             (push '("ne" . "!=") prettify-symbols-alist)
                                        ; 					;(prettify-symbols-mode t)
                                        ;             ))

					;C-c C-c C-u rust-compile
					;C-c C-c C-k rust-check
					;C-c C-c C-t rust-test
					;C-c C-c C-r rust-run
					;rust-run-clippy runs Clippy, a linter. By default, this is bound to C-c C-c C-l.
					; rust-dbg-wrap-or-unwrap C-c C-d
					; rust-toggle-mutability

                                        ;(require 'gud)
(setq left-fringe-width 160)
(set-fringe-style (quote (20 . 12))) ; left right; 12 . 8

;;; Eglot Configuration
;; Eglot is the built-in LSP client (part of Emacs 29+)
(require 'eglot)
;; Configure rust-analyzer for Rust files
(add-to-list 'eglot-server-programs
             `(rust-mode "rust-analyzer"))

;;; Note: rustic-mode extends rust-mode with LSP and flycheck integration

;;; File Type Associations
;; Configure which major mode to use for different file extensions

                                        ;(use-package csharp-mode
                                        ;  :ensure t
                                        ;  :config
;; C# files
(add-to-list 'auto-mode-alist '("\\.cs\\'" . csharp-tree-sitter-mode))

;; Web development file types
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))      ;; PHP templates
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))  ;; PHP templates
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))    ;; ASP/JSP files
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))    ;; ASP.NET files
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))        ;; Ruby ERB templates
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))   ;; Mustache templates
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))     ;; Django templates
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))      ;; HTML files
                                        ;(add-to-list 'auto-mode-alist '("\\.vue\\'" . web-mode))  ; moved to custom.el

;; Programming language file extensions
(add-to-list 'auto-mode-alist '("\\.jl" . julia-snail-mode))    ;; Julia
(add-to-list 'auto-mode-alist '("\\.rs" . rustic-mode))         ;; Rust
                                        ; automatic (add-to-list 'auto-mode-alist '("\\.R" . ess-mode))
(add-to-list 'auto-mode-alist '("\\.cs" . csharp-mode))         ;; C#
(add-to-list 'auto-mode-alist '("\\.js" . js2-mode))            ;; JavaScript
                                        ;(add-to-list 'auto-mode-alist '("\\.ts" . typescript-mode)) ; or combobulate-typescript-mode
                                        ;(add-to-list 'auto-mode-alist '("\\.rs" . rust-ts-mode))

                                        ;(add-to-list 'frames-only-mode-kill-frame-when-buffer-killed-buffer-list '(regexp . "\\*.*\\.po\\*"))
                                        ;(add-to-list 'frames-only-mode-kill-frame-when-buffer-killed-buffer-list "*Scratch*")

;; Document viewer modes
(add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-view-mode))   ;; PDF files
(add-to-list 'auto-mode-alist '("\\.PDF\\'" . pdf-view-mode))   ;; PDF (uppercase)
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))       ;; EPUB e-books

;; C/C++ with tree-sitter
(add-to-list 'auto-mode-alist '("\\.c\\'" . c-ts-mode))         ;; C files
(add-to-list 'auto-mode-alist '("\\.cpp\\'" . c++-ts-mode))     ;; C++ files
(add-to-list 'auto-mode-alist '("\\.cc\\'" . c++-ts-mode))      ;; C++ files
(add-to-list 'auto-mode-alist '("\\.ixx\\'" . c++-ts-mode))     ;; C++ module interface files

                                        ; (require 'dap-python)
                                        ;(elpy-enable)

;;; LSP Mode Configuration
;; LSP (Language Server Protocol) provides code intelligence features like
;; completion, go-to-definition, error checking, etc.
(use-package lsp-mode
  :ensure nil
  :commands lsp
  :custom
  ;; Use clippy (Rust linter) instead of cargo check on save
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  ;; Show all available information in eldoc
  (lsp-eldoc-render-all t)
  ;; Delay before updating LSP information (in seconds)
  (lsp-idle-delay 0.6)
  ;; Enable inlay hints (type annotations, parameter names, etc.)
  (lsp-inlay-hint-enable t)
  ;; Rust-specific LSP settings
  ;; See https://emacs-lsp.github.io/lsp-mode/page/lsp-rust-analyzer/
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t) ;; Show type hints for method chains
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t) ;; Show closure return types
  (lsp-rust-analyzer-display-parameter-hints nil) ;; Don't show parameter name hints
  (lsp-rust-analyzer-display-reborrow-hints nil) ;; Don't show reborrow hints
  (lsp-enable-suggest-server-download nil) ;; Don't suggest downloading servers
  :config
  ;; Enable which-key integration to show available commands
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  ;; Enable LSP UI mode for additional visual features
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))

                                        ; <https://github.com/emacs-lsp/lsp-mode/issues/2583>
                                        ;(use-package lsp-mode
                                        ;  :hook (python-mode . lsp-deferred)
                                        ;  :commands (lsp lsp-deferred))

;;; LSP UI Configuration
;; LSP-UI provides visual enhancements for lsp-mode
(use-package lsp-ui
  :ensure nil
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)         ;; Always show peek window
  (lsp-ui-sideline-show-hover t)      ;; Show hover info in sideline
  (lsp-ui-doc-enable t)               ;; Enable documentation popup
  (lsp-ui-doc-show-with-mouse t))     ;; Show documentation on mouse hover

;;; Company Mode (Completion)
;; Company provides auto-completion popups
(use-package company
  :ensure nil
  :custom
  (company-idle-delay 0.5) ;; Delay before showing completion popup (seconds)
  ;; (company-begin-commands nil) ;; Uncomment to disable automatic popup
  :config
  (progn
    ;; Enable company-mode globally after Emacs initialization
    (add-hook 'after-init-hook 'global-company-mode))
  :bind
  ;; Keybindings for navigating completion candidates
  (:map company-active-map
	("C-n". company-select-next)     ;; Next candidate
	("C-p". company-select-previous) ;; Previous candidate
	("M-<". company-select-first)    ;; First candidate
	("M->". company-select-last)))   ;; Last candidate

;;; YASnippet (Code Snippets)
;; YASnippet provides template/snippet expansion
(use-package yasnippet
  :ensure
  :config
  (yas-reload-all) ;; Load all snippet definitions
  ;; Enable yasnippet in programming modes
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  ;; Enable yasnippet in text editing modes
  (add-hook 'text-mode-hook 'yas-minor-mode))

;;; Flycheck (Syntax Checking)
;; Flycheck provides on-the-fly syntax checking
(use-package flycheck :ensure)

                                        ;(use-package flycheck
                                        ;  :hook (prog-mode . flycheck-mode))

                                        ;(use-package company
                                        ;  :hook (prog-mode . company-mode)
                                        ;  :config
                                        ;   (global-company-mode))

                                        ;(use-package lsp-mode
                                        ;  :commands lsp
                                        ;  :custom
                                        ;  (lsp-rust-analyzer-cargo-watch-command "clippy"))

;;; DAP Mode (Debug Adapter Protocol)
;; DAP provides debugging support for multiple languages
(require 'lsp-mode)
					;(with-eval-after-load 'lsp-rust
					;    (require 'dap-cpptools))
                                        ; (require 'dap-java) ; Requires eclipse jdt server--see lsp-install-server

;; Python debugging support
(require 'dap-python)
;; Configure debugpy as the Python debugger
;; https://github.com/emacs-lsp/dap-mode/issues/306
(setq dap-python-debugger 'debugpy)

;; DAP mode general configuration
(with-eval-after-load 'dap-mode
  ;; Show variable values on hover during debugging
  (dap-tooltip-mode 1)
  ;; Enable Emacs tooltips
  (tooltip-mode 1)
  ;; Show debugging controls UI
  (dap-ui-controls-mode 1)

  ;;    ;; Make sure that terminal programs open a term for I/O in an Emacs buffer
  ;;    (setq dap-default-terminal-kind "integrated")
  ;;    (dap-auto-configure-mode +1)
  )

;;; SLIME Configuration (Common Lisp)
;; Entry points: M-x slime or M-x slime-connect
(require 'slime)
;; Enable SLIME extensions: fancy features, Quicklisp, and ASDF integration
(slime-setup '(slime-fancy slime-quicklisp slime-asdf))

;;; Performance Tuning
;; Garbage collection threshold (100 MB)
(setq gc-cons-threshold (* 100 1024 1024))
;; High GC threshold for gcmh (garbage collector magic hack) - 1 GB
(setq gcmh-high-cons-threshold (* 1024 1024 1024))
;; Delay factor for GC during idle time
(setq gcmh-idle-delay-factor 20)
;; Defer font-lock (syntax highlighting) slightly for better performance
(setq jit-lock-defer-time 0.05)
;; Increase data read from processes (important for LSP performance) - 1 MB
(setq read-process-output-max (* 1024 1024))
;; Enable native compilation for packages
(setq package-native-compile t)

                                        ;(with-eval-after-load 'rustic
                                        ;  ; https://github.com/brotzeit/rustic/issues/211
                                        ;  (setq lsp-rust-analyzer-macro-expansion-method 'lsp-rust-analyzer-macro-expansion-default)
                                        ;  )

;;; Theme Configuration

;; (setq solarized-termcolors 256)
;; Set terminal background mode to dark
(set-terminal-parameter nil 'background-mode 'dark)
                                        ;(require 'solarized-theme)
                                        ; wrong solarized :P
                                        ;(solarized-create-theme-file-with-palette 'light 'solarized-solarized-light
                                        ;  '("#002b36" "#fdf6e3"
                                        ;    "#b58900" "#cb4b16" "#dc322f" "#d33682" "#6c71c4" "#268bd2" "#2aa198" "#859900"))

                                        ;(load-theme 'solarized-solarized-light t)
;; Load the Modus Vivendi Tinted dark theme
(load-theme 'modus-vivendi-tinted)
					;(enable-theme)

;;; Treemacs and LSP Integration
;; To enable bidirectional synchronization of lsp workspace folders and treemacs projects.
;; FIXME disappeared (lsp-treemacs-sync-mode 1)

					;(require 'treemacs-magit)
;; Only show the current project in treemacs
(treemacs-display-current-project-exclusively)

;; Set treemacs sidebar width to 25 characters
(setq treemacs-width 25)

;;; PDF Tools Configuration
;; PDF-tools provides better PDF viewing than doc-view-mode
                                        ; bad
                                        ; (setq doc-view-resolution 300)
(require 'pdf-tools)
                                        ;(use-package saveplace-pdf-view
                                        ;  :after pdf-tools
                                        ;  :config
                                        ;  (add-hook 'pdf-view-mode-hook 'pdf-view-restore-mode))

;; Load bookmark and saveplace for PDF position tracking
(require 'bookmark)
(require 'saveplace-pdf-view)
;; Remember cursor position in files (including PDFs)
(save-place-mode 1)

;; Replace doc-view-mode with pdf-view-mode
                                        ;(defalias 'doc-view-mode #'pdf-view-mode)

;;; Org Mode Extensions
;; org-mime allows composing emails in org-mode format
(use-package org-mime
  :ensure t)

;;; Completion UI Packages

;; Vertico: Vertical completion UI
(use-package vertico
  :ensure f
  :config
  (vertico-mode)) ;; Enable vertico completion interface

;; Marginalia: Add annotations to completion candidates
(use-package marginalia
  :ensure f
  :config
  (vertico-mode))

					;(use-package orderless
					;  :ensure f
					;  :config
					;  (setq completion-styles 'orderless))

;;; Version Control
;; Magit: Git interface for Emacs
(use-package magit
  :ensure f)

                                        ;(use-package forge
                                        ;  :ensure f
                                        ;  :after magit)

                                        ;(use-package doom-modeline
                                        ;  :ensure f
                                        ;  :init (doom-modeline-mode 1)
                                        ;  :custom ((doom-modeline-height 15)))

;;; Which-Key: Display keybinding help
;; Shows available keybindings in a popup
(use-package which-key
  :ensure f
  :init (which-key-mode)
  :diminish which-key-mode ;; Don't show in mode line
  :config
  (setq which-key-idle-delay 0.2)) ;; Show popup after 0.2 seconds

;;; Visual Enhancements
;; Rainbow-delimiters: Color-code nested parentheses
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;; Code Formatting
;; format-all provides automatic code formatting for multiple languages
(require 'format-all)

                                        ; not sure what that is (add-hook 'prog-mode-hook #'format-all-ensure-formatter)

;; Enable format-all for all programming modes
(add-hook 'prog-mode-hook #'format-all-ensure-formatter)
(add-hook 'prog-mode-hook #'format-all-mode)

                                        ;(add-hook 'rustic-mode-hook #'format-all-ensure-formatter)
                                        ;(add-hook 'rustic-mode-hook #'format-all-mode)

;;; MMM Mode Configuration (Multiple Major Modes)
;; MMM mode allows multiple major modes in a single buffer (e.g., HTML + JavaScript)
                                        ;(add-hook 'mmm-mode-hook
                                        ;          (lambda ()
                                        ;            (set-face-background 'mmm-default-submode-face "#fafafa")))

;; Don't use a different background for submode regions
(add-hook 'mmm-mode-hook
          (lambda ()
            (set-face-background 'mmm-default-submode-face nil)))

;;; Popper - Popup Buffer Management
;; Popper helps manage temporary/popup buffers (messages, help, compilation, etc.)
(use-package popper
  :ensure t ; or :straight t
  :bind (("C-`"   . popper-toggle)       ;; Toggle popup buffer
         ("M-`"   . popper-cycle)        ;; Cycle through popup buffers
         ("C-M-`" . popper-toggle-type)) ;; Toggle buffer between popup and normal
  :init
  ;; Define which buffers should be treated as popups
  (setq popper-reference-buffers
        '("\\*Messages\\*"              ;; Emacs messages
          "Output\\*$"                  ;; Shell output
          "\\*Async Shell Command\\*"   ;; Async shell commands
          help-mode                     ;; Help buffers
          compilation-mode))            ;; Compilation output
  (popper-mode +1)       ;; Enable popper globally
  (popper-echo-mode +1)) ;; Show popup names in echo area

;;; GPG/Encryption Configuration
;; Use Emacs' internal pinentry for GPG password prompts
(defvar epa-pinentry-mode)
(setq epa-pinentry-mode 'loopback)

;;; Eshell Configuration
;; Eshell is Emacs' built-in shell

(defun my/eshell-hook ()
  "Set up eshell hook for completions."
  (interactive)
  ;; Use basic completion styles for eshell
  (setq-local completion-styles '(basic partial-completion))
                                        ;(setq-local corfu-auto t)
                                        ;?! (corfu-mode) or company
                                        ;(setq-local completion-at-point-functions
                                        ;            (list (cape-capf-super
                                        ;                   #'pcomplete-completions-at-point
                                        ;                   #'cape-history)))
  ;; Bind M-r to search command history
  (define-key eshell-hist-mode-map (kbd "M-r") #'consult-history))

(use-package eshell
  :config
                                        ;(setq eshell-scroll-to-bottom-on-input t)
  (setq-local tab-always-indent 'complete)
  (setq eshell-history-size 100000)        ;; Large history size
  (setq eshell-save-history-on-exit t)     ;; Save history on exit
  (setq eshell-hist-ignoredups t)          ;; Don't save duplicate commands
  :hook
  (eshell-mode . my/eshell-hook))

;; Add shell buffers to popper (popup management)
;; Match eshell, shell, term and/or vterm buffers
;; Usually need both name and major mode for reliable matching
(setq popper-reference-buffers
      (append popper-reference-buffers
              '("^\\*eshell.*\\*$" eshell-mode ;; eshell as a popup
                "^\\*shell.*\\*$"  shell-mode  ;; shell as a popup
                "^\\*term.*\\*$"   term-mode   ;; term as a popup
                "^\\*vterm.*\\*$"  vterm-mode  ;; vterm as a popup
                )))

;;; LaTeX Configuration (AUCTeX)
;; AUCTeX provides enhanced LaTeX editing support
(load "auctex.el" nil t t)
                                        ;(load "preview-latex.el" nil t t)
(require 'auctex)

;;; Maxima Configuration (Computer Algebra System)
                                        ; (autoload 'maxima-mode "maxima" "Maxima mode" t)
                                        ; (autoload 'imaxima "imaxima" "Frontend for maxima with Image support" t)
                                        ; (autoload 'maxima "maxima" "Maxima interaction" t)
                                        ; (autoload 'imath-mode "imath" "Imath mode for math formula input" t)
                                        ; (setq imaxima-use-maxima-mode-flag t)
                                        ; (add-to-list 'auto-mode-alist '("\\.ma[cx]\\'" . maxima-mode))

;;; TRAMP Configuration (Remote File Editing)
;; Use /bin/sh for TRAMP to avoid shell compatibility issues
(with-eval-after-load 'tramp '(setenv "SHELL" "/bin/sh"))

;;; LSP Booster Integration
;; emacs-lsp-booster improves LSP performance by using bytecode instead of JSON
;; See: https://github.com/blahgeek/emacs-lsp-booster

(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of JSON for better performance."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))

;; Apply the bytecode parsing advice to json parsing functions
(advice-add (if (progn (require 'json)
                       (fboundp 'json-parse-buffer))
                'json-parse-buffer
              'json-read)
            :around
            #'lsp-booster--advice-json-parse)

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to LSP CMD if available."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)                             ;; Not checking if server is present
             (not (file-remote-p default-directory)) ;; Not editing remote files
             lsp-use-plists                          ;; Using plist representation
             (not (functionp 'json-rpc-connection))  ;; Using native json-rpc
             (executable-find "emacs-lsp-booster"))  ;; Booster is installed
        (progn
          (message "Using emacs-lsp-booster for %s!" orig-result)
          (cons "emacs-lsp-booster" orig-result))
      orig-result)))

;; Wrap LSP server commands with lsp-booster when available
(advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

                                        ;(use-package exec-path-from-shell
                                        ;  :ensure f
                                        ;  :config
                                        ;  (dolist (var '("LSP_USE_PLISTS"))
                                        ;	(add-to-list 'exec-path-from-shell-variables var))
                                        ;  (when (memq window-system '(mac ns x))
                                        ;	(exec-path-from-shell-initialize)))

;;; LaTeX/TeX Additional Settings
;; Use digestif as the LSP server for LaTeX
(setq lsp-tex-server 'digestif)
;; Automatically insert matching braces for subscripts/superscripts
(setq TeX-electric-sub-and-superscript t)
;; Enable folding mode in TeX documents
(setq TeX-fold-mode t)
                                        ;(add-hook LaTeX-mode-hook #'xenops-mode)

;;; Indentation Settings (Optional/Commented)
;; This ensures that pressing Enter will insert a new line and indent it.
                                        ;(global-set-key (kbd "RET") #'newline-and-indent)

;; Indentation based on the indentation of the previous non-blank line.
                                        ;(setq-default indent-line-function #'indent-relative-first-indent-point)

;; In modes such as `text-mode', calling `newline-and-indent' multiple times
;; removes the indentation. The following fixes the issue and ensures that text
;; is properly indented using `indent-relative' or
;; `indent-relative-first-indent-point'.
                                        ;(setq-default indent-line-ignored-functions '())

;;; Outline-Indent Package
;; The outline-indent.el package provides a minor mode that enables code folding
;; based on indentation levels for various indentation-based text files, such as
;; YAML, Python, and any other indented text files.
;;
;; In addition to code folding, outline-indent allows:
;; - Moving indented subtrees up and down
;; - Promoting and demoting sections to adjust indentation levels
;; - Customizing the ellipsis
;; - Inserting a new line with the same indentation level
(use-package outline-indent
  :ensure f
  :commands (outline-indent-minor-mode
             outline-indent-insert-heading)
  :hook ((yaml-mode . outline-indent-minor-mode)
         (yaml-ts-mode . outline-indent-minor-mode)
         (python-mode . outline-indent-minor-mode)
         (python-ts-mode . outline-indent-minor-mode))
  :custom
  (outline-indent-ellipsis " ▼ ")) ;; Custom ellipsis for folded sections

;; Enable outline-indent for Python files
(add-hook 'python-mode-hook #'outline-indent-minor-mode)
(add-hook 'python-ts-mode-hook #'outline-indent-minor-mode)

;; Enable outline-indent for YAML files
(add-hook 'yaml-mode-hook #'outline-indent-minor-mode)
(add-hook 'yaml-ts-mode-hook #'outline-indent-minor-mode)

;;; Auto-Detect Indentation (dtrt-indent)
;; The dtrt-indent package detects the original indentation offset used in source
;; code files and automatically adjusts Emacs settings accordingly, making it easier
;; to edit files created with different indentation styles.
                                        ;(use-package dtrt-indent
                                        ;  :ensure t
                                        ;  :commands (dtrt-indent-global-mode
                                        ;             dtrt-indent-mode
                                        ;             dtrt-indent-adapt
                                        ;             dtrt-indent-undo
                                        ;             dtrt-indent-diagnosis
                                        ;             dtrt-indent-highlight)
                                        ;  :config
                                        ;  (dtrt-indent-global-mode))

;;; Media Player Integration
;; MPV integration for video/audio playback from Emacs
(require 'mpv)
                                        ;(require 'howm) ; Note-taking package - not enabled currently

;;; Load Additional Configuration Files
;; Load custom.el which contains customize-generated settings
(load (locate-user-emacs-file "custom.el")
      :no-error-if-file-is-missing)
;; Additional configuration files (currently disabled)
;; (load (locate-user-emacs-file "email.el")
;;       :no-error-if-file-is-missing)
                                        ;(load (locate-user-emacs-file "git-protected-branches.el")
                                        ;      :no-error-if-file-is-missing)
;; (load (locate-user-emacs-file "git-commit-message.el")
;;       :no-error-if-file-is-missing)
;; (load (locate-user-emacs-file "autoresize.el")
;;       :no-error-if-file-is-missing)
;; (load (locate-user-emacs-file "wolfram.el")
;;       :no-error-if-file-is-missing)
;;                                         ;(load (locate-user-emacs-file "straico.el")
                                        ;       :no-error-if-file-is-missing)
;; (load (locate-user-emacs-file "mcphas.el")
;;       :no-error-if-file-is-missing)
;; (load (locate-user-emacs-file "ada.el")
;;       :no-error-if-file-is-missing)

;;; Final Setup

;; Refresh treemacs to ensure icons are displayed correctly
(treemacs-refresh)

;;; Python - Jedi Completion
;; Jedi provides Python auto-completion and static analysis
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t) ;; Trigger completion when typing a dot

;;; Environment Management
                                        ;(setq envrc-debug t)
;; Load buffer-env as late as possible for proper environment detection
                                        ;(envrc-global-mode)
;; Update buffer environment when local variables are loaded
(add-hook 'hack-local-variables-hook #'buffer-env-update)
;; Update environment in comint-based modes (shells, REPLs, etc.)
(add-hook 'comint-mode-hook #'buffer-env-update)

;;; Recent Files Tracking
;; Keep track of recently opened files
(recentf-mode 1)
(setq recentf-max-menu-items 25) ;; Show up to 25 recent files in menu

;;; Environment Variables from Shell
;; Import shell environment variables into Emacs
(require 'exec-path-from-shell)
;; List of environment variables to import
(dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO" "LANG" "LC_CTYPE" "NIX_SSL_CERT_FILE" "NIX_PATH" "GUIX_TEXMF" "GUIX_LOCPATH"))
  (add-to-list 'exec-path-from-shell-variables var))

;; Initialize exec-path-from-shell on GUI Emacs
(when (memq window-system '(mac ns x pgtk))
  (exec-path-from-shell-initialize))

;;; Claudemacs Configuration
;; Claudemacs provides integration with Claude AI
(add-to-list 'load-path (expand-file-name "claudemacs" user-emacs-directory))
(require 'claudemacs)

;; Keybindings for claudemacs (as suggested in README)
(global-set-key (kbd "C-d a") 'claudemacs-transient)   ;; Open claudemacs transient menu
(global-set-key (kbd "C-d C-a") 'claudemacs-toggle)    ;; Toggle claudemacs

;; Display buffer configuration for claudemacs
;; Show claudemacs buffers in a side window at the bottom
(add-to-list 'display-buffer-alist
             '("\\*claudemacs.*\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.4)))

;;; End of init.el
