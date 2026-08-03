;;;; tests/semver-cases.lisp
;;;;
;;;; Ported from serovers/core_test.clj (semver-cases)

(defpackage #:com.djhaskin.svers/tests/semver-cases
  (:use #:cl)
  (:import-from #:com.djhaskin.svers
    #:semver-vercmp)
  (:import-from #:parachute
    #:define-test
    #:true
    #:false
    #:is))

(in-package #:com.djhaskin.svers/tests/semver-cases)

(define-test semver-cases
  :parent nil
  (is = 0 (semver-vercmp "" ""))
  (is = 0 (semver-vercmp "1.0.0+001" "1.0.0+20130313144700"))
  (is = 0 (semver-vercmp "1.0.0+exp.sha.5114f85" "1.0.0"))
  (true (< (semver-vercmp "1.0.0-alpha" "1.0.0-alpha.1") 0))
  (true (< (semver-vercmp "1.0.0-alpha.1" "1.0.0-alpha.beta") 0))
  (true (< (semver-vercmp "1.0.0-alpha.beta" "1.0.0-beta") 0))
  (true (> (semver-vercmp "1.0.0-beta.2" "1.0.0-beta") 0))
  (true (< (semver-vercmp "1.0.0-beta.2" "1.0.0-beta.11") 0))
  (true (< (semver-vercmp "1.0.0-beta.11" "1.0.0-rc.1") 0))
  (true (< (semver-vercmp "1.0.0-rc.1" "1.0.0") 0))
  (true (> (semver-vercmp "1.0.0" "0.1.0") 0))
  (true (> (semver-vercmp "1.2.10" "1.2.9") 0))
  (is = 0 (semver-vercmp "9.8.7" "9.8.7+burarum"))
  (true (< (semver-vercmp "1.0.0" "2.0.0") 0))
  (true (< (semver-vercmp "2.0.0" "2.1.0") 0))
  (true (> (semver-vercmp "2.1.1" "2.1.0") 0))
  (true (> (semver-vercmp "1.0.0" "1.0.0-alpha") 0)))
