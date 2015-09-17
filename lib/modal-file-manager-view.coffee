{$,SelectListView} = require 'atom-space-pen-views'
{Directory,File} = require 'atom'

module.exports =
class ModalFileManagerView extends SelectListView
  #constructor: (serializedState) ->
  callback: undefined
  showHidden=false

  initialize: (@attr) ->
    super
    @panel ?= atom.workspace.addModalPanel(item: this)
    @baseElement = $(@element)

    @initTitle()
    @initKeyFunctions()

  initTitle: ->
    @subtitle = $("<h2 />",{text: 'none',id:'modal-file-manager-subtitle'})
    @title = $('<h1 />',{text: 'File Manager: ',id:'modal-file-manager-title'})
    @baseElement.prepend @subtitle
    @baseElement.prepend @title

  initKeyFunctions: ->
    @baseElement.keydown (event) =>
      # console.log "key: #{event.keyCode}"
      # for el in @list.children()
      #   console.log el
      switch event.keyCode
        when 37 then @leftArrow @getSelectedItem() if @leftArrow?
        when 39 then @rightArrow @getSelectedItem() if @rightArrow?

  getFilterKey: () ->
    "title"
  viewForItem: (item) -> #class: status-ignored if . icon-file-text
    "<li class='modal-file-manager-item directory'>
      <span class='#{
        if item.entrie.isDirectory() then 'icon-file-directory' else 'icon icon-file-text'}
         modal-file-manager-item-title'>
        #{item.title}
      </span>
    </li>"

  open: (@currentDir,callback) ->
    @callback=callback if callback?
    @currentDir = new Directory @currentDir if @currentDir not instanceof Directory #==string
    @currentDir.getEntries (error,entries) =>
      if entries?
        @subtitle.text @currentDir.getPath()
        items = []
        for entrie in entries
          if @showHidden or not (entrie.getBaseName().charAt(0)=='.')
            items.push
              'title': entrie.getBaseName()
              'entrie': entrie
        @setItems items

        @setFilterQuery ""
        if not @panel.isVisible()
          @panel.show()
        @focusFilterEditor()
      else atom.notifications.addInfo "#{@currentDir.getBaseName()}: Permission denied"

  rightArrow: (item) ->
    @open item.entrie, @showHidden
  leftArrow: (item) ->
    @open @currentDir.getParent(), @showHidden
  confirmed: (item) ->
    if @callback?
      @callback item.entrie.getRealPathSync()
    else
      atom.notifications.addInfo "no callback to open #{item.entrie.getRealPathSync()}"
    @panel.hide()

  setFilterQuery: (str) ->
    @filterEditorView.model.setText str

  cancelled: ->
    console.log("This view was cancelled")
    @panel.hide()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    console.log "destroy"
    @destroy()

  getElement: ->
    @element

  setSate: (state) ->
