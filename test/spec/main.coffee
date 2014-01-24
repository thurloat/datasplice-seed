require.config
  baseUrl: '../scripts'
  paths:
    'sinon-chai': '../bower_components/sinon-chai/lib/sinon-chai'

require [
  'sinon-chai'

  # list spec files here - would be nice to have a dynamic way of doing this
  '../spec/util/testme'

], (sinonChai)->
  chai.use sinonChai

  # enable 'should' assertion syntax
  chai.should()

  if window.mochaPhantomJS
    mochaPhantomJS.run()
  else
    mocha.run()
