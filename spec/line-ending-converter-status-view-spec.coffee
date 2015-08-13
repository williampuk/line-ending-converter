[WIN_TEXT, UNIX_TEXT, OLD_MAC_TEXT] = ['CRLF', 'LF', 'CR']

#Default is '\n'. Solely by observation and subject to change. Need docs to support this.
DEFAULT_TEXT = UNIX_TEXT

describe "Line Ending Converter Status View", ->
  [workspaceView, editor, eolStatusView, eolTile, statusBar] = []

  beforeEach ->
    atom.config.set 'line-ending-converter.showEolInStatusBar', true
    workspaceView = atom.views.getView atom.workspace
    jasmine.attachToDOM workspaceView

    waitsForPromise ->
      atom.packages.activatePackage 'status-bar'

    waitsForPromise ->
      atom.packages.activatePackage 'line-ending-converter'

    waitsForPromise ->
      atom.workspace.open 'unix.txt'

    runs ->
      # atom.packages.emitter.emit 'did-activate-all'
      editor = atom.workspace.getActiveTextEditor()
      statusBar = workspaceView.querySelector 'status-bar'
      eolStatusView = workspaceView.querySelector 'line-ending-converter-status'
      for tile in statusBar.getRightTiles()
        if tile.getItem() is eolStatusView
          eolTile = tile

  it "attaches the line ending status view to the right side of the status bar", ->
    expect(eolStatusView).not.toBe null
    expect(eolTile).not.toBe null

  it "displays the current line ending", ->
    expect(eolStatusView.eolLink.textContent).toBe DEFAULT_TEXT
    editor.setText 'abc\r\ndef\nghi\rjkl'
    editor.getBuffer().emitter.emit 'did-stop-changing'
    expect(eolStatusView.eolLink.textContent).toBe WIN_TEXT
    editor.setText 'abc\rdef\r\nghi\njkl'
    editor.getBuffer().emitter.emit 'did-stop-changing'
    expect(eolStatusView.eolLink.textContent).toBe OLD_MAC_TEXT
    editor.setText 'abc\ndef\r\nghi\rjkl'
    editor.getBuffer().emitter.emit 'did-stop-changing'
    expect(eolStatusView.eolLink.textContent).toBe UNIX_TEXT

  describe "when the new editor is opened", ->
    [newEditor] = []
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open()
      runs ->
        newEditor = atom.workspace.getActiveTextEditor()

    it "displays the current line ending", ->
      expect(eolStatusView.eolLink.textContent).toBe DEFAULT_TEXT
      newEditor.setText 'abc\r\ndef\nghi\rjkl'
      newEditor.getBuffer().emitter.emit 'did-stop-changing'
      expect(eolStatusView.eolLink.textContent).toBe WIN_TEXT
      newEditor.setText 'abc\rdef\r\nghi\njkl'
      newEditor.getBuffer().emitter.emit 'did-stop-changing'
      expect(eolStatusView.eolLink.textContent).toBe OLD_MAC_TEXT
      newEditor.setText 'abc\ndef\r\nghi\rjkl'
      newEditor.getBuffer().emitter.emit 'did-stop-changing'
      expect(eolStatusView.eolLink.textContent).toBe UNIX_TEXT

    it "does not subscribe to non-active editor", ->
      expect(newEditor is editor).toBe false
      expect(eolStatusView.eolLink.textContent).toBe DEFAULT_TEXT
      newEditor.setText 'abc\r\ndef\nghi\rjkl'
      newEditor.getBuffer().emitter.emit 'did-stop-changing'
      expect(eolStatusView.eolLink.textContent).toBe WIN_TEXT
      # set text to the non-active editor
      editor.setText 'abc\r\ndef\nghi\rjkl'
      editor.getBuffer().emitter.emit 'did-stop-changing'
      expect(eolStatusView.eolLink.textContent).toBe WIN_TEXT
      editor.setText 'abc\rdef\r\nghi\njkl'
      editor.getBuffer().emitter.emit 'did-stop-changing'
      expect(eolStatusView.eolLink.textContent).toBe WIN_TEXT
      editor.setText 'abc\ndef\r\nghi\rjkl'
      editor.getBuffer().emitter.emit 'did-stop-changing'
      expect(eolStatusView.eolLink.textContent).toBe WIN_TEXT

  describe "when the package is deactivated", ->
    it "removes the status view and subscriptions", ->
      expect(eolTile?).toBeTruthy()
      spyOn eolTile, 'destroy'
      # This is atom internal property, can be broken at any time in the future
      eventCount = editor?.getBuffer()?.emitter.handlersByEventName['did-stop-changing'].length

      atom.packages.deactivatePackage 'line-ending-converter'
      expect(eolTile.destroy).toHaveBeenCalled()
      expect(editor?.getBuffer()?.emitter.handlersByEventName['did-stop-changing'].length).toBe(eventCount - 1)

  describe "when the status view is disabled in setting", ->
    it "removes the status view and subscriptions", ->
      expect(eolTile?).toBeTruthy()
      spyOn eolTile, 'destroy'
      # This is atom internal property, can be broken at any time in the future
      eventCount = editor?.getBuffer()?.emitter.handlersByEventName['did-stop-changing'].length

      atom.config.set 'line-ending-converter.showEolInStatusBar', false
      expect(eolTile.destroy).toHaveBeenCalled()
      expect(editor?.getBuffer()?.emitter.handlersByEventName['did-stop-changing'].length).toBe(eventCount - 1)
