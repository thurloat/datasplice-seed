{ blockquote, ul, li, a, span } = React.DOM

LibraryInfo =
  label: React.PropTypes.string.isRequired
  url: React.PropTypes.string.isRequired
  version: React.PropTypes.func.isRequired

LibraryVersions = React.createClass
  displayName: 'LibraryVersions'

  propTypes:
    libraryInfo: (React.PropTypes.arrayOf React.PropTypes.shape LibraryInfo).isRequired

  render: ->
    blockquote style: { marginBottom: 0 },
      ul null,
        for info in @props.libraryInfo
          li key: info.label,
            a href: info.url, info.label
            span null, " [#{info.version()}]"

module.exports = LibraryVersions
