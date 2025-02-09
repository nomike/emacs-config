

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

;; TODO: Report bug with emacs upstream that this is missing.
(define-key global-map
  [menu-bar tools maxima]
  '("Do computer algebra via Maxima" . maxima))

(defun tool-bar-setup ()
  (setq tool-bar-separator-image-expression
    (tool-bar--image-expression "separator"))
  (tool-bar-add-item "search"
                       #'swiper-isearch
                       'swiper-isearch :label "swiper-isearch"
                       :help "Swiper-isearch...")

  ;(tool-bar-add-item-from-menu 'isearch-forward "search"
  ;                 nil :label "Search" :vert-only t)
  ;;(tool-bar-add-item-from-menu 'ispell-buffer "spell")

  (let ((tool-bar-map (default-value 'tool-bar-map)))
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/ripgrep")
                       #'consult-ripgrep
                       'consult-ripgrep :label "consult-ripgrep"
                       :help "Consult ripgrep...")

    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/embark-act")
                       #'embark-act
                       'embark-act :label "embark-act"
                       :help "Embark act")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/magit")
                       #'magit
                       'magit :label "magit"
                       :help "Magit (git)")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-store-link")
                       #'org-store-link
                       'org-store-link :label "org-store-link"
                       :help "Store Org link")
    (define-key-after tool-bar-map [separator-2] menu-bar-separator)
    ; Subsumed by org-node-find for my workflow!
    ;(tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-capture")
    ;                   #'org-capture
    ;                   'org-capture :label "org-capture"
    ;                   :help "Capture Org node...")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-capture")
                       #'org-node-find
                       'org-node-find :label "org-node-find"
                       :help "Find or make Org node...")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-node-grep")
                       #'org-node-grep
                       'org-node-grep :label "org-node-grep"
                       :help "Grep Org node...")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/org-agenda")
                       #'org-agenda
                       'org-agenda :label "org-agenda"
                       :help "Show Org agenda...")))

;; Global version.
(defun qtool-bar-setup ()
  (setq tool-bar-separator-image-expression
    (tool-bar--image-expression "separator"))
  (tool-bar-add-item-from-menu 'swiper-isearch "search"
                   nil :label "Search" :vert-only t)
  ;;(tool-bar-add-item-from-menu 'ispell-buffer "spell")

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
                       :help "Show Org agenda...")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/mu4e")
                       #'mu4e
                       'mu4e :label ""
                       :help "Mu4e (Mail)")
    (tool-bar-add-item (expand-file-name "~/.emacs.d/icons/elfeed")
                       #'elfeed
                       'elfeed :label ""
                       :help "Elfeed (RSS)")
)
