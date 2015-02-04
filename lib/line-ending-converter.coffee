{Range, Point} = require 'atom'

module.exports =
class LineEndingConverter
  @WINDOWS_FORMAT: '\r\n'
  @UNIX_FORMAT: '\n'
  @OLD_MAC_FORMAT: '\r'

  constructor: ->

  convertToUnixFormat: ->
    if editor = atom.workspace.getActiveTextEditor()
      @convert(editor, LineEndingConverter.UNIX_FORMAT)

  convertToWindowsFormat: ->
    if editor = atom.workspace.getActiveTextEditor()
      @convert(editor, LineEndingConverter.WINDOWS_FORMAT)

  convertToOldMacFormat: ->
    if editor = atom.workspace.getActiveTextEditor()
      @convert(editor, LineEndingConverter.OLD_MAC_FORMAT)

  convert: (editor, format) ->
    buffer = editor.getBuffer()
    lastRowIndex = buffer.getLastRow()
    buffer.transact ->
      for rowIndex in [0...lastRowIndex]
        do (rowIndex) ->
          currEol = buffer.lineEndingForRow rowIndex
          if currEol isnt format
            lineEndingRange = new Range(
              new Point(rowIndex, buffer.lineLengthForRow(rowIndex)),
              new Point(rowIndex + 1, 0)
            )
            buffer.setTextInRange lineEndingRange, format,
              { normalizeLineEndings: false }
          return
