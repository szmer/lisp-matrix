;;; -*- mode: lisp -*-
;;; Copyright (c) 2007, by A.J. Rossini <blindglobe@gmail.com>
;;; See COPYRIGHT file for any additional restrictions (BSD license).
;;; Since 1991, ANSI was finally finished.  Edited for ANSI Common Lisp. 

;;; This is semi-external to lisp-matrix core package.  The dependency
;;; should be that lisp-matrix packages are dependencies for the unit
;;; tests.  However, where they will end up is still to be
;;; determined. 

;; (asdf:oos 'asdf:compile-op 'lisp-matrix)
;; (asdf:oos 'asdf:load-op 'lisp-matrix)
(in-package :lisp-matrix-unittests)

;;; EXTERNAL

(defun run-lisp-matrix-tests ()
  "Check everything...!"
  (run-tests :suite 'lisp-matrix-ut))

;;(defun run-lisp-matrix-test (&rest x) (run-test x))

;;(run-lisp-matrix-tests)
;;(describe (run-lisp-matrix-tests))

;;; SUPPORT FUNCTIONS

(defun random-array (n m)
  "Return a random 2D array of size N x M.  Useful as input into a
make-matrix initial contents, reproducible if we set seed initially."
  (make-array (list n m)
              :element-type 'double-float
              :initial-contents
              (loop for i below n collect
                    (loop for j below m collect
                          (random 1d0)))))
;; (random-array 2 3)

(defmacro test-matrix-size (matrix n m)
  "test all size functions of MATRIX against N and M"
  `(progn
     (ensure (= (nrows ,matrix) ,n))
     (ensure (= (ncols ,matrix) ,m))
     (ensure (= (nelts ,matrix) (* ,n ,m)))
     (ensure (= (matrix-dimension ,matrix 0) ,n))
     (ensure (= (matrix-dimension ,matrix 1) ,m))
     (ensure-error (matrix-dimension ,matrix 2))
     (ensure-error (matrix-dimension ,matrix -1))
     (ensure (equal (matrix-dimensions ,matrix)
		    (list ,n ,m)))))

;;(test-matrix-size (make-matrix 2 5
;; 			       :implementation :lisp-array 
;; 			       :element-type 'double-float
;; 			       :initial-contents '((1d0 2d0 3d0 4d0 5d0)
;; 						   (6d0 7d0 8d0 9d0 10d0)))
;; 		  2 5)


(defmacro for-implementations ((&rest implementations) &body body)
  "Execute BODY for each implementation in IMPLEMENTATIONS."
  `(progn
     ,@(loop for implementation in implementations collect
             `(let ((*default-implementation* ,implementation)
                    (*default-element-type* 'double-float))
                ,@body))))

(defmacro for-all-implementations (&body body)
  `(for-implementations ,(mapcar #'car *implementations*)
     ,@body))



;;; TESTS

(deftestsuite lisp-matrix-ut () ())
;; (deftestsuite lisp-matrix-ut-matrix-foreign (lisp-matrix-ut) ())
;; (deftestsuite lisp-matrix-ut-matrix-lisp (lisp-matrix-ut) ())


(addtest (lisp-matrix-ut)
  wrong-data-initially
  (ensure-error  ;; because data is integer, not double-float!
    (let ((m1  (make-matrix 2 5
		      :implementation :lisp-array 
		      :element-type 'double-float
		      :initial-contents '((1d0 2d0 3d0 4d0 5d0)
					  (6d0 7 8 9 10)))))
      m1)))

(addtest (lisp-matrix-ut)
  right-data-initially
  (let ((m1 (make-matrix 2 5
			 :implementation :lisp-array 
			 :element-type 'double-float
			 :initial-contents '((1d0 2d0 3d0 4d0 5d0)
					     (6d0 7d0 8d0 9d0 10d0)))))
    (ensure (= (nrows m1) n))
    (ensure (= (ncols m1) m))
    (ensure (= (nelts m1) (* n m)))
    (ensure (= (matrix-dimension m1 0) n))
    (ensure (= (matrix-dimension m1 1) m))
    (ensure-error (matrix-dimension m1 2))
    (ensure-error (matrix-dimension m1 -1))
    (ensure (equal (matrix-dimensions matrix)
		   (list n m)))))
   


;; combinations...
(addtest (lisp-matrix-ut)
  data-initialize
  (ensure-error  
    ;; because data is integer, not double-float!
    (let ((m1  (make-matrix 2 5
		      :implementation :lisp-array 
		      :element-type 'double-float
		      :initial-contents '((1d0 2d0 3d0 4d0 5d0)
					  (6d0 7 8 9 10)))))
      m1))
  (ensure
   ;; because data is double-float, nil-return is success
   (not
    (let ((m1 (make-matrix 2 5
			   :implementation :lisp-array 
			   :element-type 'double-float
			   :initial-contents '((1d0 2d0 3d0 4d0 5d0)
					       (6d0 7d0 8d0 9d0 10d0)))))
      m1))))


;; combination + progn
(addtest (lisp-matrix-ut)
  data-initialize
  (progn
    (ensure-error  
      ;; because data is integer, not double-float!
      (let ((m1  (make-matrix 2 5
			      :implementation :lisp-array 
			      :element-type 'double-float
			      :initial-contents '((1d0 2d0 3d0 4d0 5d0)
						  (6d0 7 8 9 10)))))
	m1))
    (ensure
     ;; because data is double-float, nil-return is success
     (not
      (let ((m1 (make-matrix 2 5
			     :implementation :lisp-array 
			     :element-type 'double-float
			     :initial-contents '((1d0 2d0 3d0 4d0 5d0)
						 (6d0 7d0 8d0 9d0 10d0)))))
	m1)))))

;; macro within a macro

(defmacro silly-test (b2 b5)
  `(let ((m1 (make-matrix ,b2 ,b5
			   :implementation :lisp-array 
			   :element-type 'double-float
			   :initial-contents '((1d0 2d0 3d0 4d0 5d0)
					       (6d0 7d0 8d0 9d0 10d0)))))

      m1))


(defmacro silly-test2 (b2 b5)
  `(not (let ((m1 (make-matrix ,b2 ,b5
			       :implementation :lisp-array 
			       :element-type 'double-float
			       :initial-contents '((1d0 2d0 3d0 4d0 5d0)
						   (6d0 7d0 8d0 9d0 10d0)))))
	  m1)))


(addtest (lisp-matrix-ut)
  silly-macro-test-1
  (ensure (silly-test 2 5)))


(addtest (lisp-matrix-ut)
  silly-macro-test-2
  (ensure (silly-test 4 4)))

(addtest (lisp-matrix-ut)
  silly-macro-test-3
  (ensure-error (silly-test 4 4)))

(addtest (lisp-matrix-ut)
  silly-macro-test-4
  (ensure (silly-test2 2 5)))


(addtest (lisp-matrix-ut)
  one-random-test-2
  (test-matrix-size (make-matrix 2 5
				 :implementation :lisp-array 
				 :element-type 'double-float
				 :initial-contents '((1d0 2d0 3d0 4d0 5d0)
						     (6d0 7d0 8d0 9d0 10d0)))
		    2 5))


(addtest (lisp-matrix-ut)
 make-matrix-double-zero-size
 #-clisp (for-all-implementations
	   (ensure (make-matrix 0 0))
	   (ensure (make-matrix 0 1))
	   (ensure (make-matrix 1 0)))
 #+clisp (for-implementations (:lisp-array) ;; foriegn zero-size arrays fail in CLISP?
	   (finishes (make-matrix 0 0))
	   (finishes (make-matrix 0 1))
	   (finishes (make-matrix 1 0))))



(defun gen-integer (&key min max)
  (list 1 2 3 4 5))
;; (gen-integer :min 1 :max 5)

;; need to define for-all !

#|
(addtest (lisp-matrix-ut)
 make-matrix-double-1
 (for-all-implementations
   (for-all ((n (gen-integer :min 1 :max 100))
	     (m (gen-integer :min 1 :max 100)))
      (let ((m1 (make-matrix n m)))
        (ensure  (test-matrix-size m1 n m) )
        (dotimes (i n)
          (dotimes (j m)
            (ensure (typep (mref m1 i j) 'double-float))))))))
|#


#|

(test make-matrix-double-1
  "default initial value"
  (for-all-implementations
    (for-all ((n (gen-integer :min 1 :max 100))
              (m (gen-integer :min 1 :max 100)))
      (let (matrix)
        (finishes (setq matrix (make-matrix n m)))
        (test-matrix-size matrix n m)
        (dotimes (i n)
          (dotimes (j m)
            (unless (typep (mref matrix i j) 'double-float)
              (fail "Element (~d,~d) of matrix ~A is not of type ~
                    DOUBLE-FLOAT"
                    i j matrix))))))))

(test make-matrix-double-2
  "initial value to 1d0"
  (for-all-implementations
    (for-all ((n (gen-integer :min 1 :max 100))
              (m (gen-integer :min 1 :max 100)))
      (let (matrix)
        (finishes (setq matrix (make-matrix n m :initial-element 1d0)))
        (test-matrix-size matrix n m)
        (dotimes (i n)
          (dotimes (j m)
            (unless (= (mref matrix i j) 1d0)
              (fail "(mref matrix ~d ~d) is ~a, should be ~a"
                    i j (mref matrix i j) 1d0))))))))

(test make-matrix-double-3
  "set initial contents"
  (for-all-implementations
    (for-all ((n (gen-integer :min 1 :max 100))
              (m (gen-integer :min 1 :max 100)))
      (let ((array (random-array n m))	  
            matrix)
        (finishes (setq matrix (make-matrix n m :initial-contents
                                            array)))
        (test-matrix-size matrix n m)
        (dotimes (i n)
          (dotimes (j m)
            (unless (= (mref matrix i j) (aref array i j))
              (fail "(mref matrix ~d ~d) is ~a, should be ~a"
                    i j (mref matrix i j) (aref array i j)))))))))

(test make-matrix-double-4
  "set initial contents from a list"
  (for-all-implementations
    (for-all ((n (gen-integer :min 1 :max 100))
              (m (gen-integer :min 1 :max 100)))
      (let* ((list (loop repeat n collect
                         (loop repeat m collect (random 1d0))))
             (matrix1 (make-matrix n m
                                   :initial-contents
                                   (make-array (list n m)
                                               :initial-contents
                                               list)))
             matrix2)
        (finishes (setq matrix2
                        (make-matrix n m :initial-contents
                                     list)))
        (test-matrix-size matrix2 n m)
        (dotimes (i n)
          (dotimes (j m)
            (unless (= (mref matrix2 i j) (mref matrix1 i j))
              (fail "(mref matrix2 ~d ~d) is ~a, should be ~a"
                    i j (mref matrix2 i j) (mref matrix1 i j)))))))))

(test transpose-double
  (for-all-implementations
    (for-all ((n (gen-integer :min 0 :max 100) #+clisp (> n 0))
              (m (gen-integer :min 0 :max 100) #+clisp (> m 0)))
      (let ((matrix1 (rand n m))
            matrix2 matrix3)
        (finishes (setq matrix2 (transpose matrix1)))
        (finishes (setq matrix3 (transpose matrix2)))
        (test-matrix-size matrix2 m n)
        (test-matrix-size matrix3 n m)
        (dotimes (i n)
          (dotimes (j m)
            (unless (= (mref matrix2 j i) (mref matrix1 i j))
              (fail "(mref matrix2 ~d ~d) is ~a, should be ~a"
                    i j (mref matrix2 j i) (mref matrix1 i j)))
            (unless (= (mref matrix3 i j) (mref matrix1 i j))
              (fail "(mref matrix3 ~d ~d) is ~a, should be ~a"
                    i j (mref matrix3 i j) (mref matrix1 i j)))))))))

(test window-double
  (for-all-implementations
    (for-all ((n (gen-integer :min 0 :max 100) #+clisp (> n 0))
              (m (gen-integer :min 0 :max 100) #+clisp (> m 0))
              (n2 (gen-integer :min 0 :max 100) (<= n2 n) #+clisp (> n2 0))
              (m2 (gen-integer :min 0 :max 100) (<= m2 m) #+clisp (> m2 0))
              (row-offset (gen-integer :min 0 :max 100)
                          (<= row-offset (- n n2)))
              (col-offset (gen-integer :min 0 :max 100)
                          (<= col-offset (- m m2))))
      (let ((matrix1 (make-matrix n m :initial-contents
                                  (random-array n m)))
            matrix2)
        (finishes (setq matrix2 (window matrix1 :nrows n2 :ncols m2
                                        :row-offset row-offset
                                        :col-offset col-offset)))
        (test-matrix-size matrix2 n2 m2)
        (dotimes (i n2)
          (dotimes (j m2)
            (unless (= (mref matrix1 (+ i row-offset) (+ j col-offset))
                       (mref matrix2 i j))
              (fail "(mref matrix2 ~d ~d) is ~a, should be ~a"
                    i j (mref matrix1 (+ i row-offset) (+ j col-offset))
                    (mref matrix2 i j)))))))))

(test m=
  (for-all-implementations
    (for-all ((n (gen-integer :min 1 :max 10))
              (m (gen-integer :min 1 :max 10)))
      (let ((a (rand n m)))
        (is
         (m= (make-matrix n m :initial-contents a)
             (make-matrix n m :initial-contents a)))))
    (is (not (m= (make-matrix 1 2)
                 (make-matrix 1 1))))
    (is (not (m= (make-matrix 2 1)
                 (make-matrix 1 1))))
    (is (not (m= (make-matrix 1 1 :initial-element 1d0)
                 (make-matrix 1 1 :initial-element 0d0))))))

(test setf-mref
  (for-all-implementations
    (for-all ((n (gen-integer :min 0 :max 10) #+clisp (> n 0))
              (m (gen-integer :min 0 :max 10) #+clisp (> m 0)))
      (let ((a (make-matrix n m))
            (b (rand n m)))    
        (finishes
          (dotimes (i n)
            (dotimes (j m)
              (setf (mref a i j) (mref b i j)))))
        (is (m= a b))))))

(test transposed-p
  (for-all-implementations
    (let ((m (make-matrix 2 2)))
      (is (null (transposed-p m)))
      (is (transposed-p (transpose m)))
      (is (transposed-p (window (transpose m))))
      ;; the last one was removed because now the transpose of a
      ;; transpose returns the original matrix
      #+(or)
      (is (transposed-p (transpose (transpose m)))))))

(test zero-offset-p
  (for-all-implementations
    (let ((m (make-matrix 3 3)))
      (is (zero-offset-p m))
      (is (zero-offset-p (transpose m)))
      (is (zero-offset-p (transpose (transpose m))))
      (is (zero-offset-p (window m :nrows 1)))
      (is (zero-offset-p (strides m :ncols 1)))
      (is (not (zero-offset-p (window m :row-offset 1 :nrows 1))))
      (is (not (zero-offset-p (window m :col-offset 1 :ncols 1))))
      (is (not (zero-offset-p (strides m :row-offset 1 :nrows 1))))
      (is (not (zero-offset-p (strides m :col-offset 1 :ncols 1))))
      (is (not (zero-offset-p (window (strides m :col-offset 1 :ncols 1)))))
      (is (zero-offset-p (strides m :row-stride 2 :nrows 2))))))

(test unit-strides-p
  (for-all-implementations
    (let ((m (make-matrix 3 3)))
      (is (unit-strides-p m))
      (is (unit-strides-p (transpose m)))
      (is (unit-strides-p (transpose (transpose m))))
      (is (unit-strides-p (window m :nrows 1)))
      (is (unit-strides-p (strides m :ncols 1)))
      (is (unit-strides-p (window m :row-offset 1 :nrows 1)))
      (is (unit-strides-p (window m :col-offset 1 :ncols 1)))
      (is (unit-strides-p (strides m :row-offset 1 :nrows 1)))
      (is (unit-strides-p (strides m :col-offset 1 :ncols 1)))
      (is (not (unit-strides-p (strides m :row-stride 2 :nrows 2))))
      (is (not (unit-strides-p (transpose (strides m :row-stride 2 :nrows 2)))))
      (is (not (unit-strides-p (window (strides m :row-stride 2 :nrows 2)))))
      (is (not (unit-strides-p (strides (strides m :row-stride 2 :nrows 2))))))))

(test copy
  (for-all-implementations
    (labels ((test-copy-m= (a b)
               (and (not (eq a b))
                    (m= a b)))
             (test-copy (a)
               (let ((b (copy a))
                     (c (make-matrix (nrows a) (ncols a)
                                     :element-type (element-type a)
                                     :implementation (implementation a))))
                 (finishes (copy! a c))
                 (is (test-copy-m= a b))
                 (is (test-copy-m= b c))
                 (is (test-copy-m= a c)))))
      (for-all ((n (gen-integer :min 0 :max 10) #+clisp (> n 0))
                (m (gen-integer :min 0 :max 10) #+clisp (> m 0))
                (n2 (gen-integer :min 0 :max 10)
                    (and (<= n2 n) #+clisp (> n2 0)))
                (m2 (gen-integer :min 0 :max 10)
                    (and (<= m2 m) #+clisp (> m2 0)))
                (row-offset (gen-integer :min 0 :max 10)
                            (<= row-offset (- n n2)))
                (col-offset (gen-integer :min 0 :max 10)
                            (<= col-offset (- m m2))))
        (test-copy (rand n m))
        (test-copy (transpose (rand n m)))
        (test-copy (window (rand n m)
                           :nrows n2 :ncols m2
                           :row-offset row-offset
                           :col-offset col-offset))))))

;;; Matrix creation

(def-suite matrix-creation :in tests
           :description "tests for functions that create matrices.")

(in-suite matrix-creation)

(test ones
  (for-all-implementations
    (is (m= (ones 2 2 :element-type 'single-float)
            (make-matrix 2 2
                         :element-type 'single-float
                         :initial-contents '((1.0 1.0)
                                             (1.0 1.0)))))
    (is (m= (ones 2 2 :element-type 'double-float)
            (make-matrix 2 2
                         :element-type 'double-float
                         :initial-contents '((1d0 1d0)
                                             (1d0 1d0)))))
    (is (m= (ones 2 2 :element-type '(complex single-float))
            (make-matrix 2 2
                         :element-type '(complex single-float)
                         :initial-contents '((#C(1.0 0.0) #C(1.0 0.0))
                                             (#C(1.0 0.0) #C(1.0 0.0))))))
    (is (m= (ones 2 2 :element-type '(complex double-float))
            (make-matrix 2 2
                         :element-type '(complex double-float)
                         :initial-contents
                         '((#C(1d0 0d0) #C(1d0 0d0))
                           (#C(1d0 0d0) #C(1d0 0d0))))))))

(test zeros
  (for-all-implementations
    (is (m= (zeros 2 2 :element-type 'single-float)
            (make-matrix 2 2
                         :element-type 'single-float
                         :initial-contents '((0.0 0.0)
                                             (0.0 0.0)))))
    (is (m= (zeros 2 2 :element-type 'double-float)
            (make-matrix 2 2
                         :element-type 'double-float
                         :initial-contents '((0d0 0d0)
                                             (0d0 0d0)))))
    (is (m= (zeros 2 2 :element-type '(complex single-float))
            (make-matrix 2 2
                         :element-type '(complex single-float)
                         :initial-contents
                         '((#C(0.0 0.0) #C(0.0 0.0))
                           (#C(0.0 0.0) #C(0.0 0.0))))))
    (is (m= (zeros 2 2 :element-type '(complex double-float))
            (make-matrix 2 2
                         :element-type '(complex double-float)
                         :initial-contents
                         '((#C(0d0 0d0) #C(0d0 0d0))
                           (#C(0d0 0d0) #C(0d0 0d0))))))))

(test eye
  (for-all-implementations
    (is (m= (eye 2 2 :element-type 'single-float)
            (make-matrix 2 2
                         :element-type 'single-float
                         :initial-contents '((1.0 0.0)
                                             (0.0 1.0)))))
    (is (m= (eye 2 2 :element-type 'double-float)
            (make-matrix 2 2
                         :element-type 'double-float
                         :initial-contents '((1d0 0d0)
                                             (0d0 1d0)))))
    (is (m= (eye 2 2 :element-type '(complex single-float))
            (make-matrix 2 2
                         :element-type '(complex single-float)
                         :initial-contents
                         '((#C(1.0 0.0) #C(0.0 0.0))
                           (#C(0.0 0.0) #C(1.0 0.0))))))
    (is (m= (eye 2 2 :element-type '(complex double-float))
            (make-matrix 2 2
                         :element-type '(complex double-float)
                         :initial-contents '((#C(1d0 0d0) #C(0d0 0d0))
                                             (#C(0d0 0d0) #C(1d0 0d0))))))))

(test rand
  (for-all-implementations
    (let* ((state1 (make-random-state))
           (state2 (make-random-state state1)))
      (is (m= (rand 2 3 :state state1)
              (rand 2 3 :state state2)))
      (is (not (m= (rand 2 3 :state state1)
                   (rand 2 3 :state state1)))))))

;;; Fun with matrix views

(def-suite fun-matrix-views :in tests)
(in-suite fun-matrix-views)

(test fun-transpose
  (for-all-implementations
    (let ((a (rand 3 4)))
      (is (eq a (transpose (transpose a)))))))

(test fun-window
  (for-all-implementations
    (let ((a (rand 3 4)))
      (is (eq a (parent (window (window a :ncols 2)
                                :nrows 2))))
      (is (m= (window (window a :ncols 2) :nrows 2)
              (window a :ncols 2 :nrows 2))))))

(test fun-strides
  (for-all-implementations
    (let ((a (rand 3 4)))
      (is (eql (class-name (class-of (strides a :nrows 2)))
               (window-class a)))
      (is (eq a (parent (strides (strides a :ncols 2 :col-stride 2))))))))

;;; Vectors

(def-suite vectors :in tests)
(in-suite vectors)

(test construct-vectors
  (for-all-implementations
    (is (m= (make-vector 3 :initial-element 0d0)
            (make-matrix 1 3 :initial-element 0d0)))
    (is (m= (make-vector 3 :initial-element 0d0 :type :column)
            (make-matrix 3 1 :initial-element 0d0)))
    (is (col-vector-p (rand 3 1)))
    (is (row-vector-p (rand 1 3)))
    (let ((a (rand 3 5)))
      (is (v= (row a 0) (col (transpose a) 0)))
      (is (not (m= (row a 0) (col (transpose a) 0))))
      (is (row-vector-p (row a 0)))
      (is (col-vector-p (col a 0)))
      (is (row-vector-p (row (transpose a) 0)))
      (is (col-vector-p (col (transpose a) 0)))
      ;; strides and window should return vectors when appropriate
      (is (row-vector-p (window a :nrows 1)))
      (is (col-vector-p (window a :ncols 1)))
      ;; transpose should return the original matrix if dimensions are
      ;; 1 x 1
      (let ((m (rand 1 1)))
        (is (eq m (transpose m))))
      ;; FIXME: M x 1 or 1 x M matrices should not be considered
      ;; transposed when we think of their storage.  But we cannot
      ;; transpose them without resorting to a TRANSPOSE-VECVIEW.  So
      ;; it would be best to introduce a function like
      ;; STORAGE-TRANSPOSED-P.
      #||
      (is (not (transposed-p (transpose (make-matrix 1 10)))))
      (is (not (transposed-p (transpose (make-matrix 10 1)))))
      ||#)))

(test row-of-strided-matrix
  (let* ((a (make-matrix 6 5 :initial-contents '((1d0 2d0 3d0 4d0 5d0)
                                                 (6d0  7d0  8d0  9d0  10d0)
                                                 (11d0 12d0 13d0 14d0 15d0)
                                                 (16d0 17d0 18d0 19d0 20d0)
                                                 (21d0 22d0 23d0 24d0 25d0)
                                                 (26d0 27d0 28d0 29d0 30d0))))
         (b (strides a :nrows 2 :row-stride 2)))
    (is (m= (row b 0)
            (make-matrix 1 5 :initial-contents '((1d0 2d0 3d0 4d0 5d0)))))
    (is (m= (row b 1)
            (make-matrix 1 5 :initial-contents '((11d0 12d0 13d0 14d0 15d0)))))))

(test col-of-strided-matrix
  (let* ((a (make-matrix 6 5 :initial-contents '((1d0 2d0 3d0 4d0 5d0)
                                                 (6d0  7d0  8d0  9d0  10d0)
                                                 (11d0 12d0 13d0 14d0 15d0)
                                                 (16d0 17d0 18d0 19d0 20d0)
                                                 (21d0 22d0 23d0 24d0 25d0)
                                                 (26d0 27d0 28d0 29d0 30d0))))
         (b (strides a :nrows 2 :row-stride 2)))
    (is (m= (col b 0)
            (make-matrix 2 1 :initial-contents '((1d0) (11d0)))))
    (is (m= (col b 1)
            (make-matrix 2 1 :initial-contents '((2d0) (12d0)))))
    (is (m= (col b 2)
            (make-matrix 2 1 :initial-contents '((3d0) (13d0)))))
    (is (m= (col b 3)
            (make-matrix 2 1 :initial-contents '((4d0) (14d0)))))
    (is (m= (col b 4)
            (make-matrix 2 1 :initial-contents '((5d0) (15d0)))))))

(test v=
  (let ((a (rand 3 4)))
    ;; FIXME: this also tests ROW, COL, and their use on a transposed
    ;; matrix
    (is (v= (row a 0) (col (transpose a) 0)))
    (is (v= (col a 0) (row (transpose a) 0)))))

(test row-of-window
  (let* ((a (rand 5 10 :element-type 'integer :value 10))
         (b (window a :row-offset 1 :nrows 4 :col-offset 2 :ncols 5)))
    (is (m= (row b 0)
            (window a :row-offset 1 :nrows 1 :col-offset 2 :ncols 5)))
    (is (m= (row b 1)
            (window a :row-offset 2 :nrows 1 :col-offset 2 :ncols 5)))
    (is (m= (row b 2)
            (window a :row-offset 3 :nrows 1 :col-offset 2 :ncols 5)))
    (is (m= (row b 3)
            (window a :row-offset 4 :nrows 1 :col-offset 2 :ncols 5))))
  (let* ((a (rand 10 5 :element-type 'integer :value 10))
         (b (window (transpose a) :row-offset 1 :nrows 4 :col-offset 2 :ncols 5)))
    (is (m= (row b 0)
            (window (transpose a) :row-offset 1 :nrows 1 :col-offset 2
                                                         :ncols 5)))
    (is (m= (row b 1)
            (window (transpose a) :row-offset 2 :nrows 1 :col-offset 2
                                                         :ncols 5)))
    (is (m= (row b 2)
            (window (transpose a) :row-offset 3 :nrows 1 :col-offset 2
                                                         :ncols 5)))
    (is (m= (row b 3)
            (window (transpose a) :row-offset 4 :nrows 1 :col-offset 2
                                                         :ncols 5)))))

(test real-stride
  (is (= 1 (real-stride (zeros 2 2))))
  (is (= 2 (real-stride (row (zeros 2 2) 0))))
  (is (= 1 (real-stride (col (zeros 2 2) 0))))
  (is (= 1 (real-stride (row (transpose (zeros 2 2)) 0))))
  (is (= 2 (real-stride (col (transpose (zeros 2 2)) 0))))
  (is (null (real-stride (window (zeros 4 4) :nrows 2)))))

;;; Test lapack

(def-suite lapack :in tests
           :description "tests for lapack methods")

(in-suite lapack)

(test make-predicate
  (is (equal (make-predicate 'unit-strides-p)
             'unit-strides-p))
  (is (equal (make-predicate '(not unit-strides-p))
             '(lambda (a)
               (not (unit-strides-p a)))))
  (is (equal (make-predicate '(or (not unit-strides-p)
                               (not zero-offset-p)))
             '(lambda (a)
               (or (not (unit-strides-p a))
                (not (zero-offset-p a))))))
  (is (equal (make-predicate '(or (not unit-strides-p)
                               (not zero-offset-p)
                               transposed-p))
             '(lambda (a)
               (or (not (unit-strides-p a))
                (not (zero-offset-p a))
                (transposed-p a)))))
  (is (equal (make-predicate 't)
             '(constantly t)))
  (is (equal (make-predicate 'nil)
             '(constantly nil))))

(test datatypes
  (is (string= (datatype->letter 'float) "S"))
  (is (string= (datatype->letter 'double) "D"))
  (is (string= (datatype->letter 'complex-float) "C"))
  (is (string= (datatype->letter 'complex-double) "Z")))

;; FIXME: tests below up to IAMAX fail on SBCL versions before and
;; including 1.0.11, but succeed after and including 1.0.12

(test scal
  (for-all-implementations
    (is
     (m=
      (scal 1.5d0 (ones 2 2 :element-type 'double-float))
      (make-matrix 2 2 :element-type 'double-float
                       :initial-element 1.5d0)))
    (is
     (m=
      (scal 1.5 (ones 2 2 :element-type 'single-float))
      (make-matrix 2 2 :element-type 'single-float
                       :initial-element 1.5)))
    (is
     (m=
      (scal #C(1.5 1.5)
            (ones 2 2 :element-type '(complex single-float)))
      (make-matrix 2 2 :element-type '(complex single-float)
                       :initial-element #C(1.5 1.5))))
    (is
     (m=
      (scal #C(1.5d0 1.5d0)
            (ones 2 2 :element-type '(complex double-float)))
      (make-matrix 2 2 :element-type '(complex double-float)
                       :initial-element #C(1.5d0 1.5d0))))))

(test axpy
  (for-all-implementations
    (let ((*default-element-type* 'single-float))
      (is (m= (axpy 1.0 (ones 2 2) (scal 1.5 (ones 2 2)))
              (scal 2.5 (ones 2 2))))
      (is (m= (axpy -1.0 (ones 2 2) (scal 1.5 (ones 2 2)))
              (scal 0.5 (ones 2 2)))))
    (let ((*default-element-type* 'double-float))
      (is (m= (axpy 1d0 (ones 2 2) (scal 1.5d0 (ones 2 2)))
              (scal 2.5d0 (ones 2 2))))
      (is (m= (axpy -1d0 (ones 2 2) (scal 1.5d0 (ones 2 2)))
              (scal 0.5d0 (ones 2 2)))))
    (let* ((*default-element-type* '(complex single-float)))
      (is (m= (axpy #C(1.0 0.0)
                    (ones 2 2)
                    (scal #C(1.5 0.0) (ones 2 2)))
              (scal #C(2.5 0.0) (ones 2 2))))
      (is (m= (axpy #C(-1.0 0.0)
                    (ones 2 2)
                    (scal #C(1.5 0.0) (ones 2 2)))
              (scal #C(0.5 0.0) (ones 2 2)))))
    (let* ((*default-element-type* '(complex double-float)))
      (is (m= (axpy #C(1.0d0 0.0d0)
                    (ones 2 2)
                    (scal #C(1.5d0 0.0d0) (ones 2 2)))
              (scal #C(2.5d0 0.0d0) (ones 2 2))))
      (is (m= (axpy #C(-1.0d0 0.0d0)
                    (ones 2 2)
                    (scal #C(1.5d0 0.0d0) (ones 2 2)))
              (scal #C(0.5d0 0.0d0) (ones 2 2)))))))

(test dot
  (for-all-implementations
    (is (= (dot (ones 2 2)
                (scal 0.5d0 (ones 2 2)))
           2d0))
    (is (= (dot (ones 2 2 :element-type 'single-float)
                (scal 0.5 (ones 2 2 :element-type 'single-float)))
           2.0))))

;; FIXME: test DOTU, DOTC
#+(or)
(test dotu
 (is (= (dotu (ones 2 2 :element-type '(complex single-float))
              (scal #C(0.5 0.0) (ones 2 2 :element-type
                                      '(complex single-float))))
        #C(2.0 0.0))))

#+(or)
(test dotc
 (is (= (dotc (ones 2 2 :element-type '(complex single-float))
              (scal #C(0.5 0.0) (ones 2 2 :element-type
                                      '(complex single-float))))
        #C(2.0 0.0))))

(test nrm2
  (for-all-implementations
    (is (= (nrm2 (ones 2 2))
           2d0))
    (is (= (nrm2 (ones 2 2 :element-type 'single-float))
           2.0))
    (is (= (nrm2 (ones 2 2 :element-type '(complex single-float)))
           #C(2.0 0.0)))
    (is (= (nrm2 (ones 2 2 :element-type '(complex double-float)))
           #C(2d0 0d0)))))

(test asum
  (for-all-implementations
    (is (= (asum (ones 2 2))
           4d0))
    (is (= (asum (ones 2 2 :element-type 'single-float))
           4.0))
    (is (= (asum (ones 2 2 :element-type '(complex single-float)))
           #C(4.0 0.0)))
    (is (= (asum (ones 2 2 :element-type '(complex double-float)))
           #C(4d0 0d0)))))

(test iamax
  (for-all-implementations
    (is (= (iamax (make-matrix 2 2 :initial-contents '((1d0 2d0)
                                                       (1d0 1d0))))
           2))
    (is (= (iamax (make-matrix 2 2 :element-type 'single-float
                                   :initial-contents '((1.0 2.0)
                                                       (1.0 1.0))))
           2))
    (is (= (iamax (make-matrix 2 2 :element-type '(complex single-float)
                                   :initial-contents '((#C(1.0 0.0) #C(2.0 0.0))
                                                       (#C(1.0 0.0) #C(1.0 0.0)))))
           2))
    (is (= (iamax (make-matrix 2 2 :element-type '(complex double-float)
                                   :initial-contents '((#C(1d0 0d0) #C(2d0 0d0))
                                                       (#C(1d0 0d0) #C(1d0 0d0)))))
           2))
    (is (= (iamax (ones 1 1))
           0))
    (is (= (iamax (ones 1 1 :element-type 'single-float))
           0))
    (is (= (iamax (ones 1 1 :element-type '(complex single-float)))
           0))
    (is (= (iamax (ones 1 1 :element-type '(complex double-float)))
           0))))

(def-suite gemm :in lapack
           :description "tests of the M* function")

(in-suite gemm)

(defun check-m* (a b)
  (let ((result (make-matrix 2 2 :initial-contents
                             '((19d0 22d0)
                               (43d0 50d0)))))
    (is (m= result (m* a b)))))

(defmacro def-m*-test (name a b)
  `(test ,name
     (for-all-implementations
       (check-m* ,a ,b))))

(def-m*-test m*-basic-test
    (make-matrix 2 2 :initial-contents
                 '((1d0 2d0)
                   (3d0 4d0)))
  (make-matrix 2 2 :initial-contents
               '((5d0 6d0)
                 (7d0 8d0))))

(def-m*-test m*-transpose-a
    (transpose
     (make-matrix 2 2 :initial-contents
                  '((1d0 3d0)
                    (2d0 4d0))))
  (make-matrix 2 2 :initial-contents
               '((5d0 6d0)
                 (7d0 8d0))))

(def-m*-test m*-transpose-b
    (make-matrix 2 2 :initial-contents
                 '((1d0 2d0)
                   (3d0 4d0)))
  (transpose
   (make-matrix 2 2 :initial-contents
                '((5d0 7d0)
                  (6d0 8d0)))))

(def-m*-test m*-double-transpose-a
    (transpose
     (transpose
      (make-matrix 2 2 :initial-contents
                   '((1d0 2d0)
                     (3d0 4d0)))))
  (make-matrix 2 2 :initial-contents
               '((5d0 6d0)
                 (7d0 8d0))))

(def-m*-test m*-transpose-a-b
    (transpose
     (make-matrix 2 2 :initial-contents
                  '((1d0 3d0)
                    (2d0 4d0))))
  (transpose
   (make-matrix 2 2 :initial-contents
                '((5d0 7d0)
                  (6d0 8d0)))))

(def-m*-test m*-window-a-nocopy
    (window
     (make-matrix 3 3 :initial-contents
                  '((1d0 2d0 0d0)
                    (3d0 4d0 0d0)
                    (0d0 0d0 0d0)))
     :nrows 2 :ncols 2)
  (make-matrix 2 2 :initial-contents
               '((5d0 6d0)
                 (7d0 8d0))))

(def-m*-test m*-window-a-copy
    (window
     (make-matrix 3 3 :initial-contents
                  '((0d0 1d0 2d0)
                    (0d0 3d0 4d0)
                    (0d0 0d0 0d0)))
     :nrows 2 :ncols 2 :col-offset 1)
  (make-matrix 2 2 :initial-contents
               '((5d0 6d0)
                 (7d0 8d0))))

(def-m*-test m*-window-b-nocopy
    (make-matrix 2 2 :initial-contents
                 '((1d0 2d0)
                   (3d0 4d0)))
  (window
   (make-matrix 2 3 :initial-contents
                '((5d0 6d0 0d0)
                  (7d0 8d0 0d0)))
   :ncols 2))

(def-m*-test m*-window-b-copy
    (make-matrix 2 2 :initial-contents
                 '((1d0 2d0)
                   (3d0 4d0)))
  (window
   (make-matrix 3 3 :initial-contents
                '((0d0 0d0 0d0)
                  (5d0 6d0 0d0)
                  (7d0 8d0 0d0)))
   :ncols 2 :nrows 2 :row-offset 1))

(def-m*-test m*-stride-a-nocopy
    (strides
     (make-matrix 3 3 :initial-contents
                  '((1d0 2d0 0d0)
                    (3d0 4d0 0d0)
                    (0d0 0d0 0d0)))
     :nrows 2 :ncols 2)
  (make-matrix 2 2 :initial-contents
               '((5d0 6d0)
                 (7d0 8d0))))

(def-m*-test m*-stride-a-copy
    (strides
     (make-matrix 4 3 :initial-contents
                  '((1d0 0d0 2d0)
                    (0d0 0d0 0d0)
                    (3d0 0d0 4d0)
                    (0d0 0d0 0d0)))
     :nrows 2 :ncols 2 :row-stride 2 :col-stride 2)
  (make-matrix 2 2 :initial-contents
               '((5d0 6d0)
                 (7d0 8d0))))

(test gemm-window-c-copy
  (for-all-implementations
    (let* ((result (make-matrix 2 2 :initial-contents
                                '((19d0 22d0)
                                  (43d0 50d0))))
           (c (zeros 3 3))
           (windowed-c (window c :nrows 2 :ncols 2)))
      (is (eq windowed-c
              (gemm 1d0
                    (make-matrix 2 2 :initial-contents
                                 '((1d0 2d0)
                                   (3d0 4d0)))
                    (make-matrix 2 2 :initial-contents
                                 '((5d0 6d0)
                                   (7d0 8d0)))
                    0d0
                    windowed-c)))
      (is (m= windowed-c result))
      (is (m= windowed-c (window c :nrows 2 :ncols 2)))
      (is (m= (window c :nrows 1 :row-offset 2)
              (zeros 1 3)))
      (is (m= (window c :ncols 1 :col-offset 2)
              (zeros 3 1))))))

(test gemm-window-c-copy-copyback
  (for-all-implementations
    (let* ((result (make-matrix 2 2 :initial-contents
                                '((19d0 22d0)
                                  (43d0 50d0))))
           (c (zeros 4 4))
           (windowed-c (window c :nrows 2 :ncols 2 :row-offset 2
                                                   :col-offset 2)))
      (is (eq windowed-c
              (gemm 1d0
                    (make-matrix 2 2 :initial-contents
                                 '((1d0 2d0)
                                   (3d0 4d0)))
                    (make-matrix 2 2 :initial-contents
                                 '((5d0 6d0)
                                   (7d0 8d0)))
                    0d0
                    windowed-c)))
      (is (m= windowed-c result))
      (is (m= windowed-c (window c :nrows 2 :ncols 2 :row-offset 2
                                                     :col-offset 2)))
      (is (m= (window c :nrows 2) (zeros 2 4)))
      (is (m= (window c :ncols 2) (zeros 4 2))))))


(test m*-double
  (for-all-implementations
    (is
     (m=
      (m* (window
           (make-matrix 3 3 :element-type 'double-float
                            :initial-contents '((1d0 2d0 0d0)
                                                (3d0 4d0 0d0)
                                                (0d0 0d0 0d0)))
           :nrows 2 :ncols 2)
          (make-matrix 2 2 :element-type 'double-float
                           :initial-contents '((5d0 6d0)
                                               (7d0 8d0))))
      (make-matrix 2 2 :element-type 'double-float
                       :initial-contents '((19d0 22d0)
                                           (43d0 50d0)))))))

(test m*-single
  (for-all-implementations
    (is
     (m=
      (m* (window
           (make-matrix 3 3 :element-type 'single-float
                            :initial-contents '((1.0 2.0 0.0)
                                                (3.0 4.0 0.0)
                                                (0.0 0.0 0.0)))
           :nrows 2 :ncols 2)
          (make-matrix 2 2 :element-type 'single-float
                           :initial-contents '((5.0 6.0)
                                               (7.0 8.0))))
      (make-matrix 2 2 :element-type 'single-float
                       :initial-contents '((19.0 22.0)
                                           (43.0 50.0)))))))

(test m*-complex-single
  (for-all-implementations
    (is
     (m=
      (m* (window
           (make-matrix 3 3 :element-type '(complex single-float)
                            :initial-contents
                            '((#C(1.0 0.0) #C(2.0 0.0) #C(0.0 0.0))
                              (#C(3.0 0.0) #C(4.0 0.0) #C(0.0 0.0))
                              (#C(0.0 0.0) #C(0.0 0.0) #C(0.0 0.0))))
           :nrows 2 :ncols 2)
          (make-matrix 2 2 :element-type '(complex single-float)
                           :initial-contents
                           '((#C(5.0 0.0) #C(6.0 0.0))
                             (#C(7.0 0.0) #C(8.0 0.0)))))
      (make-matrix 2 2 :element-type '(complex single-float)
                       :initial-contents '((#C(19.0 0.0) #C(22.0 0.0))
                                           (#C(43.0 0.0) #C(50.0 0.0))))))))

(test m*-complex-double
  (for-all-implementations
    (is
     (m=
      (m* (window
           (make-matrix 3 3 :element-type '(complex double-float)
                            :initial-contents
                            '((#C(1d0 0d0) #C(2d0 0d0) #C(0d0 0d0))
                              (#C(3d0 0d0) #C(4d0 0d0) #C(0d0 0d0))
                              (#C(0d0 0d0) #C(0d0 0d0) #C(0d0 0d0))))
           :nrows 2 :ncols 2)
          (make-matrix 2 2 :element-type '(complex double-float)
                           :initial-contents
                           '((#C(5d0 0d0) #C(6d0 0d0))
                             (#C(7d0 0d0) #C(8d0 0d0)))))
      (make-matrix 2 2 :element-type '(complex double-float)
                       :initial-contents '((#C(19d0 0d0) #C(22d0 0d0))
                                           (#C(43d0 0d0) #C(50d0
  0d0))))))))


(test m*-vectors
  (for-all-implementations
    (let* ((a (make-matrix 4 4 :initial-contents '((0d0 1d0 2d0 3d0)
                                                   (1d0 2d0 3d0 4d0)
                                                   (2d0 3d0 4d0 5d0)
                                                   (3d0 4d0 5d0 6d0))))
           (x (slice (col a 3) :stride 2 :nelts 2 :type :row))
           (y (slice (col a 2) :stride 2 :nelts 2 :type :column)))
      (is (m= x (make-matrix 1 2 :initial-contents '((3d0 5d0)))))
      (is (m= y (make-matrix 2 1 :initial-contents '((2d0) (4d0)))))
      (is (m= (m* x y) (scal 26d0 (ones 1 1))))
      (is (m= (m* y x) (make-matrix 2 2 :initial-contents '((6d0 10d0)
                                                         (12d0 20d0))))))
    (is (m= (m* (ones 1 10) (ones 10 1))
            (scal 10d0 (ones 1 1))))
    (is (m= (m* (ones 10 1)
                (scal 2d0 (ones 1 10)))
            (scal 2d0 (ones 10 10))))))


(in-suite lapack)

(test m+
  (for-all-implementations
    (let* ((a (ones 2 2))
           (b (scal 2d0 (ones 2 2))))
      (is (m= a (ones 2 2)))
      (is (m= b (scal 2d0 (ones 2 2))))
      (is (m= (m+ a b) (scal 3d0 (ones 2 2)))))
    (let* ((*default-element-type* 'single-float)
           (a (ones 2 2))
           (b (scal 2.0 (ones 2 2))))
      (is (m= a (ones 2 2)))
      (is (m= b (scal 2.0 (ones 2 2))))
      (is (m= (m+ a b) (scal 3.0 (ones 2 2)))))
    (let* ((*default-element-type* '(complex single-float))
           (a (ones 2 2))
           (b (scal #C(2.0 2.0) (ones 2 2))))
      (is (m= a (ones 2 2)))
      (is (m= b (scal #C(2.0 2.0) (ones 2 2))))
      (is (m= (m+ a b) (scal #C(3.0 2.0) (ones 2 2)))))
    (let* ((*default-element-type* '(complex double-float))
           (a (ones 2 2))
           (b (scal #C(2d0 2d0) (ones 2 2))))
      (is (m= a (ones 2 2)))
      (is (m= b (scal #C(2d0 2d0) (ones 2 2))))
      (is (m= (m+ a b) (scal #C(3d0 2d0) (ones 2 2)))))))

(test m-
  (for-all-implementations
    (let* ((a (ones 2 2))
           (b (scal 2d0 (ones 2 2))))
      (is (m= a (ones 2 2)))
      (is (m= b (scal 2d0 (ones 2 2))))
      (is (m= (m- a b) (scal -1d0 (ones 2 2)))))
    (let* ((*default-element-type* 'single-float)
           (a (ones 2 2))
           (b (scal 2.0 (ones 2 2))))
      (is (m= a (ones 2 2)))
      (is (m= b (scal 2.0 (ones 2 2))))
      (is (m= (m- a b) (scal -1.0 (ones 2 2)))))
    (let* ((*default-element-type* '(complex single-float))
           (a (ones 2 2))
           (b (scal #C(2.0 2.0) (ones 2 2))))
      (is (m= a (ones 2 2)))
      (is (m= b (scal #C(2.0 2.0) (ones 2 2))))
      (is (m= (m- a b) (scal #C(-1.0 -2.0) (ones 2 2)))))
    (let* ((*default-element-type* '(complex double-float))
           (a (ones 2 2))
           (b (scal #C(2d0 2d0) (ones 2 2))))
      (is (m= a (ones 2 2)))
      (is (m= b (scal #C(2d0 2d0) (ones 2 2))))
      (is (m= (m- a b) (scal #C(-1d0 -2d0) (ones 2 2)))))))

|#