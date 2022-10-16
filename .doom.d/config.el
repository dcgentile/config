;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq lsp-julia-package-dir nil)
(setq lsp-julia-default-environment "~/.julia/environments/v1.0")

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :hook (after-init . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

(setq org-capture-templates
      '("s" "Slipbox" entry (file "~/org-roam/inbox.org")
       "* %?\n"))
;; org-roam related things
(after! org-roam
  (setq org-roam-directory "~/org-roam")

  (add-hook 'after-init-hook 'org-roam-mode)

  ;; Let's set up some org-roam capture templates
  (setq org-roam-capture-templates
        (quote (("d" "default" plain "%?"
                 :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                     "#+title: ${title}\n#+filetags: \n")
                 :file-name "%<%Y-%m-%d-%H%M%S>-${slug}"
                 :head "#+title: ${title}\n"
                 :unnarrowed t)
                ("m" "main" plain
                 "%?"
                 :if-new (file+head "main/${slug}.org"
                                    "#+title: ${title}\n")
                 :immediate-finish t
                 :unarrowed t)
                ("r" "reference" plain
                 "%?"
                 :if-new (file+head "reference/${title}.org"
                                    "#+title: ${title}\n")
                 :immediate-finish t
                 :unarrowed t)
                ("a" "article" plain
                 "%?"
                 :if-new (file+head "articles/${title}.org"
                                    "#+title: ${title}\n#+filetags:     :arti")
                 :immediate-finish t
                 :unarrowed t)
                ))))
(with-eval-after-load 'org-roam
  (cl-defmethod org-roam-node-type ((node org-roam-node))
    "Return the TYPE of NODE."
    (condition-case nil
        (file-name-nondirectory
         (directory-file-name
          (file-name-directory
           (file-relative-name (org-roam-node-file node) org-roam-directory))))
      (error "")))
  )

(setq org-roam-node-display-template
      (concat "${type:15} ${title:*} " (propertize "${tags:10}" 'face 'org-tag)))

(defun jethro/org-capture-slipbox ()
  (interactive)
  (org-capture nil "s"))

(defun jethro/org-roam-node-from-cite (keys-entries)
  (interactive (list (citar-select-ref :multiple nil :rebuild-cache t)))
  (let ((title (citar--format-entry-no-widths (cdr keys-entries)
                                                                "${author editor} :: ${title}")))
               (org-roam-capture- :templates
               '(("r" "reference" plain "%?" :if-new
                  (file+head "reference/${citekey}.org"
                             ":PROPERTIES:
:ROAM_REFS: [cite:@${citekey}]
:END:
#+title: ${title}\n")
                  :immediate-finish t
                  :unnarrowed t))
               :info (list :citekey (car keys-entries))
               :node (org-roam-node-create :title title)
               :props '(:finalize find-file))))

(defun jethro/tag-new-node-as-draft ()
  (org-roam-tag-add '("draft")))
(add-hook 'org-roam-capture-new-node-hook #'jethro/tag-new-node-as-draft)

(setq org-roam-dailies-directory "daily/")

(setq org-roam-dailies-capture-templates
      '(("d" "default" entry
         "* %?"
         :target (file+head "%<%Y-%m-%d>.org"
                            "#+title: %<%Y-%m-%d>\n"))))
(defun org-roam-capture-pdf-active-region ()
      (let* ((pdf-buf-name (plist-get org-capture-plist :original-buffer))
             (pdf-buf (get-buffer pdf-buf-name)))
        (if (buffer-live-p pdf-buf)
            (with-current-buffer pdf-buf
              (car (pdf-view-active-region-text)))
           (user-error "Buffer %S not alive" pdf-buf-namee))))

;;(add-to-list 'org-latex-classes
               ;;'("apa6"
                 ;;"\\documentclass{apa6}"
                 ;;("\\section{%s}" . "\\section*{%s}")
                 ;;("\\subsection{%s}" . "\\subsection*{%s}")
                 ;;("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ;;("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ;;("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

;; helm-bibtex related stuff
(after! helm
  (use-package! helm-bibtex
    :custom
    ;; In the lines below I point helm-bibtex to my default library file.
    (bibtex-completion-bibliography '("~/Zotero/bibtex/library.bib"))
    (reftex-default-bibliography '("~/Zotero/bibtex/library.bib"))
    ;; The line below tells helm-bibtex to find the path to the pdf
    ;; in the "file" field in the .bib file.
    (bibtex-completion-pdf-field "file")
    :hook (Tex . (lambda () (define-key Tex-mode-map "\C-ch" 'helm-bibtex))))
  ;; I also like to be able to view my library from anywhere in emacs, for example if I want to read a paper.
  ;; I added the keybind below for that.
  (map! :leader
        :desc "Open literature database"
        "o l" #'helm-bibtex)
  ;; And I added the keybinds below to make the helm-menu behave a bit like the other menus in emacs behave with evil-mode.
  ;; Basically, the keybinds below make sure I can scroll through my list of references with C-j and C-k.
  (map! :map helm-map
        "C-j" #'helm-next-line
        "C-k" #'helm-previous-line)
)


 ;; Set up org-ref stuff
 (use-package! org-ref
    :custom
    ;; Again, we can set the default library
    (org-ref-default-bibliography "~/Zotero/bibtex/library.bib"))
    ;; The default citation type of org-ref is cite:, but I use citep: much more often
    ;; I therefore changed the default type to the latter.
    ;;(org-ref-default-citation-link "citep")

 ;; The function below allows me to consult the pdf of the citation I currently have my cursor on.
 (defun my/org-ref-open-pdf-at-point ()
  "Open the pdf for bibtex key under point if it exists."
  (interactive)
  (let* ((results (org-ref-get-bibtex-key-and-file))
         (key (car results))
         (pdf-file (funcall org-ref-get-pdf-filename-function key)))
    (if (file-exists-p pdf-file)
        (find-file pdf-file)
      (message "No PDF found for %s" key))))

  (setq org-ref-completion-library 'org-ref-ivy-cite
        org-export-latex-format-toc-function 'org-export-latex-no-toc
        org-ref-get-pdf-filename-function
        (lambda (key) (car (bibtex-completion-find-pdf key)))
        ;; See the function I defined above.
        org-ref-open-pdf-function 'my/org-ref-open-pdf-at-point
        ;; For pdf export engines.
        org-latex-pdf-process (list "latexmk -pdflatex='%latex -shell-escape -interaction nonstopmode' -pdf -bibtex -f -output-directory=%o %f")
        ;; I use orb to link org-ref, helm-bibtex and org-noter together (see below for more on org-noter and orb).
        org-ref-notes-function 'orb-edit-notes)
  (require 'org-ref-arxiv)
 ;;
 ;; org-noter stuff
  (after! org-noter
    (setq
          org-noter-notes-search-path '("~/org-roam/")
          org-noter-hide-other nil
          org-noter-separate-notes-from-heading t
          org-noter-always-create-frame nil)
    (map!
     :map org-noter-doc-mode-map
     :leader
     :desc "Insert note"
     "m i" #'org-noter-insert-note
     :desc "Insert precise note"
     "m p" #'org-noter-insert-precise-note
     :desc "Go to previous note"
     "m k" #'org-noter-sync-prev-note
     :desc "Go to next note"
     "m j" #'org-noter-sync-next-note
     :desc "Create skeleton"
     "m s" #'org-noter-create-skeleton
     :desc "Kill session"
     "m q" #'org-noter-kill-session
     )
  )
 ;; org-roam-bibtex stuff
(use-package! org-roam-bibtex
  :after org-roam
  :config
  (require 'org-ref)) ; optional: if using Org-ref v2 or v3 citation links

;; Here are some additional functions/macros that could help you configure Doom:
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
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
