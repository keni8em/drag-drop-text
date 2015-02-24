###
  lib/drag-drop-text.coffee
###

$ = require 'jquery'
SubAtom = require 'sub-atom'

class DragDropText
  config:
    mouseHoldDelay:
      title: 'Mouse Hold Delay (MS)'
      type:'integer'
      default: 750
      
  activate: ->
    @subs = new SubAtom
    @subs.add atom.workspace.observeTextEditors (editor) =>
      lines = atom.views.getView(editor).shadowRoot.querySelector '.lines'
      @subs.add lines,     'mousedown', (e) => @mousedown e, editor, lines
      @subs.add $('body'), 'mouseup',   (e) => if @active then @clear()
      @subs.add lines,     'mousemove', (e) => 
        if @selected then @drag() else @clear()

  getSelection: ->
    bufRange = @editor.getLastSelection().marker.bufferMarker.range
    if not bufRange.isEmpty()
      @bufRange = bufRange
      @regionRects = []
      $(@lines).find('.highlights .highlight.selection .region').each (__, ele) =>
        @regionRects.push ele.getBoundingClientRect()
    
  mousedown: (e, @editor, @lines) ->
    @active = yes
    @bufRange = null
    @getSelection()
    holdDelay = atom.config.get 'drag-drop-text.mouseHoldDelay'
    @mouseTimeout = setTimeout =>
      @mouseTimeout = null
      @editorView = atom.views.getView @editor
      @getSelection()
      inSelection = no
      if @bufRange
        {pageX, pageY} = e
        for regionRect in @regionRects
          {left, top, right, bottom} = regionRect
          if left <= pageX < right and
              top <= pageY < bottom
            inSelection = yes
            break
      atom.commands.dispatch @editorView, (if inSelection then 'core:copy' else 'core:paste')
      if not inSelection then @clear(); return
      @selected = yes
      @marker = @editor.markBufferRange @bufRange
      @editor.decorateMarker @marker, type:'highlight', class:'drag-drop-text'
      @mouseTimeout2 = setTimeout =>
        @mouseTimeout2 = null
        @editor.setTextInBufferRange @bufRange, ''
      , holdDelay
    , holdDelay

  clearTimeouts: ->
    if @mouseTimeout 
      clearTimeout @mouseTimeout
      @mouseTimeout = null
    if @mouseTimeout2 
      clearTimeout @mouseTimeout2
      @mouseTimeout2 = null
    
  drag: ->
    @isDragging = yes
    selection = @editor.getLastSelection()
    process.nextTick -> selection.clear()
    @clearTimeouts()
  
  drop: ->
    selection = @editor.getLastSelection()
    range     = selection.marker.bufferMarker.range
    cursorPos = range.start
    selection.setBufferRange [cursorPos, cursorPos]
    atom.commands.dispatch @editorView, 'core:paste' 
    
  clear: -> 
    if @isDragging then @drop()
    @clearTimeouts()
    @active = @selected = @isDragging = no
    @marker?.destroy()
    
  deactivate: ->
    @clear()
    @subs.dispose()

module.exports = new DragDropText
