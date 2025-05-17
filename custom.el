;; -*- lexical-binding: t -*-

(load-library "~/.emacs.d/secrets.el.gpg")

(spacious-padding-mode 1)

(require 'eshell)
(require 'em-unix)

;; You've GOT to be kidding me: "If initial-buffer-choice is non-nil, then if you specify any files on the command line, Emacs still visits them, but does not display them initially."
                                        ;(setq initial-buffer-choice
                                        ;      (lambda ()
                                        ;        (eshell t)))

;; The ~/.config/autostart/emacs.desktop (emacs --daemon) for some reason doesn't have the environment variables set in ~/.bash_profile .
;; I use gdm autologin.  That uses /run/current-system/profile/share/wayland-sessions/sway.desktop and that calls sway WITHOUT a shell.
;; Sway config has: exec --no-startup-id bash --login -c 'exec dex --autostart --environment i3'
;; Sway has .local/bin in PATH
;; Emacs --daemon has .local/bin in PATH
                                        ;(setenv "PATH" (concat (getenv "PATH") ":/sw/bin"))
                                        ;(setq exec-path (append exec-path '("/sw/bin")))

;; Custom "e" command in eshell
(defun eshell/e (&rest args)
  "Open one or more files in Emacs, similar to the `find-file' function.  ARGS will be evaluated by eshell."
  (eshell-eval-using-options
   "e" args
   '((?f "file" nil nil "file")
     (?h "help" nil nil "help"))
   (if (and (not args) (not eshell-current-argument))
       (error "Usage: e FILE [FILE2 ...]")
     (dolist (file (or args (list eshell-current-argument)))
       (with-current-buffer (find-file-noselect file)
         (switch-to-buffer (current-buffer)))))))
(put 'eshell/e 'eshell-no-numeric-conversions t)

(defun eshell/nd (args)
  "Create a directory (and its parents) if they don't exist.
Warn if the directory already exists.  ARGS will be evaluated by eshell."
  (eshell-eval-using-options
   "nd" args
   '((?v "verbose" nil verbose-flag "verbose output")
     (?h "help" nil nil "show this usage information"))
   (let ((dir (car args)))
     (progn
       (if (file-exists-p dir)
           (message "Directory already exists: %s" dir)
         (progn
           (make-directory dir t)
           (if verbose-flag
               (message "Created directory: %s" dir))))
       (eshell/cd dir)))))

(put 'eshell/nd 'eshell-no-numeric-conversions t)

;;; Keybindings

(global-unset-key (kbd "<f10>"))

(global-set-key (kbd "<mouse-8>") 'back-button-global-backward)
(global-set-key (kbd "<mouse-9>") 'back-button-global-forward)
(global-set-key (kbd "M-<Left>") 'back-button-global-backward)
(global-set-key (kbd "M-<Right>") 'back-button-global-forward)

(with-eval-after-load 'nov
  (define-key nov-mode-map (kbd "<mouse-8>") #'nov-history-back)
  (define-key nov-mode-map (kbd "<mouse-9>") #'nov-history-forward)
  (define-key nov-mode-map (kbd "M-<Left>") #'nov-history-back)
  (define-key nov-mode-map (kbd "M-<Right>") #'nov-history-forward))

(global-set-key (kbd "C-a") 'mark-whole-buffer)
(global-set-key (kbd "<Search>") 'consult-line)
(with-eval-after-load 'pdf-tools
  (define-key pdf-view-mode-map (kbd "<Search>") #'pdf-occur)
  ;; Will probably not work again:
  (define-key pdf-view-mode-map (kbd "C-f") #'pdf-occur))

                                        ; pixel-scroll-interpolate-down
                                        ;(define-key isearch-mode-map (kbd "<next>") #'isearch-repeat-forward)
                                        ; pixel-scroll-interpolate-?
                                        ;(define-key isearch-mode-map (kbd "<prior>") #'isearch-repeat-backward))

(global-set-key (kbd "M-<Search>") #'consult-ripgrep)


                                        ;(global-set-key (kbd "<Launch1>") 'async-shell-command)
(global-set-key (kbd "<Launch1>") 'embark-act)


(global-set-key (kbd "C-s") 'save-buffer)
                                        ; TODO: restart
                                        ;(global-set-key (kbd "C-<f2>") ')

(global-set-key (kbd "<f3>") 'counsel-find-file)
(global-set-key (kbd "C-<f3>") 'find-file-at-point)
(global-set-key (kbd "M-<f3>") 'ff-get-other-file)

(defun define-debug-key (mode-map key gud-command &optional dap-command)
  "In MODE-MAP, bind KEY to GUD-COMMAND when GUD is active, or DAP-COMMAND when DAP is active.
KEY should be like (key \"<f8>\").
GUD-COMMAND and DAP-COMMAND should be quoted command symbols."
  (define-key mode-map key
              (lambda ()
                (interactive)
                (cond
                 ((bound-and-true-p gud-minor-mode)
                  (command-execute gud-command))
                 ((bound-and-true-p dap-tooltip-mode)
                  (and dap-command (command-execute dap-command)))
                 (t
                  (message "No debugger active"))))))

                                        ; TODO: <f12>: Compiler messages


(eval-after-load 'prog-mode
  '(progn
     (define-debug-key prog-mode-map (kbd "C-<f7>") #'gud-eval #'dap-eval)
     (define-debug-key prog-mode-map (kbd "C-<f3>") #'gud-where #'dap-ui-stackframe)
     (define-debug-key prog-mode-map (kbd "C-<f2>") #'gud-kill #'dap-disconnect)
     (define-debug-key prog-mode-map (kbd "C-<f8>") #'gud-break #'dap-breakpoint-toggle)
     (define-debug-key prog-mode-map (kbd "C-b") #'gud-break #'dap-breakpoint-toggle) ; Chromium
     (define-debug-key prog-mode-map (kbd "<f5>") #'gud-break #'dap-breakpoint-toggle)
     (define-debug-key prog-mode-map (kbd "<f11>") #'gud-step #'dap-step-in)
     (define-debug-key prog-mode-map (kbd "<f10>") #'gud-next #'dap-next)
     (define-debug-key prog-mode-map (kbd "C-<f11>") #'gud-stepi)
     (define-debug-key prog-mode-map (kbd "C-<f10>") #'gud-nexti)
                                        ;(define-debug-key prog-mode-map (kbd "s-<f11>") #'gud-finish #'dap-step-out)
     (define-debug-key prog-mode-map (kbd "<f8>") #'gud-cont #'dap-continue)
     (define-debug-key prog-mode-map (kbd "C-<f11>") #'gud-watch #'dap-ui-expressions-add)
                                        ;(define-debug-key prog-mode-map (kbd "<?>") #'gud-up)
                                        ;(define-debug-key prog-mode-map (kbd "<?>") #'gud-down)
                                        ;(define-debug-key prog-mode-map (kbd "<?>") #'gud-refresh)
                                        ;(define-debug-key prog-mode-map (kbd "<?>") #'gud-print)
                                        ;(define-debug-key prog-mode-map (kbd "<?>") #'gud-tbreak)
                                        ;(define-debug-key prog-mode-map (kbd "<?>") #'gud-kill)
     (define-debug-key prog-mode-map (kbd "C-<f4>") #'gud-jump)
     (define-debug-key prog-mode-map (kbd "<?>") #'gud-remove)
     (define-debug-key prog-mode-map (kbd "<f4>") #'gud-until) ; dap-debug-restart-frame
                                        ;(define-debug-key prog-mode-map (kbd "<?>") #'gud-goto-traceback)
                                        ;(define-debug-key prog-mode-map (kbd "<?>") #'gud-list-breakpoints)
                                        ;gud-sentinel gud-statement-end
                                        ;(define-debug-key prog-mode-map (kbd "<?>") #'gud-pp)

                                        ; TODO: Shift-F7 step to next source line!
                                        ;(global-set-key (kbd "<f7>") 'gud-step)
                                        ;(global-set-key (kbd "<f8>") 'gud-next)
                                        ; user! ; gud-remove ?
     ))

(eval-after-load 'dap-mode
  '(progn
     ;; Basic debugging
     ;; FIXME need to disable the menu opening then!
                                        ;(define-key dap-mode-map (kbd "C-c C-k") 'dap-disconnect)

     ;; Breakpoint related
                                        ;(define-key dap-mode-map (kbd "C-c C-b c") 'dap-breakpoint-condition)
                                        ;(define-key dap-mode-map (kbd "C-c C-b h") 'dap-breakpoint-hit-condition)
                                        ;(define-key dap-mode-map (kbd "C-c C-b l") 'dap-breakpoint-log-message)
                                        ;(define-key dap-mode-map (kbd "C-c C-b d") 'dap-breakpoint-delete)
                                        ;(define-key dap-mode-map (kbd "C-c C-b D") 'dap-breakpoint-delete-all)

     ;; Debug windows
                                        ;(define-key dap-mode-map (kbd "C-c C-r") 'dap-ui-repl)
                                        ;(define-key dap-mode-map (kbd "C-c C-l") 'dap-ui-locals)
                                        ;(define-key dap-mode-map (kbd "C-c C-b") 'dap-ui-breakpoints)
                                        ;(define-key dap-mode-map (kbd "C-c C-t") 'dap-ui-sessions)
                                        ;(define-key dap-mode-map (kbd "C-c C-v") 'dap-eval)
                                        ;(define-key dap-mode-map (kbd "C-c C-w") 'dap-ui-expressions)
                                        ;(define-key dap-mode-map (kbd "C-c C-i") 'dap-step-in)
                                        ;(define-key dap-mode-map (kbd "C-c C-u") 'dap-up-stack-frame)
                                        ;(define-key dap-mode-map (kbd "C-c C-d") 'dap-down-stack-frame)

     ;; Additional commands
                                        ;(define-key dap-mode-map (kbd "C-c C-p") 'dap-debug-restart-frame)
                                        ;(define-key dap-mode-map (kbd "C-c C-a") 'dap-ui-inspect)
                                        ;(define-key dap-mode-map (kbd "C-c C-m") 'dap-mouse-eval)
                                        ;(define-key dap-mode-map (kbd "C-c C-e e") 'dap-eval-thing-at-point)
                                        ;(define-key dap-mode-map (kbd "C-c C-e r") 'dap-eval-region)
                                        ;(define-key dap-mode-map (kbd "C-c C-h") 'dap-hydra)

     ;; Launch/terminate
                                        ;(define-key dap-mode-map (kbd "C-c C-x") 'dap-start-debugging)
                                        ;(define-key dap-mode-map (kbd "C-c C-q") 'dap-disconnect)
                                        ;(define-key dap-mode-map (kbd "C-c C-g") 'dap-debug-restart)
     ))

                                        ; paredit was older than combobulate
                                        ; next sibling; via combobulate
(global-set-key (kbd "C-M-<down>") 'forward-sexp)

                                        ;(eval-after-load 'emacs-lisp-mode
                                        ;  '(progn
;; overwrites down-mouse-1 that would do mouse-buffer-menu
(define-key emacs-lisp-mode-map (kbd "C-<down-mouse-1>") #'xref-find-definitions-at-mouse)
                                        ;))

;; FIXME also C-<f8> maybe
(global-set-key (kbd "<f5>") 'dap-breakpoint-toggle)

                                        ; TODO: C-<f5>: Add watch...
                                        ; TODO: M-<end>: go to next floating window
                                        ; TODO: Ctrl+R refactoring

                                        ; TODO: Alt+[ / Ctrl+Q+[  find matching bracket
                                        ; TODO: Alt+] / Ctrl+Q+]  find matching bracket
                                        ; TODO: Alt+Page Down  next tab
                                        ; TODO: Alt+Page Up  previous tab
                                        ; TODO: Alt+Up Arrow / Ctrl+Right Click  go to declaration
                                        ; TODO: Ctrl+/ comment toggle
                                        ; TODO: Ctrl+Spacebar code completion
                                        ; TODO: Ctrl+K+1 (or 2-9) set bookmark
                                        ; TODO: Ctrl+0 (or 1-9) / Ctrl+Q+0 (or 1-9) go to bookmark
                                        ; TODO: Shift+Ctrl+1 (or 2-9) remove bookmark
                                        ; TODO: Ctrl+Alt+Down Arrow go to next method!!!
                                        ; TODO: Ctrl+Alt+Mouse Scroll hop between methods!!!
                                        ; TODO: Ctrl+Alt+Up Arrow go to previous method
                                        ; TODO: Ctrl+Backspace delete word previous to cursor
                                        ; TODO: Ctrl+Home / Ctrl+Q+R  cursor to top of file
                                        ; TODO: Ctrl+F4   close current editor page
                                        ; TODO: Ctrl+J  code template completion
                                        ; TODO: Ctrl+K+N toupper block
                                        ; TODO: Ctrl+K+O tolower block
                                        ; TODO: Ctrl+O+U toggle case of block
                                        ; TODO: Ctrl+K+U / Shift+Ctrl+U / Shift+Tab  outdent
                                        ; TODO: Ctrl+K+W write block to file
                                        ; TODO: Ctrl+O+C turn on column blocking
                                        ; TODO: Ctrl+O+K turn off column blocking
                                        ; TODO: Shift+Ctrl+B  display buffer list
                                        ; TODO: Shift+Ctrl+Down Arrow jump between declaration and implementation section
                                        ; TODO: Shift+Ctrl+K+C collapse all classes
                                        ; [...]

                                        ; f5 to f9 reserved for users

                                        ; https://delphi.fandom.com/wiki/Default_IDE_Shortcut_Keys
                                        ; FIXME: also run under debugger
(global-set-key (kbd "<f9>") #'projectile-compile-project)
                                        ; FIXME: Alt+F9 recompile all, Shift-F9 same
(global-set-key (kbd "C-<f9>") #'projectile-run-project)
(global-set-key (kbd "C-S-<f9>") #'projectile-test-project)
(global-set-key (kbd "M-<f9>") #'compile) ; for mcphas
                                        ; TODO: shift-ctrl-f find in files
                                        ; TODO: ctrl-h search replace
                                        ; Ctrl+Alt+B breakpoint list
                                        ; Ctrl+Alt+S call stack
                                        ; Ctrl+Alt+W watches
                                        ; Ctrl+Alt+L local variables
                                        ; Ctrl+Alt+T thread status
                                        ; Ctrl+Alt+V event log
                                        ; Ctrl+Alt+M modules window
                                        ; Ctrl+Alt+C entire CPU pane
                                        ; Ctrl+Alt+D disassembly
                                        ; Ctrl+Alt+R registers
                                        ; Ctrl+Alt+K stack
                                        ; Ctrl+Alt+1 memory 1
                                        ; Ctrl+Alt+2 memory 2
                                        ; Ctrl+Alt+3 memory 3
                                        ; Ctrl+Alt+4 memory 4
                                        ; Ctrl+Alt+F fpu sse contents
                                        ; Shift+Ctrl+H help insight at point (info about symbol at cursor)
                                        ; F11 object inspector
                                        ; Alt+0 display list of open windows
                                        ; Shift+Ctrl+V declare variable... (popup)
                                        ; Shift+Ctrl+D declare field... (popup)
                                        ; Shift+Ctrl+M extract method
                                        ; Shift+Ctrl+L resource string
                                        ; Shift+Ctrl+X change params of method
                                        ; Shift+Ctrl+Alt+F9 deploy project
                                        ; Shift+Ctrl+F9 run without debugger

(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-S-s") 'save-buffer)

;; keys for moving to prev/next code section (Form Feed; ^L)
(global-set-key (kbd "<C-M-prior>") 'backward-page) ; Ctrl+Alt+PageUp
(global-set-key (kbd "<C-M-next>") 'forward-page)   ; Ctrl+Alt+PageDown

(keymap-set global-map "C-M-s" #'org-node-series-dispatch)

;; Those conflict with move to previous word, move to next word, respectively.
;; They have alternative bindings anyway--so kill these here.
                                        ;(eval-after-load "paredit"
                                        ;  '(progn
                                        ;     (define-key paredit-mode-map (kbd "C-<left>") 'paredit-backward) ; alternative: C-} ; new alternative: M-b
                                        ;     (define-key paredit-mode-map (kbd "C-<right>") 'paredit-forward) ; alternative: C-) ; new alternative: M-f
                                        ;     (define-key paredit-mode-map (kbd "C-<up>") 'paredit-backward-up)
                                        ;     (define-key paredit-mode-map (kbd "C-<down>") 'paredit-backward-down)))

;;; ======================

(require 'pulsar)
(setq pulsar-face 'pulsar-blue)
;; Pulse when minibuffer shows up
(add-hook 'minibuffer-setup-hook #'pulsar-pulse-line)

;; Improve contrast
(add-to-list 'default-frame-alist '(foreground-color . "#505050"))

(require 'treemacs-nerd-icons)
(treemacs-load-theme "nerd-icons")

(setq display-buffer-alist
      '(
        ("\\*messages.*"
         (display-buffer-in-side-window)
         (window-width . 0.25) ;; Side window takes up 1/4th of the screen
         (side . right)
         )
        ("^\\*Projectile.*"
         ((display-buffer-in-side-window)
          (window-height . 0.25)))
        ("^\\*scratch.*"
         (display-buffer-in-side-window)
         (window-width . 0.25) ;; Side window takes up 1/4th of the screen
         (side . right))
        ("\\*.*[Ss]hell.*\\*" ; especially "*Async Shell Command*"
         (display-buffer-in-side-window)
         (window-height . 0.20) ;; Side window takes up 1/4th of the screen
         (side . bottom)
         (reusable-frames . visible))
        ("\\*Warnings.*"
         (display-buffer-reuse-window display-buffer-in-side-window)
         (window-width . 0.25) ;; Side window takes up 1/4th of the screen
         (side . right)
         )
        ("\\*.*[Ss]hell.*\\*" ; especially "*Async Shell Command*"
         (display-buffer-same-window)
         (reusable-frames . visible))
        ))

                                        ; (require 'mh-e) ; mail

(add-to-list 'treesit-extra-load-path "/home/dannym/.guix-home/profile/lib/tree-sitter/")

(setq send-mail-function    'smtpmail-send-it
      smtpmail-smtp-server  "w0062d1b.kasserver.com"
      smtpmail-stream-type  'starttls
      smtpmail-smtp-service 587)

                                        ; argh
(setq python-shell-completion-native-disabled-interpreters '("python3" "pypy3"))

                                        ;(setq vc-handled-backends '("git"))


                                        ;(lsp-register-client
                                        ; (make-lsp-client :new-connection (lsp-tramp-connection "clangd")
                                        ;                  :major-modes '(c-mode c++-mode)
                                        ;                  :remote? t
                                        ;                  :server-id 'clangd-remote))

;; Consider setting this to a negative number
                                        ;(setq mouse-autoselect-window t)


(setq visible-bell t)

                                        ; (add-to-list 'load-path "~/.emacs.d/lisp/")
                                        ; (load "~/.emacs.d/lisp/unbreak.el")
                                        ; (load "modern-fringes.el")

                                        ; Vendored from https://raw.githubusercontent.com/Alexander-Miller/treemacs/master/src/extra/treemacs-projectile.el
(require 'treemacs-projectile)

(add-hook 'scheme-mode-hook 'guix-devel-mode)

                                        ;(straight-use-package
                                        ;  '(nano :type git :host github :repo "rougier/nano-emacs"))

                                        ;(setq nano-font-size 10)

                                        ;(add-to-list 'load-path "~/.emacs.d/nano-emacs/")
                                        ;(load "nano.el")

                                        ; Too new version requires svg-tag-mode which is dumb
                                        ;(add-to-list 'load-path "~/.emacs.d/notebook-mode/")
                                        ;(load "notebook.el")

                                        ;(setq org-ellipsis "▾")

                                        ; See https://magit.vc/manual/ghub/Storing-a-Token.html
(use-package auth-source
  :defer t
  :config
  (setq auth-sources
        (list (expand-file-name ".authinfo.gpg" user-emacs-directory))))

;; Assuming the Guix checkout is in ~/src/guix.
;; Yasnippet configuration
(with-eval-after-load 'yasnippet
  (add-to-list 'yas-snippet-dirs "~/src/guix/etc/snippets/yas"))
;; Tempel configuration
(with-eval-after-load 'tempel
  ;; Ensure tempel-path is a list -- it may also be a string.
  (unless (listp 'tempel-path)
    (setq tempel-path (list tempel-path)))
  (add-to-list 'tempel-path "~/src/guix/etc/snippets/tempel/*"))

;; Assuming the Guix checkout is in ~/src/guix.
                                        ; (load-file "~/src/guix/etc/copyright.el")

                                        ; super-g
(global-set-key (kbd "s-g") 'guix)

                                        ; Doesn't work.
                                        ;(add-hook 'shell-mode-hook 'guix-prettify-mode)
                                        ;(add-hook 'dired-mode-hook 'guix-prettify-mode)

;; Free version; see also https://github.com/WebFreak001/code-debug supports both gdb and lldb in case someone is interested.
                                        ; "gdb -i dap" is enough for DAP mode so no idea what all this is for here.
(add-to-list 'load-path "~/.emacs.d/dap-gdb/")
(load "dap-gdb.el")

(add-to-list 'load-path "~/.emacs.d/ssass-mode/")
(load "ssass-mode.el")

                                        ;(add-to-list 'load-path "~/src/dap-mode/")
;;(load "dap-mode.el")
                                        ;(require 'dap-cpptools)

(add-to-list 'load-path "~/.emacs.d/bar-cursor/")
;;(load "dap-mode.el")
(require 'bar-cursor)
(bar-cursor-mode 1)

                                        ; (add-to-list 'load-path "~/.emacs.d/elfeed-tube/")
                                        ; (require 'elfeed-tube)
                                        ; (require 'elfeed-tube-mpv)

                                        ; Scheme IDE

(setq geiser-mode-auto-p nil)
(require 'arei)

                                        ; Latex

(add-to-list 'load-path "~/.emacs.d/xenops/lisp/")
(require 'xenops)
(setq-default xenops-math-image-scale-factor 0.6)
                                        ; (setq-default xenops-reveal-on-entry t) ; unreveal in org mode is buggy
(require 'ob-python) ; optional
(add-hook 'LaTeX-mode-hook #'xenops-mode)
(add-hook 'org-mode-hook #'xenops-mode)

                                        ; (add-hook 'org-mode-hook #'xenops-mode) ; fucks up begin_src and end_src (lowercase) handling maybe

                                        ; Undefined
                                        ;(latex +cdlatex +latexmk +lsp)
                                        ;(latex +lsp)

(require 'wakib-keys)
(wakib-keys 1)
(define-key wakib-keys-overriding-map (kbd "C-f") #'consult-line) ; Note: someone overwrites this.

                                        ; Fix escape key
(wakib-define-keys wakib-keys-overriding-map `(("<escape>" . ,#'keyboard-escape-quit)))

                                        ; (load "~/.emacs.d/lisp/copilot.el")
(global-set-key (kbd "C-.") 'gptel-send)

                                        ; (require 'opascal)

                                        ; TODO: Python ∈
                                        ; (require 'python-django)

                                        ; requires markchars.el which is not in Guix
                                        ;(markchars-global-mode)
                                        ;(defface markchars-heavy
                                        ;  '((t :underline "magenta"))
                                        ;  "Heavy face for `markchars-mode' char marking."
                                        ;  :group 'markchars)

;; Must do this so the agenda knows where to look for my files
(setq org-agenda-files '("~/org-mode"))
                                        ;(setq org-agenda-deadline-lead-time 7) ;; Notify 7 days before deadlines
                                        ;(setq org-agenda-scheduled-lead-time 1) ;; Notify 1 day before scheduled items
                                        ;   <2021-07-14 Wed 14:40 -1d>  with lead time; https://github.com/orgzly/orgzly-android/issues/636

;; When a TODO is set to a done state, record a timestamp
(setq org-log-done 'time)

;; Follow the links
(setq org-return-follows-link  t)

;; Associate all org files with org mode
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; Make the indentation look nicer
(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook 'org-sticky-header-mode)


;; Shortcuts for storing links, viewing the agenda, and starting a capture
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)


;; Hide the markers so you just see bold text as BOLD-TEXT and not *BOLD-TEXT*
(setq org-hide-emphasis-markers t)

                                        ;(setq org-roam-node-display-template
                                        ;      (concat "${title:*} " (propertize "${tags}" 'face 'org-tag)))

;; Uhh.
                                        ;(setq org-roam-completion-everywhere t)

                                        ; TODO: (org-roam-node-list)
                                        ;(defun org-roam-update-recent-nodes ()
                                        ;  "Update the list of recent nodes in the org-roam recent.org file."
                                        ;  (interactive)
                                        ;  (with-temp-file "~/org-mode/recent.org"
                                        ;    (insert "#+title: Recent Nodes\n\n")
                                        ;    (dolist (node (org-roam-node-list))
                                        ;      (insert (format "- [[node:%s][%s]]\n"
                                        ;                      node
                                        ;                      (org-roam-node-title node))))))
                                        ;(run-with-timer 0 3600 'org-roam-update-recent-nodes)  ; Update every hour

                                        ;(defun org-roam-open-index ()
                                        ;  "Open the org-roam index file."
                                        ;  (interactive)
                                        ;  (find-file "~/org-mode/org-roam-index.org"))
                                        ;(global-set-key (kbd "C-c i") 'org-roam-open-index)

                                        ;(setq org-roam-index-file "~/org-mode/org-roam-index.org")

                                        ;(add-hook 'after-init-hook 'org-roam-open-index) ; Automatically open org-roam index when you open emacs (yeah, right--we'll see)

                                        ;(setq org-roam-node-search-function #'org-roam-node-find-by-tags)
                                        ;(defun org-roam-node-find-by-tags (&optional other-window initial-input)
                                        ;  "Find and open an Org-roam node by tags.
                                        ;INITIAL-INPUT can be used to pre-fill the prompt."
                                        ;  (interactive current-prefix-arg)
                                        ;  (let* ((initial-input (or initial-input ""))
                                        ;         (node (org-roam-node-read initial-input
                                        ;                                   (lambda (node)
                                        ;                                     (or (org-roam-node-file-title node)
                                        ;                                         (org-roam-node-title node)))
                                        ;                                   nil
                                        ;                                   nil
                                        ;                                   (lambda (n1 n2)
                                        ;                                     (> (org-roam-node-file-mtime n1)
                                        ;                                        (org-roam-node-file-mtime n2))))))
                                        ;    (if other-window
                                        ;        (org-roam-node-open node other-window)
                                        ;      (org-roam-node-open node))))
                                        ;
                                        ;(use-package org-roam-ql
                                        ;  :after (org-roam)
                                        ;  :bind ((:map org-roam-mode-map
                                        ;               ;; Have org-roam-ql's transient available in org-roam-mode buffers
                                        ;               ("v" . org-roam-ql-buffer-dispatch)
                                        ;               :map minibuffer-mode-map
                                        ;               ;; Be able to add titles in queries while in minibuffer.
                                        ;               ;; This is similar to `org-roam-node-insert', but adds
                                        ;               ;; only title as a string.
                                        ;               ("C-c n i" . org-roam-ql-insert-node-title))))

;; Wrap the lines in org mode so that things are easier to read ; FIXME how to make tables work correctly then?
                                        ;(add-hook 'org-mode-hook 'visual-line-mode)
(add-hook 'text-mode-hook #'visual-line-mode)
(with-current-buffer "*Messages*"
  (visual-line-mode))
                                        ;(with-current-buffer "*scratch*"
                                        ;  (visual-line-mode))

                                        ;(setq org-roam-v2-ack t)
                                        ;(use-package org-roam
                                        ;  :ensure f
                                        ;  :custom
                                        ;  (org-roam-directory "~/org-mode")
                                        ;  :bind (("C-c n l" . org-roam-buffer-toggle)
                                        ;         ("C-c n f" . org-roam-node-find)
                                        ;         ("C-c n i" . org-roam-node-insert))
                                        ;  :config
                                        ;  (org-roam-setup))
                                        ;(org-roam-db-autosync-mode)

;;; Make elfeed store-link store the link to the ORIGINAL article, not to the feed.

(org-link-set-parameters "elfeed"
                         :follow #'elfeed-link-open
                         :store #'elfeed-link-store-link
                         :export #'elfeed-link-export-link)

(defun elfeed-link-export-link (link desc format _protocol)
  "Export `org-mode' `elfeed' LINK with DESC for FORMAT."
  (if (string-match "\\([^#]+\\)#\\(.+\\)" link)
      (if-let* ((entry
                 (elfeed-db-get-entry
                  (cons (match-string 1 link)
                        (match-string 2 link))))
                (url
                 (elfeed-entry-link entry))
                (title
                 (elfeed-entry-title entry)))
          (pcase format
            ('html (format "<a href=\"%s\">%s</a>" url desc))
            ('md (format "[%s](%s)" desc url))
            ('latex (format "\\href{%s}{%s}" url desc))
            ('texinfo (format "@uref{%s,%s}" url desc))
            (_ (format "%s (%s)" desc url)))
        (format "%s (%s)" desc url))
    (format "%s (%s)" desc link)))

;;; Pandoc

(setq pandoc-data-dir "~/.emacs.d/etc/pandoc/")

(defun efe/export-to-docx ()
  "Output to docx using pandoc-mode"
  (interactive)
  (pandoc-mode)
  (execute-kbd-macro (kbd "C-c / O W d b b r"))
  (setq pandoc-mode nil))

(defun insert-html-blog-template ()
  "Insert HTML_HEAD lines at the first empty line and html code at the end of the buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((empty-line (progn (re-search-forward "^$" nil t) (point))))
      (goto-char empty-line)
      (insert "\n#+HTML_HEAD: <link rel=\"webmention\" href=\"https://webmention.io/ismailefe.org/webmention\" />\n")
      (insert "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"/templates/style.css\" />\n")
      (insert "#+HTML_HEAD: <link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"/favicon/apple-touch-icon.png\">\n")
      (insert "#+HTML_HEAD: <link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"/favicon/favicon-32x32.png\">\n")
      (insert "#+HTML_HEAD: <link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"/favicon/favicon-16x16.png\">\n")
      (insert "#+HTML_HEAD: <link rel=\"manifest\" href=\"/favicon/site.webmanifest\">\n")))
  (goto-char (point-max))
  (insert "\n\n")
  (insert "#+BEGIN_EXPORT html\n")
  (insert "<div class=\"bottom-header\">\n")
  (insert "  <a class=\"bottom-header-link\" href=\"/\">Home</a>\n")
  (insert "  <a href=\"mailto:ismailefetop@gmail.com\" class=\"bottom-header-link\">Mail Me</a>\n")
  (insert "  <a class=\"bottom-header-link\" href=\"/feed.xml\" target=\"_blank\">RSS</a>\n")
  (insert "  <a class=\"bottom-header-link\" href=\"https://github.com/Ektaynot/ismailefe_org\" target=\"_blank\">Source</a>\n")
  (insert "</div>\n")
  (insert "<div class=\"firechickenwebring\">\n")
  (insert "  <a href=\"https://firechicken.club/efe/prev\">←</a>\n")
  (insert "  <a href=\"https://firechicken.club\">🔥⁠🐓</a>\n")
  (insert "  <a href=\"https://firechicken.club/efe/next\">→</a>\n")
  (insert "</div>\n")
  (insert "#+END_EXPORT\n"))

                                        ; With these snippets added, all I have to do is run the 'org-pandoc-export-to-html5' function in Emacs (this function comes with ox-pandoc). This creates a html file with the same name as the original file.

(require 'request)
(require 'dom)
                                        ;(require 'simpleclip)

(defun google-search-first-result (query)
  "Search Google for QUERY and return the first search result."
  (interactive "sSearch Query: ")
  (let ((url (concat "https://www.google.com/search?q=" (url-hexify-string query)))
        (user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"))
    (request url
      :headers `(("User-Agent" . ,user-agent))
      :parser 'buffer-string
      :success (cl-function
                (lambda (&key data &allow-other-keys)
                  (let* ((dom (with-temp-buffer
                                (insert data)
                                (libxml-parse-html-region (point-min) (point-max))))
                         (first-result (car (dom-by-class dom "tF2Cxc"))))
                    (if first-result
                        (let ((link (dom-attr (car (dom-by-tag first-result 'a)) 'href)))
                          (when link
                            (message "First search result: %s" link)
                                        ;(simpleclip-set-contents link)
                            (kill-new link)
                            ))
                      (message "No results found."))))))))

(defun google-first-result-at-point ()
  "Get the first url from a Google search from the word at point."
  (interactive)
  (let ((word (thing-at-point 'word)))
    (if word
        (google-search-first-result word)
      (message "No word found at point."))))

                                        ; (setq scroll-preserve-screen-position nil)

                                        ;                                         ; Unbreak image scrolling

(add-to-list 'load-path "~/.emacs.d/iscroll/")
(require 'iscroll)
                                        ; Note: Only enable in text modes, not prog modes
                                        ;(iscroll-mode)

(add-hook 'elfeed-show-mode-hook 'iscroll-mode)

;;; Org mode

(setq org-todo-keywords
      '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i@/!)" "VERIFYING(v!)" "BLOCKED(b@)" "ON-HOLD (h)" "WAITING (w)" "|" "DONE(d!)" "OBE(o@!)" "WONT-DO(n@/!)" )))

(setq my-org-header (concat "#+DATE: %<%Y-%m-%d>
#+AUTHOR: " user-full-name "
#+FILETAGS: :internal:

%?"))

(defun transform-square-brackets-to-round-ones (string-to-transform)
  "Convert `[' into `(' and `]' into `)' of STRING-TO-TRANSFORM.  That's especially for arxiv."
  (concat (mapcar #'(lambda (c) (if (equal c ?\[) ?\( (if (equal c ?\]) ?\) c))) string-to-transform)))

(setq org-capture-templates
      `(("i" "Capture into ID node"
         plain (function org-node-capture-target)
         ,my-org-header
         :empty-lines-after 1)


        ("j" "Jump to ID node"
         plain (function org-node-capture-target)
         ,my-org-header
         :jump-to-captured t
         :immediate-finish t)

        ;; Sometimes handy after `org-node-insert-link' to
        ;; make a stub you plan to fill in later
        ("q" "Make quick stub ID node"
         plain (function org-node-capture-target)
         ,my-org-header
         :immediate-finish t)

        ("w" "Work Log Entry"
         entry (file+datetree "~/doc/org/work-log.org")
         "* %?"
         :empty-lines 0)
        ("n" "Note"
         entry (file+headline "~/org-mode/notes.org" "Random Notes")
         "** %?"
         :empty-lines 0)
        ("g" "General To-Do"
         entry (file+headline "~/org-mode/todos.org" "General Tasks")
         "* TODO [#B] %?\n:Created: %T\n "
         :empty-lines 0)
        ("c" "Code To-Do" ; execute this on the line of code you want to link it to
         entry (file+headline "~/org-mode/todos.org" "Code Related Tasks")
         "* TODO [#B] %?\n:Created: %T\n%i\n%a\nProposed Solution: "
         :empty-lines 0)
        ("m" "Meeting"
         entry (file+datetree "~/org-mode/meetings.org")
         "* %? :meeting:%^g \n:Created: %T\n** Attendees\n*** \n** Notes\n** Action Items\n*** TODO [#A] "
         :tree-type week
         :clock-in t
         :clock-resume t
         :empty-lines 0)

        ;; org-protocol by chrome org-capture extension.
        ("p" "Protocol" entry (file+headline ,(concat org-directory "notes.org") "Inbox") ; WTF?
         "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
        ;; org-protocol by chrome org-capture extension.
        ("L" "Protocol Link" entry (file+headline ,(concat org-directory "notes.org") "Inbox") ; WTF?
         "* %? [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\nCaptured On: %U")

        ;; org-protocol-html bookmarklet.
        ("w" "Web site" entry (file "") ; or (file+olp ,(concat org-directory "inbox.org" "Web"))
         "* %a :website:\n\n%U %?\n\n%:initial")

        ))

;; Tags
(setq org-tag-alist '(
                      ;; Ticket types (exclusive)
                      (:startgroup . nil)
                      ("@bug" . ?b)
                      ("@feature" . ?u)
                      ("@spike" . ?j)
                      (:endgroup . nil)

                      ("WAITING" . ?w)
                      ("HOLD" . ?h)
                      ("CANCELLED" . ?c)
                      ("FLAGGED" . ??)

                      ;; Ticket flags
                      ("@write_future_ticket" . ?w)
                      ("@emergency" . ?e)
                      ("@research" . ?r)

                      ;; Meeting types (exclusive)
                      (:startgroup . nil)
                      ("big_sprint_review" . ?i)
                      ("cents_sprint_retro" . ?n)
                      ("dsu" . ?d)
                      ("grooming" . ?g)
                      ("sprint_retro" . ?s)
                      (:endgroup . nil)

                      ;; Code TODOs tags
                      ("QA" . ?q)
                      ("backend" . ?k)
                      ("broken_code" . ?c)
                      ("frontend" . ?f)

                      ;; Special tags
                      ("CRITICAL" . ?x)
                      ("obstacle" . ?o)

                      ;; Meeting tags
                      ("HR" . ?h)
                      ("general" . ?l)
                      ("meeting" . ?m)
                      ("misc" . ?z)
                      ("planning" . ?p)

                      ;; Work Log Tags
                      ("accomplishment" . ?a)
                      ))

;; The ones without "t" are cleared..
(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("HOLD" ("WAITING") ("HOLD" . t))
              (done ("WAITING") ("HOLD"))
              ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
              ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
              ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

;; Tag colors
(setq org-tag-faces
      '(("planning" . (:foreground "mediumPurple1" :weight bold))
        ("backend" . (:foreground "royalblue1" :weight bold))
        ("frontend" . (:foreground "forest green" :weight bold))
        ("QA" . (:foreground "sienna" :weight bold))
        ("meeting" . (:foreground "yellow1" :weight bold))
        ("CRITICAL" . (:foreground "red1" :weight bold))))

;; Agenda View "d"
(defun air-org-skip-subtree-if-priority (priority)
  "Skip an agenda subtree if it has a priority of PRIORITY.

  PRIORITY may be one of the characters ?A, ?B, or ?C."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (pri-value (* 1000 (- org-lowest-priority priority)))
        (pri-current (org-get-priority (thing-at-point 'line t))))
    (if (= pri-value pri-current)
        subtree-end
      nil)))

(setq org-agenda-skip-deadline-if-done t)

(setq org-agenda-custom-commands
      '(
        ;; Daily Agenda & TODOs
        ("d" "Daily agenda and all TODOs"

         ;; Display items with priority A
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High-priority unfinished tasks:")))

          ;; View 7 days in the calendar view
          (agenda "" ((org-agenda-span 7)))

          ;; Display items with priority B (really it is view all items minus A & C)
          (alltodo ""
                   ((org-agenda-skip-function '(or (air-org-skip-subtree-if-priority ?A)
                                                   (air-org-skip-subtree-if-priority ?C)
                                                   (org-agenda-skip-if nil '(scheduled deadline))))
                    (org-agenda-overriding-header "ALL normal priority tasks:")))

          ;; Display items with pirority C
          (tags "PRIORITY=\"C\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Low-priority Unfinished tasks:")))
          )

         ;; Don't compress things (change to suite your tastes)
         ((org-agenda-compact-blocks nil)))

        ;; James's Super View
        ("j" "James's Super View"
         ((agenda "" ( (org-agenda-remove-tags t) (org-agenda-span 7)))
          (alltodo ""  (;; Remove tags to make the view cleaner
                        (org-agenda-remove-tags t)
                        (org-agenda-prefix-format "  %t  %s")
                        (org-agenda-overriding-header "CURRENT STATUS")
                        ;; Define the super agenda groups (sorts by order)
                        (org-super-agenda-groups
                         '(;; Filter where tag is CRITICAL
                           (:name "Critical Tasks"  :tag "CRITICAL" :order 0)
                           ;; Filter where TODO state is IN-PROGRESS
                           (:name "Currently Working" :todo "IN-PROGRESS" :order 1)
                           ;; Filter where TODO state is PLANNING
                           (:name "Planning Next Steps" :todo "PLANNING" :order 2 )
                           ;; Filter where TODO state is BLOCKED or where the tag is obstacle
                           (:name "Problems & Blockers" :todo "BLOCKED" :tag "obstacle" :order 3)
                           ;; Filter where tag is @write_future_ticket
                           (:name "Tickets to Create" :tag "@write_future_ticket" :order 4)
                           ;; Filter where tag is @research
                           (:name "Research Required" :tag "@research" :order 7)
                           ;; Filter where tag is meeting and priority is A (only want TODOs from meetings)
                           (:name "Meeting Action Items" :and (:tag "meeting" :priority "A") :order 8)
                           ;; Filter where state is TODO and the priority is A and the tag is not meeting
                           (:name "Other Important Items" :and (:todo "TODO" :priority "A" :not (:tag "meeting")) :order 9)
                           ;; Filter where state is TODO and priority is B
                           (:name "General Backlog" :and (:todo "TODO" :priority "B") :order 10)
                           ;; Filter where the priority is C or less (supports future lower priorities)
                           (:name "Non Critical" :priority<= "C" :order 11)
                           ;; Filter where TODO state is VERIFYING
                           (:name "Currently Being Verified" :todo "VERIFYING" :order 20)))))
          ))
        ))

;; Work around envrc and julia-snail sillyness:
;; envrc, correctly, changes the buffer-local process-environment PATH to whatever was specified in the .envrc file.
;; But then, most of the REPLs you start up don't notice the PATH change. That means that you will have the wrong Julia.
;; Therefore, every time buffer process environment is changed we update the REPL executable names.

                                        ; (defun update-repl-executable-from-env (repl-config)
                                        ;   "Update the REPL executable based on the current `process-environment'.
                                        ; REPL-CONFIG is a cons cell where the car is the local variable and
                                        ; the cdr is the executable name."
                                        ;   (let ((variable-name (car repl-config))
                                        ;         (executable-name (cdr repl-config)))
                                        ;     (make-local-variable variable-name)
                                        ;                                         ;(message (executable-find executable-name))
                                        ;     (set variable-name (or (executable-find executable-name) executable-name))))

                                        ; TODO inferior-js-program-command ?
                                        ; TODO could also intercept (make-comint comint-program-command) and change comint-program-command there--but that's maybe a little magical.
(defvar repl-env-configurations
  '((inferior-lisp-program . "sbcl")
    (python-shell-interpreter . "python3")
    (geiser-guile-binary . "guile")
    (geiser-racket-binary . "racket")
    (geiser-chicken-binary . "chicken")
    (haskell-process-path-ghci . "ghci")
    (js-comint-program-command . "node"))
  "A list of REPL environment configurations.  Each item is (name of the local variable to `setq-local' . name of the executable program to search for (searched-for in PATH)).")

(defun update-repl-commands (&rest _args)
  "Update all REPL executable names for the current `process-environment'."
  (when (bound-and-true-p envrc-mode)
    (mapc 'update-repl-executable-from-env repl-env-configurations)))

(advice-add 'envrc--update :after #'update-repl-commands)

(defun get-projectile-project-root ()
  "Get the root directory of the project according to Projectile."
  (when (and (featurep 'projectile) (projectile-project-p))
    (projectile-project-root)))

(defun get-builtin-project-root ()
  "Get the root directory of the project according to Emacs' built-in `project.el'."
  (when-let ((project (project-current)))
    (project-root project)))

(defun my/ensure-line-in-file (line file-path)
  "Open FILE-PATH in a buffer and ensure that a specific LINE exists. Does not save the buffer automatically."
  (let* ((file (expand-file-name file-path))
         (buffer (find-file-noselect file)))
    (with-current-buffer buffer
      (goto-char (point-min))
      ;; Check if line exists; if not, insert it at the end
      (unless (search-forward (concat line "\n") nil t)
        (goto-char (point-max))
        (unless (bolp) (insert "\n"))  ; Ensure newline before inserting
        (insert line "\n")
        ;; Make the buffer visible for the user to review
        (switch-to-buffer-other-window buffer)
        (message "Review the changes and save the buffer if they are correct.")))))

(defun my/envrc-root-directory ()
  "Attempt to get the envrc root directory for the current buffer."
  (when (featurep 'envrc)
    (envrc--find-env-dir)))

(defun my/update-guix-shell-authorized ()
  "Ensure the current buffer's project or its directory is listed in '~/.config/guix/shell-authorized-directories'."
  (let ((project-dir (my/envrc-root-directory)))
    (when project-dir
      ;; Ensure there's no trailing slash to keep consistency in shell-authorized-directories
      (setq project-dir (directory-file-name project-dir))
      (my/ensure-line-in-file project-dir
                              (expand-file-name "~/.config/guix/shell-authorized-directories")))))

;; envrc-allow also allows `guix shell' to do its thing
(advice-add 'envrc-allow :before #'update-guix-shell-authorized)

(defun my-notdeft-import-web-page (url &optional ask-dir)
  "Import the web page at URL into NotDeft.
Query for the target directory if ASK-DIR is non-nil.
Interactively, query for a URL, and set ASK-DIR if a prefix
argument is given. Choose a file name based on any document
<title>, or generate some unique name."
  (interactive "sPage URL: \nP")
  (let* ((s (shell-command-to-string
             (concat "curl --silent " (shell-quote-argument url) " | "
                     "pandoc" " -f html-native_divs-native_spans"
                     " -t org"
                     " --wrap=none --smart --normalize --standalone")))
         (title
          (and
           (string-match "^#\\+TITLE:[[:space:]]+\\(.+\\)$" s)
           (match-string 1 s))))
    (notdeft-create-file
     (and ask-dir 'ask)
     (and title `(title, title))
     "org" s)))

                                        ; TODO: https://tero.hasu.is/blog/transient-directories-in-notdeft/

(setq buffer-env-script-name '("manifest.scm" ".envrc"))

;; Original wakib binding would save and quit emacs (using save-buffers-kill-terminal).  Who wants that?
(keymap-set wakib-keys-overriding-map "C-q" #'quoted-insert)

(use-package org-notify
  :after org
  :config
  (wrap-with-global-env #'org-notify-process))

(use-package org-node
  :after org
  :config
  (org-node-cache-mode)

(keymap-set global-map "C-<Search>" #'org-node-find)
(keymap-set global-map "M-<Search>" #'org-node-grep) ; Requires consult
                                        ;(global-set-key (kbd "C-c l") 'org-store-link)
                                        ;(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

  (add-hook 'org-mode-hook #'org-node-backlink-mode)
  (setq org-node-creation-fn #'org-capture)
  (setq org-node-alter-candidates t)

  ;; Prefer visiting node with URL in ROAM_REFS property instead of opening URL in web browser.
  (add-hook 'org-open-at-point-functions
            #'org-node-try-visit-ref-node)

(setq org-directory "~/doc/org")
(setq org-default-notes-file (concat org-directory "/notes.org"))


                                        ;        "~/Syncthing/"

(setq org-node-extra-id-dirs
      '("~/doc/org-roam/"))
                                        ;Do a M-x org-node-reset and see if it can find your notes now.
                                        ; Then org-id-update-id-locations

(setq org-node-series-defs
      (list
       '("d" :name "Daily-files"
         :version 2
         :classifier (lambda (node)
                       (let ((path (org-node-get-file-path node)))
                         (when (string-search "~/doc/org/daily" path)
                           (let ((ymd (org-node-helper-filename->ymd path)))
                             (when ymd
                               (cons ymd path))))))
         :whereami (lambda ()
                     (org-node-helper-filename->ymd buffer-file-name))
         :prompter (lambda (key)
                     (let ((org-node-series-that-marks-calendar key))
                       (org-read-date)))
         :try-goto (lambda (item)
                     (org-node-helper-try-visit-file (cdr item)))
         :creator (lambda (sortstr key)
                    (let ((org-node-datestamp-format "")
                          (org-node-ask-directory "~/doc/org/daily"))
                      (org-node-create sortstr (org-id-new) key))))

         ;; Obviously, this series works best if you have `org-node-put-created' on
         ;; `org-node-creation-hook'.
         '("a" :name "All ID-nodes by property :CREATED:"
           :version 2
           :capture "n"
           :classifier (lambda (node)
                         (let ((time (cdr (assoc "CREATED" (org-node-get-props node)))))
                           (when (and time (not (string-blank-p time)))
                             (cons time (org-node-get-id node)))))
           :whereami (lambda ()
                       (let ((time (org-entry-get nil "CREATED" t)))
                         (and time (not (string-blank-p time)) time)))
           :prompter (lambda (key)
                       (let ((series (cdr (assoc key org-node-built-series))))
                         (completing-read "Go to: " (plist-get series :sorted-items))))
           :try-goto (lambda (item)
                       (when (org-node-helper-try-goto-id (cdr item))
                         t))
           :creator (lambda (sortstr key)
                      (org-node-create sortstr (org-id-new) key)))))

                                        ;(setq tramp-verbose 9)
                                        ; (tramp-cleanup-all-connections)
                                        ; check tramp/foo* and debug tramp/foo*


  (wrap-with-global-env #'el-job-launch)
  (wrap-with-global-env #'org-node-find)
)

(setq org-src-tab-acts-natively t)
(add-hook 'org-mode-hook #'mixed-pitch-mode)

                                        ;(add-to-list 'load-path "~/.emacs.d/qemu/")
                                        ;(require 'qemu-qmp)
                                        ;(require 'qemu-dap)

;; TODO: Add to Guix.

(add-to-list 'load-path "~/.emacs.d/org-notify/")
(require 'org-notify)
(org-notify-start)

                                        ; Autoinsert

(require 'autoinsert)
(auto-insert-mode t)
(setq auto-insert 'other)
(setq auto-insert-query nil)

;; Java File Template
(define-auto-insert '(".*\\.java\\'" . "Java program")
  '("Java"
    "// SPDX-License-Identifier: GPL-3.0-or-later" \n
    "/*" \n
    " * " (file-name-nondirectory (buffer-file-name)) \n
    " *" \n
    " * TODO: Describe." \n
    " */" \n
    "public class " (file-name-sans-extension (file-name-nondirectory (buffer-file-name))) " {" > \n
    "public static void main(String[] args) {" > \n
    > _ \n
    "}" > \n
    "}" > \n))

;; Vala File Template
(define-auto-insert '(".*\\.vala\\'" . "Vala program")
  '("Vala program"
    "// SPDX-License-Identifier: GPL-3.0-or-later" > \n
    "/*" > \n
    " * " (file-name-nondirectory (buffer-file-name)) > \n
    " *" > \n
    " * TODO: Describe." > \n
    " */" > \n
    "using Gtk;" > \n
    "" > \n
    "int main (string[] args) {" > \n
    "    Gtk.init (ref args);" > \n
    "    var window = new Window ();" > \n
    "    window.title = \"First GTK+ Program\";" > \n
    "    window.border_width = 10;" > \n
    "    window.window_position = WindowPosition.CENTER;" > \n
    "    window.set_default_size (350, 70);" > \n
    "    window.destroy.connect (Gtk.main_quit);" > \n
    "    var button = new Button.with_label (\"Click me!\");" > \n
    "    button.clicked.connect (() => {" > \n
    "        button.label = \"Thank you\";" > \n
    "    });" > \n
    "    window.add (button);" > \n
    "    window.show_all ();" > \n
    > _ \n
    "    Gtk.main ();" > \n
    "    return 0;" > \n
    "}" > \n))

;; Guix Package Template
(define-auto-insert '(".*\\.scm\\'" . "Guix package")
  '("Guix package"
    "; Guix package definition." \n
    "(use-modules (guix packages))" \n
    "(use-modules (guix gexp))" \n
    "(use-modules (guix build-system glib-or-gtk))" \n
    "(use-modules (guix build-system gnu))" \n
    ";(use-modules (guix build-system maven))" \n
    ";(use-modules (guix build-system node))" \n
    "(use-modules ((guix licenses) #:prefix license:))" \n
    \n
    ";(define %source-dir (getcwd))" \n
    "(define " (file-name-sans-extension (file-name-nondirectory (buffer-file-name))) "\n"
    "  (package\n"
    "    (name \"" (file-name-sans-extension (file-name-nondirectory (buffer-file-name))) "\")\n"
    "    (version \"0.1\")\n"
    "    (source " _ "(origin\n"
    "              (method url-fetch)\n"
    "              (uri (string-append \"TODO:\" name \"-\" version \".tar.gz\"))\n"
    "              (sha256 (base32 \"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\"))))\n"
    "    (build-system gnu-build-system)\n"
    "    (native-inputs (list))\n"
    "    (inputs (list))\n"
    "    (synopsis \"TODO: A brief description of the package.\")\n"
    "    (description \"TODO: A longer description of the package.\"))\n"
    "    (home-page \"TODO: url\")\n"
    "    (license #f)) ; TODO: Put license.\n"
    (file-name-sans-extension (file-name-nondirectory (buffer-file-name))) \n))

;; Guix Manifest Template
(define-auto-insert '("manifest\\.scm\\'" . "Guix manifest")
  '("Guix manifest"
    ";;; Guix manifest definition." \n
    "(specifications->manifest" \n
    " (list \"rust-analyzer\" \"ccls\" \"ocaml-lsp-server\" \"gcc-toolchain\" \"gdb\" \"rr\" \"texlive-minted\" \"texlive-latex-bin\" \"dvisvgm\" \"python-lsp-server\" \"emacs-ediprolog\" \"tidy-html\"))" \n))

                                        ; (add-to-list 'load-path "~/.emacs.d/kiwix.el")
                                        ; (require 'kiwix)
                                        ; duplicate
(setq kiwix-default-browser-function 'eww-browse-url)

                                        ; TODO: Use which-key instead.
                                        ;(require 'discover-my-major)
                                        ;(global-set-key (kbd "C-h C-m") 'discover-my-major)

                                        ;(setq which-key-persistent-popup t)

(add-to-list 'load-path "~/.emacs.d/shr-tag-math")
(require 'shr-tag-math)
                                        ;(add-hook 'nov-mode-hook #'xenops-mode) ; so we render <math>; unfortunately, that fucks up all the other formatting. Also, the size of the rendered images is much too big here.

(require 'emms-setup)
(emms-all)
(setq emms-player-list '(emms-player-mpv))
(emms-add-directory-tree "~/Music")

                                        ; (defun elfeed-search-print-entry (entry)
                                        ;   "Print ENTRY to the buffer."
                                        ;   (let* ((date (elfeed-search-format-date (elfeed-entry-date entry)))
                                        ;          (title (or (elfeed-meta entry :title) (elfeed-entry-title entry) ""))
                                        ;          (title-faces (elfeed-search--faces (elfeed-entry-tags entry)))
                                        ;          (feed (elfeed-entry-feed entry))
                                        ;          (feed-title
                                        ;           (when feed
                                        ;             (or (elfeed-meta feed :title) (elfeed-feed-title feed))))
                                        ;          (tags (mapcar #'symbol-name (elfeed-entry-tags entry)))
                                        ;          (tags-str (mapconcat
                                        ;                     (lambda (s) (propertize s 'face 'elfeed-search-tag-face))
                                        ;                     tags ","))
                                        ;          (title-width (- (window-width) 10 elfeed-search-trailing-width))
                                        ;          (title-column (elfeed-format-column
                                        ;                         title (elfeed-clamp
                                        ;                                elfeed-search-title-min-width
                                        ;                                title-width
                                        ;                                elfeed-search-title-max-width)
                                        ;                         :left)))
                                        ;     (insert (propertize date 'face 'elfeed-search-date-face) " ")
                                        ;     (insert (propertize title-column 'face title-faces 'kbd-help title) "\t")
                                        ;     (when feed-title
                                        ;       (insert (propertize feed-title 'face 'elfeed-search-feed-face) " "))
                                        ;     (when tags
                                        ;       (insert "(" tags-str ")"))))

                                        ; (setq elfeed-search-print-entry-function #'elfeed-search-print-entry)

(setq gptel-backend
      (gptel-make-openai "llama-cpp"
        :stream t
        :protocol "http"
        :host "localhost:8080"
        :models '(llama)))  ; Any names, doesn't matter for Llama

(setq gptel-model 'llama)
(setq gptel-default-mode 'org-mode)

                                        ; see also org-disputed-keys for CUA mode.
                                        ;(setq org-replace-disputed-keys t)

(setq-default line-spacing 0.2) ; compromise between Rust source code and org mode
;; TODO: Scala; PHP; C++; Kotlin; Swift
(add-hook 'perl-mode-hook #'form-feed-mode)
(add-hook 'python-mode-hook #'form-feed-mode)
(add-hook 'python-ts-mode-hook #'form-feed-mode)
(add-hook 'scheme-mode-hook #'form-feed-mode)
(add-hook 'lisp-mode-hook #'form-feed-mode)
(add-hook 'fortran-mode-hook #'form-feed-mode)
                                        ;(add-hook 'js-mode-hook #'form-feed-mode)
                                        ;(add-hook 'js-ts-mode-hook #'form-feed-mode)
(add-hook 'js-base-mode-hook #'form-feed-mode)
(add-hook 'c-ts-base-mode-hook #'form-feed-mode)
(add-hook 'ruby-mode-hook #'form-feed-mode)
(add-hook 'ruby-ts-mode-hook #'form-feed-mode)
(add-hook 'typescript-mode-hook #'form-feed-mode)
(add-hook 'typescript-ts-mode-hook #'form-feed-mode)
(add-hook 'java-mode-hook #'form-feed-mode)
(add-hook 'go-mode-hook #'form-feed-mode)
(add-hook 'go-ts-mode-hook #'form-feed-mode)
(add-hook 'go-mod-ts-mode-hook #'form-feed-mode)
(add-hook 'haskell-mode-hook #'form-feed-mode)
(add-hook 'csharp-mode-hook #'form-feed-mode)
(add-hook 'csharp-ts-mode-hook #'form-feed-mode)
(add-hook 'bash-ts-mode-hook #'form-feed-mode)
(add-hook 'objc-mode-hook #'form-feed-mode)
(add-hook 'rustic-mode-hook #'form-feed-mode)
(add-hook 'rust-mode-hook #'form-feed-mode)
(add-hook 'julia-mode-hook #'form-feed-mode)
(add-hook 'org-mode-hook #'form-feed-mode) ; looks weird and sometimes disappears on save
(add-hook 'elisp-mode-hook #'form-feed-mode)
(add-hook 'elisp-mode-hook #'smartparens-mode)
(add-hook 'scheme-mode-hook #'smartparens-mode)

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

;; Don't bother user with emacs warnings
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

(use-package vertico
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Emacs minibuffer configurations.
(use-package emacs
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))


(use-package marginalia
  :ensure nil
  :hook (after-init . marginalia-mode))

;; Apparently doesn't do anything
(use-package orderless
  :ensure f
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrride nil))

(global-set-key (kbd "C-c r") 'gptel-rewrite-menu)
                                        ; gptel-add-file	 C-u gptel-send	 transient menu

                                        ;(add-hook 'vala-mode-hook #'lsp)  ;; Enable LSP for Vala mode
                                        ;(add-hook 'vala-mode-hook #'lsp-mode) ; disconnects immediately

;; DAP Python Configuration
                                        ;(with-eval-after-load 'dap-mode
                                        ;  (dap-register-debug-template "Python :: Uvicorn (FastAPI)"
                                        ;    (list :type "python"
                                        ;          :request "launch"
                                        ;          :name "Python :: Uvicorn (FastAPI)"
                                        ;          :program "${workspaceFolder}/main.py"  ;; Path to your FastAPI app
                                        ;          :args ["run" "main:app" "--reload" "--host" "127.0.0.1" "--port" "8000"]
                                        ;          :env (list (cons "PYTHONPATH" "${workspaceFolder}"))
                                        ;          :justMyCode t
                                        ;          :console "integratedTerminal")))

                                        ; (with-eval-after-load 'dap-mode
                                        ;   (dap-register-debug-template "Python :: Attach via port 5678"
                                        ;                                (list :type "python"
                                        ;                                      :request "attach"
                                        ;                                      :name "Python :: Attach to Running"
                                        ;                                      :hostName "127.0.0.1"  ;; Address of the Python process
                                        ;                                      :port 5678             ;; Port that debugpy is listening on
                                        ;                                         ; :justMyCode t          ;; Optional: Only debug your code, not external libraries
                                        ;                                      :env (list (cons "PYTHONPATH" "${workspaceFolder}"))
                                        ;                                      :console "integratedTerminal")))

                                        ;(which-key-setup-side-window-right-bottom)
(which-key-setup-side-window-bottom)


;; Display which-key keybindings in the right margin
                                        ;(setq which-key-side-window-location 'right) ; Set position to right margin
                                        ;(setq which-key-side-window-max-width 0.25)  ; Set maximum width of the side window (25% of the frame width)
                                        ; what? (setq which-key-side-window-slot -10)        ; Slot for side window
                                        ;(setq which-key-show-early-on-C-h t)         ; Show key hints when pressing C-h
                                        ;(setq which-key-idle-delay 0.5)              ; Delay before the keybindings show up
                                        ;(setq which-key-idle-secondary-delay 0.05)   ; Delay for showing secondary hints
;; Allow the margin window to take up multiple lines
                                        ;(setq which-key-side-window-multi-line-p t)   ; Allow multi-line keybindings
                                        ;(setq which-key-side-window-max-height 0.5)    ; Max height of the side window (50% of the frame height)

                                        ;(custom-set-faces
                                        ; '(which-key-key-face ((t (:foreground "yellow")))) ; Key face color
                                        ; '(which-key-command-description-face ((t (:foreground "green")))) ; Command description color
                                        ; '(which-key-group-description-face ((t (:foreground "cyan"))))) ; Group description color

                                        ; Eventually provided by manifest.scm
(setq lsp-clients-clangd-executable "ccls")

                                        ;(setq dired-launch-default-launcher '("xdg-open"))
(setf dired-launch-extensions-map
      '(("xlsx" ("libreoffice"))
        ("odt" ("libreoffice" "abiword"))))

(add-hook 'python-mode-hook 'eglot-ensure)
;; Tab Completion: Use company-mode for completion, integrating company-capf with eglot.
;; elpy or something.
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
(add-hook 'python-mode-hook 'flycheck-mode)
                                        ;(add-hook 'python-mode-hook (lambda () (add-to-list 'company-backends 'company-jedi)))

(require 'company-lsp)
(with-eval-after-load 'company
                                        ; (push 'company-robe company-backends)
  (push 'company-lsp company-backends))

(require 'vlf-setup) ; very large files

(projectile-register-project-type 'npm '("package.json")
                                  :project-file "package.json"
				  :compile "npm run build" ; or "npm install" or something
				  :test "npm test"
				  :run "npm start"
				  :test-suffix ".test")

;; Rails & RSpec
(projectile-register-project-type 'rails-rspec '("Gemfile") ; "app" "lib" "db" "config" "spec"
                                  :project-file "Gemfile"
                                  :compile "bundle exec rails server"
                                  :src-dir "lib/"
                                  :test "bundle exec rspec"
                                  :test-dir "spec/"
                                  :test-suffix "_spec")

(setq org-agenda-files '("~/org-mode/agenda"))
(setq org-agenda-file-regexp "\\`[^.].*\\.org\\'")

;; I'm using org-indent-mode together with form-feed-mode: org-indent-mode interprets the form feed character as part of the previous section and indents it--which is not what I want.  I'm use the form feed for sections. So the form feed should belong to no section.
(defun fix-org-indent-form-feed ()
  (setq-local org-outline-regexp "\\*+ \\|\\(^\f$\\)"))
(add-hook 'org-mode-hook #'fix-org-indent-form-feed)

;; Doesn't work. Sigh.
                                        ;(defun fix-org-indent-form-feed ()
                                        ;  (setq-local org-heading-regexp "^\\(\f?\\*+\\)\\(?: +\\(.*?\\)\\)?[ 	]*$"))
                                        ;(add-hook 'org-mode-hook #'fix-org-indent-form-feed)

;; Skip flyspell on code blocks

                                        ; See https://endlessparentheses.com/ispell-and-org-mode.html
(defun endless/org-ispell ()
  "Configure `ispell-skip-region-alist' for `org-mode'."
  (make-local-variable 'ispell-skip-region-alist)
  (add-to-list 'ispell-skip-region-alist '(org-property-drawer-re))
  (add-to-list 'ispell-skip-region-alist '("~" "~"))
  (add-to-list 'ispell-skip-region-alist '("=" "="))
  (add-to-list 'ispell-skip-region-alist '("^#\\+BEGIN_SRC" . "^#\\+END_SRC")))
(add-hook 'org-mode-hook #'endless/org-ispell)

(with-eval-after-load 'org
  '(progn
     (define-key org-mode-map (kbd "<home>") #'move-beginning-of-line) ; ignored
     (define-key org-mode-map (kbd "<end>") #'move-end-of-line)
     (define-key org-mode-map (kbd "C-c <up>") #'org-priority-up)
     (define-key org-mode-map (kbd "C-c <down>") #'org-priority-down)
     (define-key org-mode-map (kbd "C-s M-i") #'org-node-insert-link)
     ;; When you want to change the level of an org item, use SMR
     (define-key org-mode-map (kbd "C-c C-g C-r") #'org-shiftmetaright)))

(defun unset-line-move-visual ()
  (define-key org-mode-map [remap move-beginning-of-line] nil)
  (define-key org-mode-map [remap move-end-of-line] nil)
  (setq line-move-visual nil))

(add-hook 'org-mode-hook #'unset-line-move-visual)

                                        ;(with-eval-after-load 'web-mode ...)
(require 'lsp-mode)
(require 'lsp-volar)
(require 'lsp-vetur)
                                        ;(add-hook 'web-mode-hook #'lsp-vue-mmm-enable) ; missing.

(require 'web-mode)
(define-derived-mode genehack-vue-mode web-mode "ghVue"
  "A major mode derived from web-mode, for editing .vue files with LSP support.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . genehack-vue-mode))
                                        ;(add-hook 'genehack-vue-mode-hook #'eglot-ensure)
(add-hook 'genehack-vue-mode-hook #'lsp)

(require 'mmm-auto)
(setq mmm-global-mode 'maybe)
(mmm-add-mode-ext-class 'html-mode "\\.php\\'" 'html-php)
                                        ; (mmm-add-mode-ext-class 'html-mode "\\.html\\'" 'html-js) ; maybe automatic?
                                        ;just modify mmm-mode-ext-classes-alist directly
                                        ;     (add-to-list 'mmm-mode-ext-classes-alist
                                        ;                  '(rpm-spec-mode "\\.spec\\'" rpm-sh))

                                        ; (require 'ox-publish)
                                        ; (setq org-publish-project-alist
                                        ;       '(("friendly-machines.com"
                                        ;          :base-directory "~/org-mode/"
                                        ;          :publishing-directory "~/friendly-machines.com/www/mirror/public/blog/"
                                        ;          :base-extension "org"
                                        ;          :recursive t
                                        ;          :publishing-function org-html-publish-to-html
                                        ;          :html-doctype "html5"
                                        ;          :with-toc nil
                                        ;          :section-numbers nil
                                        ;          :html-head "<link rel=\"stylesheet\" href=\"/css/org.css\" type=\"text/css\"/>"
                                        ;          :html-preamble nil
                                        ;          :html-postamble nil
                                        ;          :exclude ".*-private.org\\|.*-confidential.org\\|.*-internal.org"
                                        ;          :select-tags ("public"))))

(setq org-src-fontify-natively t)
                                        ; (setq org-confirm-babel-evaluate nil)

;; Disambiguate /home/user/project1/main.cpp and /home/user/project2/main.cpp
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(defun other-window-mru ()
  "Select the most recently used window on this frame."
  (interactive)
  (when-let ((mru-window
              (get-mru-window
               nil nil 'not-this-one-dummy)))
    (select-window mru-window)))

(keymap-global-set "M-o" 'other-window-mru)

                                        ; (when (daemonp)
                                        ;                                         ;(global-set-key (kbd "C-d C-c") 'handle-delete-frame-without-kill-emacs)
                                        ;                                         ;(define-key global-map [delete-frame] 'handle-delete-frame)
                                        ;   (define-key special-event-map [delete-frame]
                                        ;               (lambda (event)
                                        ;                 (interactive "e")
                                        ;                 (let ((frame (posn-window (event-start event))))
                                        ;                   (select-frame frame)
                                        ;                   ;; (save-some-buffers) returns t on "q", nil if there's nothing to save. So that's not useful :P
                                        ;                   ;; But if I press Esc, it quits and doesn't continue. Good, I guess.
                                        ;                   (save-some-buffers)
                                        ;                   (dolist (win (window-list frame))
                                        ;                     (with-selected-window win
                                        ;                       ;; You could (kill-buffer x) instead--but it would have a potential TOCTOU.
                                        ;                       (kill-buffer-if-not-modified (current-buffer))))
                                        ;                   (delete-frame frame)))))

;; Align the current prompt with the BOTTOM of the window.
;; That way the area before that prompt (which is the previous response) is maximized.
                                        ;(setq eshell-show-maximum-output t)

                                        ; better maybe: Add eshell-smart to eshell-modules-list
                                        ; that assumes that you keep editing existing commands because you got them wrong. I really don't. (add-to-list 'eshell-modules-list 'eshell-smart)

(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              (remove-if-not 'buffer-file-name (buffer-list)))))

;; Stop asking "Autosave file on local temporary directory, do you want to continue? (yes or no)" for files on remote hosts owned by root
;; This will just put the autosave files on that same host instead of localhost.
(setq auto-save-file-name-transforms nil)
                                        ; (setq tramp-auto-save-directory "~/emacs/tramp-autosave")

;; This is an lsp-ui workaround for <https://github.com/emacs-lsp/lsp-ui/issues/607>.
(let ((areas '("mode-line" "left-margin" "left-fringe" "right-fringe" "header-line" "vertical-scroll-bar" "tool-bar" "menu-bar"))
      loc)
  (while areas
    (setq loc (pop areas))
    (global-set-key
     (kbd (concat "<" loc "> <mouse-movement>")) #'ignore)))

;; Make the tab tooltip show the buffer file name.
(defun tab-line-tab-name-format-default (tab tabs)
  "Default function to use as `tab-line-tab-name-format-function', which see."
  (let* ((buffer-p (bufferp tab))
         (selected-p (if buffer-p
                         (eq tab (window-buffer))
                       (cdr (assq 'selected tab))))
         (name (if buffer-p
                   (funcall tab-line-tab-name-function tab tabs)
                 (cdr (assq 'name tab))))
         (face (if selected-p
                   (if (mode-line-window-selected-p)
                       'tab-line-tab-current
                     'tab-line-tab)
                 'tab-line-tab-inactive)))
    (dolist (fn tab-line-tab-face-functions)
      (setf face (funcall fn tab tabs face buffer-p selected-p)))
    (apply 'propertize
           (concat (propertize (string-replace "%" "%%" name) ;; (bug#57848)
                               'keymap tab-line-tab-map
                               'help-echo (let ((buffer (if buffer-p tab (cdr (assq 'buffer tab)))))
                                            (if selected-p
                                                (buffer-file-name buffer)
                                              (buffer-file-name buffer)))
                               ;; Don't turn mouse-1 into mouse-2 (bug#49247)
                               'follow-link 'ignore)
                   (or (and (or buffer-p (assq 'buffer tab) (assq 'close tab))
                            tab-line-close-button-show
                            (not (eq tab-line-close-button-show
                                     (if selected-p 'non-selected 'selected)))
                            tab-line-close-button)
                       ""))
           `(
             tab ,tab
             ,@(if selected-p '(selected t))
             face ,face
             mouse-face tab-line-highlight))))

;;; Keep unsaved state
(desktop-save-mode 1)
(setq desktop-restore-frames t) ; restore window configuration
(setq desktop-path '("~/.emacs.d/desktop/")) ; where to save desktop files
(setq desktop-auto-save-timeout 30) ; save desktop automatically every 30 seconds
(auto-save-visited-mode 1)
(setq desktop-save t) ; always save without asking

;; keyboard-shortcuts

(define-key global-map (kbd "M-g f" ) #'org-node-find)
(define-key org-mode-map (kbd "M-g M-l" ) #'org-node-insert-link)
(define-key global-map (kbd "M-g t") (lambda () (interactive) (
                                                               find-file "~/org-mode/todo.org")))

(define-key global-map (kbd "C-f" ) #'swiper)
(define-key wakib-keys-overriding-map (kbd "C-f") #'swiper-isearch) ; Note: someone overwrites this.

(add-hook 'git-commit-setup-hook #'my/generate-lisp-commit-message)

(keymap-set global-map "C-<f5>" `eval-region)
(keymap-set global-map "C-S-<escape>" `eshell)
(keymap-set global-map "C-<F5>" `eval-buffer)
(keymap-set wakib-keys-overriding-map "C-w" `bury-buffer)

(require 'minimap)
(require 'buffer-move)

-backend
(gptel-make-openai "llama-cpp"
  :stream t
  :protocol "http"
  :host "localhost:8080"
  :models '(llama))  ; Any names, doesn't matter for Llama

(setq gptel-model 'llama)
(setq gptel-default-mode 'org-mode)

                                        ; see also org-disputed-keys for CUA mode.
                                        ;(setq org-replace-disputed-keys t)

(setq-default line-spacing 0.2) ; compromise between Rust source code and org mode
;; TODO: Scala; PHP; C++; Kotlin; Swift
(add-hook 'perl-mode-hook #'form-feed-mode)
(add-hook 'python-mode-hook #'form-feed-mode)
(add-hook 'python-ts-mode-hook #'form-feed-mode)
(add-hook 'scheme-mode-hook #'form-feed-mode)
(add-hook 'lisp-mode-hook #'form-feed-mode)
(add-hook 'fortran-mode-hook #'form-feed-mode)
                                        ;(add-hook 'js-mode-hook #'form-feed-mode)
                                        ;(add-hook 'js-ts-mode-hook #'form-feed-mode)
(add-hook 'js-base-mode-hook #'form-feed-mode)
(add-hook 'c-ts-base-mode-hook #'form-feed-mode)
(add-hook 'ruby-mode-hook #'form-feed-mode)
(add-hook 'ruby-ts-mode-hook #'form-feed-mode)
(add-hook 'typescript-mode-hook #'form-feed-mode)
(add-hook 'typescript-ts-mode-hook #'form-feed-mode)
(add-hook 'java-mode-hook #'form-feed-mode)
(add-hook 'go-mode-hook #'form-feed-mode)
(add-hook 'go-ts-mode-hook #'form-feed-mode)
(add-hook 'go-mod-ts-mode-hook #'form-feed-mode)
(add-hook 'haskell-mode-hook #'form-feed-mode)
(add-hook 'csharp-mode-hook #'form-feed-mode)
(add-hook 'csharp-ts-mode-hook #'form-feed-mode)
(add-hook 'bash-ts-mode-hook #'form-feed-mode)
(add-hook 'objc-mode-hook #'form-feed-mode)
(add-hook 'rustic-mode-hook #'form-feed-mode)
(add-hook 'rust-mode-hook #'form-feed-mode)
(add-hook 'julia-mode-hook #'form-feed-mode)
(add-hook 'org-mode-hook #'form-feed-mode) ; looks weird and sometimes disappears on save
(add-hook 'elisp-mode-hook #'paredit-mode)
(add-hook 'scheme-mode-hook #'paredit-mode)

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

;; Don't bother user with emacs warnings
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

(use-package vertico
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Emacs minibuffer configurations.
(use-package emacs
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))


;;; (setq completion-category-overrides '((file (styles basic))))
                                        ;(keymap-set vertico-map "<Return>" #'vertico-exit-input)

(use-package marginalia
  :ensure nil
  :hook (after-init . marginalia-mode))

(use-package orderless
  :ensure f
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrride nil))

(global-set-key (kbd "C-c r") 'gptel-rewrite-menu)
                                        ; gptel-add-file	 C-u gptel-send	 transient menu

                                        ;(add-hook 'vala-mode-hook #'lsp)  ;; Enable LSP for Vala mode
                                        ;(add-hook 'vala-mode-hook #'lsp-mode) ; disconnects immediately

;; DAP Python Configuration
                                        ;(with-eval-after-load 'dap-mode
                                        ;  (dap-register-debug-template "Python :: Uvicorn (FastAPI)"
                                        ;    (list :type "python"
                                        ;          :request "launch"
                                        ;          :name "Python :: Uvicorn (FastAPI)"
                                        ;          :program "${workspaceFolder}/main.py"  ;; Path to your FastAPI app
                                        ;          :args ["run" "main:app" "--reload" "--host" "127.0.0.1" "--port" "8000"]
                                        ;          :env (list (cons "PYTHONPATH" "${workspaceFolder}"))
                                        ;          :justMyCode t
                                        ;          :console "integratedTerminal")))

                                        ; (with-eval-after-load 'dap-mode
                                        ;   (dap-register-debug-template "Python :: Attach via port 5678"
                                        ;                                (list :type "python"
                                        ;                                      :request "attach"
                                        ;                                      :name "Python :: Attach to Running"
                                        ;                                      :hostName "127.0.0.1"  ;; Address of the Python process
                                        ;                                      :port 5678             ;; Port that debugpy is listening on
                                        ;                                         ; :justMyCode t          ;; Optional: Only debug your code, not external libraries
                                        ;                                      :env (list (cons "PYTHONPATH" "${workspaceFolder}"))
                                        ;                                      :console "integratedTerminal")))

                                        ;(which-key-setup-side-window-right-bottom)
(which-key-setup-side-window-bottom)


;; Display which-key keybindings in the right margin
                                        ;(setq which-key-side-window-location 'right) ; Set position to right margin
                                        ;(setq which-key-side-window-max-width 0.25)  ; Set maximum width of the side window (25% of the frame width)
                                        ; what? (setq which-key-side-window-slot -10)        ; Slot for side window
                                        ;(setq which-key-show-early-on-C-h t)         ; Show key hints when pressing C-h
                                        ;(setq which-key-idle-delay 0.5)              ; Delay before the keybindings show up
                                        ;(setq which-key-idle-secondary-delay 0.05)   ; Delay for showing secondary hints
;; Allow the margin window to take up multiple lines
                                        ;(setq which-key-side-window-multi-line-p t)   ; Allow multi-line keybindings
                                        ;(setq which-key-side-window-max-height 0.5)    ; Max height of the side window (50% of the frame height)

                                        ;(custom-set-faces
                                        ; '(which-key-key-face ((t (:foreground "yellow")))) ; Key face color
                                        ; '(which-key-command-description-face ((t (:foreground "green")))) ; Command description color
                                        ; '(which-key-group-description-face ((t (:foreground "cyan"))))) ; Group description color

                                        ; Eventually provided by manifest.scm
(setq lsp-clients-clangd-executable "ccls")

                                        ;(setq dired-launch-default-launcher '("xdg-open"))
(setf dired-launch-extensions-map
      '(("xlsx" ("libreoffice"))
        ("odt" ("libreoffice" "abiword"))))

(add-hook 'python-mode-hook 'eglot-ensure)
;; Tab Completion: Use company-mode for completion, integrating company-capf with eglot.
;; elpy or something.
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
(add-hook 'python-mode-hook 'flycheck-mode)
                                        ;(add-hook 'python-mode-hook (lambda () (add-to-list 'company-backends 'company-jedi)))

(require 'company-lsp)
(with-eval-after-load 'company
  (push 'company-robe company-backends)
  (push 'company-lsp company-backends))

(require 'vlf-setup) ; very large files

(projectile-register-project-type 'npm '("package.json")
                                  :project-file "package.json"
				  :compile "npm run build" ; or "npm install" or something
				  :test "npm test"
				  :run "npm start"
				  :test-suffix ".test")

;; Rails & RSpec
(projectile-register-project-type 'rails-rspec '("Gemfile") ; "app" "lib" "db" "config" "spec"
                                  :project-file "Gemfile"
                                  :compile "bundle exec rails server"
                                  :src-dir "lib/"
                                  :test "bundle exec rspec"
                                  :test-dir "spec/"
                                  :test-suffix "_spec")

(setq org-agenda-files '("~/org-mode/agenda"))
(setq org-agenda-file-regexp "\\`[^.].*\\.org\\'")

;; I'm using org-indent-mode together with form-feed-mode: org-indent-mode interprets the form feed character as part of the previous section and indents it--which is not what I want.  I'm use the form feed for sections. So the form feed should belong to no section.
(defun fix-org-indent-form-feed ()
  (setq-local org-outline-regexp "\\*+ \\|\\(^\f$\\)"))
(add-hook 'org-mode-hook #'fix-org-indent-form-feed)

;; Doesn't work. Sigh.
                                        ;(defun fix-org-indent-form-feed ()
                                        ;  (setq-local org-heading-regexp "^\\(\f?\\*+\\)\\(?: +\\(.*?\\)\\)?[ 	]*$"))
                                        ;(add-hook 'org-mode-hook #'fix-org-indent-form-feed)

;; Skip flyspell on code blocks

                                        ; See https://endlessparentheses.com/ispell-and-org-mode.html
(defun endless/org-ispell ()
  "Configure `ispell-skip-region-alist' for `org-mode'."
  (make-local-variable 'ispell-skip-region-alist)
  (add-to-list 'ispell-skip-region-alist '(org-property-drawer-re))
  (add-to-list 'ispell-skip-region-alist '("~" "~"))
  (add-to-list 'ispell-skip-region-alist '("=" "="))
  (add-to-list 'ispell-skip-region-alist '("^#\\+BEGIN_SRC" . "^#\\+END_SRC")))
(add-hook 'org-mode-hook #'endless/org-ispell)

(with-eval-after-load 'org
  '(progn
     (define-key org-mode-map (kbd "<home>") #'move-beginning-of-line) ; ignored
     (define-key org-mode-map (kbd "<end>") #'move-end-of-line)
     (define-key org-mode-map (kbd "C-c <up>") #'org-priority-up)
     (define-key org-mode-map (kbd "C-c <down>") #'org-priority-down)
     (define-key org-mode-map (kbd "C-s M-i") #'org-node-insert-link)
     ;; When you want to change the level of an org item, use SMR
     (define-key org-mode-map (kbd "C-c C-g C-r") #'org-shiftmetaright)))

(defun unset-line-move-visual ()
  (define-key org-mode-map [remap move-beginning-of-line] nil)
  (define-key org-mode-map [remap move-end-of-line] nil)
  (setq line-move-visual nil))

(add-hook 'org-mode-hook #'unset-line-move-visual)

                                        ;(with-eval-after-load 'web-mode ...)
(require 'lsp-mode)
(require 'lsp-volar)
(require 'lsp-vetur)
                                        ;(add-hook 'web-mode-hook #'lsp-vue-mmm-enable) ; missing.

(require 'web-mode)
(define-derived-mode genehack-vue-mode web-mode "ghVue"
  "A major mode derived from web-mode, for editing .vue files with LSP support.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . genehack-vue-mode))
                                        ;(add-hook 'genehack-vue-mode-hook #'eglot-ensure)
(add-hook 'genehack-vue-mode-hook #'lsp)

(require 'mmm-auto)
(setq mmm-global-mode 'maybe)
(mmm-add-mode-ext-class 'html-mode "\\.php\\'" 'html-php)
                                        ; (mmm-add-mode-ext-class 'html-mode "\\.html\\'" 'html-js) ; maybe automatic?
                                        ;just modify mmm-mode-ext-classes-alist directly
                                        ;     (add-to-list 'mmm-mode-ext-classes-alist
                                        ;                  '(rpm-spec-mode "\\.spec\\'" rpm-sh))

                                        ; (require 'ox-publish)
                                        ; (setq org-publish-project-alist
                                        ;       '(("friendly-machines.com"
                                        ;          :base-directory "~/org-mode/"
                                        ;          :publishing-directory "~/friendly-machines.com/www/mirror/public/blog/"
                                        ;          :base-extension "org"
                                        ;          :recursive t
                                        ;          :publishing-function org-html-publish-to-html
                                        ;          :html-doctype "html5"
                                        ;          :with-toc nil
                                        ;          :section-numbers nil
                                        ;          :html-head "<link rel=\"stylesheet\" href=\"/css/org.css\" type=\"text/css\"/>"
                                        ;          :html-preamble nil
                                        ;          :html-postamble nil
                                        ;          :exclude ".*-private.org\\|.*-confidential.org\\|.*-internal.org"
                                        ;          :select-tags ("public"))))

(setq org-src-fontify-natively t)
                                        ; (setq org-confirm-babel-evaluate nil)

;; Disambiguate /home/user/project1/main.cpp and /home/user/project2/main.cpp
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(defun other-window-mru ()
  "Select the most recently used window on this frame."
  (interactive)
  (when-let ((mru-window
              (get-mru-window
               nil nil 'not-this-one-dummy)))
    (select-window mru-window)))

(keymap-global-set "M-o" 'other-window-mru)

                                        ; (when (daemonp)
                                        ;                                         ;(global-set-key (kbd "C-d C-c") 'handle-delete-frame-without-kill-emacs)
                                        ;                                         ;(define-key global-map [delete-frame] 'handle-delete-frame)
                                        ;   (define-key special-event-map [delete-frame]
                                        ;               (lambda (event)
                                        ;                 (interactive "e")
                                        ;                 (let ((frame (posn-window (event-start event))))
                                        ;                   (select-frame frame)
                                        ;                   ;; (save-some-buffers) returns t on "q", nil if there's nothing to save. So that's not useful :P
                                        ;                   ;; But if I press Esc, it quits and doesn't continue. Good, I guess.
                                        ;                   (save-some-buffers)
                                        ;                   (dolist (win (window-list frame))
                                        ;                     (with-selected-window win
                                        ;                       ;; You could (kill-buffer x) instead--but it would have a potential TOCTOU.
                                        ;                       (kill-buffer-if-not-modified (current-buffer))))
                                        ;                   (delete-frame frame)))))

;; Align the current prompt with the BOTTOM of the window.
;; That way the area before that prompt (which is the previous response) is maximized.
                                        ;(setq eshell-show-maximum-output t)

                                        ; better maybe: Add eshell-smart to eshell-modules-list
                                        ; that assumes that you keep editing existing commands because you got them wrong. I really don't. (add-to-list 'eshell-modules-list 'eshell-smart)

(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              (remove-if-not 'buffer-file-name (buffer-list)))))

;; Stop asking "Autosave file on local temporary directory, do you want to continue? (yes or no)" for files on remote hosts owned by root
;; This will just put the autosave files on that same host instead of localhost.
(setq auto-save-file-name-transforms nil)
                                        ; (setq tramp-auto-save-directory "~/emacs/tramp-autosave")

;; This is an lsp-ui workaround for <https://github.com/emacs-lsp/lsp-ui/issues/607>.
(let ((areas '("mode-line" "left-margin" "left-fringe" "right-fringe" "header-line" "vertical-scroll-bar" "tool-bar" "menu-bar"))
      loc)
  (while areas
    (setq loc (pop areas))
    (global-set-key
     (kbd (concat "<" loc "> <mouse-movement>")) #'ignore)))

;; Make the tab tooltip show the buffer file name.
(defun tab-line-tab-name-format-default (tab tabs)
  "Default function to use as `tab-line-tab-name-format-function', which see."
  (let* ((buffer-p (bufferp tab))
         (selected-p (if buffer-p
                         (eq tab (window-buffer))
                       (cdr (assq 'selected tab))))
         (name (if buffer-p
                   (funcall tab-line-tab-name-function tab tabs)
                 (cdr (assq 'name tab))))
         (face (if selected-p
                   (if (mode-line-window-selected-p)
                       'tab-line-tab-current
                     'tab-line-tab)
                 'tab-line-tab-inactive)))
    (dolist (fn tab-line-tab-face-functions)
      (setf face (funcall fn tab tabs face buffer-p selected-p)))
    (apply 'propertize
           (concat (propertize (string-replace "%" "%%" name) ;; (bug#57848)
                               'keymap tab-line-tab-map
                               'help-echo (let ((buffer (if buffer-p tab (cdr (assq 'buffer tab)))))
                                            (if selected-p
                                                (buffer-file-name buffer)
                                              (buffer-file-name buffer)))
                               ;; Don't turn mouse-1 into mouse-2 (bug#49247)
                               'follow-link 'ignore)
                   (or (and (or buffer-p (assq 'buffer tab) (assq 'close tab))
                            tab-line-close-button-show
                            (not (eq tab-line-close-button-show
                                     (if selected-p 'non-selected 'selected)))
                            tab-line-close-button)
                       ""))
           `(
             tab ,tab
             ,@(if selected-p '(selected t))
             face ,face
             mouse-face tab-line-highlight))))

;;; Keep unsaved state
(desktop-save-mode 1)
(setq desktop-restore-frames t) ; restore window configuration
(setq desktop-path '("~/.emacs.d/desktop/")) ; where to save desktop files
(setq desktop-auto-save-timeout 30) ; save desktop automatically every 30 seconds
(auto-save-visited-mode 1)
(setq desktop-save t) ; always save without asking

;; keyboard-shortcuts

(define-key global-map (kbd "M-g f" ) #'org-node-find)
(define-key org-mode-map (kbd "M-g M-l" ) #'org-node-insert-link)
(define-key global-map (kbd "M-g t") (lambda () (interactive) (
                                                               find-file "~/org-mode/todo.org")))

(define-key global-map (kbd "C-f" ) #'swiper)
(define-key wakib-keys-overriding-map (kbd "C-f") #'swiper-isearch) ; Note: someone overwrites this.

(add-hook 'git-commit-setup-hook #'my/generate-lisp-commit-message)

(keymap-set global-map "C-<f5>" `eval-region)
(keymap-set global-map "C-S-<escape>" `eshell)
(keymap-set global-map "C-<F5>" `eval-buffer)
(keymap-set wakib-keys-overriding-map "C-w" `bury-buffer)

(require 'minimap)
(require 'buffer-move)

-backend
(gptel-make-openai "llama-cpp"
  :stream t
  :protocol "http"
  :host "localhost:8080"
  :models '(llama))  ; Any names, doesn't matter for Llama

(setq gptel-model 'llama)
(setq gptel-default-mode 'org-mode)

                                        ; see also org-disputed-keys for CUA mode.
                                        ;(setq org-replace-disputed-keys t)

(setq-default line-spacing 0.2) ; compromise between Rust source code and org mode
;; TODO: Scala; PHP; C++; Kotlin; Swift
(add-hook 'perl-mode-hook #'form-feed-mode)
(add-hook 'python-mode-hook #'form-feed-mode)
(add-hook 'python-ts-mode-hook #'form-feed-mode)
(add-hook 'scheme-mode-hook #'form-feed-mode)
(add-hook 'lisp-mode-hook #'form-feed-mode)
(add-hook 'fortran-mode-hook #'form-feed-mode)
                                        ;(add-hook 'js-mode-hook #'form-feed-mode)
                                        ;(add-hook 'js-ts-mode-hook #'form-feed-mode)
(add-hook 'js-base-mode-hook #'form-feed-mode)
(add-hook 'c-ts-base-mode-hook #'form-feed-mode)
(add-hook 'ruby-mode-hook #'form-feed-mode)
(add-hook 'ruby-ts-mode-hook #'form-feed-mode)
(add-hook 'typescript-mode-hook #'form-feed-mode)
(add-hook 'typescript-ts-mode-hook #'form-feed-mode)
(add-hook 'java-mode-hook #'form-feed-mode)
(add-hook 'go-mode-hook #'form-feed-mode)
(add-hook 'go-ts-mode-hook #'form-feed-mode)
(add-hook 'go-mod-ts-mode-hook #'form-feed-mode)
(add-hook 'haskell-mode-hook #'form-feed-mode)
(add-hook 'csharp-mode-hook #'form-feed-mode)
(add-hook 'csharp-ts-mode-hook #'form-feed-mode)
(add-hook 'bash-ts-mode-hook #'form-feed-mode)
(add-hook 'objc-mode-hook #'form-feed-mode)
(add-hook 'rustic-mode-hook #'form-feed-mode)
(add-hook 'rust-mode-hook #'form-feed-mode)
(add-hook 'julia-mode-hook #'form-feed-mode)
(add-hook 'org-mode-hook #'form-feed-mode) ; looks weird and sometimes disappears on save
(add-hook 'elisp-mode-hook #'paredit-mode)
(add-hook 'scheme-mode-hook #'paredit-mode)

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

;; Don't bother user with emacs warnings
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

(use-package vertico
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Emacs minibuffer configurations.
(use-package emacs
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))


(use-package marginalia
  :ensure nil
  :hook (after-init . marginalia-mode))

;; Apparently doesn't do anything
(use-package orderless
  :ensure f
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrride nil))

(global-set-key (kbd "C-c r") 'gptel-rewrite-menu)
                                        ; gptel-add-file	 C-u gptel-send	 transient menu

                                        ;(add-hook 'vala-mode-hook #'lsp)  ;; Enable LSP for Vala mode
                                        ;(add-hook 'vala-mode-hook #'lsp-mode) ; disconnects immediately

;; DAP Python Configuration
                                        ;(with-eval-after-load 'dap-mode
                                        ;  (dap-register-debug-template "Python :: Uvicorn (FastAPI)"
                                        ;    (list :type "python"
                                        ;          :request "launch"
                                        ;          :name "Python :: Uvicorn (FastAPI)"
                                        ;          :program "${workspaceFolder}/main.py"  ;; Path to your FastAPI app
                                        ;          :args ["run" "main:app" "--reload" "--host" "127.0.0.1" "--port" "8000"]
                                        ;          :env (list (cons "PYTHONPATH" "${workspaceFolder}"))
                                        ;          :justMyCode t
                                        ;          :console "integratedTerminal")))

                                        ; (with-eval-after-load 'dap-mode
                                        ;   (dap-register-debug-template "Python :: Attach via port 5678"
                                        ;                                (list :type "python"
                                        ;                                      :request "attach"
                                        ;                                      :name "Python :: Attach to Running"
                                        ;                                      :hostName "127.0.0.1"  ;; Address of the Python process
                                        ;                                      :port 5678             ;; Port that debugpy is listening on
                                        ;                                         ; :justMyCode t          ;; Optional: Only debug your code, not external libraries
                                        ;                                      :env (list (cons "PYTHONPATH" "${workspaceFolder}"))
                                        ;                                      :console "integratedTerminal")))

                                        ;(which-key-setup-side-window-right-bottom)
(which-key-setup-side-window-bottom)


;; Display which-key keybindings in the right margin
                                        ;(setq which-key-side-window-location 'right) ; Set position to right margin
                                        ;(setq which-key-side-window-max-width 0.25)  ; Set maximum width of the side window (25% of the frame width)
                                        ; what? (setq which-key-side-window-slot -10)        ; Slot for side window
                                        ;(setq which-key-show-early-on-C-h t)         ; Show key hints when pressing C-h
                                        ;(setq which-key-idle-delay 0.5)              ; Delay before the keybindings show up
                                        ;(setq which-key-idle-secondary-delay 0.05)   ; Delay for showing secondary hints
;; Allow the margin window to take up multiple lines
                                        ;(setq which-key-side-window-multi-line-p t)   ; Allow multi-line keybindings
                                        ;(setq which-key-side-window-max-height 0.5)    ; Max height of the side window (50% of the frame height)

                                        ;(custom-set-faces
                                        ; '(which-key-key-face ((t (:foreground "yellow")))) ; Key face color
                                        ; '(which-key-command-description-face ((t (:foreground "green")))) ; Command description color
                                        ; '(which-key-group-description-face ((t (:foreground "cyan"))))) ; Group description color

                                        ; Eventually provided by manifest.scm
(setq lsp-clients-clangd-executable "ccls")

                                        ;(setq dired-launch-default-launcher '("xdg-open"))
(setf dired-launch-extensions-map
      '(("xlsx" ("libreoffice"))
        ("odt" ("libreoffice" "abiword"))))

(add-hook 'python-mode-hook 'eglot-ensure)
;; Tab Completion: Use company-mode for completion, integrating company-capf with eglot.
;; elpy or something.
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
(add-hook 'python-mode-hook 'flycheck-mode)
                                        ;(add-hook 'python-mode-hook (lambda () (add-to-list 'company-backends 'company-jedi)))

(require 'company-lsp)
(with-eval-after-load 'company
                                        ; (push 'company-robe company-backends)
  (push 'company-lsp company-backends))

(require 'vlf-setup) ; very large files

(projectile-register-project-type 'npm '("package.json")
                                  :project-file "package.json"
				  :compile "npm run build" ; or "npm install" or something
				  :test "npm test"
				  :run "npm start"
				  :test-suffix ".test")

;; Rails & RSpec
(projectile-register-project-type 'rails-rspec '("Gemfile") ; "app" "lib" "db" "config" "spec"
                                  :project-file "Gemfile"
                                  :compile "bundle exec rails server"
                                  :src-dir "lib/"
                                  :test "bundle exec rspec"
                                  :test-dir "spec/"
                                  :test-suffix "_spec")

(setq org-agenda-files '("~/org-mode/agenda"))
(setq org-agenda-file-regexp "\\`[^.].*\\.org\\'")

(defun fix-org-indent-form-feed ()
  "I'm using `org-indent-mode' together with `form-feed-mode': `org-indent-mode' interprets the form feed character as part of the previous section and indents it--which is not what I want.  I use the form feed for sections.  So the form feed should belong to no section."
  (setq-local org-outline-regexp "\\*+ \\|\\(^\f$\\)"))
(add-hook 'org-mode-hook #'fix-org-indent-form-feed)

;; See <https://www.naiquev.in/recurring-checklists-using-org-mode-in-emacs.html>.
(use-package org-contrib
  :ensure t
  :config
  (require 'org-checklist))


;; Doesn't work. Sigh.
                                        ;(defun fix-org-indent-form-feed ()
                                        ;  (setq-local org-heading-regexp "^\\(\f?\\*+\\)\\(?: +\\(.*?\\)\\)?[ 	]*$"))
                                        ;(add-hook 'org-mode-hook #'fix-org-indent-form-feed)

;; Skip flyspell on code blocks

                                        ; See https://endlessparentheses.com/ispell-and-org-mode.html
(defun endless/org-ispell ()
  "Configure `ispell-skip-region-alist' for `org-mode'."
  (make-local-variable 'ispell-skip-region-alist)
  (add-to-list 'ispell-skip-region-alist '(org-property-drawer-re))
  (add-to-list 'ispell-skip-region-alist '("~" "~"))
  (add-to-list 'ispell-skip-region-alist '("=" "="))
  (add-to-list 'ispell-skip-region-alist '("^#\\+BEGIN_SRC" . "^#\\+END_SRC")))
(add-hook 'org-mode-hook #'endless/org-ispell)

;;; Shortcuts for storing links, viewing the agenda, and starting a capture should work whereever you are.

;; "Queues" a link-to-point for later.
(define-key global-map (kbd "C-c m") 'org-store-link)
(define-key global-map (kbd "C-c a") 'org-agenda)
(define-key global-map (kbd "C-c c") 'org-capture)
                                        ; with-eval-after-load org wouldn't work!
(progn
  (define-key org-mode-map (kbd "<home>") #'move-beginning-of-line) ; ignored
  (define-key org-mode-map (kbd "<end>") #'move-end-of-line)
  (define-key org-mode-map (kbd "C-c <up>") #'org-priority-up)
  (define-key org-mode-map (kbd "C-c <down>") #'org-priority-down)
  ;; Inserts a link to a queued item into the current doc.
  (define-key org-mode-map (kbd "C-c l") #'org-insert-link)
  ;; When you want to change the level of an org item, use SMR
  (define-key org-mode-map (kbd "C-c C-g C-r") #'org-shiftmetaright))

(defun my/unset-line-move-visual ()
  "Fix up `org-mode' so it lets me have logical lines."
  (define-key org-mode-map [remap move-beginning-of-line] nil)
  (define-key org-mode-map [remap move-end-of-line] nil)
  (setq line-move-visual nil))

(add-hook 'org-mode-hook #'my/unset-line-move-visual)

                                        ;(with-eval-after-load 'web-mode ...)
(require 'lsp-mode)
(require 'lsp-volar)
(require 'lsp-vetur)
                                        ;(add-hook 'web-mode-hook #'lsp-vue-mmm-enable) ; missing.

(require 'web-mode)
(define-derived-mode genehack-vue-mode web-mode "ghVue"
  "A major mode derived from `web-mode', for editing .vue files with LSP support.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . genehack-vue-mode))
                                        ;(add-hook 'genehack-vue-mode-hook #'eglot-ensure)
(add-hook 'genehack-vue-mode-hook #'lsp)

(require 'mmm-auto)
(setq mmm-global-mode 'maybe)
(mmm-add-mode-ext-class 'html-mode "\\.php\\'" 'html-php)
                                        ; (mmm-add-mode-ext-class 'html-mode "\\.html\\'" 'html-js) ; maybe automatic?
                                        ;just modify mmm-mode-ext-classes-alist directly
                                        ;     (add-to-list 'mmm-mode-ext-classes-alist
                                        ;                  '(rpm-spec-mode "\\.spec\\'" rpm-sh))

                                        ; (require 'ox-publish)
                                        ; (setq org-publish-project-alist
                                        ;       '(("friendly-machines.com"
                                        ;          :base-directory "~/org-mode/"
                                        ;          :publishing-directory "~/friendly-machines.com/www/mirror/public/blog/"
                                        ;          :base-extension "org"
                                        ;          :recursive t
                                        ;          :publishing-function org-html-publish-to-html
                                        ;          :html-doctype "html5"
                                        ;          :with-toc nil
                                        ;          :section-numbers nil
                                        ;          :html-head "<link rel=\"stylesheet\" href=\"/css/org.css\" type=\"text/css\"/>"
                                        ;          :html-preamble nil
                                        ;          :html-postamble nil
                                        ;          :exclude ".*-private.org\\|.*-confidential.org\\|.*-internal.org"
                                        ;          :select-tags ("public"))))

(setq org-src-fontify-natively t)
                                        ; (setq org-confirm-babel-evaluate nil)

;; Disambiguate /home/user/project1/main.cpp and /home/user/project2/main.cpp
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(defun other-window-mru ()
  "Select the most recently used window on this frame."
  (interactive)
  (when-let ((mru-window
              (get-mru-window
               nil nil 'not-this-one-dummy)))
    (select-window mru-window)))

(keymap-global-set "M-o" 'other-window-mru)

                                        ; (when (daemonp)
                                        ;                                         ;(global-set-key (kbd "C-d C-c") 'handle-delete-frame-without-kill-emacs)
                                        ;                                         ;(define-key global-map [delete-frame] 'handle-delete-frame)
                                        ;   (define-key special-event-map [delete-frame]
                                        ;               (lambda (event)
                                        ;                 (interactive "e")
                                        ;                 (let ((frame (posn-window (event-start event))))
                                        ;                   (select-frame frame)
                                        ;                   ;; (save-some-buffers) returns t on "q", nil if there's nothing to save. So that's not useful :P
                                        ;                   ;; But if I press Esc, it quits and doesn't continue. Good, I guess.
                                        ;                   (save-some-buffers)
                                        ;                   (dolist (win (window-list frame))
                                        ;                     (with-selected-window win
                                        ;                       ;; You could (kill-buffer x) instead--but it would have a potential TOCTOU.
                                        ;                       (kill-buffer-if-not-modified (current-buffer))))
                                        ;                   (delete-frame frame)))))

;; Align the current prompt with the BOTTOM of the window.
;; That way the area before that prompt (which is the previous response) is maximized.
                                        ;(setq eshell-show-maximum-output t)

                                        ; better maybe: Add eshell-smart to eshell-modules-list
                                        ; that assumes that you keep editing existing commands because you got them wrong. I really don't. (add-to-list 'eshell-modules-list 'eshell-smart)

(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              (remove-if-not 'buffer-file-name (buffer-list)))))

;; Stop asking "Autosave file on local temporary directory, do you want to continue? (yes or no)" for files on remote hosts owned by root
;; This will just put the autosave files on that same host instead of localhost.
(setq auto-save-file-name-transforms nil)
                                        ; (setq tramp-auto-save-directory "~/emacs/tramp-autosave")

;; This is an lsp-ui workaround for <https://github.com/emacs-lsp/lsp-ui/issues/607>.
(let ((areas '("mode-line" "left-margin" "left-fringe" "right-fringe" "header-line" "vertical-scroll-bar" "tool-bar" "menu-bar"))
      loc)
  (while areas
    (setq loc (pop areas))
    (global-set-key
     (kbd (concat "<" loc "> <mouse-movement>")) #'ignore)))

(defun tab-line-tab-name-format-default (tab tabs)
  "Default function to use as `tab-line-tab-name-format-function'.  Show a tooltip with the full path if you hover on TAB, and show a window tool bar inside TAB."
  (let* ((buffer-p (bufferp tab))
         (selected-p (if buffer-p
                         (eq tab (window-buffer))
                       (cdr (assq 'selected tab))))
         (name (if buffer-p
                   (funcall tab-line-tab-name-function tab tabs)
                 (cdr (assq 'name tab))))
         (face (if selected-p
                   (if (mode-line-window-selected-p)
                       'tab-line-tab-current
                     'tab-line-tab)
                 'tab-line-tab-inactive)))
    (dolist (fn tab-line-tab-face-functions)
      (setf face (funcall fn tab tabs face buffer-p selected-p)))
    (apply 'propertize
           (concat (propertize (string-replace "%" "%%" name) ;; (bug#57848)
                               'keymap tab-line-tab-map
                               'help-echo (let ((buffer (if buffer-p tab (cdr (assq 'buffer tab)))))
                                            (if selected-p
                                                (buffer-file-name buffer)
                                              (buffer-file-name buffer)))
                               ;; Don't turn mouse-1 into mouse-2 (bug#49247)
                               'follow-link 'ignore)
                   (if selected-p (window-tool-bar-string) "")
                   (or (and (or buffer-p (assq 'buffer tab) (assq 'close tab))
                            tab-line-close-button-show
                            (not (eq tab-line-close-button-show
                                     (if selected-p 'non-selected 'selected)))
                            tab-line-close-button)
                       ""))
           `(
             tab ,tab
             ,@(if selected-p '(selected t))
             face ,face
             mouse-face tab-line-highlight))))

;;; Keep unsaved state
(desktop-save-mode 1)
(setq desktop-restore-frames t) ; restore window configuration
(setq desktop-path '("~/.emacs.d/desktop/")) ; where to save desktop files
(setq desktop-auto-save-timeout 30) ; save desktop automatically every 30 seconds
(auto-save-visited-mode 1)
(setq desktop-save t) ; always save without asking

;; keyboard-shortcuts

(define-key global-map (kbd "M-g f" ) #'org-node-find)
(define-key org-mode-map (kbd "M-g M-l" ) #'org-node-insert-link)
(define-key global-map (kbd "M-g t") (lambda () (interactive) (
                                                          find-file "~/org-mode/todo.org")))

(define-key global-map (kbd "C-f" ) #'swiper)
(define-key wakib-keys-overriding-map (kbd "C-f") #'swiper-isearch) ; Note: someone overwrites this.

(add-hook 'git-commit-setup-hook #'my/generate-lisp-commit-message)

(keymap-set global-map "C-<f5>" `eval-region)
(keymap-set global-map "C-S-<escape>" `eshell)
(keymap-set global-map "C-<F5>" `eval-buffer)
(keymap-set wakib-keys-overriding-map "C-w" `bury-buffer)

(setenv "PATH" (concat "/home/nomike/.config/guix/current/bin:" (getenv "PATH")))

(require 'minimap)
(require 'buffer-move)

;; OPTIONAL configuration
(setq gptel-model   'deepseek-reasoner
      gptel-backend (gptel-make-deepseek "DeepSeek"
                                         :stream t
                                         :key deepseek-api-key))

(global-auto-revert-mode 1)
(setq auto-revert-avoid-polling t)
