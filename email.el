
(setq message-send-mail-function 'smtpmail-send-it)

(setq mu4e-get-mail-command "offlineimap"
      mu4e-maildir (expand-file-name "~/Mail")
      mu4e-update-interval 180
      message-kill-buffer-on-exit t
      mu4e-headers-skip-duplicates t
      mu4e-compose-signature-auto-include nil
      mu4e-view-show-images t
      mu4e-view-show-addresses t
      mu4e-attachment-dir "~/Downloads"
      mu4e-use-fancy-chars t
      mu4e-headers-auto-update t
      message-signature-file "~/.emacs.d/.signature"
      mu4e-compose-signature-auto-include nil
      mu4e-view-prefer-html t
      mu4e-compose-in-new-frame t
      mu4e-change-filenames-when-moving t
                                        ;message-send-mail-function 'smtpmail-send-it
      starttls-use-gnutls t
      smtpmail-stream-type 'starttls
      ;;mu4e-html2text-command "w3m -T text/html"
      )

(require 'mu4e-context)

(setq mu4e-context-policy 'pick-first)
(setq mu4e-compose-context-policy 'always-ask)
(setq mu4e-contexts
      (list
       (make-mu4e-context
        :name "scratchpost.org"
        :enter-func (lambda () (mu4e-message "Entering scratchpost.org context"))
        :leave-func (lambda () (mu4e-message "Leaving scratchpost.org context"))
        :match-func (lambda (msg)
                      (when msg
                        (mu4e-message-contact-field-matches
                         msg '(:from :to :cc :bcc) "dannym@scratchpost.org")))
        :vars '((user-mail-address . "dannym@scratchpost.org")
                                        ; from passwd (user-full-name . "Danny Milosavljevic")
                (mu4e-sent-folder . "/scratchpost.org/sent")
                (mu4e-drafts-folder . "/scratchpost.org/drafts")
                (mu4e-trash-folder . "/scratchpost.org/trash")
                (mu4e-refile-folder . "/scratchpost.org/Archives")
                                        ;(smtpmail-queue-dir . "~/.email/gmail/queue/cur")
                                        ;(smtpmail-smtp-user . "mail@xxx.com")
                                        ;(smtpmail-starttls-credentials . (("mail.xxx.com" 587 nil nil)))
                                        ;(smtpmail-auth-credentials . (expand-file-name "~/.authinfo.gpg"))
                                        ;(smtpmail-default-smtp-server . "mail.xxx.com")
                                        ;(smtpmail-smtp-server . "mail.xxx.com")
                                        ;(smtpmail-smtp-service . 587)
                (mu4e-get-mail-command . "offlineimap -a dannym@scratchpost.org")
                (mu4e-sent-messages-behavior . sent)
                (send-mail-function . 'smtpmail-send-it)
                (smtpmail-smtp-server . "smtp.scratchpost.org")
                (smtpmail-stream-type . 'starttls)
                (smtpmail-smtp-service . 587)
                (mu4e-maildir-shortcuts . ( ("/scratchpost.org/inbox" . ?i)
                                            ("/scratchpost.org/sent" . ?s)
                                            ("/scratchpost.org/trash" . ?t)
                                            ("/scratchpost.org/archives" . ?a)
                                            ("/scratchpost.org/drafts" . ?d)
                                            ("/scratchpost.org/Apartment" . ?p)
                                            ("/scratchpost.org/Learning" . ?l)
                                            ("/scratchpost.org/Astronomie_Uni" . ?u)
                                            ("/scratchpost.org/TU_work" . ?w)
                                            ("/scratchpost.org/Incoming-Invoice" . ?v)
                                            ("/scratchpost.org/Software" . ?s)
                                            ("/scratchpost.org/Software/mes" . ?m)
                                            ("/scratchpost.org/Software/mes/tinycc" . ?c)
                                            ("/scratchpost.org/Software/Oxide" . ?o)
                                            ("/scratchpost.org/Software/bootstrappable" . ?b)
                                            ("/scratchpost.org/Gesundheit" . ?g)
                                            ("/scratchpost.org/Social" . ?i)
                                            ("/scratchpost.org/Profession" . ?f)
                                            ("/scratchpost.org/Hardware" . ?h)
                                            ("/scratchpost.org/Hardware/A20" . ?a)
                                            ("/scratchpost.org/Science" . ?s)
                                            ("/scratchpost.org/News" . ?w)))))

       (make-mu4e-context
        :name "friendly-machines.com"
        :enter-func (lambda () (mu4e-message "Entering friendly-machines.com context"))
        :leave-func (lambda () (mu4e-message "Leaving friendly-machines.com context"))
        :match-func (lambda (msg)
                      (when msg
                        (mu4e-message-contact-field-matches
                         msg '(:from :to :cc :bcc) "dannym@friendly-machines.com")))
        :vars '((user-mail-address . "dannym@friendly-machines.com")
                                        ; from passwd (user-full-name . "Danny Milosavljevic")
                (mu4e-sent-messages-behavior . sent)
                (send-mail-function . 'smtpmail-send-it)
                (smtpmail-smtp-server . "mail.friendly-machines.com")
                (smtpmail-stream-type . 'starttls)
                (smtpmail-smtp-service . 587)
                                        ;(smtpmail-auth-credentials . (expand-file-name "~/.authinfo.gpg"))
                (mu4e-sent-folder . "/friendly-machines.com/sent")
                (mu4e-drafts-folder . "/friendly-machines.com/drafts")
                (mu4e-trash-folder . "/friendly-machines.com/trash")
                (mu4e-refile-folder . "/friendly-machines.com/Archives")
                (mu4e-get-mail-command . "offlineimap -a dannym@friendly-machines.com")

                (mu4e-maildir-shortcuts . ( ("/friendly-machines.com/inbox" . ?i)
                                            ("/friendly-machines.com/sent" . ?s)
                                            ("/friendly-machines.com/trash" . ?t)
                                            ("/friendly-machines.com/archives" . ?a)
                                            ("/friendly-machines.com/drafts" . ?d)
                                            ("/friendly-machines.com/Project" . ?p)
                                            ("/friendly-machines.com/Research" . ?r)
                                            ("/friendly-machines.com/Work" . ?w)
                                            ("/friendly-machines.com/Important" . ?i)))))))

(setq mu4e-change-filenames-when-moving t)

(setq mu4e-view-show-images t)
(setq mu4e-view-show-addresses t)

                                        ;(defvar my-mu4e-account-alist
                                        ;  '(("scratchpost.org"
                                        ;     (user-mail-address  "dannym@scratchpost.org")
                                        ;     (user-full-name     "Danny Milosavljevic")
                                        ;     (mu4e-sent-folder   "/scratchpost.org/sent")
                                        ;     (mu4e-drafts-folder "/scratchpost.org/drafts")
                                        ;     (mu4e-trash-folder  "/scratchpost.org/trash")
                                        ;     (mu4e-refile-folder "/scratchpost.org/archive"))))

                                        ;(setq mu4e-user-mail-address-list
                                        ;      (mapcar (lambda (account) (cadr (assq 'user-mail-address account)))
                                        ;              my-mu4e-account-alist))

                                        ; offlineimap offlineimap --dry-run -a dannym@scratchpost.org
(setq mu4e-context-policy 'pick-first)
(setq mu4e-compose-context-policy 'ask)

(setq org-mu4e-convert-to-html t)

;;; Bookmarks
(setq mu4e-bookmarks
      `(("flag:unread AND NOT flag:trashed" "Unread messages" ?u)
        ("flag:unread" "new messages" ?n)
        ("date:today..now" "Today's messages" ?t)
        ("date:7d..now" "Last 7 days" ?w)
        ("mime:image/*" "Messages with images" ?p)))
