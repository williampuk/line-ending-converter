# path = require 'path'
# fs = require 'fs'
# {WorkspaceView} = require 'atom'
# # Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
# #
# # To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# # or `fdescribe`). Remove the `f` to unfocus the block.
#
# describe "LineEndingConverter", ->
#   beforeEach ->
#     waitsForPromise ->
#       console.log atom.packages
#       atom.packages.enablePackage 'line-ending-converter'
#
#   describe "when the line-ending-converter:convert-to-unix-format event is triggered", ->
#     it "should convert all the line endings to unix format", ->
#       [beforeFileEditor, beforeFileEditorView] = []
#       atom.workspaceView = new WorkspaceView
#       resultText = fs.readFileSync path.join(__dirname, './fixtures/convert-to-unix/after.txt'), 'utf8'
#       waitsForPromise ->
#         atom.workspaceView.open(path.join __dirname, './fixtures/convert-to-unix/before.txt')
#         .then (editor) ->
#           beforeFileEditorView = atom.workspaceView.getActiveView()
#           beforeFileEditor = editor
#
#       runs ->
#         expect(beforeFileEditor.getBuffer().getText().match /\r\n/g).not.toBe null
#         beforeFileEditorView.trigger 'line-ending-converter:convert-to-unix-format'
#         expect(beforeFileEditor.getBuffer().getText()).toBe resultText
#         expect(beforeFileEditor.getBuffer().getText().match /\r\n/g).toBe null
