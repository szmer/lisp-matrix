;; License: MH, BSD/MIT -- fill in details!

;; DSL support tools.

(in-package :lisp-matrix)

(defun make-symbol* (&rest args)
  "build a symbol by concatenating each element of ARGS, and intern it
  in the current package.  Elements can be strings or symbols."
  (intern (apply #'concatenate 'string
                 (mapcar (lambda (arg)
                           (etypecase arg
                             (symbol (symbol-name arg))
                             (string arg)))
                         args))))

;;; (make-symbol* "test" "me")        =>   |testme| , :INTERNAL
;;; (make-symbol* "test" 'metoo "me") =>   |testMETOOme| , :INTERNAL
;;; (make-symbol* "TEsT" 'metoo "me") =>   |TEsTMETOOme| , :INTERNAL

(defun with-pkg-prefix (symb)
  "Wrap SYMB with lisp-matrix package prefix, which ensures the correct value
  is found when referencing the SYMB from an external package."
  `,(read-from-string (concatenate 'string
                                   "LISP-MATRIX:"
                                   (symbol-name symb))))
