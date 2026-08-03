;;;; tests/debian-cases.lisp
;;;;
;;;; Ported from serovers/core_test.clj (debian-cases)

(defpackage #:com.djhaskin.svers/tests/debian-cases
  (:use #:cl)
  (:import-from #:com.djhaskin.svers
    #:debian-vercmp)
  (:import-from #:parachute
    #:define-test
    #:true
    #:false
    #:is))

(in-package #:com.djhaskin.svers/tests/debian-cases)

(define-test debian-cases
             :parent nil
             ;; (is = 0 result) means using = to compare result to 0
             (is = 0 (debian-vercmp "" ""))
             (true (< (debian-vercmp "~~" "~~a") 0))
             (true (> (debian-vercmp "~" "~~a") 0))
             (true (< (debian-vercmp "~" "") 0))
             (true (> (debian-vercmp "a" "") 0))
             (true (< (debian-vercmp "1.2.3~rc1" "1.2.3") 0))
             (is = 0 (debian-vercmp "1.2" "1.2"))
             (true (< (debian-vercmp "1.2" "a1.2") 0))
             (true (> (debian-vercmp "1.2.3" "1.2-3") 0))
             (true (> (debian-vercmp "1.2.3~rc1" "1.2.3~~rc1") 0))
             (true (< (debian-vercmp "1.2.3" "2") 0))
             (true (> (debian-vercmp "2.0.0" "2.0") 0))
             (true (> (debian-vercmp "1.2.a" "1.2.3") 0))
             (true (> (debian-vercmp "1.2.a" "1.2a") 0))
             (true (< (debian-vercmp "1" "1.2.3.4") 0))
             (is = 0 (debian-vercmp "1:2.3.4" "1:2.3.4"))
             (is = 0 (debian-vercmp "0:" "0:"))
             (is = 0 (debian-vercmp "0:" ""))
             (is = 0 (debian-vercmp "0:1.2" "1.2"))
             (true (< (debian-vercmp "0:" "1:") 0))
             (true (< (debian-vercmp "0:1.2.3" "2:0.4.5") 0)))
