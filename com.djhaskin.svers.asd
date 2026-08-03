(defsystem "com.djhaskin.svers"
  :version "0.1.0"
  :author "Daniel Jay Haskin"
  :license "MIT"
  :depends-on (
               "cl-ppcre"
               "alexandria"
               )
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description "Version comparison library supporting multiple schemes."
  :in-order-to ((test-op (test-op "com.djhaskin.svers/tests"))))

(defsystem "com.djhaskin.svers/tests"
  :version "0.1.0"
  :author "Daniel Jay Haskin"
  :license "MIT"
  :depends-on (
               "com.djhaskin.svers"
               "parachute"
               )
  :components ((:module "tests"
                :components
                ((:file "debian-cases")
                 (:file "maven-cases")
                 (:file "rpm-cases")
                 (:file "semver-cases")
                 (:file "gem-cases")
                 (:file "naive-cases")
                 (:file "python-cases"))))
  :description "Test system for svers."
  :perform (asdf:test-op (op c)
                         (uiop:symbol-call :parachute :test
                                           (list
                                             '#:com.djhaskin.svers/tests/debian-cases
                                             '#:com.djhaskin.svers/tests/maven-cases
                                             '#:com.djhaskin.svers/tests/rpm-cases
                                             '#:com.djhaskin.svers/tests/semver-cases
                                             '#:com.djhaskin.svers/tests/gem-cases
                                             '#:com.djhaskin.svers/tests/naive-cases
                                             '#:com.djhaskin.svers/tests/python-cases))))