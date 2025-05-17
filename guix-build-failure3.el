
(defun guix-build-dir-p (target)
  "Return non-nil if TARGET appears to be a Guix build directory path."
  (and (stringp target)
       (string-match-p "^/tmp/guix-build-[^/]*\\.drv-[0-9]+" target)))

(defun guix-ensure-drv-0-directory (dir)
  "Ensure the toplevel directory ends with drv-0, renaming if necessary."
  (interactive "DEnter directory path: ")
  (if (string-match "^/tmp/\\(guix-build-[^/]*\\)\\.drv-\\([0-9]+\\)\\(.*\\)" dir)
      (let* ((base (match-string 1 dir))
             (num (match-string 2 dir))
             (suffix (match-string 3 dir))
             (base-dir (format "/tmp/%s.drv-%s" base num)))
        (if (string= num "0")
            base-dir
          (let* ((new-base-dir (format "/tmp/%s.drv-0" base))
                 (new-dir (format "/tmp/%s.drv-0%s" base suffix)))
            (when (and (file-exists-p base-dir)
                       (yes-or-no-p
                        (format "Delete existing directory %s? " new-base-dir)))
              (condition-case nil
                  (delete-directory new-base-dir t)
                (file-error nil)))
            (rename-file base-dir new-base-dir t)
            new-dir)))
    nil))

(defun guix-normalize-and-open-build-dir (path)
  "Normalize and open failed guix build directory."
  (interactive "DEnter directory path:")
  (let ((path (thing-at-point 'filename t)))
    (let ((dir (guix-ensure-drv-0-directory path)))
      (if dir
          (let ((treemacs-follow-mode nil))
            (dired dir))
        nil))))

;; First, define the regexp pattern
(defvar guix-build-dir-regexp
  '(guix-build-dir
    "note: keeping build directory \`\\(/tmp/guix-build-[^&#x27;]+\\)\'"
    1))

;; Then add the symbol to compilation-error-regexp-alist
(add-hook 'compilation-mode-hook
          (lambda ()
            (add-to-list 'compilation-error-regexp-alist 'guix-build-dir)
            (add-to-list 'compilation-error-regexp-alist-alist guix-build-dir-regexp)))

;; Launch key.
(with-eval-after-load 'embark
  (add-to-list 'embark-target-finders
               (lambda ()
                 (when (and (eq major-mode 'compilation-mode)
                            (thing-at-point 'filename))
                   (let ((file (thing-at-point 'filename t)))
                     (when (guix-build-dir-p file)
                       `(guix-build-dir . ,file))))))

  ;; Create a keymap specifically for Guix build directories
  (defvar-keymap embark-guix-build-dir-map
    :doc "Keymap for actions on Guix build directories."
    "d" (lambda (path)
          "Normalize and open failed guix build directory."
          (message "PPP %S\n" path)
          (guix-normalize-and-open-build-dir path)))

  (add-to-list 'embark-keymap-alist
               '(guix-build-dir . embark-guix-build-dir-map))
                                        ;(define-key embark-file-map (kbd "d") #'my/guix-normalize-and-open-build-dir)
                                        ;(setf (alist-get 'my/normalize-and-open-nix-build-dir embark-keymap-prompter-key-list)
                                        ;'("normalize and open guix build dir"))
  )
