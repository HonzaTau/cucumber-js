Feature: Parameter transforms

  Users can register their own parameters to be used in Cucumber expressions.
  Custom parameters can be used to match certain patterns, and optionally to
  transform the matched value into a custom type.

  Background:
    Given a file named "features/particular_steps.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a particular step
      """
    Given a file named "features/step_definitions/my_steps.js" with:
      """
      import assert from 'assert'
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({Given}) => {
        Given('a {param} step', function(param) {
          assert.equal(param, 'PARTICULAR')
        })
      })
      """

  Scenario: sync transform (success)
    Given a file named "features/support/transforms.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({addParameter}) => {
        addParameter({
          captureGroupRegexps: /particular/,
          transformer: s => s.toUpperCase(),
          typeName: 'param'
        })
      })
      """
    When I run cucumber.js
    Then the step "a particular step" has status "passed"

  Scenario: sync transform (success) using deprecated addTransform API
    Given a file named "features/support/transforms.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({addTransform}) => {
        addTransform({
          captureGroupRegexps: /particular/,
          transformer: s => s.toUpperCase(),
          typeName: 'param'
        })
      })
      """
    When I run cucumber.js
    Then the step "a particular step" has status "passed"

  Scenario: sync transform (error)
    Given a file named "features/support/transforms.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({addParameter}) => {
        addParameter({
          captureGroupRegexps: /particular/,
          transformer: s => {
            throw new Error('transform error')
          },
          typeName: 'param'
        })
      })
      """
    When I run cucumber.js
    Then it fails
    And the step "a particular step" failed with:
      """
      transform error
      """

  Scenario: async transform (success)
    Given a file named "features/step_definitions/particular_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'
      import Promise from 'bluebird'

      defineSupportCode(({addParameter}) => {
        addParameter({
          captureGroupRegexps: /particular/,
          transformer: s => Promise.resolve(s.toUpperCase()),
          typeName: 'param'
        })
      })
      """
    When I run cucumber.js
    Then the step "a particular step" has status "passed"

  Scenario: async transform (error)
    Given a file named "features/step_definitions/particular_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'
      import Promise from 'bluebird'

      defineSupportCode(({addParameter}) => {
        addParameter({
          captureGroupRegexps: /particular/,
          transformer: s => Promise.reject(new Error('transform error')),
          typeName: 'param'
        })
      })
      """
    When I run cucumber.js
    Then it fails
    And the step "a particular step" failed with:
      """
      transform error
      """
