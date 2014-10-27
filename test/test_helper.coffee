# Test Helpers
# -------------------------------------------------------------------------------------
# Add a global shortcut to `console.log`
global.log = console.log
# Add Chai to the global scope
global.chai = require('chai')
# Add Chai's `expect` and `assert` functions to the global scope.
# They will simply be available to the tests as `assert()` and `expect()`.
global.expect = chai.expect
global.assert = chai.assert
# Add UnderscoreJS globablly as `_`
global._ = require 'underscore'
# Add sinon globablly as `sinon`
global.sinon = require 'sinon'
# Set up a global convenience `timeout` function that receives the timeout time
# parameter before the callback
global.timeout = (time, callback) -> setTimeout(callback, time)

