;; adbr 2024-10-06

;; Builtin packages
;; ==============================

(use-package emacs
  :delight
  (auto-fill-function)
  (outline-minor-mode)
  (eldoc-mode)
  :config
  (global-set-key (kbd "C-c p") 'execute-extended-command)
  (global-set-key (kbd "C-x C-b") 'ibuffer)
  (global-set-key (kbd "M-/") 'hippie-expand)
  (indent-tabs-mode 0)
  (tool-bar-mode 0)
  (column-number-mode 1)
  (repeat-mode 1)
  (context-menu-mode 1)
  (setq minibuffer-default-prompt-format "")
  (setq sentence-end-double-space nil)
  (setq make-backup-files nil)
  (setq line-spacing 0.05)
  (setq warning-minimum-level :error)
  (setq default-frame-alist '((width . 80) (height . 30))))

(use-package package
  :config
  (add-to-list 'package-archives
               '("melpa-stable" . "https://stable.melpa.org/packages/") t)
  (add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/") t)
  (setq package-archive-priorities
        '(("gnu" . 2)                   ; default archive
          ("nongnu" . 2)                ; default archive
          ("melpa-stable" . 1)
          ("melpa" . 0))))

(use-package savehist
  :config
  (setq history-length 500)
  (setq history-delete-duplicates t)
  (savehist-mode 1))

(use-package saveplace
  :config
  (save-place-mode 1))

(use-package windmove
  :config
  (windmove-default-keybindings 'meta)
  (windmove-mode 1))

(use-package ispell
  :config
  (setq ispell-dictionary "polish"))

(use-package ibuffer
  :config
  (add-hook 'ibuffer-mode-hook 'hl-line-mode))

(use-package dired
  :config
  (use-package dired-x
    :config
    ;; wyłącza powiązania typu pliku z programem zdefiniowane w dired-aux.el
    (setq dired-guess-shell-alist-default nil))
  (setq dired-listing-switches "-alvF --time-style=long-iso")
  (setq dired-free-space nil)
  (setq dired-dwim-target t)
  (add-hook 'dired-mode-hook #'hl-line-mode)
  (add-hook 'dired-mode-hook #'dired-hide-details-mode))

(use-package tab-bar
  :config
  (setq tab-bar-new-tab-to 'rightmost)
  (setq tab-bar-new-tab-choice "*scratch*")
  (setq tab-bar-select-tab-modifiers '(meta))
  (setq tab-bar-tab-hints t))

(use-package org
  :bind
  (("C-c l" . org-store-link)
   ("C-c a" . org-agenda)
   ("C-c c" . org-capture))
  :config
  (setq org-directory "~/notes/org")
  (setq org-default-notes-file "~/notes/org/todo.org")
  (setq org-agenda-files "~/notes/org/agenda-files.org")
  (setq org-log-into-drawer t)
  (setq org-use-speed-commands t)
  (setq org-use-fast-todo-selection 'expert)
  (setq org-agenda-window-setup 'current-window)
  (setq org-agenda-sticky t)          ; q powoduje "burry buffer" agendy
  (setq org-agenda-skip-scheduled-if-done t)
  (setq org-agenda-skip-deadline-if-done t)
  (setq org-agenda-skip-timestamp-if-done t)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "STARTED(s!)" "WAITING(w)" "MOVED(m)" "|"
                    "DONE(d!)" "CANCEL(c!)")))
  (setq org-show-notification-handler "/usr/bin/notify-send")
  (setq org-startup-folded 'show2levels)
  (setq org-columns-default-format
        "%25ITEM %TODO %3PRIORITY %TAGS %EFFORT %CLOCKSUM")
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-targets '((org-agenda-files :maxlevel . 2)))
  (setq org-refile-use-cache t)
  (setq org-refile-use-outline-path 'title)
  (add-hook 'org-mode-hook
            (lambda ()
              ;; Włączenie wcięć (przez TAB) po nagłówku do początku nagłówka.
              (setq org-adapt-indentation t)
              ;; Wyłączenie automatycznego robienia wcięć.
              (electric-indent-local-mode -1)
              ;; Włączenie automatycznego formatowania (łamania) akapitów.
              (auto-fill-mode 1)))
  (add-hook 'org-agenda-finalize-hook 'hl-line-mode))

;; Installed packages
;; ==============================

;; Convenience
;; ------------------------------

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic)))

(use-package vertico
  :ensure t
  :config
  (vertico-multiform-mode 1)
  (vertico-mode 1)
  ;; Tidy shadowed file names (info "(vertico) Extensions")
  ;; This works with `file-name-shadow-mode' enabled. When you are in
  ;; a sub-directory and use, say, `find-file' to go to your home '~/'
  ;; or root '/' directory, Vertico will clear the old path to keep
  ;; only your current input. (komentarz i kod z filmu Prota).
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy))

(use-package marginalia
  :ensure t
  :config
  (define-key minibuffer-local-map (kbd "M-A") 'marginalia-cycle)
  (marginalia-mode 1))

(use-package consult
  :ensure t
  :init
  ;; Use `consult-completion-in-region' if Vertico is enabled.
  ;; Otherwise use the default `completion--in-region' function.
  (setq completion-in-region-function
        (lambda (&rest args)
          (apply (if vertico-mode
                     #'consult-completion-in-region
                   #'completion--in-region)
                 args))))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Wpisanie '<prefiks> C-h' wyświetla listę poleceń dla prefiksu
  ;; <prefiks> - np. 'C-c C-h' wyświetla listę poleceń dla prefiksu C-c,
  ;; z możliwością wyboru przez system kompletacji, jak np. vertico.
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (use-package embark-consult
    :ensure t))

(use-package modus-themes
  :ensure t
  :config
  (setq modus-themes-italic-constructs t)
  (setq modus-themes-bold-constructs t)
  (load-theme 'modus-vivendi t))

;; Misc packages
;; ------------------------------

(use-package delight
  :ensure t)

(use-package markdown-mode
  :ensure t)

(use-package ledger-mode
  :ensure t
  :pin melpa                  ; wersja 4.0.0 z melpa-stable nie działa
  :config
  (setq ledger-default-date-format "%Y-%m-%d")
  (setq ledger-clear-whole-transactions t))

(use-package mu4e
  :config
  (setq mail-user-agent 'mu4e-user-agent)
  (setq mu4e-get-mail-command "getmail")
  (setq mu4e-headers-date-format "%F")
  (setq mu4e-attachment-dir "~/tmp")
  (setq mu4e-completing-read-function 'completing-read)

  ;; Dla zmiany nagłówka "from" na "from-or-to" - dla wysłanych maili
  ;; wyświetla do kogo wysłałem. Pozostałe pola są domyślne.
  (setq mu4e-headers-fields
        (quote
         ((:human-date . 12)              ; default
          (:flags . 6)                    ; default
          (:mailing-list . 10)            ; default
          (:from-or-to . 22)              ; zamiast :from
          (:subject))))                   ; default

  ;; Domyślne znaki są mało czytelne
  (setq mu4e-headers-thread-child-prefix '("├>" . "├▶ "))
  (setq mu4e-headers-thread-last-child-prefix '("└>" . "└▶ "))
  (setq mu4e-headers-thread-connection-prefix '("│" . "│ "))
  (setq mu4e-headers-thread-orphan-prefix '("┬>" . "┬▶ "))
  (setq mu4e-headers-thread-single-orphan-prefix '("─>" . "─▶ "))

  ;; Wysyłanie maili - używa ~/.authinfo.gpg
  (setq user-mail-address "adam.bryt@gmx.com")
  (setq user-full-name "Adam Bryt")
  (setq send-mail-function 'smtpmail-send-it)
  (setq smtpmail-smtp-server "mail.gmx.com")
  (setq smtpmail-stream-type 'starttls)
  (setq smtpmail-smtp-service 587))

(use-package tmr
  :ensure t)

(use-package denote
  :ensure t
  :bind
  (("C-c n n" . denote)
   ("C-c n N" . denote-type)
   ("C-c n o" . denote-open-or-create)
   ("C-c n i" . denote-link)
   ("C-c n j" . denote-journal-extras-new-or-existing-entry)
   ("C-c n s n" . denote-silo-extras-create-note)
   ("C-c n s o" . denote-silo-extras-open-or-create)
   ("C-c n s c" . denote-silo-extras-select-silo-then-command))
  :config
  (setq denote-directory (expand-file-name "~/notes/denote"))
  (setq denote-dired-directories
        (list denote-directory
              (expand-file-name "~/workspace/eyetom/notes")))
  (setq denote-dired-directories-include-subdirectories t)
  (setq denote-journal-extras-title-format "%Y-%m-%d %a")
  (add-hook 'dired-mode-hook #'denote-dired-mode-in-directories)
  (denote-dired-mode 1)
  (denote-rename-buffer-mode 1))

(use-package magit
  :ensure t
  :config
  (setq magit-diff-refine-hunk t))

(use-package dired-subtree
  :ensure t
  :after dired
  :bind
  ((:map dired-mode-map
         ("<tab>" . dired-subtree-toggle)
         ("<backtab>" . dired-subtree-remove))))

(use-package async
  :ensure t
  :config
  (dired-async-mode 1))

(use-package treemacs
  :ensure t
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-c t 1"   . treemacs-delete-other-windows)
        ("C-c t t"   . treemacs)
        ("C-c t d"   . treemacs-select-directory)
        ("C-c t B"   . treemacs-bookmark)
        ("C-c t C-t" . treemacs-find-file)
        ("C-c t M-t" . treemacs-find-tag)))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

(use-package treemacs-tab-bar
  :ensure t
  :after (treemacs tab-bar)
  :config (treemacs-set-scope-type 'Tabs))

(use-package corfu
  :ensure t
  :bind
  (:map corfu-map ("SPC" . corfu-insert-separator)))

(use-package company
  :ensure t)

;; Customize
;; ==============================

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(company corfu treemacs-tab-bar treemacs-magit treemacs async dired-subtree magit denote tmr ledger-mode markdown-mode markdown delight modus-themes embark-consult embark consult marginalia vertico orderless mu4e)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
