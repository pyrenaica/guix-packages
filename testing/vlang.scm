;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2020 Ryan Prior <rprior@protonmail.com>

(define-module (testing vlang)
  #:use-module (gnu packages c)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages vlang)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

(define-public v-interim-1
  (package
    (name "v")
    (version "847a1035a5cd4455af52e29940fbde3785c82df5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/vlang/v.git")
             (commit version)))
       (file-name (git-file-name name version))
       ;; (sha256
       ;;  (base32 "00k05gjcmbgn0a53vn61vahwj68gjm3g263yffvqcr7fxpbfirc4"))
       (sha256 #f)
       ))
    (build-system gnu-build-system)
    (arguments
     '(#:tests? #f ; tests are broken in v 0.1.27
       #:make-flags
       `("CC=gcc"
         "GITCLEANPULL=true"
         "GITFASTCLONE=mkdir -p"
         "TCCREPO="
         "TMPTCC=tcc"
         ,(string-append "TMPVC=" (assoc-ref %build-inputs "vc"))
         "VCREPO="
         "VERBOSE=1"
         "V_ALWAYS_CLEAN_TMP=false")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'build
           (lambda _
             (invoke "v -cc gcc cmd/v")))
         (add-before 'build 'patch-makefile
           (lambda _
             (substitute* "Makefile"
               (("rm -rf") "true")
               (("v self") "v -cc gcc cmd/v"))
             #t))
         ;; A few tests are broken in v 0.1.27. This function should be
         ;; enabled to run tests in the next release.
         ;; (replace 'check
         ;;   (lambda _
         ;;     (let* ((tmpbin "tmp/bin")
         ;;            (gcc (which "gcc")))
         ;;       (mkdir-p tmpbin)
         ;;       (symlink gcc (string-append tmpbin "/cc"))
         ;;       (setenv "PATH" (string-append tmpbin ":" (getenv "PATH")))
         ;;       (invoke "./v" "test-fixed"))
         ;;     #t))
         (replace 'install
           (lambda _
             (let* ((bin (string-append (assoc-ref %outputs "out") "/bin"))
                    (tools (string-append bin "/cmd/tools"))
                    (thirdparty (string-append bin "/thirdparty"))
                    (vlib (string-append bin "/vlib"))
                    (vmod (string-append bin "/v.mod")))
               (mkdir-p bin)
               (copy-file "./v" (string-append bin "/v"))
               ;; v requires as of 0.1.27 that these other components are in the
               ;; same directory. In a future release we may be able to move
               ;; these into other output folders.
               (copy-recursively "cmd/tools" tools)
               (copy-recursively "thirdparty" thirdparty)
               (copy-recursively "vlib" vlib)
               (copy-file "v.mod" vmod))
             #t)))))
    (inputs
     `(("glib" ,glib)
       ("gcc" ,gcc)))
    (native-inputs
     `(("v" ,v)))
    (home-page "https://vlang.io/")
    (synopsis "Compiler for the V programming language")
    (description
     "V is a systems programming language.  It provides memory safety and thread
safety guarantees with minimal abstraction.")
    (license license:expat)))

v-interim-1
