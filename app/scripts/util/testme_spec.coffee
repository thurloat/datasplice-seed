do (
  TestMe = require './testme'
) ->
  describe 'TestMe', ->
    it 'should add two numbers', ->
      answer = (new TestMe).add 1, 2
      answer.should.equal 3
