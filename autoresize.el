;; -*- lexical-binding: t -*-

(defcustom document-window-max-width 120
  "Maximum width in characters for PDF/DocView windows."
  :type 'integer
  :group 'pdf-tools)

(defun document-window-enforce-max-width ()
  "Scale window width so image fits window height exactly."
  (interactive)
  (when (and (memq major-mode '(pdf-view-mode doc-view-mode))
             (or (and (eq major-mode 'pdf-view-mode) (pdf-view-current-image))
                 (and (eq major-mode 'doc-view-mode) (doc-view-current-slice))))
    (let* ((window (selected-window))
           (image-size (if (eq major-mode 'pdf-view-mode)
                           (pdf-view-image-size)
                         (image-size (doc-view-current-image))))
           (image-width (car image-size))
           (image-height (cdr image-size))
           (window-height (window-body-height window t))
           (current-width (window-body-width window t))
           (target-width (floor (* image-width (/ (float window-height) image-height))))
           (max-width (* document-window-max-width (frame-char-width)))
           (final-width (min target-width max-width))
           (delta (- final-width current-width 5))) ; 5: fudge term
      (when (> image-height window-height)  ; Only resize if image is too big
        (message "Current width: %d, Target width: %d, Delta: %d pixels"
                 current-width target-width delta)
        ;; window-resize arguments:
        ;; WINDOW - the window to resize
        ;; DELTA  - the size change in pixels (positive=grow, negative=shrink)
        ;; HORIZONTAL - t means adjust width, nil means adjust height
        ;; ALL - t means adjust all windows in this direction
        ;; PIXELWISE - t means use pixels instead of columns/rows
        (window-resize window delta t t t)))))

(add-hook 'pdf-view-after-change-page-hook #'document-window-enforce-max-width)
(add-hook 'doc-view-after-change-page-hook #'document-window-enforce-max-width)

(defvar-local window-resizing-in-progress nil
  "Guard against recursive window resizing.")

(add-hook 'window-configuration-change-hook
          (lambda ()
            (unless window-resizing-in-progress
              (setq window-resizing-in-progress t)
              (unwind-protect
                  (document-window-enforce-max-width)
                (setq window-resizing-in-progress nil)))))
