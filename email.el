
(setq message-send-mail-function 'smtpmail-send-it)
(setq mail-user-agent #'mu4e-user-agent
      message-mail-user-agent t)

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
                (mu4e-sent-folder . "/friendly-machines.com/INBOX/Sent")
                (mu4e-drafts-folder . "/friendly-machines.com/INBOX/Drafts")
                (mu4e-trash-folder . "/friendly-machines.com/INBOX/Trash")
                (mu4e-refile-folder . "/friendly-machines.com/INBOX/Archives") ; TODO: Check.
                (mu4e-get-mail-command . "offlineimap -a dannym@friendly-machines.com")

                (mu4e-maildir-shortcuts . ( ("/friendly-machines.com/INBOX" . ?i)
                                            ("/friendly-machines.com/INBOX/Sent" . ?s)
                                            ("/friendly-machines.com/INBOX/Trash" . ?t)
                                            ("/friendly-machines.com/INBOX/Archives" . ?a)
                                            ("/friendly-machines.com/INBOX/Drafts" . ?d)
                                            ("/friendly-machines.com/INBOX/Hobby/Shellbox" .?s)
                                            ("/friendly-machines.com/INBOX/Work/Friendly_Machines" .?f)
                                            ("/friendly-machines.com/INBOX/Work/Guix/Devel" . ?g)
                                            ("/friendly-machines.com/INBOX/Work/Guix/Patches" . ?h)
                                            ("/friendly-machines.com/INBOX/Work/Physics" . ?p)
                                            ("/friendly-machines.com/INBOX/Work/TU_Tieftemperatur" . ?i)
                                            ("/friendly-machines.com/INBOX/Work/Oxide" . ?x)))))))

(setq mu4e-change-filenames-when-moving t)

(setq mu4e-view-show-images t)
(setq mu4e-view-show-addresses t)

; offlineimap: offlineimap --dry-run -a dannym@friendly-machines.com
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
