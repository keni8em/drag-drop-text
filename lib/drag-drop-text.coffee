###
  lib/drag-drop-text.coffee
###

# SubAtom = require 'sub-atom'

module.exports = 
class DragDropText
  activate: ->
    console.log 'activate'
    # @subs = new SubAtom
    # @subs.add atom.workspace.observeTextEditors (editor) =>
    #   @subs.add editor, 'mousedown', '.item-views atom-text-editor:shadow .lines .line.cursor-line', (e) => @mousedown(e, editor)
  #     
  # mousedown: (e, editor) ->
  #   console.log editor.getSelectionsOrderedByBufferPosition()
  #   
  # 
  # deactivate: ->
  #   console.log 'deactivate'
  #   @subs.dispose()
