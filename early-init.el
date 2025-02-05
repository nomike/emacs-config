
(defun tool-bar-setup ()
  (setq tool-bar-separator-image-expression
    (tool-bar--image-expression "separator"))
  (tool-bar-add-item-from-menu 'find-file "new" nil :label "New File"
                   :vert-only t)
  (tool-bar-add-item-from-menu 'menu-find-file-existing "open" nil
                   :label "Open" :vert-only t)
  ; too big (tool-bar-add-item-from-menu 'dired "diropen" nil :vert-only t)
  (tool-bar-add-item-from-menu 'kill-this-buffer "close" nil :vert-only t)
  (tool-bar-add-item-from-menu 'save-buffer "save" nil
                   :label "Save")
  (define-key-after (default-value 'tool-bar-map) [separator-1] menu-bar-separator)
  (tool-bar-add-item-from-menu 'undo "undo" nil)
  (define-key-after (default-value 'tool-bar-map) [separator-2] menu-bar-separator)
  (tool-bar-add-item-from-menu (lookup-key menu-bar-edit-menu [cut])
                   "cut" nil :vert-only t)
  (tool-bar-add-item-from-menu (lookup-key menu-bar-edit-menu [copy])
                   "copy" nil :vert-only t)
  (tool-bar-add-item-from-menu (lookup-key menu-bar-edit-menu [paste])
                   "paste" nil :vert-only t)
  (define-key-after (default-value 'tool-bar-map) [separator-3] menu-bar-separator)
  (tool-bar-add-item-from-menu 'isearch-forward "search"
                   nil :label "Search" :vert-only t)
  ;;(tool-bar-add-item-from-menu 'ispell-buffer "spell")

  ;; There's no icon appropriate for News and we need a command rather
  ;; than a lambda for Read Mail.
  ;;(tool-bar-add-item-from-menu 'compose-mail "mail/compose")

  ;; Help button on a tool bar is rather non-standard...
  ;; (let ((tool-bar-map (default-value 'tool-bar-map)))
  ;;   (tool-bar-add-item "help" (lambda ()
  ;;                (interactive)
  ;;                (popup-menu menu-bar-help-menu))
  ;;               'help
  ;;               :help "Pop up the Help menu"))

  (define-key-after (default-value 'tool-bar-map) [separator-4] menu-bar-separator)
  ;;; org
  (let ((tool-bar-map (default-value 'tool-bar-map)))
    (tool-bar-add-item "ezimage/tag-plus" (lambda () (interactive) (org-capture)) 'org-capture :help "Capture Org node...")
    (tool-bar-add-item "jump-to" (lambda () (interactive) (org-node-find)) 'org-node-find :help "Find Org node...")
    (tool-bar-add-item "connect" (lambda () (interactive) (org-store-link)) 'org-store-link :help "Store Org link")
    (tool-bar-add-item "mpc/play" (lambda () (interactive) (org-agenda)) 'org-agenda :help "Show Org agenda")
))
