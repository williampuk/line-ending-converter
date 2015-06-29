path = require 'path'
fs = require 'fs'
[WIN_TEXT, UNIX_TEXT, OLD_MAC_TEXT] = ['Win(CRLF)', 'Unix(LF)', 'Old Mac(CR)']
#Default is '\n'. Solely by observation and subject to change. Need docs to support this.
DEFAULT_TEXT = UNIX_TEXT
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Line Ending Converter", ->
  [editor, editorView, workspaceView] = []

  SAMPLE_TEXT = "a\nb\rc\r\nd\r\ne\rf\ng"
  TO_UNIX_RESULT = "a\nb\nc\nd\ne\nf\ng"
  TO_WINDOWS_RESULT = "a\r\nb\r\nc\r\nd\r\ne\r\nf\r\ng"
  TO_OLD_MAC_RESULT = "a\rb\rc\rd\re\rf\rg"

  beforeEach ->
    workspaceView = atom.views.getView atom.workspace

    waitsForPromise ->
      atom.workspace.open()

    waitsForPromise ->
      atom.packages.activatePackage 'status-bar'

    waitsForPromise ->
      atom.packages.activatePackage 'line-ending-converter'

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView editor

  describe 'line ending conversion commands', ->
    describe "when the line-ending-converter:convert-to-unix-format event is triggered", ->
      it "converts all the line endings to Unix format", ->
        editor.setText SAMPLE_TEXT
        atom.commands.dispatch editorView,
          'line-ending-converter:convert-to-unix-format'

        runs ->
          expect(SAMPLE_TEXT.match /\r\n|\r\w/g).not.toBe null
          expect(editor.getText()).toBe TO_UNIX_RESULT
          expect(editor.getText().match /\r\n|\r\w/g).toBe null

    describe "when the line-ending-converter:convert-to-windows-format event is triggered", ->
      it "converts all the line endings to Windows format", ->
        editor.setText SAMPLE_TEXT
        atom.commands.dispatch editorView,
          'line-ending-converter:convert-to-windows-format'

        runs ->
          expect(SAMPLE_TEXT.match /\w\n|\r\w/g).not.toBe null
          expect(editor.getText()).toBe TO_WINDOWS_RESULT
          expect(editor.getText().match /\w\n|\r\w/g).toBe null


    describe "when the line-ending-converter:convert-to-old-mac-format event is triggered", ->
      it "converts all the line endings to old Mac format", ->
        editor.setText SAMPLE_TEXT
        atom.commands.dispatch editorView,
          'line-ending-converter:convert-to-old-mac-format'

        runs ->
          expect(SAMPLE_TEXT.match /\r\n|\w\n/g).not.toBe null
          expect(editor.getText()).toBe TO_OLD_MAC_RESULT
          expect(editor.getText().match /\r\n|\w\n/g).toBe null

  describe 'line ending status view', ->
    [eolStatusView, eolTile, statusBar] = []

    beforeEach ->
      atom.packages.emitter.emit 'did-activate-all'
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
        expect(eolStatusView.eolLink.textContent).toBe DEFAULT_TEXT
        newEditor.setText 'abc\r\ndef\nghi\rjkl'
        newEditor.getBuffer().emitter.emit 'did-stop-changing'
        expect(eolStatusView.eolLink.textContent).toBe WIN_TEXT
        # set text to the non-active editor
        editor.setText 'abc\r\ndef\nghi\rjkl'
        editor.getBuffer().emitter.emit 'did-stop-changing'
        expect(eolStatusView.eolLink.textContent).toBe DEFAULT_TEXT
        editor.setText 'abc\rdef\r\nghi\njkl'
        editor.getBuffer().emitter.emit 'did-stop-changing'
        expect(eolStatusView.eolLink.textContent).toBe DEFAULT_TEXT
        editor.setText 'abc\ndef\r\nghi\rjkl'
        editor.getBuffer().emitter.emit 'did-stop-changing'
        expect(eolStatusView.eolLink.textContent).toBe DEFAULT_TEXT

    describe "when the package is deactivated", ->
      it "removes the line ending status view", ->
        spyOn eolTile, 'destroy'
        atom.packages.deactivatePackage 'line-ending-converter'
        expect(eolTile.destroy).toHaveBeenCalled()
