;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2020 Ryan Prior <rprior@protonmail.com>

(define-module (experiments wrap-cc)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages c)
  #:use-module (gnu packages gcc)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module (guix build utils)
  #:use-module (guix utils)
  #:use-module (guix packages))

(define* (wrap-cc cc
                  #:optional
                  (bin (package-name cc))
                  (name (string-append (package-name cc) "-wrapper")))
  (package/inherit cc
    (name name)
    (source #f)
    (build-system trivial-build-system)
    (outputs '("out"))
    (propagated-inputs `(("cc" ,cc)))
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let ((bin-dir (string-append (assoc-ref %build-inputs "cc") "/bin/"))
               (wrapper-dir (string-append (assoc-ref %outputs "out") "/bin/")))
           (mkdir-p wrapper-dir)
           (symlink (string-append bin-dir ,bin)
                    (string-append wrapper-dir "cc"))))))
    (synopsis "Wrapper for c compilers")
    (description "This package provides wrappers for c compilers such that they
can be invoked under the name @command{cc}.")))

(define-public gcc-wrapper (wrap-cc gcc-toolchain "gcc" "gcc-wrapper"))
;; (define-public gcc-wrapper (wrap-cc gcc))
;; (define-public tcc-wrapper (wrap-cc tcc))

gcc-wrapper