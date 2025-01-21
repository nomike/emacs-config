;; -*- lexical-binding: t -*-

;; Enable syntax highlighting for `.myext` files
(add-to-list 'auto-mode-alist '("\\.sipf\\'" . prog-mode))
(add-to-list 'auto-mode-alist '("\\.cif\\'" . prog-mode))
(add-to-list 'auto-mode-alist '("\\.j\\'" . prog-mode))
(add-to-list 'auto-mode-alist '("\\.tst\\'" . prog-mode))
(add-to-list 'auto-mode-alist '("\\.grid\\'" . prog-mode))

;; Add custom syntax highlighting directly
(add-hook 'prog-mode-hook
          (lambda ()
            (when (string-match "\\.sipf\\'" (buffer-name))
              (font-lock-add-keywords
               nil
               '(("#.*$" . font-lock-comment-face)
                 ("\"[^\"]*\"" . font-lock-string-face))))
            (when (string-match "\\.cif\\'" (buffer-name))
              (font-lock-add-keywords
               nil
               '(("#.*$" . font-lock-comment-face)
                 ("\"[^\"]*\"" . font-lock-string-face))))
            (when (string-match "\\.tst\\'" (buffer-name))
              (font-lock-add-keywords
               nil
               '(("#.*$" . font-lock-comment-face)
                 ("\"[^\"]*\"" . font-lock-string-face))))
            (when (string-match "\\.grid\\'" (buffer-name))
              (font-lock-add-keywords
               nil
               '(("#.*$" . font-lock-comment-face)
                 ("\"[^\"]*\"" . font-lock-string-face))))
            (when (string-match "\\.j\\'" (buffer-name))
              (font-lock-add-keywords
               nil
               '(("#.*$" . font-lock-comment-face)
                 ("\"[^\"]*\"" . font-lock-string-face))))))

;(defun open-java-view (file)
;  "Open a .jvx file with JavaView external application."
;  (interactive "fSelect .jvx file: ")
;  (start-process "javaview" nil "/home/dannym/src/mcphas/wrapper/javaview" file))
;(add-to-list 'auto-mode-alist '("\\.jvx\\'" . open-java-view))

; TODO: .fum* .hkl .cf
