LineEndingConverter = require './line-ending-converter'

module.exports =
  lineEndingConverter: null

  activate: (state) ->
    @lineEndingConverter = new LineEndingConverter()

  deactivate: ->
    @lineEndingConverter?.destroy?()
    @lineEndingConverter = null
