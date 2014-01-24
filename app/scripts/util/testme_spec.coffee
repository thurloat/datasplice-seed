do (
  TestMe = require '../dist/scripts/main'
) ->
  it 'should add two numbers', ->
    answer = (new TestMe).add 1, 2
    answer.should.equal 3
