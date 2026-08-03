# svers

A Common Lisp library for version comparison.

Port of the [serovers](https://gitlab.com/djhaskin987/serovers) Clojure library.

## Version Schemes Supported

| Scheme | Function | Status |
|--------|----------|--------|
| **Debian** | `debian-vercmp` | Full epoch & revision support |
| **Maven** | `maven-vercmp` | Qualifiers: alpha, beta, milestone, rc,
|          |                | snapshot, ga, final, stable |
| **RPM** | `rpm-vercmp` | Fedora/RPM version comparison |
| **SemVer 2.0** | `semver-vercmp` | Including build metadata ignoring |
| **RubyGem** | `rubygem-vercmp` | Ruby gem version comparison |
| **Python (PEP 440)** | `python-vercmp` | Full PEP 440 including
|                      |                  | local versions |
| **Naive** | `naive-vercmp` | Punctuation-separated parts (used by
|           |                 | Python local parts) |

## How It Works

The key insight: by using the **Debian version comparison algorithm** under the
hood and simply normalizing version numbers from other schemes so that they
compare correctly, (almost) all of the version comparison algorithms can be
improved by optimizing just the Debian version comparison algorithm.

This architecture also makes it easy to add and maintain new version comparison
algorithms — just write a normalization function.

> **Note on liberality:** svers is liberal in what it accepts. If you compare
> two versions using `semver-vercmp` but one is not semver-compliant, svers
> will do its best instead of failing. This is important because package
> version numbers are set by maintainers, and it would be bad to break a build
> over a technicality.

## Usage

```lisp
(asdf:load-system "com.djhaskin.svers")
(use-package :com.djhaskin.svers)

;; Debian version comparison
(debian-vercmp "1.2.3~rc1" "1.2.3")  ;; => -1 (rc1 < release)

;; Maven
(maven-vercmp "1.0.0-alpha" "1.0.0-beta")  ;; => -1

;; RPM
(rpm-vercmp "1.0010" "1.9")  ;; => 1 (1.0010 > 1.9)

;; SemVer
(semver-vercmp "1.0.0-alpha" "1.0.0")  ;; => -1

;; RubyGem
(rubygem-vercmp "1.0.a10" "1.0.a9")  ;; => 1

;; Python (PEP 440)
(python-vercmp "1.0a1" "1.0b1")  ;; => -1 (alpha < beta)

;; Naive (punctuation-separated parts)
(naive-vercmp "1.2.0" "1.2")  ;; => 1
```

All comparison functions return:
- **Negative** if the first argument is older/less than the second
- **Zero** if they are equal
- **Positive** if the first argument is newer/greater than the second

## Etymology

Named after [Valentin Serov](https://en.wikipedia.org/wiki/Valentin_Serov),
the painter.

## License

Copyright © 2017-2024 Daniel Jay Haskin et. al.

Distributed under the MIT License.