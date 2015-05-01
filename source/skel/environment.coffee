# inject shared libraries as globals - would be nice to be able to do this
# from the webpack config, but I can't figure out a way yet
# see skel.webpack.config.sharedLibraries
window._ = _
window.async = async
window.React = React

require 'console-shim'
(require 'es6-promise').polyfill();
require 'whatwg-fetch'

# also ensure Promise.done exists - see:
# https://www.promisejs.org/polyfills/promise-done-1.0.0.js
unless Promise::done
  Promise::done = (cb, eb) ->
    @then(cb, eb)
      .then null, (err) ->
        setTimeout ( () -> throw err ), 0

# basket.js needs to be loaded into the global scope
require 'imports?this=>window!basket.js'
# it also needs a mocked RSVP object for promises
window.RSVP = { Promise, all: Promise.all.bind Promise }

# by design changes to the application cache are not available until the page
# is refreshed after the cache has been updated. detect that and automatically
# refresh the page if that is the case (http://appcachefacts.info/)
ac = window.applicationCache
if ac
  ac.addEventListener 'updateready', -> location.reload()
