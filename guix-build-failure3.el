
(defun guix-ensure-drv-0-directory (dir)
  "Ensure the toplevel directory ends with drv-0, renaming if necessary."
  (interactive "DEnter directory path: ")
  (if (string-match "^/tmp/\\(guix-build-[^/]*\\)\\.drv-\\([0-9]+\\)\\(.*\\)" dir)
      (let* ((base (match-string 1 dir))
             (num (match-string 2 dir))
             (suffix (match-string 3 dir))
             (base-dir (format "/tmp/%s.drv-%s" base num)))
        (unless (string= num "0")
          (let* ((new-base-dir (format "/tmp/%s.drv-0" base))
                 (new-dir (format "/tmp/%s.drv-0%s" base suffix)))
            (when (and (file-exists-p base-dir)
                      (yes-or-no-p
                       (format "Delete existing directory %s? " new-base-dir)))
              (condition-case nil
                  (delete-directory new-base-dir t)
                (file-error nil)))
            (rename-file base-dir new-base-dir t))
            new-dir)))
    nil))

(defun my/guix-normalize-and-open-build-dir (path)
  "Normalize and open failed guix build directory."
  (interactive)
  (let ((dir (guix-ensure-drv-0-directory path)))
    (if dir
        (dired dir)
      nil)))

(add-hook 'compilation-mode-hook
          (lambda ()
            (add-to-list 'compilation-error-regexp-alist
                         '(guix-build-dir
                           "keeping build directory \'/tmp/guix-build-[^&#x27;]+\'"
                           1))))

(with-eval-after-load 'embark
  ;; Launch key.
  (define-key embark-file-map (kbd "d") #'my/guix-normalize-and-open-build-dir)
  ;(setf (alist-get 'my/normalize-and-open-nix-build-dir embark-keymap-prompter-key-list)
  ;'("normalize and open guix build dir"))
)
