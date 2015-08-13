SAMPLE_TEXT = "a\nb\rc\r\nd\r\ne\rf\ng"
TO_UNIX_RESULT = "a\nb\nc\nd\ne\nf\ng"
TO_WINDOWS_RESULT = "a\r\nb\r\nc\r\nd\r\ne\r\nf\r\ng"
TO_OLD_MAC_RESULT = "a\rb\rc\rd\re\rf\rg"

describe "Line Ending Converter", ->
  [workspaceView, editor, editorView] = []

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
      atom.packages.emitter.emit 'did-activate-all'
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
