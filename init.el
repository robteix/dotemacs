(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
	  )

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
;; misc emacs stuff
(setq inhibit-startup-screen t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(show-paren-mode 1)

(defun add-to-path (path-element)
  "Add the specified path element to the Emacs PATH and exec-path"
  (if (file-directory-p path-element)
      (progn
	(setq expanded-path-element (expand-file-name path-element))
	(setenv "PATH"
		(concat (expand-file-name path-element)
			path-separator (getenv "PATH")))
	(setq exec-path (cons expanded-path-element exec-path)))))

;; init PATH from shell if on OSX
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(require 'smartparens-config)
(require 'auto-complete)


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

