do (
  chai = require 'chai'
  sinonChai = require 'sinon-chai'

  # TODO: do this dynamically
  TestMe = require './util/testme_spec'
) ->
  chai.use sinonChai

  # enable 'should' assertion syntax
  chai.should()
