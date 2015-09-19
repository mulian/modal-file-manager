{$,SelectListView} = require 'atom-space-pen-views'
{Directory,File} = require 'atom'

module.exports =
class ModalFileManagerView extends SelectListView
  #constructor: (serializedState) ->
  callback: undefined
  showHidden:false
  #selectNoDir:false
  showAllSubDir: true #not working right now

  comfirmFilter:
    #dir,file could be an regular Expression only files how pass will comfirmed
    dir: true
    file: true

  initialize: (@attr) ->
    super
    @panel ?= atom.workspace.addModalPanel(item: this)
    @baseElement = $(@element)

    @initTitle()
    @initKeyFunctions()

  initTitle: ->
    @sub = $("<h2 />",{id:'modal-file-manager-subtitle'})
    @subtitle = $("<h2 />",{text: 'none'})
    @subBefore = $("<div class='pull-right'><kbd class='key-binding'>←</kbd></div>")
    @title = $('<h1 />',{text: 'File Manager',id:'modal-file-manager-title'})
    @sub.append @subBefore
    @sub.append @subtitle
    @baseElement.prepend @sub
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
    iconClass = ""
    bindArrow = ""
    if item.entrie.isDirectory()
      iconClass = "icon-file-directory"
      bindArrow = "<div class='pull-right'><kbd class='key-binding'>→</kbd></div>"
    else
      iconClass = "icon icon-file-text"
    "<li class='modal-file-manager-item directory'>
      <span class='#{iconClass}
         modal-file-manager-item-title'>
        #{item.title}
      </span> #{bindArrow}
    </li>"

  open: (@currentDir,callback) ->
    @callback=callback if callback?
    @currentDir = new Directory @currentDir if @currentDir not instanceof Directory #==string
    @currentDir.getEntries (error,entries) =>
      if entries?
        @subtitle.text @currentDir.getPath()
        items = []
        for entrie in entries
          #if @showAllSubDir and entrie.isDirectory() #TODO: inklude all sub dir
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

  reOpen: ->
    @open @currentDir

  rightArrow: (item) ->
    @open item.entrie
  leftArrow: (item) ->
    @open @currentDir.getParent()
  confirmed: (item) =>
    if item.entrie.isDirectory()
      if @comfirmFilter.dir instanceof RegExp
        @callBackNow item.entrie if @comfirmFilter.dir.test item.entrie.getBaseName()
      else if @comfirmFilter.dir
        @callBackNow item.entrie
    else
      if @comfirmFilter.file instanceof RegExp
        @callBackNow item.entrie if @comfirmFilter.file.test item.entrie.getBaseName()
      else if @comfirmFilter.file
        @callBackNow item.entrie
  callBackNow: (item) ->
    @callback item
    @panel.hide()

  setFilterQuery: (str) ->
    @filterEditorView.model.setText str

  cancelled: ->
    #console.log("This view was cancelled")
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
