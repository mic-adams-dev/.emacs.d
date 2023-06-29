;; package
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/") 
                         ("org" . "https://orgmode.org/elpa/") 
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents (package-refresh-contents))

(setq custom-file "~/.emacs.d/custom.el")

;; use-package
(unless (package-installed-p 'use-package) 
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; straight.el
(defvar bootstrap-version)
(let ((bootstrap-file (expand-file-name "straight/repos/straight.el/bootstrap.el"
                                        user-emacs-directory)) 
      (bootstrap-version 6)) 
  (unless (file-exists-p bootstrap-file) 
    (with-current-buffer (url-retrieve-synchronously
                          "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
                          'silent 'inhibit-cookies) 
      (goto-char (point-max)) 
      (eval-print-last-sexp))) 
  (load bootstrap-file nil 'nomessage))

;; housekeeping
(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(display-time-mode t)
(menu-bar-mode -1)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq visible-bell t)
(setq indent-line-function 'insert-tab)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(dolist (face '(window-divider window-divider-first-pixel window-divider-last-pixel)) 
  (face-spec-reset-face face) 
  (set-face-foreground face (face-attribute 'default 
                                            :background)))
(set-face-background 'fringe (face-attribute 'default 
                                             :background))
(electric-pair-mode t)

;; font
(defvar efs/default-font-size 90)
(defvar efs/default-variable-font-size 90)
(set-face-attribute 'default nil 
                    :font "Fira Code" 
                    :height efs/default-font-size)

  ;; misc functions
  (defun ex/split-eshell () 
    "Open eshell in new split" 
    (interactive) 
    (split-window-right) 
    (other-window 1) 
    (eshell))

(column-number-mode)
(global-display-line-numbers-mode t)

;; disable line numbers for some modes
(dolist (mode '(org-mode-hook term-mode-hook shell-mode-hook treemacs-mode-hook eshell-mode-hook pdf-tools-enabled-hook)) 
  (add-hook mode (lambda () 
                   (display-line-numbers-mode 0))))

;; make esc quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; doom modeline
(use-package 
  all-the-icons)

(use-package 
  doom-modeline 
  :init (doom-modeline-mode 1) 
  :custom((doom-modeline-height 20)))

;; which-key
(use-package 
  which-key 
  :init (which-key-mode) 
  :diminish which-key-mode 
  :config (setq which-key-idle-delay 0.6))

(use-package 
  counsel 
  :bind (("C-M-j" . 'counsel-switch-buffer) :map minibuffer-local-map ("C-r" .
                                                                       'counsel-minibuffer-history)) 
  :config (counsel-mode 1))

;; helpful
(use-package 
  helpful 
  :custom (counsel-describe-function-funciton #'helpful-callable) 
  (counsel-describe-variable-function #'helpful-variable) 
  :bind ([remap describe-function] . counsel-describe-function) 
  ([remap describe-command] . helpful-command) 
  ([remap describe-variable] . counsel-describe-variable) 
  ([remap describe-key] . helpful-key))

;; rainbow-delimiters
(use-package 
  rainbow-delimiters 
  :hook (prog-mode . rainbow-delimiters-mode))

;; app launcher
(use-package 
  app-launcher 
  :straight '(app-launcher :host github 
                           :repo "SebastienWae/app-launcher"))

;; paredit
(use-package 
  paredit 
  :config (autoload 'enable-paredit-mode "paredit" t) 
  (add-hook 'emacs-lisp-mode-hook		#'enable-paredit-mode) 
  (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode) 
  (add-hook 'ielm-mode-hook			#'enable-paredit-mode) 
  (add-hook 'lisp-mode-hook			#'enable-paredit-mode) 
  (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode) 
  (add-hook 'scheme-mode-hook			#'enable-paredit-mode))

;; flycheck
(use-package 
  flycheck
  :ensure t
  :config
  (add-hook 'typescript-mode-hook 'flycheck-mode))

(defun setup-tide-mode () 
  (interactive) 
  (tide-setup) 
  (flycheck-mode +1) 
  (setq flycheck-check-syntax-automatically '(save mode-enabled)) 
  (eldoc-mode +1) 
  (tide-hl-identifier-mode +1) 
  (company-mode +1))

;; web-mode
(use-package 
  web-mode 
  :ensure t 
  :mode (("\\.html?\\'" . web-mode) 
         ("\\.tsx\\'" . web-mode) 
         ("\\.jsx\\'" . web-mode)) 
  :config (setq web-mode-markup-indent-offset 2 web-mode-css-indent-offset 2
                web-mode-code-indent-offset 2 web-mode-block-padding 2 web-mode-comment-style 2
                web-mode-enable-css-colorization t web-mode-enable-auto-pairing t
                web-mode-enable-comment-keywords t web-mode-enable-current-element-highlight t) 
  (add-hook 'web-mode-hook (lambda () 
                             (when (string-equal "tsx" (file-name-extension buffer-file-name)) 
                               (setup-tide-mode)))) 
  (flycheck-add-mode 'typescript-tslint 'web-mode))

(use-package 
  typescript-mode 
  :ensure t 
  :config (setq typescript-indent-level 2) 
  (add-hook 'typescript-mode #'subword-mode))

(use-package 
  tide 

  :init 
  :ensure t 
  :after (typescript-mode company flycheck) 
  :hook ((typescript-mode . tide-setup) 
         (typescript-mode . tide-hl-identifier-mode) 
         (before-save . tide-format-before-save)))


;; org
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(setq org-agenda-files (directory-files-recursively "~/org/" "\\.org$"))
(setq org-return-follows-link 1)
(setq org-pretty-entities 1)
(org-babel-do-load-languages 'org-babel-load-languages '((haskell . t)))
(require 'org-tempo)
(use-package 
  org-modern 
  :config (setq org-auto-align-tags nil org-tags-column 0 org-catch-invisible-edits 'show-and-error
                org-special-ctrl-a/e t org-insert-heading-respect-content t
                org-hide-emphasis-markers t org-pretty-entities t org-ellipsis "…"
                org-agenda-tags-column 0 org-agenda-block-separator ?─ org-agenda-time-grid '((daily
                                                                                               today
                                                                                               require-timed) 
                                                                                              (800
                                                                                               1000
                                                                                               1200
                                                                                               1400
                                                                                               1600
                                                                                               1800
                                                                                               2000)
                                                                                              " ┄┄┄┄┄ "
                                                                                              "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
                org-agenda-current-time-string
                "⭠ now ─────────────────────────────────────────────────") 
  (add-hook 'org-mode-hook #'org-modern-mode) 
  (add-hook 'org-agenda-finalize-hook #'org-modern-agenda))

(use-package 
  org-roam 
  :ensure t 
  :custom (org-roam-directory "~/org") 
  (org-roam-complete-everywhere t) 
  :config (org-roam-setup))
(use-package 
  org-roam-ui 
  :after org-roam 
  :hook (after-init . org-roam-ui-mode) 
  :config (setq org-roam-ui-sync-theme t org-roam-ui-follow t org-roam-ui-update-on-save t
                org-roam-ui-open-on-start t))

;; exwm
(defun efs/exwm-update-class () 
  (exwm-workspace-rename-buffer exwm-class-name))

(use-package 
  exwm 
  :config
	;; set default number of workspaces
	(setq exwm-workspace-number 9)

	;; when window "class" updates, use it to set buffer name
	(add-hook 'exwm-update-class-hook #'efs/exwm-update-class)

	;; randr
	(require 'exwm-randr)
  (add-hook 'exwm-randr-screen-change-hook
            (lambda ()
              (start-process-shell-command
               "xrandr" nil "xrandr --output VGA-1-2 --right-of LVDS-1 --auto")))
  (exwm-randr-enable) 
  (setq exwm-randr-workspace-monitor-plist '(1 "VGA-1-2" 8 "VGA-1-2"))
	;; load system tray before exwm-init
	(require 'exwm-systemtray) 
  (exwm-systemtray-enable) 
  (setq exwm-systemtray-height 15)

	;; keys to always pass through to Emacs
	(setq exwm-input-prefix-keys '(?\C-x ?\C-u ?\C-h ?\M-x ?\M-`?\M-& ?\M-: ?\C-\M-j ;; Buffer list
		                                   ?\C-\ )) ;; Ctrl+Space

	;; ctrl+q will enable next key to be sent directly
	(define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

	;; lobal key bindings
	(setq exwm-input-global-keys `(
		                             ;; reset to line-mode
		                             (,(kbd "s-r") . exwm-reset)

		                             ;; move between windows
		                             ([s-left] . windmove-left) 
                                 ([s-right] . windmove-right) 
                                 ([s-up] . windmove-up) 
                                 ([s-down] . windmove-down)
                                 (,(kbd "s-<return>") . ex/split-eshell)
                                 (,(kbd "<XF86AudioPlay>") . (lambda () (interactive)
              (start-process-shell-command
               "play-pause" nil "playerctl play-pause")))
                                 (,(kbd "<XF86AudioNext>") . (lambda () (interactive)
              (start-process-shell-command
               "next" nil "playerctl next")))
                                 (,(kbd "<XF86AudioPrev>") . (lambda () (interactive)
              (start-process-shell-command
               "prev" nil "playerctl previous")))
                                 (,(kbd "<XF86MonBrightnessDown>") . (lambda () (interactive)
              (start-process-shell-command
               "brightness-down" nil "brightnessctl set 10%-")))
                                 (,(kbd "<XF86MonBrightnessUp>") . (lambda () (interactive)
              (start-process-shell-command
               "brightness-down" nil "brightnessctl set +10%")))
                                 (,(kbd "<XF86AudioRaiseVolume>") . (lambda () (interactive)
                                                                      (start-process-shell-command
                                                                       "volume-up" nil "pactl set-sink-volume @DEFAULT_SINK@ +2%")))
                                 (,(kbd "<XF86AudioLowerVolume>") . (lambda () (interactive)
                                                                      (start-process-shell-command
                                                                       "volume-down" nil "pactl set-sink-volume @DEFAULT_SINK@ -2%")))
                                 (,(kbd "<XF86AudioMute>") . (lambda () (interactive)
                                                                      (start-process-shell-command
                                                                       "volume-toggle" nil "pactl set-sink-mute @DEFAULT_SINK@@ toggle")))

                                 ([?\s-&] . (lambda (command) 
                                              (interactive (list (read-shell-command "$ "))) 
                                              (start-process-shell-command command nil command)))

		                             ;; switch workspace
		                             ([?\s-w] . exwm-workspace-switch) 
                                 ([?\s-`] . (lambda () 
                                              (interactive) 
                                              (exwm-workspace-switch-create 0)))

		                             ;; switch to certain workspace with super + number
		                             ,@(mapcar (lambda (i) 
                                             `(,(kbd (format "s-%d" i)) . (lambda () 
                                                                            (interactive) 
                                                                            (exwm-workspace-switch-create
                                                                             ,i)))) 
                                           (number-sequence 0 9)))) 
  (exwm-enable))

(use-package 
  exwm-modeline 
  :ensure t 
  :config (exwm-modeline-mode))

;; ox-hugo
(use-package 
  ox-hugo 
  :ensure t 
  :after ox)

;; pdf-tools
(use-package 
  pdf-tools 
  :config (pdf-loader-install))

;; rustic
(use-package 
  rustic)

;; ivy
(use-package 
  ivy 
  :config (ivy-mode)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  ;; enable this if you want `swiper' to use it
  ;; (setq search-default-mode #'char-fold-to-regexp)
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "<f6>") 'ivy-resume)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  (global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
  (global-set-key (kbd "<f1> l") 'counsel-find-library)
  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-c g") 'counsel-git)
  (global-set-key (kbd "C-c j") 'counsel-git-grep)
  (global-set-key (kbd "C-c k") 'counsel-ag)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history))

;; company-lsp
(use-package 
  company 
  :ensure t 
  :config (setq company-show-numbers t) 
  (setq company-tooltip-align-annotations t) 
  (setq company-tooltip-flip-when-above t) 
  (global-company-mode))

(use-package 
  company-quickhelp 
  :ensure t 
  :init (company-quickhelp-mode 1) 
  (use-package 
    pos-tip 
    :ensure t))

;; direnv
(use-package 
  direnv 
  :config (direnv-mode))

;; treemacs
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

;; exercism
(use-package exercism)

(defun my-eval-and-run-all-tests-in-buffer ()
  "Deletes all loaded tests from the runtime, evaluates the current buffer and runs all loaded tests with ert."
  (interactive)
  (ert-delete-all-tests)
  (eval-buffer)
  (ert 't))

;; theme
(use-package 
  modus-themes 
  :config
    (setq modus-themes-common-palette-overrides
      '((fringe unspecified)))
  (load-theme 'modus-vivendi-tinted t))


;; misc keybinds
(global-set-key (kbd "s-p") 'app-launcher-run-app)
(global-set-key (kbd "C-c C-f") 'projectile-find-file)
p
