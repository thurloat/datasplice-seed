LibraryVersions = require './libraryversions'

describe 'Library Versions', ->

  it 'should report the current Lodash version', ->
    lodash = _.find LibraryVersions, (test) -> test.key is 'lodash'
    expect(lodash.version()).to.equal _.VERSION

  it 'should report the current React version', ->
    react = _.find LibraryVersions, (test) -> test.key is 'react'
    expect(react.version()).to.equal React.version
