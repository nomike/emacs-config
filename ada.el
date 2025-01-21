;; -*- lexical-binding: t -*-

; See <https://github.com/emacs-mirror/emacs/blob/master/lisp/progmodes/pascal.el>

(defconst ada-font-lock-keywords
  `(,(concat "\\_<\\("
             "abort\\|abs\\|accept\\|access\\|all\\|array\\|at\\|begin\\|body\\|case\\|constant\\|declare\\|delay\\|delta\\|digits\\|do\\|else\\|elsif\\|end\\|entry\\|exception\\|exit\\|for\\|function\\|generic\\|goto\\|if\\|in\\|is\\|limited\\|loop\\|mod\\|new\\|null\\|of\\|others\\|out\\|package\\|pragma\\|private\\|procedure\\|protected\\|raise\\|range\\|record\\|rem\\|renames\\|requeue\\|return\\|reverse\\|select\\|separate\\|subtype\\|tagged\\|task\\|terminate\\|then\\|type\\|until\\|use\\|when\\|while\\|with\\|xor"
             "\\)\\_>"))
  "Additional expressions to highlight in Ada mode.")

(define-derived-mode ada-mode prog-mode "Ada"
  "Major mode for Ada."
  ;(setq-local indent-line-function 'ada-indent-line)
  ;(setq-local comment-indent-function 'ada-indent-comment)
  (setq-local parse-sexp-ignore-comments nil)
  (setq-local blink-matching-paren-dont-ignore-comments t)
  (setq-local case-fold-search t)
  ; FIXME comment-start "--"
  (setq-local comment-start "{")
  (setq-local comment-start-skip "(\\*+ *\\|{ *")
  (setq-local comment-end "}")

  ;; Font locking
  (setq-local font-lock-defaults '(ada-font-lock-keywords nil t))
  ;(setq-local syntax-propertize-function ada--syntax-propertize)
)

;; For org-mode integration
;(add-to-list 'org-src-lang-modes '("ada" . ada))
