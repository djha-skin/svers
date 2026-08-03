;;;; src/main.lisp
;;;;
;;;; Version comparison library supporting multiple schemes.
;;;;
;;;; Ported from serovers (Clojure) to svers (Common Lisp).
;;;;
;;;; The key insight: by using the Debian version comparison algorithm
;;;; under the hood and simply normalizing version numbers from other
;;;; schemes so that they compare correctly, (almost) all of the version
;;;; comparison algorithms can be improved by optimizing just the Debian
;;;; version comparison algorithm.

(defpackage #:com.djhaskin.svers
  (:use #:cl)
  (:import-from #:cl-ppcre)
  (:import-from #:alexandria)
  (:local-nicknames
    (#:re #:cl-ppcre)
    (#:a #:alexandria))
  (:export
    #:debian-vercmp
    #:maven-normalize
    #:maven-vercmp
    #:rpm-normalize
    #:rpm-vercmp
    #:semver-normalize
    #:semver-vercmp
    #:rubygem-normalize
    #:rubygem-vercmp
    #:naive-vercmp
    #:python-normalize
    #:python-vercmp))

(in-package #:com.djhaskin.svers)

(defparameter +nullc+ (code-char 0))

;;; ─── Epoch handling ─────────────────────────────────────────────────────────

(defun epoch (a)
  "Extract the epoch number from a version string.
  Returns (list epoch version) where epoch is an integer."
  (multiple-value-bind (match groups)
      (re:scan-to-strings "^([0-9]+):(.*)$" a)
    (if match
      (list (parse-integer (elt groups 0)) (elt groups 1))
      (list 0 a))))

;;; ─── Lexical comparison ─────────────────────────────────────────────────────

(defun lexical-comparison (a b)
  "Lexically compare two characters according to Debian version rules."
  (cond
    ((char= a b) 0)
    ((char= a #\~) -1)
    ((char= b #\~) 1)
    ((and (alpha-char-p a)
          (not (alpha-char-p b))
          (not (char= b +nullc+)))
     -1)
    ((and (alpha-char-p b)
          (not (alpha-char-p a))
          (not (char= a +nullc+)))
     1)
    (t
     (- (char-code a) (char-code b)))))

;;; ─── String justification ──────────────────────────────────────────────────

(defun justify-strings (a b)
  "Return two character lists of equal length, padded with nullc."
  (let ((va (coerce a 'list))
        (vb (coerce b 'list))
        (ca (length a))
        (cb (length b)))
    (cond
      ((= ca cb) (list va vb))
      ((> cb ca) (list (append va (make-list (- cb ca) :initial-element +nullc+))
                       vb))
      (t (list va
               (append vb (make-list (- ca cb) :initial-element +nullc+)))))))

;;; ─── Debian string comparison ──────────────────────────────────────────────

(defun debian-string-compare (a b)
  "Compare two strings using Debian lexical comparison rules."
  (or (some (lambda (x) (if (not (zerop x)) x nil))
            (let ((just (justify-strings a b)))
              (mapcar #'lexical-comparison (first just) (second just))))
      0))

;;; ─── Numeric part comparison ────────────────────────────────────────────────

(defun numeric-part-compare (a b)
  "Compare two numeric version parts."
  (let* ((trimmed-a (re:regex-replace-all "^0+" a ""))
         (trimmed-b (re:regex-replace-all "^0+" b ""))
         (ldiff (- (length trimmed-a) (length trimmed-b))))
    (if (zerop ldiff)
      (if (string< trimmed-a trimmed-b) -1
        (if (string> trimmed-a trimmed-b) 1 0))
      ldiff)))

;;; ─── Epochless Debian version comparison ───────────────────────────────────

(defun epochless-debian-vercmp (a b)
  "Compare two Debian version strings without epoch."
  (if (and (string= a "") (string= b ""))
    0
    (multiple-value-bind (ma groups-a)
        (re:scan-to-strings "^([^0-9]*)" a)
      (declare (ignore ma))
      (multiple-value-bind (mb groups-b)
          (re:scan-to-strings "^([^0-9]*)" b)
        (declare (ignore mb))
        (let* ((initial-a (if groups-a (elt groups-a 0) ""))
               (initial-b (if groups-b (elt groups-b 0) ""))
               (diff (debian-string-compare initial-a initial-b)))
          (if (not (zerop diff))
            diff
            (let ((next-a (re:regex-replace "^[^0-9]*" a ""))
                  (next-b (re:regex-replace "^[^0-9]*" b "")))
              (if (and (string= next-a "") (string= next-b ""))
                0
                (multiple-value-bind (mna groups-na)
                    (re:scan-to-strings "^([0-9]*)" next-a)
                  (declare (ignore mna))
                  (multiple-value-bind (mnb groups-nb)
                      (re:scan-to-strings "^([0-9]*)" next-b)
                    (declare (ignore mnb))
                    (let* ((numeric-a (if groups-na (elt groups-na 0) ""))
                           (numeric-b (if groups-nb (elt groups-nb 0) ""))
                           (ndiff (numeric-part-compare numeric-a numeric-b)))
                      (if (not (zerop ndiff))
                        ndiff
                        (epochless-debian-vercmp
                          (re:regex-replace "^[0-9]*" next-a "")
                          (re:regex-replace "^[0-9]*" next-b ""))))))))))))))

;;; ─── Debian version comparison ─────────────────────────────────────────────

(defun debian-vercmp (a b)
  "Compare two Debian version numbers according to the Debian Policy Manual.
  
  Epoch numbers, upstream versions, and Debian revision version parts are
  fully supported.
  
  All other vercmp algorithms in svers are implemented in terms of this
  function."
  (let* ((a-epoch-result (epoch a))
         (a-epoch (first a-epoch-result))
         (a-vers (second a-epoch-result))
         (b-epoch-result (epoch b))
         (b-epoch (first b-epoch-result))
         (b-vers (second b-epoch-result)))
    (if (= a-epoch b-epoch)
      (epochless-debian-vercmp a-vers b-vers)
      (- a-epoch b-epoch))))

;;; ─── Maven version comparison ──────────────────────────────────────────────

(defun maven-normalize (vers)
  "Convert a Maven version number to a Debian version number."
  (let ((it vers))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+([Aa][Ll][Pp][Hh][Aa]|[Aa])" it "~~alpha"))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+([Bb][Ee][Tt][Aa]|[Bb])" it "~~beta"))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+([Mm][Ii][Ll][Ee][Ss][Tt][Oo][Nn][Ee]|[Mm])"
               it "~~milestone"))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+([Rr][Cc]|[Cc][Rr])" it "~~rc"))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+([Ss][Nn][Aa][Pp][Ss][Hh][Oo][Tt])"
               it "~~snapshot"))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+([Gg][Aa])" it ""))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+([Ff][Ii][Nn][Aa][Ll])" it ""))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+([Ss][Tt][Aa][Bb][Ll][Ee])" it ""))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+([a-zA-Z]+)" it "~\\1"))
    (setf it (re:regex-replace-all
               "[!-/:-@\\[-\\`{-}]+0+\\b" it ""))
    it))

(defun maven-vercmp (a b)
  "Compare two Maven version numbers."
  (debian-vercmp (maven-normalize a) (maven-normalize b)))

;;; ─── RPM version comparison ────────────────────────────────────────────────

(defun rpm-normalize (vers)
  "Convert an RPM version number to a Debian version number."
  (let ((it vers))
    (setf it (re:regex-replace-all "[!-/:-@\\[-\\`{-}]+" it "."))
    (setf it (re:regex-replace-all "([a-zA-Z]+)\\.([0-9]+)" it "\\1\\2"))
    (setf it (re:regex-replace-all "([0-9]+)\\.([a-zA-Z]+)" it "\\1\\2"))
    it))

(defun rpm-vercmp (a b)
  "Compare two RPM version numbers."
  (debian-vercmp (rpm-normalize a) (rpm-normalize b)))

;;; ─── Semver version comparison ─────────────────────────────────────────────

(defun semver-normalize (vers)
  "Convert a SemVer version number to a Debian version number."
  (let ((it vers))
    (setf it (re:regex-replace-all "\\+.*$" it ""))
    (setf it (re:regex-replace-all "-" it "~"))
    it))

(defun semver-vercmp (a b)
  "Compare two SemVer version numbers."
  (debian-vercmp (semver-normalize a) (semver-normalize b)))

;;; ─── RubyGem version comparison ────────────────────────────────────────────

(defun rubygem-normalize (vers)
  "Convert a Ruby Gem version number to a Debian version number."
  (let ((it vers))
    (setf it (re:regex-replace-all
               "([0-9]+)([a-zA-Z]+)" it "\\1.\\2"))
    (setf it (re:regex-replace-all
               "([a-zA-Z]+)([0-9]+)" it "\\1.\\2"))
    (setf it (re:regex-replace-all
               "([0-9]+(\\.[0-9]+)*)\\.([a-zA-Z].*)$" it "\\1~\\3"))
    it))

(defun rubygem-vercmp (a b)
  "Compare two Ruby Gem version numbers."
  (debian-vercmp (rubygem-normalize a) (rubygem-normalize b)))

;;; ─── Python local part normalization ───────────────────────────────────────

(defun python-local-part-normalize (part)
  "Normalize a Python local version part (0-9 → A-J)."
  (reduce (lambda (c pair)
            (re:regex-replace-all (string (first pair))
                                  c
                                  (string (second pair))))
          (map 'list (lambda (from-char to-char) (list from-char to-char))
                  "0123456789" "ABCDEFGHIJ")
          :initial-value part))

;;; ─── Python version comparison ─────────────────────────────────────────────

(defun python-normalize (vers)
  "Convert a Python (pip) version number to a Debian version number."
  (let ((it (string-downcase vers)))
    (setf it (re:regex-replace-all "^([0-9]+)!" it "\\1:"))
    (setf it (re:regex-replace-all "\\.post([0-9]+)" it "!~\\1"))
    (setf it (re:regex-replace-all
               "([0-9]+)([!-/:-@\\[-\\`{-}])?a([0-9]+)" it "\\1~a\\3"))
    (setf it (re:regex-replace-all
               "([0-9]+)([!-/:-@\\[-\\`{-}])?b([0-9]+)" it "\\1~b\\3"))
    (setf it (re:regex-replace-all
               "([0-9]+)([!-/:-@\\[-\\`{-}])?rc([0-9]+)" it "\\1~rc\\3"))
    (setf it (re:regex-replace-all
               "([0-9]+)([!-/:-@\\[-\\`{-}])?c([0-9]+)" it "\\1~rc\\3"))
    (setf it (re:regex-replace-all "[.]dev([0-9]+)" it "~~dev\\1"))
    it))

;;; ─── Naive part comparison (used by naive-vercmp) ─────────────────────────

(defun naive-partcmp (a b)
  "Compare two version parts of a naive version number."
  (cond
    ((and (re:scan "^[0-9]+$" a)
          (re:scan "^[0-9]+$" b))
     (numeric-part-compare a b))
    ((re:scan "^[0-9]+$" a) 1)
    ((re:scan "^[0-9]+$" b) -1)
    (t (if (string< a b) -1
         (if (string> a b) 1 0)))))

;;; ─── Naive version comparison ──────────────────────────────────────────────

(defun naive-vercmp (a b)
  "Compare two version numbers separated into parts by punctuation.
  This is the old rpmvercmp algorithm, used for Python local version parts."
  (let ((a-parts (re:split "[!-/:-@\\[-\\`{-}]+" a))
        (b-parts (re:split "[!-/:-@\\[-\\`{-}]+" b)))
    (or (some (lambda (x) (if (not (zerop x)) x nil))
              (mapcar #'naive-partcmp a-parts b-parts))
        (- (length a-parts) (length b-parts)))))

;;; ─── Python version comparison (full) ──────────────────────────────────────

(defun python-vercmp (a b)
  "Compare two Python (pip) version numbers according to PEP 440."
  (let* ((a-pub (re:regex-replace "\\+.*$" a ""))
         (b-pub (re:regex-replace "\\+.*$" b ""))
         (pub-result (debian-vercmp (python-normalize a-pub)
                                    (python-normalize b-pub))))
    (if (zerop pub-result)
      (cond
        ((and (search "+" a) (search "+" b))
         (naive-vercmp (re:regex-replace "^[^\\+]+\\+" a "")
                       (re:regex-replace "^[^\\+]+\\+" b "")))
        ((search "+" a) 1)
        ((search "+" b) -1)
        (t 0))
      pub-result)))
