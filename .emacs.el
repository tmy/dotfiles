;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Carbon emacs21 init file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq load-path (append '("~/Library/Lisp") load-path))
(setq exec-path (append '("/usr/local/bin") exec-path))
(setq exec-path (append '("/opt/local/bin") exec-path))

;;; 言語環境の指定
;(require 'un-define)
;(require 'jisx0213)
;(set-language-environment "Japanese")

;;; 初期設定ファイルの指定
;;; ここで指定したファイルにオプション設定等が書き込まれます
(setq user-init-file "~/.emacs-options.el")
(setq custom-file "~/.emacs-options.el")
(load-file "~/.emacs-options.el")

;;; 漢字コードの指定
;(set-default-coding-systems 'utf-8)
;(set-buffer-file-coding-system 'shift_jis-mac)
;(set-terminal-coding-system 'euc-jp)
;(set-keyboard-coding-system 'shift_jis-mac)
;(set-keyboard-coding-system 'utf-8)
;(set-clipboard-coding-system 'sjis-mac)
;(set-file-name-coding-system 'utf-8)
;(require 'mac-utf)
(load "utf-8m")
(set-file-name-coding-system 'utf-8m)

;;; Quartz 2D
;(setq mac-allow-anti-aliasing t)

(set-frame-parameter nil 'alpha 90)

;; ;;; Mac IM Patch
;; ;(progn
;; ;  (add-hook 'isearch-mode-hook 'mac-im-isearch-mode-setup)
;; ;  (add-hook 'isearch-mode-end-hook 'mac-im-isearch-mode-cleanup)
;; (if (eq window-system 'mac)
;;     (progn
;;       (global-set-key "\C-\\" 'mac-toggle-input-method)
;;       (add-hook 'minibuffer-setup-hook 'mac-change-language-to-us)
;;       ))

;; ;; Synergy 経由でバックスラッシュを入力すると « になっちゃうのを直す
;; (global-set-key [2219] '(lambda()(interactive)(insert 92)))

;; ;;; フォントの設定
(if (eq window-system 'mac)
    (progn
      (create-fontset-from-mac-roman-font
       "-apple-september-medium-r-normal--12-*-*-*-*-*-iso10646-1"
       nil
       "september12")
      (create-fontset-from-mac-roman-font
       "-apple-september-medium-r-normal--14-*-*-*-*-*-iso10646-1"
       nil
       "september14")
      (create-fontset-from-mac-roman-font
       "-apple-september-medium-r-normal--16-*-*-*-*-*-iso10646-1"
       nil
       "september16")
      (create-fontset-from-mac-roman-font
       "-apple-september-medium-r-normal--18-*-*-*-*-*-iso10646-1"
       nil
       "september18")
      (create-fontset-from-mac-roman-font
       "-apple-september-medium-r-normal--24-*-*-*-*-*-iso10646-1"
       nil
       "september24")
      (set-fontset-font "fontset-september12"
                        'japanese-jisx0208
                        '("セプテンバー*" . "jisx0208.*"))
      (set-fontset-font "fontset-september12"
                        'katakana-jisx0201
                        '("セプテンバー*" . "jisx0201.*"))
      (set-fontset-font "fontset-september14"
                        'japanese-jisx0208
                        '("セプテンバー*" . "jisx0208.*"))
      (set-fontset-font "fontset-september14"
                        'katakana-jisx0201
                        '("セプテンバー*" . "jisx0201.*"))
      (set-fontset-font "fontset-september16"
                        'japanese-jisx0208
                        '("セプテンバー*" . "jisx0208.*"))
      (set-fontset-font "fontset-september16"
                        'katakana-jisx0201
                        '("セプテンバー*" . "jisx0201.*"))
      (set-fontset-font "fontset-september18"
                        'japanese-jisx0208
                        '("セプテンバー*" . "jisx0208.*"))
      (set-fontset-font "fontset-september18"
                        'katakana-jisx0201
                        '("セプテンバー*" . "jisx0201.*"))
      (set-fontset-font "fontset-september24"
                        'japanese-jisx0208
                        '("セプテンバー*" . "jisx0208.*"))
      (set-fontset-font "fontset-september24"
                        'katakana-jisx0201
                        '("セプテンバー*" . "jisx0201.*"))
      (add-to-list 'default-frame-alist '(font . "fontset-september14"))
      ))

;; ;;; Wnn7 setup
;; ;; (if (string-match "imjp\\.co\\.jp$" (system-name))
;; ;;     (progn
;; ;;       (global-set-key "\C-\\" 'toggle-input-method)
;; ;;       (setq load-path (append '("~/Library/Lisp/wnn7") load-path))
;; ;;       (setq wnn7-server-name "linux3.imjp.co.jp")
;; ;;       (load "wnn7egg-leim")
;; ;;       (set-input-method "japanese-egg-wnn7")
;; ;;       (set-language-info "Japanese" 'input-method "japanese-egg-wnn7")
;; ;;       (if (boundp 'fence-mode-map)
;; ;;           (progn
;; ;;             (define-key fence-mode-map [f1] 'fence-mode-help-command)
;; ;;             (define-key fence-mode-map [f2] 'egg-use-input-predict)
;; ;;             (define-key fence-mode-map [f3] 'egg-unuse-input-predict)
;; ;;             (define-key fence-mode-map "\C-h" 'fence-backward-delete-char)
;; ;;             (define-key fence-mode-map [delete] 'fence-backward-delete-char)
;; ;;             (define-key fence-mode-map [backspace] 'fence-backward-delete-char)
;; ;;             (define-key fence-mode-map [(shift space)] 'fence-self-insert-command)
;; ;;             (define-key fence-mode-map [tab] 'egg-predict-start-parttime)
;; ;;             ))
;; ;;       (if (boundp 'henkan-mode-map)
;; ;;           (progn
;; ;;             (define-key henkan-mode-map [f1] 'henkan-mode-help-command)
;; ;;             (define-key fence-mode-map "\C-h" 'henkan-quit)
;; ;;             ))
;; ;;       (setq enable-double-n-syntax t) ; ``nn'' を ``ん'' にする
;; ;;       (egg-use-input-predict) ; 先読み
;; ;;       ))


;;;キーバインド
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\M-r" 'query-replace-regexp)
(global-set-key "\M-n" 'special-symbol-input)
(global-set-key "\M- " 'dabbrev-expand)
(global-set-key "\M-/" 'dabbrev-expand)
;(global-set-key "\M-/" 'expand-abbrev)
;(global-set-key "\C-\　" 'set-mark-command)


;;; 一行が 80 字以上になった時には自動改行する
;(setq fill-column 80)
;(setq text-mode-hook 'turn-on-auto-fill)
(setq default-major-mode 'text-mode)

;;;行数表示
;(custom-set-variables '(line-number-mode t))

(setq make-backup-files nil)        ; backupファイルを作成しない
(setq kill-whole-line nil)  ;一行全消し


;;; emacsclient サーバを起動
(server-start)

;;; gzファイルも編集できるように
(auto-compression-mode t)
;;; 画像表示
(auto-image-file-mode)

;;;
;;; emacs -nw ではmenu-barなんかいらない
(if window-system (menu-bar-mode 1) (menu-bar-mode -1))

;;; スクロールバーを右側に表示する
(set-scroll-bar-mode 'right)

;;; iswitchb
(iswitchb-mode 1)
(add-hook 'iswitchb-define-mode-map-hook
          (lambda ()
            (define-key iswitchb-mode-map "\C-n" 'iswitchb-next-match)
            (define-key iswitchb-mode-map "\C-p" 'iswitchb-prev-match)
            (define-key iswitchb-mode-map "\C-f" 'iswitchb-next-match)
            (define-key iswitchb-mode-map "\C-b" 'iswitchb-prev-match)))

;;;バッファの最後でnewlineで新規行を追加するのを禁止する
(setq next-line-add-newlines nil)

;;; sgml-mode で auto-fill-mode を無効に
(add-hook 'sgml-mode-hook
          '(lambda()
             (auto-fill-mode nil)))
(add-hook 'html-mode-hook
          '(lambda()
             (auto-fill-mode nil)))

(add-to-list 'auto-mode-alist '("\\.jsp$" . html-mode))

;;; 最終更新日の自動挿入
;;;   ファイルの先頭から 8 行以内に Time-stamp: <> または
;;;   Time-stamp: " " と書いてあれば、セーブ時に自動的に日付が挿入されます
(if (not (memq 'time-stamp write-file-functions))
    (setq write-file-functions
          (cons 'time-stamp write-file-functions)))

;;; CVS 版 Carbon Emacs で TRAMP が動かない問題の workarond
;;; see http://mail.gnu.org/archive/html/emacs-devel/2003-04/msg00789.html
;(setq process-connection-type t)

; cperl-mode
;(autoload 'perl-mode "cperl-mode" "alternate mode for editing Perl programs" t)
;; ;; Mew
;; ;(load-file "~/.mew.el")

;; w3m
(autoload 'w3m "w3m" "Interface for w3m on Emacs." t)

;; ;;; lookup の設定
;; (setq load-path (cons "~/Library/Lisp/lookup" load-path))
;; (autoload 'lookup "lookup" nil t)
;; (autoload 'lookup-region "lookup" nil t)
;; (autoload 'lookup-pattern "lookup" nil t)
;; (define-key ctl-x-map "l" 'lookup)
;; (define-key ctl-x-map "y" 'lookup-region)
;; (define-key ctl-x-map "\C-y" 'lookup-pattern)
;; (setq lookup-search-agents
;;       '((ndeb "/Users/tommy/Library/Dictionaries/KENKYUSHA_CHUJITEN"
;;               :appendix "/Users/tommy/Library/Dictionaries/appendix/chujiten")))

;; psvn
(require 'psvn)
(setq svn-status-coding-system 'utf-8)
(setq svn-status-svn-environment-var-list '("LANG=ja_JP.UTF-8"))
(setq svn-status-hide-unmodified t)

(load-file "~/Library/Lisp/cedet/speedbar/speedbar.el")
;; CEDET
;(load-file "~/Library/Lisp/cedet/common/cedet.el")
;; Enabling various SEMANTIC minor modes.  See semantic/INSTALL for more ideas.
;; Select one of the following
;;(semantic-load-enable-code-helpers)
;; (semantic-load-enable-guady-code-helpers)
;(semantic-load-enable-excessive-code-helpers)
;;semantic cache is ~/.semantic
;(setq semanticdb-default-save-directory (expand-file-name "~/.semantic"))
;; Enable this if you develop in semantic, or develop grammars
;; (semantic-load-enable-semantic-debugging-helpers)

;; ;; ECB
;; (add-to-list 'load-path "~/Library/Lisp/ecb")
;; (require 'ecb)
;; (setq ecb-tip-of-the-day nil)
;; (setq ecb-windows-width 0.2)

;; (defun ecb-toggle ()
;;   (interactive)
;;   (if ecb-minor-mode
;;       (ecb-deactivate)
;;     (ecb-activate)))
;; (global-set-key [f2] 'ecb-toggle)


;; ;; FreeStyle Wiki
;; (autoload 'fswiki-mode "fswiki" "Major mode for editing FreeStyle Wiki data files." t)
;; (add-to-list 'auto-mode-alist '("\\.wiki$" . fswiki-mode))

;; ;; Hiki
;; ;(setq hiki-site-list '(("Local-Hiki" "http://localhost/hiki/")))
;; ;(require 'hiki-mode)

;; ;; Graphviz dot mode
;; (autoload 'graphviz-dot-mode "dot" "Major mode for editing Graphviz dot files." t)
;; (add-to-list 'auto-mode-alist '("\\.dot$" . graphviz-dot-mode))

;; ;; Curl mode
;; (autoload 'curl-mode "Curl" "Major mode for editing Curl code." t)
;; (add-to-list 'auto-mode-alist '("\\.curl$" . curl-mode))
;; (add-to-list 'auto-mode-alist '("\\.surl$" . curl-mode))
;; (add-to-list 'auto-mode-alist '("\\.purl$" . curl-mode))
;; (add-to-list 'auto-mode-alist '("\\.murl$" . curl-mode))

;; ;; PHP mode
;; (require 'php-mode)
;; (add-hook 'php-mode-user-hook 'turn-on-font-lock)
;; (add-to-list 'auto-mode-alist '("\\.php[34]?\\'" . php-mode))
(autoload 'smarty-mode "smarty-mode" "Major mode for editing Smarty template files." t)
;(add-to-list 'auto-mode-alist '("\\.tpl$" . smarty-mode))

;; ;; CSS mode
;; (autoload 'css-mode "css-mode" "Major mode for editing CSS files." t)
;; (add-to-list 'auto-mode-alist '("\\.css$" . css-mode))

;; ;; ecmascript-mode
;; (autoload 'ecmascript-mode "ecmascript-mode" "Major mode for editing ECMAScript code." t)
;; (add-to-list 'auto-mode-alist '("\\.js$" . ecmascript-mode))
;; ;(add-to-list 'auto-mode-alist '("\\.js\\'" . javascript-mode))
;; (autoload 'javascript-mode "javascript" nil t)
;; (setq javascript-indent-level 4)

;; js2-mode
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; ;; csharp-mode
;; (autoload 'csharp-mode "csharp-mode" "Major mode for editing C# files." t)
;; (add-to-list 'auto-mode-alist '("\\.cs$" . csharp-mode))

;; ;; ruby-mode
(require 'ruby-mode)
;(autoload 'ruby-mode "ruby-mode" "Major mode for editing Ruby files." t)
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode))
                                     interpreter-mode-alist))
(autoload 'run-ruby "inf-ruby" "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook
          '(lambda ()
             (inf-ruby-keys)))
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
;(add-to-list 'auto-mode-alist '("\\.rhtml$" . ruby-mode))
(modify-coding-system-alist 'file "\\.rb$" 'utf-8)
(modify-coding-system-alist 'file "\\.rhtml$" 'utf-8)

;; ;;; mmm-mode
(require 'mmm-auto)
(setq mmm-global-mode 'maybe)
(setq mmm-submode-decoration-level 2)
;(set-face-background 'mmm-output-submode-face  "DarkOrchid4")
;(set-face-background 'mmm-code-submode-face    "LightCyan")
;(set-face-background 'mmm-comment-submode-face "LightPink")

;; ;(mmm-add-mode-ext-class 'html-mode "\\.php\\'" 'html-php)
;; ;; set up an mmm group for fancy html editing
;; (mmm-add-group
;;  'fancy-html
;;  '(
;;    (html-php-tagged
;;     :submode php-mode
;;     :face mmm-code-submode-face
;;     :front "<[?]php"
;;     :back "[?]>")
;;    (js-tag
;;     :submode ecmascript-mode
;;     :face mmm-code-submode-face
;;     :delimiter-mode nil
;;     :front "<script\[^>\]*\\(language=\"javascript\\([0-9.]*\\)\"\\|type=\"text/javascript\"\\)\[^>\]*>"
;;     :back"</script>"
;;     :insert ((?j js-tag nil @ "<script language=\"JavaScript\">"
;;                  @ "\n" _ "\n" @ "</script>" @))
;;     )
;;    (js-inline
;;     :submode ecmascript-mode
;;     :face mmm-code-submode-face
;;     :delimiter-mode nil
;;     :front "on\\w+=\""
;;     :back "\"")
;;    (html-css-attribute
;;     :submode css-mode
;;     :face mmm-declaration-submode-face
;;     :front "style=\""
;;     :back "\"")))
;; ;(add-to-list 'auto-mode-alist '("\\.php[34]?\\'" . html-mode))
;; ;(add-to-list 'mmm-mode-ext-classes-alist '(html-mode nil html-js))
;; (add-to-list 'mmm-mode-ext-classes-alist '(html-mode nil embedded-css))
;; (add-to-list 'mmm-mode-ext-classes-alist '(html-mode nil fancy-html))

(mmm-add-classes
 '((mmm-css
    :submode css-mode
;;    :face mmm-code-submode-face
;;    :front "<style[^>]*>¥¥([^<]*¥¥)?¥n[ ¥t]*</style>"
    :front "<style[^>]*>"
    :back "</style>"
    )
   (mmm-javascript
    :submode javascript-mode
;;    :face mmm-code-submode-face
    :front "<script[^>]*>[^<]"
    :front-offset -1
    :back "</script>"
    )
   (mmm-eruby
    :submode ruby-mode
    :match-face (("<%#" . mmm-comment-submode-face)
                 ("<%=" . mmm-output-submode-face)
                 ("<%"  . mmm-code-submode-face))
    :front "<%[#=]?"
    :back "-?%>"
    :insert ((?% erb-code       nil @ "<%"  @ " " _ " " @ "%>" @)
             (?# erb-comment    nil @ "<%#" @ " " _ " " @ "%>" @)
             (?= erb-expression nil @ "<%=" @ " " _ " " @ "%>" @)))
   (mmm-smarty
    :submode smarty-mode
    :front "{{"
    :back "}}")
   (mmm-php
    :submode php-mode
    :front "<\\?\\(php\\)?"
    :back "\\(\\?>\\|\\'\\)")))
(mmm-add-mode-ext-class 'html-mode nil 'mmm-css)
(mmm-add-mode-ext-class 'html-mode nil 'mmm-javascript)
(mmm-add-mode-ext-class 'html-mode nil 'mmm-smarty)
(mmm-add-mode-ext-class 'sgml-mode nil 'mmm-css)
(mmm-add-mode-ext-class 'sgml-mode nil 'mmm-javascript)
(mmm-add-mode-ext-class 'sgml-mode nil 'mmm-smarty)
(mmm-add-mode-ext-class nil "\\.rhtml$" 'mmm-eruby)
(mmm-add-mode-ext-class nil "\\.php$" 'mmm-php)
(add-to-list 'auto-mode-alist '("\\.rhtml$" . html-mode))
(add-to-list 'auto-mode-alist '("\\.php$" . html-mode))

;; Rails
(defun try-complete-abbrev (old)
  (if (expand-abbrev) t nil))
(setq hippie-expand-try-functions-list
      '(try-complete-abbrev
        try-complete-file-name
        try-expand-dabbrev))

(require 'snippet)
(require 'rails)

;(define-key rails-minor-mode-map [(control m)] 'rails-nav:goto-models)
;(define-key rails-minor-mode-map [(control ,)] 'rails-nav:goto-controllers)
;(define-key rails-minor-mode-map [(control .)] 'rails-nav:goto-helpers)
;(define-key rails-minor-mode-map [(control /)] 'rails-find-config)
;(define-key rails-minor-mode-map [(control up)] 'rails-lib:run-primary-switch)
;(define-key rails-minor-mode-map [(control down)] 'rails-lib:run-primary-switch)
;(define-key rails-minor-mode-map [(control left)] 'rails-lib:run-secondary-switch)
;(define-key rails-minor-mode-map [(control right)] 'rails-lib:run-secondary-switch)

;; (add-hook 'ruby-mode-hook
;;           (lambda()
;;             (add-hook 'local-write-file-hooks
;;                       '(lambda()
;;                          (save-excursion
;;                            (untabify (point-min) (point-max))
;;                            (delete-trailing-whitespace)
;;                            )))
;;             (set (make-local-variable 'indent-tabs-mode) 'nil)
;;             (set (make-local-variable 'tab-width) 2)
;;             (imenu-add-to-menubar "IMENU")
;;             (require 'ruby-electric)
;;             (ruby-electric-mode t)
;;             ))


;;; tab と行末 space に色をつける
;`(defface my-face-b-1 '((t (:foreground "#800000" :underline t))) nil)
;(defface my-face-u-1 '((t (:foreground "#808000" :underline t))) nil)
;(defvar my-face-b-1 'my-face-b-1)
;(defvar my-face-u-1 'my-face-u-1)
;(defadvice font-lock-mode (before my-font-lock-mode ())
;  (font-lock-add-keywords
;   major-mode
;   '(("\t" 0 my-face-b-1 append)
;     ("[ \t]+$" 0 my-face-u-1 append)
;     )))
;(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
;(ad-activate 'font-lock-mode)

;; ;;; cperl モードの方が強力らしい
;; ;(setq perl-mode-hook
;; ;      '(lambda ()(cperl-mode)
;; ;      ))

;; ;;; Relax/Relax NG
;; (add-to-list 'auto-mode-alist '("\\.rxl$" . xml-mode))
;; (add-to-list 'auto-mode-alist '("\\.rxm$" . xml-mode))
;; (add-to-list 'auto-mode-alist '("\\.rng$" . xml-mode))

;; Gauche
(setq scheme-program-name "/opt/local/bin/gosh -i")
(autoload 'scheme-mode "cmuscheme" "Major mode for Scheme." t)
(autoload 'run-scheme "smuscheme" "Run an inferior Scheme process." t)
(defun scheme-other-window ()
  "Run scheme on other window"
  (interactive)
  (switch-to-buffer-other-window
   (get-buffer-create "*scheme*"))
  (run-scheme scheme-program-name))
(define-key global-map
  "\C-cS" 'scheme-other-window)

;; ;--- GNU GLOBAL(gtags) gtags.el ---
;; (autoload 'gtags-mode "gtags" "" t)
;; (setq gtags-mode-hook
;;       '(lambda ()
;;     (local-set-key "\M-t" 'gtags-find-tag)     ;関数の定義元へ
;;     (local-set-key "\M-r" 'gtags-find-rtag)    ;関数の参照先へ
;;     (local-set-key "\M-s" 'gtags-find-symbol)  ;変数の定義元/参照先へ
;; ;       (local-set-key "\C-t" 'gtags-pop-stack)  ;前のバッファに戻る
;;    ))
;; ;
;; (global-set-key "\C-cgt" 'gtags-find-tag)    ;関数の定義元へ
;; (global-set-key "\C-cgr" 'gtags-find-rtag)   ;関数の参照先へ
;; (global-set-key "\C-cgs" 'gtags-find-symbol) ;変数の定義元/参照先へ
;; (global-set-key "\C-cgf" 'gtags-find-file)
;; (global-set-key "\C-cgp" 'gtags-find-pattern)
;; (global-set-key "\C-cg." 'gtags-find-tag-from-here)
;; (global-set-key "\C-cg*" 'gtags-pop-stack)
;; (global-set-key "\C-c*" 'gtags-pop-stack)    ;前のバッファに戻る
;; ;(global-set-key "\C-cg" 'gtags-mode)

;; ;;; wl
;; ;(autoload 'wl "wl" "Wanderlust" t)
;; ;(autoload 'wl-draft "wl-draft" "Write draft with Wanderlust." t)


;;; 先頭が #! で始まるファイルは実行権をつけて保存
(add-hook 'after-save-hook
      'executable-make-buffer-file-executable-if-script-p)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; このファイルに間違いがあった場合に全てを無効にします
;(put 'eval-expression 'disabled nil)

;;;; 保存時にバイトコンパイル
;Local variables:
;after-save-hook: (lambda () (byte-compile-file "~/.emacs.el"))
;End:
