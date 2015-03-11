(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t))

;; my own lisp files
(add-to-list 'load-path "~/.emacs.d/lisp")

;; install package if not installed
(defun require-package (package &optional min-version no-refresh)
    "Ask elpa to install given PACKAGE."
    (if (package-installed-p package min-version)
	t
      (if (or (assoc package package-archive-contents) no-refresh)
	  (package-install package)
	(progn
	  (package-refresh-contents)
	  (require-package package min-version t)))))

;; packages I need installed
(require-package 'flycheck)
(require-package 'go-autocomplete)
(require-package 'go-eldoc)
(require-package 'auto-complete)
(require-package 'exec-path-from-shell)
(require-package 'go-mode)
(require-package 'js2-mode)
(require-package 'ac-js2)
(require-package 'smartparens)
(require-package 'web-mode)
(require-package 'magit)
(require-package 'markdown-mode)
(require-package 'rebox2)

;; misc emacs stuff
(setq inhibit-startup-screen t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(show-paren-mode 1)
(define-key global-map [home] 'beginning-of-line)
(define-key global-map [end] 'end-of-line)
(savehist-mode 1)
(setq ring-bell-function #'ignore
      column-number-mode 1
      size-indication-mode 1
      savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

;;(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
;;(setq indent-line-function 'insert-tab) 

;; save a list of open files in ~/.emacs.d/.emacs.desktop
;; save the desktop file automatically if it already exists
(setq desktop-save 'if-exists)
(desktop-save-mode 1)

;; better organize autosave and backup files everywhere
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t))
	  backup-directory-alist '((".*" . "~/.emacs.d/backups/")))
;; create the autosave dir if necessary, since emacs won't.
(make-directory "~/.emacs.d/autosaves/" t)

;; save a bunch of variables to the desktop file
;; for lists specify the len of the maximal saved data also
(setq desktop-globals-to-save
      (append '((extended-command-history . 30)
                (file-name-history        . 100)
                (grep-history             . 30)
                (compile-history          . 30)
                (minibuffer-history       . 50)
                (query-replace-history    . 60)
                (read-expression-history  . 60)
                (regexp-history           . 60)
                (regexp-search-ring       . 20)
                (search-ring              . 20)
                (shell-command-history    . 50)
                tags-file-name
                register-alist)))

(defun add-to-path (path-element)
  "Add the specified path element to the Emacs PATH and exec-path"
  (if (file-directory-p path-element)
      (progn
	(setq expanded-path-element (expand-file-name path-element))
	(setenv "PATH"
		(concat (expand-file-name path-element)
			path-separator (getenv "PATH")))
	(setq exec-path (cons expanded-path-element exec-path)))))

;; start the server if not running
(load "server")
(unless (server-running-p)
  (server-start)
  (remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function))

;; init PATH from shell if on OSX
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)
  (setq mouse-wheel-scroll-amount (quote (0.01))))

;; magit rules
(global-set-key (kbd "C-x g") 'magit-status)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2))
(add-hook 'web-mode-hook  'my-web-mode-hook)

(require 'smartparens-config)
(require 'auto-complete)

;; TRAMP
(add-to-list 'load-path "~/.emacs.d/tramp/lisp")
(require 'tramp)
(setq tramp-default-method "ssh"
      tramp-persistency-file-name "~/.tramp-persistence-file")

;; js stuff
(add-hook 'js-mode-hook 'js2-minor-mode)
(add-hook 'js2-mode-hook 'ac-js2-mode)

;; go stuff
(exec-path-from-shell-copy-env "GOPATH")
(add-to-path "~/bin")
(add-to-path "~/go/bin")
(add-hook 'go-mode-hook (lambda () 
			  (flycheck-mode 1)
			  (setq flycheck-checker 'go-golint)
			  (setq flycheck-check-syntax-automatically '(mode-enabled idle-change))
			  (add-hook 'before-save-hook #'gofmt-before-save)

			  (setq gofmt-command "goimports")
			  (smartparens-mode 1)
			  ))

(require 'go-eldoc)
(add-hook 'go-mode-hook 'go-eldoc-setup)

(require 'go-autocomplete)
(require 'auto-complete-config)

;; markdown mode
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))


(defun font-existsp (font)
  "Tests whether a given font exists in the system."
  (if (null (x-list-fonts font))
      nil t))

;; Set font to Source Code Pro in systems that have it
(if (and (display-graphic-p) (font-existsp "Source Code Pro"))
    (progn
      (set-face-font 'default "Source Code Pro")
	  (require 'robteix-theme)
      (cond ((eq system-type 'darwin) (set-face-attribute 'default nil :height 160))
			((eq system-type 'gnu/linux) (set-face-attribute 'default nil :height 130)))))

;; rebox2
(defun rebox-setup ()
  ;;(set (make-local-variable 'rebox-style-loop) '(43 24 243))
  (set (make-local-variable 'rebox-min-fill-column) 70)
  (local-set-key [(meta q)] 'rebox-dwim)
  (local-set-key [(shift meta q)] 'rebox-cycle)
  (rebox-mode 1))

(add-hook 'prog-mode-hook 'rebox-setup)
(add-hook 'js-mode-hook 'rebox-setup)
