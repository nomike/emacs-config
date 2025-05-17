;; -*- lexical-binding: t -*-
(require 'seq)
(defun menu-item-exists-p (command)
  "Check if a menu item exists for the given COMMAND in the specified MENUS.
If MENUS is not provided, the function searches through all menus in the menu bar."

  (let ((result (seq-filter (lambda (item)
                              (and (vectorp item) (eq 'menu-bar (elt item 0))))
                            (where-is-internal command overriding-local-map nil nil))))
    (if (> (length result) 0)
        (progn
          (print "menu bar")
          (princ result)
          (print "\n")
          t)
      nil)))

(defun detour (group)
  (pcase group
                                        ;("flycheck" [menu-bar flycheck])
                                        ;("vc" [menu-bar tools vc]) ; existing menu cannot be adapted
                                        ;("magit" [menu-bar tools vc]) ; existing menu cannot be adapted
                                        ; [menu-bar file]
                                        ;("elisp" [menu-bar lisp-interaction]) ; existing menu cannot be adapted since it disappears often
    ("describe" [menu-bar help-menu describe]) ; ok
                                        ; ([menu-bar edit goto go-to-line])
                                        ; [menu-bar tools project]
                                        ; ([menu-bar file project-dired] [menu-bar tools project project-dired])

    (_ nil)
    ))


(defun group-commands-by-first-word ()
  "Group Emacs commands by the first word of their names."
  (let ((groups (make-hash-table :test 'equal))
        (detours (make-hash-table :test 'equal)))
    (mapatoms
     (lambda (sym)
       (when (and (commandp sym)              ; Check if it's a command
                  (not (eq sym 'undefined))  ; Exclude undefined commands
                  (not (string-prefix-p "menu-" (symbol-name sym)))  ; Exclude menu commands
                  (null (search "--" (symbol-name sym))) ; Exclude private commands
                  (let ((keys (where-is-internal sym overriding-local-map t)))
                    (and keys (not (eq keys nil)))))  ; Check if it has key bindings
         (let* ((keys (where-is-internal sym overriding-local-map t))
                (key (key-description keys))
                (name (symbol-name sym))
                (group (car (split-string name "-"))))
           (if (menu-item-exists-p sym)
               (progn
                 (print "skip")
                 (princ sym)
                 (print "\n"))
             (progn
               (print "push")
               (princ sym)
               (print "\n")
               (push sym (gethash group groups))))))))
    groups))

                                        ; compose-mail

(defun drop-prefix (needle haystack)
  (if (> (length haystack) (length needle))
      (substring haystack (+ 1 (length needle)))
    haystack))

(defun lookup-function (keymap func)
  "Given a function symbol, finds the keybinding for it."
  (let ((all-bindings (where-is-internal (if (symbolp func)
                                             func
                                           (cl-first func))
                                         keymap))
        keys key-bindings)
    (dolist (binding all-bindings)
      (when (and (vectorp binding)
                 (integerp (aref binding 0)))
        (push binding key-bindings)))
    (push (mapconcat #'key-description key-bindings " or ") keys)
    (car keys)))

;; total result: Missing menus for Xref, Lsp, Project, Bookmark, Kmacro, Rustic, Vc, Describe, Tab, Find, Set, Magit, Org, Flycheck, Hi-lock
(defun unbreak ()
  "Create toolbar items for groups of Emacs commands."
  (interactive)
  (let ((groups (group-commands-by-first-word)))
                                        ;(princ groups)
                                        ;(print "\n")
    (maphash
     (lambda (group commands)
       (unless (member group '("cycle" "shrink" "end" "next" "scroll" "downcase" "forward" "complete" "highlight" "unhighlight" "mouse" "delete" "backward"
                               "inverse" "save" "comment" "rename" "display" "copy" "beginning" "list" "font" "recenter" "frameset" "reposition" "same"
                               "enlarge" "eval" "yank" "buffer" "upcase" "handle" "default" "other" "insert" "mark" "revert" "capitalize"

                                        ; compose-mail
                               "compose"
                               "expand"
                               "pgtk"
                               "overwrite"
                               "text"
                               "2C" ; from 2C-command https://www.gnu.org/software/emacs/manual/html_node/emacs/Two_002dColumn.html
                               "kill"
                               "universal"
                               "isearch"
                               "switch"
                               "widen"
                               "add"
                               "search"
                               "async"
                               "ignore"
                               "narrow"
                               "count"
                               "execute"
                                        ; electric-newline-*
                               "electric"
                               "dired"
                               "help"
                               "newline"
                               "finder" ; ???
                               "rectangle" ; rectangle-mark-mode
                               "abort"
                               "apropos"
                               "self"
                               "shell" ; ??
                               "toggle"
                               "suspend"
                               "left"
                               "right"
                               "keyboard"
                               "undo"
                               "point"
                               "about"
                               "move"
                               "window" ; window-toggle-side-windows
                               "open" ; open-line, open-rectangle
                               "make"
                               "repeat"
                               "quoted" ; quoted-insert AHA
                               "query" ; query-replace
                               "calc"
                               "view"
                               "occur"
                               "digit"
                               "zap" ; zap-to-char
                                        ;"indent" ; !!
                               "info"
                               "Info"
                               "where" ; where-is
                               "activate" ; activate-transient-input-method
                               "back" ; back-to-indentation
                               "append" ; append-next-kill
                               "exchange" ; exchange-point-and-mark
                               "write" ; write-file
                               "undelete" ; undelete-frame
                               "tear"
                                        ;"goto" ; !!!
                               "previous"
                               "not"
                               "eww" ; eww-search-words
                               "fill" ; fill-paragraph
                               "balance" ; balance-windows
                               "string" ; string-rectangle
                               "down" ; down-list
                               "abbrev" ; abbrev-prefix-mark
                               "exit" ; exit-recursive-edit
                               "number" ; number-to-register
                               "fit" ; fit-window-to-buffer
                               "context" ; context-menu-open
                               "global" ; global-text-scale-adjust
                               "pop" ; pop-global-mark
                               "what" ; what-cursor-position
                               "increment" ; increment-register
                               "imenu"
                               "jump" ; jump-to-register
                               "negative" ; negative-argument
                               "ispell" ; ispell-word
                               "clear" ; clear-rectangle
                               "kbd"
                               "apply"
                               "dabbrev"

                               "mwheel"
                               "cua"

                               "goto" ; goto-line-relative

                               "clone" ; hmm
                               "transpose" ; hmm

                                        ;"yas" ; we have a menu
                               "split"
                                        ;"elisp" ; we have a menu, kinda

                               ;; Debugger

                               "dap" ; only mouse move etc
                                        ; "gud" ; annoying but maybe useful ; gud-watch, gud-refresh
                                        ;"vc" ; see "Tools" menu.

                                        ;"describe" ; see "Help" / "Describe"

                               "hi" ; hi-lock-*, seems to do nothing
                               "tmm" ; tmm-menubar (keyboard centric)

                                        ; "flycheck" ; see "Tools" / "Syntax Checking"; but not everything is there.
                               ))
         (when (> (length commands) 1)
           (let ((detour-menu (detour group)))
             (if detour-menu ; existing menu
                 (progn
                   (mapc (lambda (command)
                           (print "DETOUR ")
                           (princ command)
                           (princ (vconcat detour-menu `[,command]))
                           (print "\n")
                           (define-key-after global-map (vconcat detour-menu `[,command])
                             (cons (concat (capitalize (replace-regexp-in-string "-" " " (symbol-name command))) " (default)") command)))
                         commands)
                   )
               (let ((default-menu `[menu-bar ,(intern (concat "menu-def-" group))]))

                 (progn
                   (define-key-after global-map default-menu
                     (cons (concat "" group) (make-sparse-keymap group)))
                   (mapc (lambda (command)
                           (define-key-after global-map (vconcat default-menu `[,command])

                             (let* ((command-name (drop-prefix group (symbol-name command)))
                                    (doc (documentation command))
                                    (menu-label (capitalize (replace-regexp-in-string "-" " " command-name))))
                               `(menu-item ,menu-label ,command :help ,doc))))
                         commands))))))

         (when (= (length commands) 1)
                                        ; See <https://www.gnu.org/software/emacs/manual/html_node/elisp/Defining-Images.html>
           (let* ((command-symbol (car commands))
                  (keybinding (lookup-function (current-global-map) command-symbol))
                  (keybinding (if (and keybinding
                                       (> (length keybinding) 0))
                                  (concat "\n\nKeybinding: " keybinding) keybinding)))
             (tool-bar-add-item
              "index"
              (lambda ()
                (interactive)
                (call-interactively (car commands)))
              (car commands)
                                        ;nil
              :label (capitalize (replace-regexp-in-string "-" " " (symbol-name (car commands))))
              :help (concat (documentation (car commands)) keybinding)
                                        ;:enable (lambda () t)
              )))))
     groups)))

(defun find-single-word-commands ()
  "Find and display all M-x commands that don't contain hyphens."
  (interactive)
  (let ((commands '())
        (buffer (get-buffer-create "*Single Word Commands*")))
    ;; Collect all commands without hyphens
    (mapatoms
     (lambda (symbol)
       (when (and (commandp symbol)
                  (not (string-match-p "-" (symbol-name symbol))))
         (push (symbol-name symbol) commands))))
    
    ;; Sort commands alphabetically
    (setq commands (sort commands 'string<))
    
    ;; Display results in a buffer
    (with-current-buffer buffer
      (erase-buffer)
      (insert "Commands without hyphens:\n\n")
      (dolist (cmd commands)
        (insert cmd "\n"))
      (goto-char (point-min)))
    
    ;; Display the buffer
    (display-buffer buffer)
    (message "Found %d commands without hyphens" (length commands))))
