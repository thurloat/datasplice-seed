# require.config
#   baseUrl: '../scripts'
#   paths:
#     'sinon-chai': '../bower_components/sinon-chai/lib/sinon-chai'

# require [
#   'sinon-chai'

#   # list spec files here - would be nice to have a dynamic way of doing this
#   '../spec/util/testme'

# ], (sinonChai)->

do (
  chai = require 'chai'
  sinonChai = require 'sinon-chai'
  TestMe = require './util/testme'
) ->
  chai.use sinonChai

  # enable 'should' assertion syntax
  chai.should()
