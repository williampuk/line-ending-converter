{Range} = require 'atom'

module.exports =
class LineEndingConverter
  @EOL_REGEX: /\r\n|\n|\r/g
  @WINDOWS_FORMAT: '\r\n'
  @UNIX_FORMAT: '\n'
  @OLD_MAC_FORMAT: '\r'

  constructor: ->
    atom.workspaceView.command 'line-ending-converter:convert-to-unix-format', => @convertToUnixFormat()
    atom.workspaceView.command 'line-ending-converter:convert-to-windows-format', => @convertToWindowsFormat()
    atom.workspaceView.command 'line-ending-converter:convert-to-old-mac-format', => @convertToOldMacFormat()

  convertToUnixFormat: ->
    if editor = atom.workspace.getActiveEditor()
      @convert(editor, 'UNIX')

  convertToWindowsFormat: ->
    if editor = atom.workspace.getActiveEditor()
      @convert(editor, 'WINDOWS')

  convertToOldMacFormat: ->
    if editor = atom.workspace.getActiveEditor()
      @convert(editor, 'OLD_MAC')

  convert: (editor, format) ->
    buffer = editor.getBuffer()
    wholeRange = new Range buffer.getFirstPosition(), buffer.getEndPosition()
    textWithNewEol = buffer.getText().replace LineEndingConverter.EOL_REGEX, LineEndingConverter[format+'_FORMAT']
    buffer.setTextInRange wholeRange, textWithNewEol, false
