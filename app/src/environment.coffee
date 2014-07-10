# Responsible for setting up environment shims, hacks, and other nonsense

# ensure 'global' reference to top-level object
# node always defines this, so browsers are the only environment where it
# might not be defined so we can set it to window
unless global?
  window.global = window

# load ES6 Promise polyfill if needed
unless global.Promise
  global.Promise = (require 'es6-promise').Promise

# also ensure Promise.done exists - see:
# https://www.promisejs.org/polyfills/promise-done-1.0.0.js
unless Promise::done
  Promise::done = (cb, eb) ->
    @then(cb, eb)
      .then null, (err) ->
        setTimeout ( () -> throw err ), 0

# fixup broken console in various environments (IE, mobile, etc)
unless global.console
  global.console =
    log: ->
    warn: ->
    debug: ->
    info: ->
    error: ->

unless console.debug?
  console.debug = console.log

