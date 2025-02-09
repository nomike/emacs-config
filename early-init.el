
;; TODO: Report bug with trashed upstream that this is missing.
(define-key global-map
  [menu-bar tools trashed]
  '("View trash" . trashed))

;; TODO: Report bug with gptel upstream that this is missing.
(define-key global-map
  [menu-bar tools gptel]
  '("Talk to Large Language Model" . gptel))

;; TODO: Report bug with osm upstream that this is missing.
(define-key global-map
  [menu-bar tools osm]
  '("View street map" . osm))

;; TODO: Report bug with emms upstream that this is missing.
(define-key global-map
  [menu-bar tools emms]
  '("Play music..." . emms))

;; TODO: Report bug with wttrin upstream that this is missing.
(define-key global-map
  [menu-bar tools wttrin]
  '("Check weather" . wttrin))

(define-key global-map
  [menu-bar tools maxima]
  '("Do computer algebra via Maxima" . maxima))

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
  (tool-bar-add-item-from-menu 'swiper-isearch "search"
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

  (let ((tool-bar-map (default-value 'tool-bar-map)))
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/ripgrep")
                       #'consult-ripgrep
                       'consult-ripgrep :label ""
                       :help "Consult ripgrep...")

    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/embark-act")
                       #'embark-act
                       'embark-act :label ""
                       :help "Embark act")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/magit")
                       #'magit
                       'magit :label ""
                       :help "Magit (git)")
                       )

  (define-key-after (default-value 'tool-bar-map) [separator-4] menu-bar-separator)
  
  ;;; org
  (let ((tool-bar-map (default-value 'tool-bar-map)))
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-store-link")
                       #'org-store-link
                       'org-store-link :label ""
                       :help "Store Org link")
    ; Subsumed by org-node-find for my workflow!
    ;(tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-capture")
    ;                   #'org-capture
    ;                   'org-capture :label ""
    ;                   :help "Capture Org node...")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-capture")
                       #'org-node-find
                       'org-node-find :label ""
                       :help "Find or make Org node...")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-node-grep")
                       #'org-node-grep
                       'org-node-grep :label ""
                       :help "Grep Org node...")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-agenda")
                       #'org-agenda
                       'org-agenda :label ""
                       :help "Show Org agenda..."))
  (define-key-after (default-value 'tool-bar-map) [separator-5] menu-bar-separator)
  (let ((tool-bar-map (default-value 'tool-bar-map)))
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/mu4e")
                       #'mu4e
                       'mu4e :label ""
                       :help "Mu4e (Mail)")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/elfeed")
                       #'elfeed
                       'elfeed :label ""
                       :help "Elfeed (RSS)")
    (tool-bar-add-item-from-menu 'gptel "gptel" nil :label "Talk to LLM" :vert-only t)
    (tool-bar-add-item-from-menu 'osm "osm" nil :label "View street map" :vert-only t)
    (tool-bar-add-item-from-menu 'emms "emms" nil :label "Play music..." :vert-only t)))
