;;; need license and etc data.

(in-package :lisp-matrix)

(defmacro with-typed-values ((&rest bindings) matrix &body body)
  "Each binding in BINDINGS is of the form (VARIABLE VALUE).  VARIABLE
  is bound to VALUE coerced to the element type of MATRIX."
  (with-unique-names (element-type)
    (labels ((make-coerced-binding (binding)
               (destructuring-bind (variable value) binding
                 `(,variable (coerce ,value ,element-type)))))
     `(let ((,element-type (element-type ,matrix)))
        (let (,@(mapcar #'make-coerced-binding bindings))
          ,@body)))))

(defgeneric m* (a b)
  (:documentation "Matrix multiplication: A * B.")
  (:method ((a matrix-like) (b matrix-like))
    (with-typed-values ((one 1)
                        (zero 0)) a
      (let ((c (make-matrix (nrows a) (ncols b)
                            :element-type (element-type a))))
        (gemm one a b zero c)))))

(defgeneric m+ (a b)
  (:documentation "Matrix addition: A + B.")
  (:method ((a matrix-like) (b matrix-like))
    (with-typed-values ((one 1)) a
      (axpy one a (copy b)))))

(defgeneric m- (a b)
  (:documentation "Matrix subtraction: A - B.")
  (:method ((a matrix-like) (b matrix-like))
    (with-typed-values ((minus-one -1)) a
      (axpy minus-one b (copy a)))))

;; TODO: SUM is not yet done
#+ (or)
(defgeneric sum (matrix)
  (:documentation "")
  (:method ((matrix matrix-like))
    (asum matrix)))


;;; We need to consider the equivalent of rbind/cbind operations, for
;;; building larger matrices from smaller but "dimension-matching"
;;; matrices. 


;; next variant, bind, should handle "unlimited" arguments to bind
;; together
(defgeneric bind2 (type m1 m2)
  (:documentation "Simple experiment, not necessarily part of the API
  yet!  When type is :row, If the number of columns of m1 and m2
  match, join them.  Think of a sandwich approach, resulting in:

         m1
         --
         m2 

  The ARGS can be matrices, vectors, or lists. Arguments are bound
  into a matrix along their rows. Example:

    (bind2 :rows #2a((1 2)(3 4)) #(5 6)) returns #2a((1 2)(3 4)(5 6))


  When type is :column, if the number of rows of m1 and m2 match, join 
  them.  Think of a pair of columns, resulting in 
 
         m1 | m2 

  API should result with the ARGS as matrices, vectors, or
  lists. Arguments are bound into a matrix along their columns.
  Example: 
    (bind2 :columns #2a((1 2)(3 4)) #(5 6)) returns #2a((1 2 5)(3 4 6))"))


;;; also on the list would be outer-product, but that should come from
;;; LAPACK?
