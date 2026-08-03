;;;; tests/naive-cases.lisp
;;;;
;;;; Ported from serovers/core_test.clj (naive-cases)

(defpackage #:com.djhaskin.svers/tests/naive-cases
  (:use #:cl)
  (:import-from #:com.djhaskin.svers
    #:naive-vercmp)
  (:import-from #:parachute
    #:define-test
    #:true
    #:false
    #:is))

(in-package #:com.djhaskin.svers/tests/naive-cases)

(define-test naive-cases
             :parent nil
             (is = 0 (naive-vercmp "" ""))
             (is = 0 (naive-vercmp "abc" "abc"))
             (is = 0 (naive-vercmp "a.b.c" "a_b-c"))
             (true (> (naive-vercmp "1.2.0" "1.2") 0))
             (true (< (naive-vercmp "1.a" "1.2") 0))
             (is = 0 (naive-vercmp "0100" "100"))
             (true (< (naive-vercmp "0100.al0100" "100.al100") 0))
             (true (> (naive-vercmp "1000.9.17" "100.9.18") 0)))
