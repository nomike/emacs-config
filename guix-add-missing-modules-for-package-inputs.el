
(defun guix-add-missing-modules-for-package-inputs ()
  "Collect all (inputs ...) lists, find their modules via guix search, and format output."
  (interactive)
  (let ((inputs '())
        (module-regexp (concat (regexp-quote "location: gnu/packages/") "\\([^\\.]+\\)\\."))
        (guix-search-cmd "/home/nomike/.config/guix/current/bin/guix search '^%s$'"))
    (save-excursion
      (goto-char (point-min))
      ;; search for all inputs and native-inputs and store them in list
      (while (re-search-forward "(\\(native-\\)?inputs\\_>" nil t)
        (dolist (element (cdr (read (current-buffer))))
          (add-to-list 'inputs element)))
      (message "Found the following inputs: %s" (sort inputs #'string<))
      ;; loop over all found inputs, call =guix search= on each of them and parse the package module name out of it
      (let ((modules '()))
        (dolist (package inputs)
          (let ((foo (shell-command-to-string (format guix-search-cmd package)))
                (result nil)
                (module nil))
            (when (string-match module-regexp foo)
              (setq module (match-string 1 foo))
              (message "Found module: %s for package %s" module package)
              (add-to-list 'modules module))))
        ;; for each module, if it's not already used, add a use-line to the module definition
        (goto-char (point-min))
        (when (re-search-forward (regexp-quote "(define-module ") nil t)
          (forward-list)
          (dolist (module modules)
            (let ((point (point))
                  (use (format "#:use-module (gnu packages %s)" module)))
              (goto-char point)
              (unless (re-search-forward (regexp-quote (format "#:use-module (gnu packages %s)" module)) nil t)
                (insert (format "\n  %s" use))))))))))
