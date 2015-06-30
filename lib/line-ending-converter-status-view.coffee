[WINDOWS_FORMAT, UNIX_FORMAT, OLD_MAC_FORMAT] = ['\r\n', '\n', '\r']
[WIN_TEXT, UNIX_TEXT, OLD_MAC_TEXT] = ['Win(CRLF)', 'Unix(LF)', 'Old Mac(CR)']
#Default is '\n'. Solely by observation and subject to change. Need docs to support this.
DEFAULT_TEXT = UNIX_TEXT
# EOL status view in the status Bar
class LineEndingConverterStatusView extends HTMLDivElement
  initialize: (@statusBar) ->
    @classList.add('eol-status', 'inline-block')
    @eolLink = document.createElement('span')
    # @eolLink.href = '#'  #TODO make it a link <a> tag and support click to change
    @appendChild(@eolLink)
    @initConfigSubscriptions()
    this

  destroy: ->
    @disposeViewSubscriptions()
    @showConfigSubscription?.dispose()
    @showConfigSubscription = null
    @tile?.destroy()
    @tile = null
    return

  initConfigSubscriptions: ->
    @showConfigSubscription = atom.config.onDidChange 'line-ending-converter.showEolInStatusBar', ()=>
      @attach()

  attach: ->
    @tile?.destroy()
    if atom.config.get 'line-ending-converter.showEolInStatusBar'
      @initViewSubscriptions()
      @tile = @statusBar.addRightTile(item: this, priority: 12)
    else
      @disposeViewSubscriptions()
    @tile

  disposeViewSubscriptions: ->
    @activeItemSubscription?.dispose()
    @activeItemSubscription = null
    @eolSubscription?.dispose()
    @eolSubscription = null
    return

  initViewSubscriptions: ->
    @disposeViewSubscriptions()
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()
    @subscribeToActiveTextEditor()
    return

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  subscribeToActiveTextEditor: ->
    @eolSubscription?.dispose()
    # Set new subscription to the active Text Editor
    @eolSubscription = @getActiveTextEditor()?.onDidStopChanging =>
      @setCurrentEolText()
    @setCurrentEolText()
    return

  setCurrentEolText: ->
    buffer = @getActiveTextEditor()?.getBuffer()
    eolText = if buffer? then @getEolText(buffer.lineEndingForRow(0)) else undefined
    if eolText?
      @eolLink.textContent = eolText
      @eolLink.dataset.eol = eolText
      @style.display = ''
    else
      @eolLink.textContent = ''
      @eolLink.dataset.eol = ''
      @style.display = 'none'
    return

  getEolText: (eol) ->
    switch eol
      when UNIX_FORMAT then UNIX_TEXT
      when WINDOWS_FORMAT then WIN_TEXT
      when OLD_MAC_FORMAT then OLD_MAC_TEXT
      when '' then DEFAULT_TEXT
      else undefined

module.exports = document.registerElement('line-ending-converter-status', prototype: LineEndingConverterStatusView.prototype)
