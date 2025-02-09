
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

(defun tool-bar-setup ()
  (setq tool-bar-separator-image-expression
    (tool-bar--image-expression "separator"))
  nil)
