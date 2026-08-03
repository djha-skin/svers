;;;; tests/python-cases.lisp
;;;;
;;;; Ported from serovers/core_test.clj (python-cases)
;;;;
;;;; The following test case versions list is taken from the file
;;;; "tests/test_version.py" of the `pypa/packaging` git repository, found here:
;;;; https://github.com/pypa/packaging

(defpackage #:com.djhaskin.svers/tests/python-cases
  (:use #:cl)
  (:import-from #:com.djhaskin.svers
    #:python-vercmp)
  (:import-from #:parachute
    #:define-test
    #:true
    #:false
    #:is))

(in-package #:com.djhaskin.svers/tests/python-cases)

(defparameter *python-versions*
  ;; Implicit epoch of 0
  '("1.0.dev456" "1.0a1" "1.0a2.dev456" "1.0a12.dev456" "1.0a12"
    "1.0b1.dev456" "1.0b2" "1.0b2.post345.dev456" "1.0b2.post345"
    "1.0b2-346" "1.0c1.dev456" "1.0c1" "1.0rc2" "1.0c3" "1.0"
    "1.0.post456.dev34" "1.0.post456" "1.1.dev1" "1.2" "1.2+123abc"
    "1.2+123abc456" "1.2+abc" "1.2+abc123" "1.2+abc123def" "1.2+1234.abc"
    "1.2+123456" "1.2.r32+123456" "1.2.rev33+123456"
    ;; Explicit epoch of 1
    "1!1.0.dev456" "1!1.0a1" "1!1.0a2.dev456" "1!1.0a12.dev456" "1!1.0a12"
    "1!1.0b1.dev456" "1!1.0b2" "1!1.0b2.post345.dev456" "1!1.0b2.post345"
    "1!1.0b2-346" "1!1.0c1.dev456" "1!1.0c1" "1!1.0rc2" "1!1.0c3" "1!1.0"
    "1!1.0.post456.dev34" "1!1.0.post456" "1!1.1.dev1" "1!1.2+123abc"
    "1!1.2+123abc456" "1!1.2+abc" "1!1.2+abc123" "1!1.2+abc123def"
    "1!1.2+1234.abc" "1!1.2+123456" "1!1.2.r32+123456" "1!1.2.rev33+123456"))

(defun test-python-pair (a b)
  (true (< (python-vercmp a b) 0))
  (true (> (python-vercmp b a) 0))
  (is = 0 (python-vercmp a a)))

(define-test python-cases
             :parent nil
             ;; Python edge cases
             (is = 0 (python-vercmp "" ""))
             (is = 0 (python-vercmp "1.2.3rc1" "1.2.3RC1"))
             (true (< (python-vercmp "1.0+foo0100" "1.0+foo100") 0))
             (true (< (python-vercmp "1.0+0100foo" "1.0+100foo") 0))
             (is = 0 (python-vercmp "1.0.a1" "1.0a1"))
             (is = 0 (python-vercmp "1.0.rc1" "1.0rc1"))
             (is = 0 (python-vercmp "1.0.b1" "1.0b1"))

             ;; Test the full python-versions ordering
             (test-python-pair (first *python-versions*)
                               (car (last *python-versions*)))
             (loop for (a b) on *python-versions*
                   while b
                   do (test-python-pair a b)))
