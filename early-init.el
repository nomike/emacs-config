
(add-to-list 'image-load-path (expand-file-name "~/.emacs.d/icons"))

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

;; TODO: Report bug with emacs upstream that org major mode (org.el) doesn't have menu items for org-insert-last-stored-link.

;; orgmode:
;; Install ‘cdlatex.el’ and ‘texmathp.el’ (the latter comes also with AUCTeX) from NonGNU ELPA with the Emacs packaging system or alternatively from https://staff.fnwi.uva.nl/c.dominik/Tools/cdlatex/.
;; Do not use CDLaTeX mode itself under Org mode, but use the special version Org CDLaTeX minor mode that comes as part of Org.
;(add-hook 'org-mode-hook #'turn-on-org-cdlatex)

;; Otherwise hidpi displays with small toolbar icons would have one HUGE icon fucking up the layout.
(defun tool-bar-setup ()
  (setq tool-bar-separator-image-expression
    (tool-bar--image-expression "separator"))
  nil)
