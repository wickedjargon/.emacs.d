;; what I want to do later:
;; TODO: fix buffer switching workflow / projectile / projectile / look at other tools
;; TODO: is there a way to get hyperlinks to files and urls working in vterm similar to a compilation buffer?

;; the next two blocks are required as sometimes I get an emacs frame that is smaller
;; then the boarders of my window on dwm for some reason:

;; Maximize screen on new frame:
(add-hook 'after-make-frame-functions
          (lambda (&optional frame)
            (when frame
              (set-frame-parameter frame 'fullscreen 'maximized))))

;; Maximize the initial frame
(set-frame-parameter nil 'fullscreen 'maximized)


;; switching to straight.el as feel it'll be a better way to manage forked packages

;; bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(use-package emacs
  :ensure nil
  :config

  ;; for youtube change it to this:
  ;; (set-face-attribute 'default nil :height 150)

  ;; setting font height
  (if (string= (system-name) "x1c")
      (set-face-attribute 'default nil :height 135)
    (set-face-attribute 'default nil :height 135))

  ;; hooks
  (add-hook 'modus-themes-after-load-theme-hook #'pdf-view-themed-minor-mode)
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'prog-mode-hook (lambda ()
                              (setq show-trailing-whitespace t)))
  (add-hook 'dired-mode-hook #'auto-revert-mode)          ;; revert dired buffers, but not buffer list buffers
  (add-hook 'prog-mode-hook #'hs-minor-mode)              ;; let me toggle shrink and expansion of code blocks
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  (add-hook 'comint-mode-hook (lambda ()
                                (define-key comint-mode-map (kbd "C-p") 'comint-previous-input)
                                (define-key comint-mode-map (kbd "C-n") 'comint-next-input)))
  (add-hook 'inferior-lisp-mode-hook (lambda ()
                                       (define-key inferior-lisp-mode-map (kbd "C-p") 'comint-previous-input)
                                       (define-key inferior-lisp-mode-map (kbd "C-n") 'comint-next-input)))
  (add-hook 'prog-mode-hook 'visual-line-mode)

  ;; make elpa files read-only
  (add-hook 'find-file-hook (lambda ()
                              (when (and buffer-file-name
                                         (string-prefix-p (expand-file-name "elpa" user-emacs-directory) buffer-file-name))
                                (read-only-mode 1))))

  (add-hook 'kill-emacs-query-functions
            (lambda ()
              (yes-or-no-p "Are you sure you want to exit Emacs? ")))

  ;; key bindings
  (global-set-key (kbd "M-u") 'universal-argument)
  (global-set-key (kbd "C-x k") 'bury-buffer)
  (global-unset-key (kbd "C-x C-c"))
  (global-unset-key (kbd "C-h h"))
  (define-key ctl-x-map (kbd "C-f") 'fff-find-file)
  (global-set-key (kbd "C-x C-f")  'fff-find-file)
  (global-set-key (kbd "C-c c")  'fff-clear-shell)
  (global-set-key (kbd "C-<backspace>") 'kill-whole-line)

  ;; tab-bar mode
  (tab-bar-mode -1) ;; off by default
  (setq tab-bar-new-tab-to 'rightmost)
  (setq tab-bar-new-tab-choice 'empty-buffer)
  (global-set-key (kbd "C-c w") 'tab-bar-close-tab)
  (global-set-key (kbd "C-c n") 'fff-tab-bar-new-tab)
  (global-set-key (kbd "C-c r") 'tab-bar-rename-tab)
  (global-set-key (kbd "C-c h") 'tab-bar-switch-to-prev-tab)
  (global-set-key (kbd "C-c l") 'tab-bar-switch-to-next-tab)

  ;; backup and auto save
  (setq version-control t)
  (setq vc-make-backup-files t)
  (setq delete-old-versions t)
  (setq kept-new-versions 10)
  (setq kept-old-versions 10)
  (setq auto-save-no-message nil)
  (setq auto-save-file-name-transforms
        `((".*" ,(expand-file-name "auto-save-list/" user-emacs-directory) t)))
  (setq backup-directory-alist
        `(("." . ,(expand-file-name "backups/" user-emacs-directory))))

  ;; evil undo
  (setq evil-undo-system 'undo-fu)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)

  (setq custom-safe-themes t)                             ;; make all themes safe
  (setq inhibit-startup-message t)                        ;; no splash screen
  (setq use-short-answers t)                              ;; just type `y`, not `yes`
  (blink-cursor-mode -1)                                  ;; don't blink my cursor
  (setq auto-revert-verbose nil)
  (global-auto-revert-mode +1)                            ;; auto revert files and buffers
  (global-goto-address-mode +1)                           ;; make links/urls clickable
  (setq safe-local-variable-values '((checkdoc-minor-mode . t))) ;; make local variables safe
  (delete-selection-mode +1)                              ;; delete selction when hitting backspace on region
  (set-default 'truncate-lines t)                         ;; don't wrap my text
  (setq custom-file (locate-user-emacs-file "custom.el")) ;; separate custom.el file
  (when (file-exists-p custom-file) (load custom-file))   ;; when it exists, load it
  (setq initial-scratch-message "")                       ;; no message on scratch buffer
  (setq auth-source-save-behavior nil)                    ;; don't prompt to save auth info in home dir
  (setq-default tab-width 4)                              ;; I prefer a tab length of 4, not 8
  (setq-default indent-tabs-mode nil)                     ;; Use spaces instead of tabs
  (setq indent-tabs-mode nil)                             ;; Use spaces instead of tabs
  (electric-pair-mode 1)                                  ;; automatically insert matching paren as well as auto indent on new line
  (setq dired-listing-switches "-ahl --group-directories-first")  ;; group my directories and display size
  (setq disabled-command-function nil)                    ;; enable all disabled commands
  (setq ring-bell-function 'ignore)                       ;; don't ring my bell
  (setq sentence-end-double-space nil)                    ;; sentence ends with one space, not two
  (display-battery-mode +1)
  (setq frame-resize-pixelwise t)                         ;; cover the whole screen when maximized
  (setq help-window-select t)  ; Switch to help buffers automatically
  (setq use-dialog-box nil)
  (setq fill-column 100)
  (setq suggest-key-bindings nil)                         ;; don't display key bindings suggestions when I run M-x commands
  ;; (global-font-lock-mode -1)
  (setq safe-local-variable-values
        '((checkdoc-package-keywords-flag)
          (checkdoc-minor-mode . t)))

  ;; launch new buffers in current window
  (setq display-buffer-alist
      '((".*" . (display-buffer-same-window))))

  ;; prevent active process when closing a shell like vterm or eshell:
  (setq kill-buffer-query-functions (delq 'process-kill-buffer-query-function kill-buffer-query-functions))

  ;; show startup time on launch
  (defun display-startup-echo-area-message ()
    (message "(emacs-init-time) -> %s" (emacs-init-time)))

  ;; open .pl files in prolog-mode
  (autoload 'prolog-mode "prolog" "" t)
  (add-to-list 'auto-mode-alist '("\\.pl\\'" . prolog-mode))

  (setq recentf-max-menu-items 25)
  (setq recentf-max-saved-items 25)
  (recentf-mode +1)
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  ;; all the builtin themes suck except for modus themes. remove all of them except modus themes.
  (advice-add 'custom-available-themes :filter-return
            (lambda (themes)
              (seq-remove (lambda (theme)
                            (member theme '(adwaita deeper-blue dichromacy leuven-dark
                                             leuven light-blue manoj-dark misterioso
                                             tango-dark tango tsdh-dark tsdh-light
                                             wheatgrass whiteboard wombat)))
                          themes))))

(use-package modus-themes
  :ensure t
  :straight t
  :config
  (if (daemonp)
      ;; If running as a client (daemon mode), load modus-vivendi
      (add-hook 'after-make-frame-functions
                (lambda (frame)
                  (with-selected-frame frame
                    (load-theme 'modus-vivendi t))))
    ;; Otherwise, running Emacs normally, load modus-vivendi-tinted
    (load-theme 'modus-vivendi-tinted t)))

(use-package  doom-themes :straight t :ensure t :defer t)

(use-package ef-themes :straight t :ensure t :defer t)

(use-package sublime-themes :straight t :ensure t :defer t)

(use-package zenburn-theme :straight t :ensure t :defer t)

(use-package standard-themes :straight t :ensure t)

(use-package hippie-expand :ensure nil :defer t
  :init
  (setq hippie-expand-try-functions-list '(try-expand-dabbrev try-complete-file-name-partially try-complete-file-name try-expand-all-abbrevs try-expand-list  try-expand-line  try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill try-complete-lisp-symbol-partially try-complete-lisp-symbol)))

(use-package Info :ensure nil :defer t
  :init
  (add-hook 'Info-mode-hook (lambda ()
                              (define-key Info-mode-map  (kbd "M-n") 'Info-search-next)
                              (define-key Info-mode-map (kbd "M-p") 'fff-Info-search-previous))))

(use-package doom-modeline :ensure t :defer t
  :straight t
  :config
  (setq doom-modeline-hud t)
  (setq doom-modeline-highlight-modified-buffer-name nil)
  (setq doom-modeline-position-line-format '(""))
  (setq doom-modeline-buffer-encoding nil)
  (setq doom-modeline-percent-position '(""))
  (setq doom-modeline-modal nil)
  (setq doom-modeline-env-enable-rust nil)
  (setq display-time-default-load-average nil)
  (setq display-time-day-and-date t)
  (display-time)
  :init
  (doom-modeline-mode +1))

(use-package yasnippet
  :straight t
  :ensure t
  :init
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  (add-hook 'org-mode-hook #'yas-minor-mode)
  :config
  (add-to-list #'yas-snippet-dirs (expand-file-name "snippets/" user-emacs-directory))
  (yas-reload-all))

(use-package flimenu :ensure t
  :straight t
  :config
  (flimenu-global-mode))

(use-package evil-collection
  :straight t
  :after evil
  :config
  (evil-collection-init))

(use-package evil-leader :defer t
  :straight t
  :commands (evil-leader-mode)
  :ensure t
  :init
  (global-evil-leader-mode)
  :config
  (progn

    (evil-leader/set-leader "<SPC>")
    (evil-leader/set-key "<escape> <escape> <escape>" 'keyboard-escape-quit)

    ;; single key
    (evil-leader/set-key "SPC" 'execute-extended-command)
    (evil-leader/set-key "RET" 'crux-open-with)
    (evil-leader/set-key ";" 'eval-expression)
    (evil-leader/set-key "d" 'delete-blank-lines)
    (evil-leader/set-key "k" 'fff-hydra-expand-region/er/expand-region)
    (evil-leader/set-key "o" 'other-window)
    (evil-leader/set-key "q" 'fff-delete-window-and-bury-buffer)
    (evil-leader/set-key "w" 'save-buffer)

    ;; text scaling
    (evil-leader/set-key "0" 'fff-set-scale-to-zero)
    (evil-leader/set-key "=" 'fff-hydra-zoom/text-scale-increase)
    (evil-leader/set-key "-" 'fff-hydra-zoom/text-scale-decrease)

    ;; shell ocmmand
    (evil-leader/set-key "1" 'shell-command)

    ; paragraph navigation
    (evil-leader/set-key "[" 'fff-hydra-paragraph-movement/evil-backward-paragraph)
    (evil-leader/set-key "]" 'fff-hydra-paragraph-movement/evil-forward-paragraph)
    
    ;; window size adjustment
    (evil-leader/set-key "H" 'fff-hydra-windsize/windsize-left)
    (evil-leader/set-key "L" 'fff-hydra-windsize/windsize-right)
    (evil-leader/set-key "J" 'fff-hydra-windsize/windsize-down)
    (evil-leader/set-key "K" 'fff-hydra-windsize/windsize-up)

    ;; search and replace
    (evil-leader/set-key "a a" 'avy-goto-char)
    (evil-leader/set-key "r" 'fff-evil-regex-search)

    ;; narrow
    (evil-leader/set-key "n n" 'narrow-to-region)
    (evil-leader/set-key "n N" 'widen)

    ;; magit
    (evil-leader/set-key "m m" 'magit)

    ;; visual line mode
    (evil-leader/set-key "v v" 'visual-line-mode)


    ;; f: shortcut to file or dired buffer
    (evil-leader/set-key "f b" 'fff-access-bookmarks)
    (evil-leader/set-key "f B" 'fff-access-books)
    (evil-leader/set-key "f h" 'fff-access-hosts)

    ;; full screen
    (evil-leader/set-key "f s" 'toggle-frame-fullscreen)

    ;; switch to scratch
    (evil-leader/set-key "i i" 'fff-switch-to-scratch-buffer)
    (evil-leader/set-key "i I" 'fff-switch-to-new-scratch-buffer)

    ;; imenu
    (evil-leader/set-key "i m" 'consult-imenu)

    ;; terminal
    (evil-leader/set-key "t t" 'fff-switch-or-create-vterm)
    (evil-leader/set-key "t T" 'fff-open-new-vterm)
    (evil-leader/set-key "t p" 'terminal-here)

    ;; chatgpt
    (evil-leader/set-key "g g" 'fff-switch-or-create-gptel)

    ;; x: C-x prefixes
    (evil-leader/set-key "x b" 'consult-buffer)
    (evil-leader/set-key "x B" 'projectile-switch-to-buffer)
    (evil-leader/set-key "x 0" 'delete-window)
    (evil-leader/set-key "x 1" 'delete-other-windows)
    (evil-leader/set-key "x 2" 'split-window-below)
    (evil-leader/set-key "x 3" 'split-window-right)
    (evil-leader/set-key "x 4 4" 'other-window-prefix)
    (evil-leader/set-key "x 4 1" 'same-window-prefix)
    (evil-leader/set-key "x o" 'other-window)
    (evil-leader/set-key "x k" 'bury-buffer)
    (evil-leader/set-key "x K" 'kill-buffer)
    (evil-leader/set-key "x D" 'make-directory)
    (evil-leader/set-key "x f" 'fff-find-file)
    (evil-leader/set-key "x F" 'fff-find-file-in-project-root)
    (evil-leader/set-key "x r" 'crux-recentf-find-file)
    (evil-leader/set-key "x w" 'write-file)
    (evil-leader/set-key "x SPC b" 'ibuffer)
    (evil-leader/set-key "x SPC B" 'projectile-ibuffer)
    (evil-leader/set-key "X C" 'save-buffers-kill-terminal)

    ;; shortcut
    (evil-leader/set-key "4 4" 'other-window-prefix)
    (evil-leader/set-key "4 1" 'same-window-prefix)

    ;; access dirs
    (evil-leader/set-key "x c" 'fff-access-config-dir)
    (evil-leader/set-key "x m" 'fff-access-home-dir)
    (evil-leader/set-key "x n" 'fff-open-file-in-notes)
    (evil-leader/set-key "x p" 'fff-open-file-in-projects)
    (evil-leader/set-key "x s" 'fff-find-file-ssh)
    (evil-leader/set-key "x t" 'fff-open-file-in-tmp)
    (evil-leader/set-key "x /" 'fff-open-file-in-root-dir)

    ;; project root
    (evil-leader/set-key "h k" 'fff-find-file-in-project-root)
    (evil-leader/set-key "p r" 'fff-find-file-in-project-root)

    ;; winner undo/redo and previous buffer
    (evil-leader/set-key "u u" 'fff-winner/winner-undo)
    (evil-leader/set-key "j j" 'evil-switch-to-windows-last-buffer)

    ;; tooltip hover
    (evil-leader/set-key "h h" 'fff-display-tooltip-at-point)

    ;; run/debug bindings for projects
    (evil-leader/set-key "c c" 'compile)))

(use-package evil :defer nil :ensure t
  :straight t
  :init
  (setq evil-insert-state-message nil)
  (setq evil-undo-system 'undo-fu)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-fine-undo t)
  (setq evil-search-wrap nil)
  (setq evil-kill-on-visual-paste nil)

  ;; hitting C-n and C-p doesn't work for the company-mode pop-up
  ;; after using C-h. The code below resolves this issue
  (with-eval-after-load 'evil
    (with-eval-after-load 'company
      (define-key evil-insert-state-map (kbd "C-n") nil)
      (define-key evil-insert-state-map (kbd "C-p") nil)
      (evil-define-key nil company-active-map (kbd "C-n") #'company-select-next)
      (evil-define-key nil company-active-map (kbd "C-p") #'company-select-previous)))
  :config
  (progn

    (setq evil-undo-system 'undo-fu)
    (setq evil-want-integration t)
    (setq evil-want-keybinding nil)
    (setq evil-want-fine-undo t)
    (setq evil-search-wrap nil)
    (setq evil-kill-on-visual-paste nil)
    (evil-mode +1)

    (define-key evil-visual-state-map (kbd "C-e") 'move-end-of-line)
    (define-key evil-visual-state-map (kbd "<backpace>") 'delete-char)
    (define-key evil-visual-state-map (kbd "C-/") 'fff-comment)
    (define-key evil-visual-state-map (kbd "j") 'evil-next-visual-line)
    (define-key evil-visual-state-map (kbd "k") 'evil-previous-visual-line)

    (define-key evil-insert-state-map (kbd "C-e") 'move-end-of-line)
    (define-key evil-insert-state-map (kbd "C-w") 'kill-region)
    (define-key evil-insert-state-map (kbd "M-w") 'easy-kill)
    (define-key evil-insert-state-map (kbd "C-y") 'yank)
    (define-key evil-insert-state-map (kbd "M-y") 'yank-pop)
    (define-key evil-insert-state-map (kbd "C-'") 'hippie-expand)
    (define-key evil-insert-state-map (kbd "M-a") 'yas-insert-snippet)
    (define-key evil-insert-state-map (kbd "C-d") 'delete-char)
    (define-key evil-insert-state-map (kbd "C-/") 'fff-comment)

    (define-key evil-normal-state-map (kbd "C-e") 'move-end-of-line)
    (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
    (define-key evil-normal-state-map (kbd "C-o") 'evil-jump-backward)
    (define-key evil-normal-state-map (kbd "M-o") 'evil-jump-forward)
    (define-key evil-normal-state-map (kbd "gp") 'fff-evil-paste-and-indent-after)
    (define-key evil-normal-state-map (kbd "gP") 'fff-evil-paste-and-indent-before)
    (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
    (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
    (define-key evil-normal-state-map (kbd "C-/") 'fff-comment)
    (define-key evil-normal-state-map (kbd "C-c a") 'evil-numbers/inc-at-pt)
    (define-key evil-normal-state-map (kbd "C-c x") 'evil-numbers/dec-at-pt)
    (define-key evil-normal-state-map (kbd "C-c g a") 'evil-numbers/inc-at-pt-incremental)
    (define-key evil-normal-state-map (kbd "C-c g x") 'evil-numbers/dec-at-pt-incremental)
    (define-key evil-normal-state-map (kbd "q") 'quit-window)
    (define-key evil-normal-state-map (kbd "Q") 'evil-record-macro)
    (define-key evil-normal-state-map (kbd "ZZ") 'fff-save-and-bury-buffer)
    (define-key evil-normal-state-map (kbd "ZQ") 'fff-revert-and-bury-buffer)
    (define-key evil-normal-state-map (kbd "o") 'fff-evil-open-below)
    (define-key evil-normal-state-map (kbd "O") 'fff-evil-open-above)
    (define-key evil-normal-state-map (kbd "C-/") 'fff-comment)
    (define-key evil-normal-state-map (kbd "<left>") 'previous-buffer)
    (define-key evil-normal-state-map (kbd "<right>") 'next-buffer)
    (evil-global-set-key 'normal (kbd "SPC e") 'eval-last-sexp)))

(use-package evil-better-visual-line :ensure t :straight t
  :config
  (evil-better-visual-line-on))

(use-package fff-lisp :defer nil :ensure nil
  :after evil
  :init
  (load (expand-file-name "hide-comnt.el" user-emacs-directory))
  (load (expand-file-name "fff-functions.el" user-emacs-directory))
  (load (expand-file-name "weather.el" user-emacs-directory))
  (load (expand-file-name "asm-mode.el") user-emacs-directory))

(use-package ocen-mode
  :straight nil ; not to install from a package repository
  :load-path (lambda () (expand-file-name "ocen-mode" user-emacs-directory))
  :mode "\\.oc\\'"
  :config
  (require 'lsp-mode)
  (with-eval-after-load 'lsp-mode
    (add-to-list 'lsp-language-id-configuration '("\\.oc\\'" . "ocen"))
    (add-to-list 'lsp-language-id-configuration '(oc-mode . "ocen")))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection
                     (lambda () '("node" "/home/ff/.local/src/ocen-vscode/out/server/src/server.js" "--stdio")))
                     ;; (lambda () '("ocen" "lsp-server")))
    :major-modes '(ocen-mode)  ;; Ensure you associate this with ocen-mode
    :server-id 'ocen-language-server)))

(use-package undo-fu :straight t :defer t :ensure t)

(use-package evil-surround :ensure t
  :straight t
  :config
  (global-evil-surround-mode +1))

(use-package evil-numbers :straight t :defer t :ensure t)

(use-package expand-region :straight t :defer t :ensure t)

(use-package lisp-mode :ensure nil
  :init
  (set-default 'auto-mode-alist
               (append '(("\\.lisp$" . lisp-mode)
                         ("\\.lsp$" . lisp-mode)
                         ("\\.cl$" . lisp-mode))
                       auto-mode-alist)))

(use-package sly :straight t :defer t :ensure t
  :init
  (set-default 'auto-mode-alist
               (append '(("\\.lisp$" . lisp-mode)
                         ("\\.lsp$" . lisp-mode)
                         ("\\.cl$" . lisp-mode))
                       auto-mode-alist))
  (add-hook 'sly-mrepl-mode-hook (lambda ()
                                   (define-key sly-mrepl-mode-map (kbd "C-p") 'comint-previous-input)
                                   (define-key sly-mrepl-mode-map (kbd "C-n") 'comint-next-input)))
  (setq inferior-lisp-program "/usr/bin/sbcl")
  :config
  (define-key lisp-mode-map (kbd "C-j") 'sly-eval-print-last-expression)
  (define-key lisp-mode-map (kbd "C-<return>") 'sly-eval-print-last-expression)
  (evil-set-initial-state 'sly-mrepl-mode 'normal))

(use-package terminal-here :straight t :defer t :ensure t
  :init
  (setq terminal-here-linux-terminal-command 'st))

(use-package so-long :defer t :ensure t
  :straight t
  :init
  (global-so-long-mode +1))

(use-package lorem-ipsum :straight t :defer t :ensure t)

(use-package hydra :straight t :defer t :ensure t :commands defhydra
  :config

  (defhydra fff-hydra-windsize (:color red :pre (setq hydra-is-helpful nil) :after-exit (setq hydra-is-helpful t))
    ("H" windsize-left nil)
    ("L" windsize-right nil)
    ("J" windsize-down nil)
    ("K" windsize-up nil))

  (defhydra fff-hydra-zoom (:color red :pre (setq hydra-is-helpful nil) :after-exit (setq hydra-is-helpful t))
    ( "=" text-scale-increase)
    ( "-" text-scale-decrease)
    ( "0"  (text-scale-set 0)))

  (defhydra fff-hydra-expand-region (:color red :pre (setq hydra-is-helpful nil) :after-exit (setq hydra-is-helpful t))
    ("k" er/expand-region)
    ("j" er/contract-region))

  (defhydra fff-hydra-paragraph-movement (:color red :pre (setq hydra-is-helpful nil) :after-exit (setq hydra-is-helpful t))
    ("[" evil-backward-paragraph)
    ("]" evil-forward-paragraph))

  (defhydra fff-tabs (:color red :pre (setq hydra-is-helpful nil) :after-exit (setq hydra-is-helpful t))
    ("l" tab-next)
    ("h" tab-previous))

  (defhydra fff-buffer-switch (:color red :pre (setq hydra-is-helpful nil) :after-exit (setq hydra-is-helpful t))
    ( "h" previous-buffer)
    ( "l" next-buffer))

  (defhydra fff-winner (:color red :pre (setq hydra-is-helpful nil) :after-exit (setq hydra-is-helpful t))
    ("u" winner-undo)
    ("U" winner-redo)))

(use-package company :straight t :defer t :ensure t
  :init
  (setq company-format-margin-function nil)
  (setq company-idle-delay 0.2)
  (setq company-tooltip-limit 2)
  (global-company-mode)
  :config
  (add-hook 'c-mode-common-hook
            (lambda ()
              (when (file-remote-p default-directory)
                ;; Remove company-clang for remote files
                (setq-local company-backends
                            (remove 'company-clang company-backends))))))

(use-package company-statistics
  :straight t
  :ensure t
  :after company
  :hook (after-init . company-statistics-mode))

(use-package restart-emacs :straight t :defer t :ensure t)

(use-package windsize :straight t :defer t :ensure t)

(use-package crux :straight t :defer t :ensure t)

(use-package emmet-mode :straight t :defer t :ensure t
  :init (add-hook 'sgml-mode-hook 'emmet-mode))

;; (use-package markdown-mode :straight t :defer t :ensure nil
;;   :mode ("README\\.md\\'" . gfm-mode)
;;   :init
;;   (setq markdown-command "multimarkdown")
;;   (add-hook 'markdown-mode-hook (lambda () (visual-line-mode +1))))

(use-package mw-thesaurus :straight t :defer t :ensure t)

(use-package sicp :straight t :defer t :ensure t)

(use-package gh-md :straight t :ensure t :defer t)

(use-package go-mode :straight t :ensure t :defer t)

(use-package vertico :straight t :defer t :ensure t
  :init
  (setq enable-recursive-minibuffers t)
  :config
  (vertico-mode +1)
  (define-key vertico-map (kbd "C-c d") 'vertico-exit-input)
  (define-key vertico-map (kbd "C-<backspace>") 'vertico-directory-delete-word))

(use-package vertico-prescient :straight t :ensure t
  :config
  (setq prescient-filter-method  '(literal regexp initialism))
  (vertico-prescient-mode +1))

(use-package  savehist :straight t
  :init
  (savehist-mode))

(use-package projectile :straight t :defer t :ensure t
  :config
  (dolist (file '(".venv/" "venv/" "manage.py" ".git/" "go.mod" "package.json" "Cargo.toml" "build.sh" "v.mod"
                  "make.bat" "Makefile" "Dockerfile" ".editorconfig" ".gitignore" ".git" ".svn" ".hg" ".bzr"
                  "Pipfile" "tox.ini" "requirements.txt" "pom.xml" "build.gradle" "Cargo.lock" "yarn.lock"
                  "webpack.config.js" "Gemfile" ".ruby-version" "composer.json" ".env" "README.md" ".eslint.js"
                  "tsconfig.json" ".babelrc" ".prettierrc" "CMakeLists.txt" ".project"))
    (add-to-list 'projectile-project-root-files file))
  :bind*
  (("C-c k" . projectile-find-file))
  :init
  (setq projectile-ignored-projects '("~/"))
  (projectile-mode +1)
  (with-eval-after-load 'projectile
    (define-key projectile-command-map (kbd "C-c p") nil)
    (define-key projectile-command-map (kbd "C-c P") nil)))

(use-package consult-projectile :straight t :ensure t)

(use-package marginalia :straight t :defer t :ensure t
  :init
  (marginalia-mode))

(use-package emojify :straight t :ensure t :defer t)

(use-package dired :defer t :ensure nil
  :config
  (add-hook 'dired-mode-hook
            (lambda ()
              (dired-hide-details-mode))))

(use-package switch-window :straight t :ensure t :defer t)

(use-package rainbow-mode :straight t :ensure t :defer t)

(use-package vimrc-mode :straight t :ensure t :defer t)

;; (use-package org-bullets :straight t :ensure t :defer t
;;   :init
;;   (require 'org-bullets)
;;   (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package emmet-mode :straight t :ensure t :defer t
  :init
  (require 'emmet-mode)
  (add-hook 'html-mode-hook (lambda () (emmet-mode 1))))

(use-package smex :straight t :ensure t)

(use-package git-gutter :straight t :ensure t
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.02)
  (add-hook 'find-file-hook
            (lambda ()
              (when (and (fboundp 'tramp-tramp-file-p)
                         (tramp-tramp-file-p (or buffer-file-name "")))
                (git-gutter-mode -1))))
  )

(use-package git-gutter-fringe :straight t :ensure t
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))

(use-package hl-todo :straight t :ensure t :defer t
  :custom-face
  (hl-todo ((t (:inherit hl-todo :italic t))))
  :hook ((prog-mode . hl-todo-mode)))

(use-package saveplace :straight t :init (save-place-mode))

(use-package winner :straight t :ensure t :defer t
  :init (winner-mode +1))

(use-package haskell-mode :straight t :ensure t :defer t)

(use-package helpful :straight t :ensure t :defer t
  :bind
  ([remap describe-key] . helpful-key)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-function] . helpful-callable))

(use-package volatile-highlights :straight t :ensure t :defer t
  :init
  (volatile-highlights-mode t)
  :config
  (vhl/define-extension 'evil 'evil-paste-after 'evil-paste-before
                        'evil-paste-pop 'evil-move)
  (vhl/install-extension 'evil))

(use-package typescript-mode :straight t :ensure t :defer t)

(use-package rust-mode :straight t :ensure t :defer t)

(use-package lsp-mode :straight t :ensure t :defer t
  ;; preferred LSPs:
  ;; - javascript/typescript: jsts-ls
  ;; - python:  pylsp, python-pyflakes
  ;; - html:
  ;; - css:
  ;; hooks:
  :hook (ocen-mode . lsp-deferred)
  :hook (rust-mode . lsp-deferred)
  ;; :hook (svelte-mode . lsp-deferred)
  :hook (c-mode . lsp-deferred)
  :hook (c++-mode . lsp-deferred)
  ;; :hook (typescript-mode . lsp-deferred)
  ;; :hook (javascript-mode . lsp-deferred)
  ;; :hook (python-mode . lsp-deferred)
  ;; :hook (d-mode . lsp-deferred)
  ;; :hook (go-mode . lsp-deferred)
  ;; to do, find a way to conditionally install
  ;; an lsp using:
  ;; (lsp-install-server nil 'jsts-ls)
  :config
  (setq lsp-diagnostics-provider :flymake)
  (setq lsp-auto-guess-root t)
  (setq lsp-keymap-prefix "C-c l")
  ;; apparently copilot is an lsp now and is listed for every major mode as a possible lsp. no thanks.
  (setq lsp-copilot-enabled nil)
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)

  ;; https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/
  (setq lsp-enable-file-watchers nil) ; Disable file watchers for better performance
  (setq lsp-enable-symbol-highlighting nil) ; disable symbol highlighting
  (setq lsp-headerline-breadcrumb-enable nil) ; Disable breadcrumbs in the headerline
  (setq lsp-completion-show-kind nil)
  (setq lsp-completion-show-detail nil)
  (setq lsp-signature-auto-activate nil)
  (setq lsp-lens-enable nil)
  ;; (setq lsp-inlay-hints-mode t) ; the type hints next to arguments in func signature lines and variable definitions.
  ;; (setq lsp-inlay-hint-enable t)
  (setq lsp-rust-analyzer-display-parameter-hints t))

(use-package lsp-python-ms :straight t :ensure t :defer t)

(use-package lsp-haskell :straight t :ensure t :defer t)

(use-package lsp-metals
  :straight t
  :ensure t
  :custom
  (lsp-metals-server-args '("-J-Dmetals.allow-multiline-string-formatting=off"
                            "-J-Dmetals.icons=unicode"))
  (lsp-metals-enable-semantic-highlighting t))

(use-package macrostep :straight t :ensure t :defer t)

(use-package nov :straight t :ensure t :defer t
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

(use-package embark :straight t :ensure t :defer t
  :bind*
  (("C-c e" . embark-act)
   ("C-h b" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package diminish :straight t :ensure t :defer t)

(use-package emms :straight t :ensure t :defer t
  :diminish emms-mode-line
  :config
  (setq emms-mode-line-format "")
  (setq emms-mode-line-icon-enabled-p nil)
  (setq emms-playing-time-display-format "")
  :init
  (emms-all)
  (emms-default-players))

(use-package circe :straight t :ensure t :defer t)

(use-package avy :straight t :ensure t :defer t)

(use-package pdf-tools :straight t :ensure t  :defer t
  :mode ("\\pdf\\'" . pdf-view-mode)
  :init
  (add-hook 'pdf-view-mode-hook (lambda ()
                                  (define-key pdf-view-mode-map (kbd "<tab>") 'pdf-outline)
                                  (pdf-view-themed-minor-mode)))
  :config
  (pdf-tools-install :no-query))

(use-package vterm :straight t :ensure t :defer t
  :config
  (define-key vterm-mode-map (kbd "C-c c") 'vterm-clear))

(use-package org :ensure nil :defer t
  :init
  (setq org-babel-lisp-eval-fn "sly-eval")
  (setq org-confirm-babel-evaluate nil)
  (setq org-startup-with-inline-images t)
  (setq org-babel-lisp-eval-command "sbcl --script")
  (setq org-edit-src-content-indentation 0)
  (setq org-startup-folded t)
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python .t)
     (haskell . t)
     (lisp . t)
     (ruby . t)
     (C . t)
     (js . t))))

(use-package magit :straight t :ensure t :defer t
  :init
  (setq magit-section-initial-visibility-alist
        '(([hunk file staged status] . hide)
          ([file unstaged status] . show)
          ([hunk file unstaged status] . hide))))

(use-package git-timemachine :straight t :ensure t :defer t)

(use-package clojure-mode :straight t :ensure t :defer t)

(use-package cider :straight t :ensure t :defer t
  :config
  (define-key cider-repl-mode-map (kbd "C-c c") #'cider-repl-clear-buffer))

(use-package consult :straight t :ensure t :defer t)

(use-package embark-consult :straight t :ensure t :defer t)

(use-package pyvenv :straight t :ensure t :defer t)

(use-package keycast :straight t :ensure t :defer t)

(use-package org-download :straight t :ensure t
  :config
  (add-hook 'dired-mode-hook 'org-download-enable))

(use-package evil-org
  :straight t
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (evil-org-set-key-theme '(navigation insert textobjects additional calendar))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package evil-visualstar :straight t :ensure t :defer nil
  :straight t
  :config
  (global-evil-visualstar-mode))

(use-package evil-matchit :straight t :ensure t :defer nil
  :straight t
  :config
  (global-evil-matchit-mode +1))

(use-package zig-mode :straight t :ensure t :defer t)

(use-package all-the-icons :straight t :ensure t
  :if (display-graphic-p))

(use-package evil-iedit-state :straight t :ensure t :defer t
  :init
  (global-set-key (kbd "C-;") 'iedit-mode))

(use-package scala-mode :straight t :ensure t :defer t
  :interpreter
  ("scala" . scala-mode))

(use-package tree-sitter
  :straight t
  :ensure t
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs
  :straight t
  :ensure t
  :after tree-sitter)

(use-package devdocs :ensure t
  :straight t
  :init
  (add-hook 'devdocs-mode-hook (lambda () (visual-line-mode +1))))

(use-package projectile-ripgrep :straight t :ensure t)

(use-package dockerfile-mode :straight t :ensure t)

(use-package json-mode :straight t :ensure t)

(use-package deadgrep :straight t :ensure t)

(use-package aggressive-indent :straight t :ensure t)

(use-package exec-path-from-shell
  :straight t
  :ensure t
  :config
  ;; only initialize this package when on unix-like system:
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package wgrep :straight t :ensure t :defer t)

(use-package gptel
  :straight t
  :ensure t
  :init
  (when (file-exists-p "~/.chat_gpt_api_key")
    (setq gptel-api-key
          (string-trim
           (with-temp-buffer
             (insert-file-contents "~/.chat_gpt_api_key")
             (buffer-string)))))
  (setq gptel-api-key (string-trim (with-temp-buffer (insert-file-contents "~/.chat_gpt_api_key") (buffer-string))))
  :config
  (setq gptel-model 'gpt-4o))

;; (use-package gptel
;;   :straight t
;;   :ensure t
;;   :init
;; ;; (setq gptel-model   'llama3.1-8b
;; ;;       gptel-backend
;; ;;       (gptel-make-openai "Cerebras"
;; ;;         :host "api.cerebras.ai"
;; ;;         :endpoint "/v1"
;; ;;         :stream t
;; ;;         :key "csk-dhc4xt396mrh6ph246f28yf4d386e63f5hfckntmd3fnthvw"
;; ;;         :models '(llama3.1-70b
;; ;;                   llama3.1-8b)))

;; ;; (setq gptel-model   'llama3-70b-8192
;; (setq gptel-model   'deepseek-r1-distill-llama-70b
;;       gptel-backend
;;       (gptel-make-openai "Groq"
;;         :host "api.groq.com"
;;         :endpoint "/openai/v1/chat/completions"
;;         :stream t
;;         :key "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"
;;         ;; :models '(llama-3.1-70b-versatile
;;         :models '(deepseek-r1-distill-llama-70b
;;                   llama-3.1-70b-versatile
;;                   llama-3.1-8b-instant
;;                   llama3-70b-8192
;;                   llama3-8b-8192
;;                   mixtral-8x7b-32768
;;                   gemma-7b-it))))



(use-package sml-mode :straight t :ensure t)

(use-package compiler-explorer :straight t :ensure t :defer t)

(use-package clhs :straight t :ensure t :defer t)

(use-package d-mode
  :straight t
  :ensure t
  :mode "\\.d\\'"
  :config
  (setq d-mode-indent-style 'k&r))

(use-package svelte-mode :straight t :ensure t :mode "\\.svelte\\'")

(use-package dtrt-indent :straight t :ensure t :defer nil
  :config
  (require 'dtrt-indent)
  (dtrt-indent-global-mode +1)
  ;; run `dtrt-indent-try-set-offset` whenever running a function that changes the indentation
  (dolist (fn '(lsp-format-buffer
                lsp-format-region
                indent-region
                tabify
                untabify))
    (advice-add fn :after (lambda (&rest _args)
                            (when (called-interactively-p 'any)
                              (dtrt-indent-try-set-offset))))))

(use-package elfeed
  :straight t
  :ensure t
  :config
  (setq elfeed-feeds
        '("https://www.youtube.com/feeds/videos.xml?channel_id=UCrqM0Ym_NbK1fqeQG2VIohg" ;; Tsoding Daily
          "https://protesilaos.com/codelog.xml"                                          ;; prot code blogs
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC2eYFnH61tmytImy1mTYvhA" ;; Luke Smith yt
          "https://lukesmith.xyz/index.xml"                                              ;; Luke Smith site
          "https://www.youtube.com/feeds/videos.xml?channel_id=UC6biysICWOJ-C3P4Tyeggzg" ;; Low level programming
          "https://bergsoe.net/rss.xml"                                                  ;; Fatty's blog
          "https://lyte.dev/blog/index.xml"                                              ;; Daniel's blog
          "https://planet.emacslife.com/atom.xml"                                        ;; emacslife
          "https://sachachua.com/blog/feed/index.xml"                                    ;; sacha chua
          )))

(use-package eww :ensure nil
  :config
  (setq eww-search-prefix "https://wiby.me/?q="))

(use-package text-mode :ensure nil
  :hook (text-mode . display-line-numbers-mode))

(use-package asm-mode :ensure nil
  :mode ("\\.s\\'" . asm-mode)
  ("\\.asm\\'" . asm-mode)
  :config
  ;; remove indentation
  (defun asm-indent-line ()
    "Auto-indent the current line."
    (interactive)
    (indent-line-to 0))
  (defun asm-calculate-indentation () 0)
  (defun asm-colon ()
    "Insert a colon without triggering indentation."
    (interactive)
    (let ((labelp nil))
      (save-excursion
        (skip-syntax-backward "w_")
        (skip-syntax-backward " ")
        (setq labelp (bolp)))
      (call-interactively 'self-insert-command)
      (when labelp
        (delete-horizontal-space)))))

(use-package tmr :straight t :ensure t :defer t)

(use-package ibuffer  :ensure nil
  :config
  (setq ibuffer-formats
        '((mark modified read-only " "
                (name 35 35 :left :elide) ; change: 35s were originally 18s
                " "
                (size 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " " filename-and-process)
          (mark " "
                (name 16 -1)
                " " filename))))

(use-package v-mode :straight t :ensure t :defer t)

(use-package markdown-mode
  :ensure nil
  :hook (markdown-mode . visual-line-mode))

(use-package sly-macrostep
  :defer t
  :straight t
  :config
  (add-to-list 'sly-contribs 'sly-macrostep 'append))

(use-package read-aloud
  :defer t
  :ensure t
  :straight t
  :config
  (cl-defun read-aloud--current-word()
    "Pronounce a word under the pointer. If under there is rubbish,
ask user for an additional input."
    (let* ((cw (read-aloud--u-current-word))
           (word (nth 2 cw)))

      (unless (and word (string-match "[[:alnum:]]" word))
        ;; maybe we should share the hist list w/ `wordnut-completion-hist`?
        (setq word (read-string "read aloud: " word 'read-aloud-word-hist)) )

      (read-aloud--overlay-make (nth 0 cw) (nth 1 cw))
      (read-aloud--string (replace-regexp-in-string "\\." "," word) "word")
      ))

  (cl-defun read-aloud-this()
    "Pronounce either the selection or a word under the pointer."
    (interactive)

    (when read-aloud--c-locked
      (read-aloud-stop)
      (cl-return-from read-aloud-selection))

    (if (use-region-p)
        (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
          (read-aloud--string (replace-regexp-in-string "\\." "," text) "selection"))
      (read-aloud--current-word))))

(use-package graphviz-dot-mode
  :defer t
  :straight t
  :ensure t
  :config
  (setq graphviz-dot-indent-width 4))

;; always open urls in a new window, use chromium always.
(use-package browse-url
  :ensure nil
  :init
  (setq browse-url-chromium-program "chromium")
  (defun browse-url-chromium-new-window (url &optional _new-window)
    "Open URL in a new Chromium window."
    (interactive (browse-url-interactive-arg "URL: "))
    (start-process (concat "chromium " url) nil
                   browse-url-chromium-program "--new-window" url))
  (setq browse-url-browser-function 'browse-url-chromium-new-window))

(use-package hyperspec
  :straight t
  :ensure t)

(use-package ytdl
  :straight t
  :ensure t)

(use-package compile
  :ensure nil
  :hook (compilation-filter . ansi-color-compilation-filter))


;; (use-package evil-mc
;;   :straight t
;;   :ensure t
;;   :after evil
;;   :config
;;   (global-evil-mc-mode 1))


(use-package evil-mc
  :straight t
  :ensure t
  :after evil
  :config
  (global-evil-mc-mode 1))
