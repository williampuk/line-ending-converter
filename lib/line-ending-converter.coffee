{Range, Point} = require 'atom'
{CompositeDisposable} = require 'atom'
[WINDOWS_FORMAT, UNIX_FORMAT, OLD_MAC_FORMAT] = ['\r\n', '\n', '\r']
NormalizeConfig =
  DISABLED:
    text: 'Disabled'
  AUTO:
    text: "Auto Detect (Use First Row's EOL)"
  WIN:
    text: 'Win (CRLF)'
    format: WINDOWS_FORMAT
  UNIX:
    text: 'Unix (LF)'
    format: UNIX_FORMAT
  OLD_MAC:
    text: 'Old Mac (CR)'
    format: OLD_MAC_FORMAT

module.exports =
class LineEndingConverter
  constructor: ->
    @initConfigSubscriptions()

  destroy: ->
    @disposeOnSaveSubscriptions()
    return

  initConfigSubscriptions: ->
    @showConfigSubscription = atom.config.observe 'line-ending-converter.normalizeEolOnSave',
      (newConfigValue) =>
        # console.log 'config subscription', newConfigValue
        # console.log(newConfigValue is NormalizeConfig.DISABLED.text)
        if newConfigValue is NormalizeConfig.DISABLED.text
          @disposeOnSaveSubscriptions()
        else
          @initOnSaveSubscriptions(newConfigValue)

  disposeOnSaveSubscriptions: ->
    # console.log 'disposing all'
    @activeOnSaveSubscription?.dispose()
    @activeOnSaveSubscription = null
    @bufferSubscriptions?.dispose()
    @bufferSubscriptions = null
    return

  initOnSaveSubscriptions: (configValue) ->
    # console.log 'init on save', configValue
    @disposeOnSaveSubscriptions()
    @bufferSubscriptions = new CompositeDisposable
    @activeOnSaveSubscription = atom.workspace.observeTextEditors (editor) =>
      # console.log 'editor subscription is called'
      buffer = editor.getBuffer()
      eolFormat = switch configValue
        when NormalizeConfig.WIN.text then NormalizeConfig.WIN.format
        when NormalizeConfig.UNIX.text then NormalizeConfig.UNIX.format
        when NormalizeConfig.OLD_MAC.text then NormalizeConfig.OLD_MAC.format
        else null
      if configValue is NormalizeConfig.AUTO.text or eolFormat?
        # How to handle buffer getting subscribed multiple times?
        # without simply saving a set of buffer?
        bufferSubscription = buffer.onWillSave =>
          # console.log 'Will save is called'
          if configValue is NormalizeConfig.AUTO.text
            detectedEol = buffer.lineEndingForRow 0
            if detectedEol isnt ''
              @convert buffer, detectedEol
          else
            @convert buffer, eolFormat
        destroySubscription = buffer.onDidDestroy =>
          # console.log 'Destroy is called'
          bufferSubscription.dispose()
          destroySubscription.dispose()
          @bufferSubscriptions.remove bufferSubscription
          @bufferSubscriptions.remove destroySubscription
        @bufferSubscriptions.add bufferSubscription
        @bufferSubscriptions.add destroySubscription
      # else
      #   # for DEBUG
      #   console.error 'Fatal: eol format is null'
    return

  convertToUnixFormat: ->
    if editor = atom.workspace.getActiveTextEditor()
      @convert editor.getBuffer(), UNIX_FORMAT

  convertToWindowsFormat: ->
    if editor = atom.workspace.getActiveTextEditor()
      @convert editor.getBuffer(), WINDOWS_FORMAT

  convertToOldMacFormat: ->
    if editor = atom.workspace.getActiveTextEditor()
      @convert editor.getBuffer(), OLD_MAC_FORMAT

  convert: (buffer, format) ->
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
