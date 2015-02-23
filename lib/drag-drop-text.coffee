###
  lib/drag-drop-text.coffee
###

$ = require 'jquery'
SubAtom = require 'sub-atom'

class DragDropText
  activate: ->
    console.log 'activate'
    @subs = new SubAtom
    do subscribeToAllEditors = =>
      @subs.add atom.workspace.observeTextEditors (editor) =>
        lines = atom.views.getView(editor).shadowRoot.querySelector '.lines'
        @subs.add lines,     'mousedown',         (e) => @mousedown e, editor, lines
        @subs.add $('body'), 'mouseup mousemove', (e) => if @active then @clear()
        @subs.add editor.onDidDestroy =>
          @clear()
          @subs.dispose()
          @subs = new SubAtom
          subscribeToAllEditors()

  mousedown: (e, editor, lines) ->
    selection = editor.getLastSelection()
    bufRange = selection.marker.bufferMarker.range
    if not bufRange.isEmpty()
      line = lines.querySelector ".line[data-screen-row=\"#{bufRange.start.row}\"]"
      {top:linTop, bottom:linBot} = line.getBoundingClientRect() 
      {top:tgtTop, bottom:tgtBot} = e.target.getBoundingClientRect() 
      if not (tgtBot <= linTop or tgtTop >= linBot)
        console.log 'in line'
        @active = yes
        @mouseTimeout = setTimeout =>
          @mouseTimeout = null
          @marker = editor.markBufferRange bufRange
          dm = editor.decorateMarker @marker, type:'highlight', class:'drag-drop-text'
          console.log 'mouse held', bufRange, @marker, dm
          @isDragging  = yes
        , 1000
        
  clear: -> 
    @active = @isDragging = no
    if @mouseTimeout 
      clearTimeout @mouseTimeout
      @mouseTimeout = null
    @marker?.destroy()
    
  deactivate: ->
    @clear()
    @subs.dispose()

module.exports = new DragDropText
