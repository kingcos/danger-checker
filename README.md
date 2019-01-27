# danger-checker

[![Build Status](https://travis-ci.org/kingcos/danger-checker.svg?branch=master)](https://travis-ci.org/kingcos/danger-checker)

**danger-checker** is a plugin for [Danger](https://danger.systems/swift) to simply check your changes as you like.

## Installation

    $ gem install danger-checker

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `checker` namespace.

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

---

> ***Do you want to compress your images during CI? Please check my another Danger plugin called [danger-tinypng](https://github.com/kingcos/danger-tinypng).***
