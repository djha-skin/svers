;;;; tests/gem-cases.lisp
;;;;
;;;; Ported from serovers/core_test.clj (gem-cases)

(defpackage #:com.djhaskin.svers/tests/gem-cases
  (:use #:cl)
  (:import-from #:com.djhaskin.svers
    #:rubygem-vercmp)
  (:import-from #:parachute
    #:define-test
    #:true
    #:false
    #:is))

(in-package #:com.djhaskin.svers/tests/gem-cases)

(define-test gem-cases
  :parent nil
  (is = 0 (rubygem-vercmp "" ""))
  (true (> (rubygem-vercmp "1.0.0" "0.1.0") 0))
  (true (< (rubygem-vercmp "1.0.0" "2.0.0") 0))
  (is = 0 (rubygem-vercmp "1.1.1" "1.1.1"))
  (true (< (rubygem-vercmp "2.0.0" "2.1.0") 0))
  (true (> (rubygem-vercmp "2.1.1" "2.1.0") 0))
  (true (> (rubygem-vercmp "1.0.1" "1.0") 0))
  (true (< (rubygem-vercmp "1.0.0" "1.0.1") 0))
  (true (> (rubygem-vercmp "1.0.0" "0.9.2") 0))
  (true (< (rubygem-vercmp "0.9.2" "0.9.3") 0))
  (true (> (rubygem-vercmp "0.9.2" "0.9.1") 0))
  (true (< (rubygem-vercmp "0.9.5" "0.9.13") 0))
  (true (< (rubygem-vercmp "10.2.0.3.0" "11.2.0.3.0") 0))
  (true (> (rubygem-vercmp "10.2.0.3.0" "5.2.0.3.0") 0))
  (true (> (rubygem-vercmp "1.0" "1") 0))
  (true (< (rubygem-vercmp "1.2.a" "1.2") 0))
  (true (< (rubygem-vercmp "1.2.z" "1.2") 0))
  (true (> (rubygem-vercmp "1.1.z" "1.0") 0))
  (true (> (rubygem-vercmp "1.0.a10" "1.0.a9") 0))
  (true (> (rubygem-vercmp "1.0" "1.0.b1") 0))
  (true (< (rubygem-vercmp "1.0.a2" "1.0.b1") 0))
  (true (> (rubygem-vercmp "1.0.a2" "0.9") 0))
  (is = 0 (rubygem-vercmp "1.0.a.10" "1.0.a10"))
  (is = 0 (rubygem-vercmp "1.0.a10" "1.0.a.10")))
