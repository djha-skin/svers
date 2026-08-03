;;;; tests/rpm-cases.lisp
;;;;
;;;; Ported from serovers/core_test.clj (rpm-cases)

(defpackage #:com.djhaskin.svers/tests/rpm-cases
  (:use #:cl)
  (:import-from #:com.djhaskin.svers
    #:rpm-vercmp)
  (:import-from #:parachute
    #:define-test
    #:true
    #:false
    #:is))

(in-package #:com.djhaskin.svers/tests/rpm-cases)

(define-test rpm-cases
             :parent nil
             (is = 0 (rpm-vercmp "" ""))
             (is = 0 (rpm-vercmp "1.2.3" "1.2-3"))
             (true (> (rpm-vercmp "1.0010" "1.9") 0))
             (is = 0 (rpm-vercmp "1.05" "1.5"))
             (true (> (rpm-vercmp "1.0" "1") 0))
             (true (> (rpm-vercmp "2.50" "2.5") 0))
             (is = 0 (rpm-vercmp "fc4" "fc.4"))
             (true (< (rpm-vercmp "FC5" "fc4") 0))
             (true (< (rpm-vercmp "2a" "2.0") 0))
             (is = 0 (rpm-vercmp "2.a" "2a"))
             (true (> (rpm-vercmp "1.0" "1.fc4") 0))
             (is = 0 (rpm-vercmp "3.0.0_fc" "3.0.0.fc"))
             (true (< (rpm-vercmp "~~" "~~a") 0))
             (true (> (rpm-vercmp "~" "~~a") 0))
             (true (< (rpm-vercmp "~" "") 0))
             (true (> (rpm-vercmp "a" "") 0)))
