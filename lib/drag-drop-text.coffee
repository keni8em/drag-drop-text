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
    oldBufRange = editor.getLastSelection().marker.bufferMarker.range
    @active = yes
    @mouseTimeout = setTimeout =>
      @mouseTimeout = null
      bufRange  = editor.getLastSelection().marker.bufferMarker.range
      if bufRange.isEmpty() then bufRange = oldBufRange
      if not bufRange.isEmpty()
        linesTop = null
        for row in [bufRange.start.row..bufRange.end.row]
          if (line = lines.querySelector ".line[data-screen-row=\"#{row}\"]")
            rect = line.getBoundingClientRect() 
            linesTop ?= rect.top
            linesBot =  rect.bottom
        if linesTop
          {top, bottom} = e.target.getBoundingClientRect()
          if top >= linesTop and bottom <= linesBot
            @marker = editor.markBufferRange bufRange
            dm = editor.decorateMarker @marker, type:'highlight', class:'drag-drop-text'
            console.log 'mouse held', bufRange
            # console.log '.drag-drop-text', atom.views.getView(editor).shadowRoot.querySelector '.drag-drop-text'
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
