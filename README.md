ICTSC スコアサーバー
---

[![CircleCI](https://circleci.com/gh/ictsc/ictsc-score-server.svg?style=svg)](https://circleci.com/gh/ictsc/ictsc-score-server)
![Docker Automated build](https://img.shields.io/docker/automated/upluse10/ictsc-score-server.svg)

The contest site for [ICTSC](http://icttoracon.net/) (ICT Trouble Shooting Contest).

It's called also *score server*.  The main feature of this is to propose problem and marking.

This provides whole game operations during contest:

- Proposing a problems (participant to solve in contest)
- Creating and discussing issues
- Submitting and marking answers
  - with a scoreboard
- Announcing notices

## Architecture, using frameworks

API and SPA

- API
  - Written in Ruby
  - API framework: Rails
    - Provides Graphql API (but session is stateful...)

#### Coding style

* [EditorConfig](http://editorconfig.org/): return code, indent, charset, and more
* [YAMLlint](https://github.com/adrienverge/yamllint): for YAML files
* [Rubocop](https://github.com/rubocop-hq/rubocop): for Ruby
* [ESLint](https://eslint.org/): for JavaScript


## Usage and How to Contribute

See [Wiki](https://github.com/ictsc/ictsc-score-server/wiki)

