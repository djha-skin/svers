;;;; tests/main.lisp
;;;;
;;;; Unit tests for svers version comparison library.

(defpackage #:com.djhaskin.svers/tests
  (:use #:cl)
  (:import-from
      #:org.shirakumo.parachute
    #:define-test
    #:true
    #:false
    #:is
    #:isnt
    #:finish
    #:test)
  (:import-from
      #:com.djhaskin.svers)
  (:local-nicknames
    (#:parachute #:org.shirakumo.parachute)
    (#:svers #:com.djhaskin.svers)))

(in-package #:com.djhaskin.svers/tests)
