;;; Keep unsaved state
(desktop-save-mode 1)
(setq desktop-restore-frames t) ; restore window configuration
(setq desktop-path '("~/.emacs.d/desktop/")) ; where to save desktop files
(setq desktop-auto-save-timeout 30) ; save desktop automatically every 30 seconds
(auto-save-visited-mode 1)
(setq desktop-save t) ; always save without asking

;; keyboard-shortcuts

(define-key global-map (kbd "M-g f" ) #'org-node-find)
(define-key org-mode-map (kbd "M-g M-l" ) #'org-node-insert-link)
(define-key global-map (kbd "M-g t") (lambda () (interactive) (
                                                          find-file "~/org-mode/todo.org")))

(define-key global-map (kbd "C-f" ) #'swiper)
(define-key wakib-keys-overriding-map (kbd "C-f") #'swiper-isearch) ; Note: someone overwrites this.

(add-hook 'git-commit-setup-hook #'my/generate-lisp-commit-message)

(keymap-set global-map "C-<f5>" `eval-region)
(keymap-set global-map "C-S-<escape>" `eshell)
(keymap-set global-map "C-<F5>" `eval-buffer)
(keymap-set wakib-keys-overriding-map "C-w" `bury-buffer)

(setenv "PATH" (concat "/home/nomike/.config/guix/current/bin:" (getenv "PATH")))

(require 'minimap)
(require 'buffer-move)

;; OPTIONAL configuration
(setq gptel-model   'deepseek-reasoner
      gptel-backend (gptel-make-deepseek "DeepSeek"
                                         :stream t
                                         :key "sk-298dadffa5784d0dbd028d247ef81dfe"))

(global-auto-revert-mode 1)
(setq auto-revert-avoid-polling t)
