;;;; tests/maven-cases.lisp
;;;;
;;;; Ported from serovers/core_test.clj (maven-cases)

(defpackage #:com.djhaskin.svers/tests/maven-cases
  (:use #:cl)
  (:import-from #:com.djhaskin.svers
    #:maven-vercmp)
  (:import-from #:parachute
    #:define-test
    #:true
    #:false
    #:is))

(in-package #:com.djhaskin.svers/tests/maven-cases)

(define-test maven-cases
  :parent nil
  ;; Numeric Comparison
  (is = 0 (maven-vercmp "1.0.0" "1.0.0"))
  (is = 0 (maven-vercmp "1.0.0" "1.0"))
  (true (> (maven-vercmp "1.0.1" "1.0") 0))
  (true (< (maven-vercmp "1.0.0" "1.0.1") 0))
  (true (< (maven-vercmp "1.0.0" "1.0.0-1") 0))
  (true (> (maven-vercmp "1.0.0" "0.9.2") 0))
  (true (< (maven-vercmp "0.9.2" "0.9.3") 0))
  (true (> (maven-vercmp "0.9.2" "0.9.1") 0))
  (true (< (maven-vercmp "0.9.5" "0.9.13") 0))
  (true (< (maven-vercmp "10.2.0.3.0" "11.2.0.3.0") 0))
  (true (> (maven-vercmp "10.2.0.3.0" "5.2.0.3.0") 0))
  (true (< (maven-vercmp "1.0.0-SNAPSHOT" "1.0.1-SNAPSHOT") 0))
  (true (< (maven-vercmp "1.0.0-alpha" "1.0.1-beta") 0))
  (true (< (maven-vercmp "1.1-dolphin" "1.1.1-cobra") 0))

  ;; Lexical Comparison
  (true (< (maven-vercmp "1.0-alpaca" "1.0-bermuda") 0))
  (true (< (maven-vercmp "1.0-alpaca" "1.0-alpaci") 0))
  (true (> (maven-vercmp "1.0-dolphin" "1.0-cobra") 0))

  ;; Qualifier Comparison
  (true (< (maven-vercmp "1.0.0-alpha" "1.0.0-beta") 0))
  (true (> (maven-vercmp "1.0.0-beta" "1.0.0-alpha") 0))
  (true (< (maven-vercmp "1.0.0-alpaca" "1.0.0-beta") 0))
  (true (> (maven-vercmp "1.0.0-final" "1.0.0-milestone") 0))

  ;; Qualifier/Numeric Comparison
  (true (< (maven-vercmp "1.0.0-alpha1" "1.0.0-alpha2") 0))
  (true (< (maven-vercmp "1.0.0-alpha5" "1.0.0-alpha23") 0))
  (true (< (maven-vercmp "1.0-RC5" "1.0-RC20") 0))
  (true (> (maven-vercmp "1.0-RC11" "1.0-RC6") 0))

  ;; Releases are newer than SNAPSHOTs
  (true (> (maven-vercmp "1.0.0" "1.0.0-SNAPSHOT") 0))
  (is = 0 (maven-vercmp "1.0.0-SNAPSHOT" "1.0.0-SNAPSHOT"))
  (true (< (maven-vercmp "1.0.0-SNAPSHOT" "1.0.0") 0))

  ;; Releases are newer than qualified versions
  (true (> (maven-vercmp "1.0.0" "1.0.0-alpha5") 0))
  (true (< (maven-vercmp "1.0.0-alpha5" "1.0.0") 0))

  ;; SNAPSHOTS are newer than qualified versions
  (true (> (maven-vercmp "1.0.0-SNAPSHOT" "1.0.0-RC1") 0))
  (true (< (maven-vercmp "1.0.0-SNAPSHOT" "1.0.1-RC1") 0))

  ;; Some other Formats
  (true (> (maven-vercmp "9.1-901.jdbc4" "9.1-901.jdbc3") 0))
  (true (> (maven-vercmp "9.1-901-1.jdbc4" "9.1-901.jdbc4") 0))

  ;; Some more zero-extension Tests
  (is = 0 (maven-vercmp "1-SNAPSHOT" "1.0-SNAPSHOT"))
  (is = 0 (maven-vercmp "1-alpha" "1-alpha0")))
