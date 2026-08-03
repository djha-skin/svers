# Change Log
All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-08-02
### Added
- Initial port from serovers (Clojure) to svers (Common Lisp)
- Debian version comparison with epoch support (`debian-vercmp`)
- Maven version comparison with qualifier support
  (`maven-vercmp`, `maven-normalize`)
- RPM version comparison (`rpm-vercmp`, `rpm-normalize`)
- SemVer 2.0 version comparison with build metadata ignoring
  (`semver-vercmp`, `semver-normalize`)
- RubyGem version comparison (`rubygem-vercmp`, `rubygem-normalize`)
- Python PEP 440 version comparison with local version parts
  (`python-vercmp`, `python-normalize`)
- Naive/punctuation-separated version comparison (`naive-vercmp`)
- Comprehensive test suite with 293 parachute tests