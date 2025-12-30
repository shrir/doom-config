;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))

;; Start Doom fullscreen
(add-to-list 'default-frame-alist '(width . 92))
(add-to-list 'default-frame-alist '(height . 40))
;; (add-to-list 'default-frame-alist '(alpha 97 100))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
(global-display-line-numbers-mode 1)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)
(remove-hook! '(text-mode-hook) #'display-line-numbers-mode)

;; Icons stuff
(use-package nerd-icons-ibuffer
  :ensure t
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

;; Transparency
(add-to-list 'default-frame-alist '(alpha-background . 96))

;; Modeline
(setq doom-modeline-height 35)

;;; Enable Corfu (completion UI)
(use-package! corfu
  :init
  (global-corfu-mode)  ;; Make sure it's on everywhere
  :custom
  (corfu-auto t)         ;; Automatically show completions
  (corfu-auto-delay 0.2) ;; Short delay
  (corfu-auto-prefix 1)) ;; Start suggesting after 1 char

;;; Fuzzy matching with Orderless
(use-package! orderless
  :custom
  (completion-styles '(orderless basic)) ;; orderless for most, fallback basic
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; LSP integration for Pyright and Ruff
(setq lsp-completion-provider :capf) ;; use capf, needed for corfu

;;; Optional fix: ensure LSP completions are set correctly per buffer
(defun my/setup-lsp-completion ()
  (setq-local completion-at-point-functions
              (list #'lsp-completion-at-point)))

(add-hook 'lsp-mode-hook
          (lambda ()
            (setq-local completion-at-point-functions
                        (list (cape-super-capf
                               #'lsp-completion-at-point
                               #'cape-file)))))

;;; LSP UI tweaks
(use-package! lsp-ui
  :config
  (setq lsp-ui-doc-delay 2
        lsp-ui-doc-max-width 80
        lsp-signature-function 'lsp-signature-posframe))

;;; Start LSP in Python files
(add-hook 'python-mode-hook #'lsp-deferred)

;;; Set up Pyright for autocompletion (LSP server)
(use-package lsp-pyright
  :custom (lsp-pyright-langserver-command "pyright") ;; or basedpyright
  :after lsp-mode
  :config
  ;; Make sure lsp-pyright is the preferred LSP server for Python
  (setq lsp-pyright-auto-import-completions t)  ;; Enable auto-import completions
  (setq lsp-python-ms-executable "pyright")
  )

;; Prettier configuration
;;(use-package! prettier
;;  :hook ((typescript-mode . prettier-mode)
;;         (rjsx-mode . prettier-mode)
;;         (js2-mode . prettier-mode)))

;; Configure Black for Python formatting
(use-package blacken
  :hook (python-mode . blacken-mode))

;; Format on save for TypeScript, JavaScript, and Python
;;(add-hook 'before-save-hook 'prettier-mode) ;; Apply Prettier on save for JS/TS
(add-hook 'before-save-hook 'blacken-mode)  ;; Apply Black on save for Python

;; gptel LLM chat client (Key in ~/.authinfo)
(use-package! gptel
  :config
  (setq! gptel-api-key "gptel-api-key-from-auth-source"))

(setq gptel-model   'mistral-small-latest
      gptel-backend
      (gptel-make-openai "MistralLeChat"  ;Any name you want
        :host "api.mistral.ai"
        :endpoint "/v1/chat/completions"
        :protocol "https"
        :stream t
        :key 'gptel-api-key-from-auth-source
        :models '("mistral-small-latest"))) ;Default key is 'gptel-api-key-from-auth-source, which means use the key from ~/.authinfo

;; Aider config
(use-package aidermacs
  :bind (("C-c a" . aidermacs-transient-menu))
  :config

  ;; Retrieve OpenRouter API key from ~/.authinfo or ~/.authinfo.gpg
  (defun get-openrouter-api-key ()
    (let ((found (auth-source-pick-first-password :host "openrouter")))
      (if found
          found
        (error "No OpenRouter API key found in auth-source"))))

  ;; defun get-openrouter-api-key yourself elsewhere for security reasons
  (setenv "OPENROUTER_API_KEY" (get-openrouter-api-key))

  :custom
  ;; See the Configuration section below
  (aidermacs-default-chat-mode 'architect)
  (aidermacs-default-model "openrouter/mistralai/devstral-2512:free"))
