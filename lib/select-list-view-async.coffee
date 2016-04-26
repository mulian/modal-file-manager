{$,SelectListView} = require 'atom-space-pen-views'
{Emitter} = require 'atom'

fuzzyFilter=null
#TODO: Cleanup
module.exports =
class SelectListViewAsync extends SelectListView
  callback: undefined
  currentPath: null

  initialize: (@attr) ->
    super
    @initEmitter()
    # @emitter.on "did-finished-collect", =>
    #   lastWatchedDir = @list.find('li.lastWatchedDirectory')
    #   @selectItemView lastWatchedDir

  initEmitter: ->
    @emitter = new Emitter
    @keydown (event) =>
      switch event.keyCode
        when 37 then @emitter.emit 'did-press-left-arrow', @getSelectedItem(), event
        when 39 then @emitter.emit 'did-press-right-arrow', @getSelectedItem(), event

  # getFilterKey: () ->
    # "title"
  # viewForItem: (item) -> #class: status-ignored if . icon-file-text
    # #TODO: rewrite
    # iconClass = ""
    # bindArrow = ""
    # showSubFolderFromFirst= ""
    # itemClass = ""
    # if item.subFromFirst?
    #   if item.subFromFirst.length>35
    #     item.subFromFirst = item.subFromFirst.substring 0,35
    #     item.subFromFirst = "#{item.subFromFirst}..."
    #   showSubFolderFromFirst= "<div class='pull-right'><kbd class='subFolder'>#{item.subFromFirst}</kbd></div>"
    # #if not item.entrie?
    #   #console.log item
    # if item.entrie.isDirectory()
    #   iconClass = "icon-file-directory"
    #   bindArrow = "<div class='pull-right'><kbd class='key-binding'>→</kbd></div>"
    # else
    #   iconClass = "icon icon-file-text"
    # if item.entrie.isDirectory() and @lastWatchedDirectory?.getRealPathSync() ==item.entrie.getRealPathSync()
    #   #console.log "set lastWatchedClass: #{item.title}"
    #   itemClass= "lastWatchedDirectory"
    #   @lastWatchedDirectory=undefined
    # "<li class='modal-file-manager-item directory #{itemClass}' >
    #   <span class='#{iconClass}
    #      modal-file-manager-item-title'>
    #     #{item.title}
    #   </span> #{showSubFolderFromFirst}#{bindArrow}
    # </li>"



  #override super.selectItemView to define the right selectItem for this Project
  # selectItemView: (item) ->
  #   lastWatchedItem = @list.find('li.lastWatchedDirectory')
  #   if item? and lastWatchedItem.length==1
  #     item = lastWatchedItem
  #   else if item?
  #     item = @list.find('li:first')
  #   super item

  # selectItemViewLastWatched: ->
  #   @selectItemView $('#lastWatchedDirectory')

  # updateListOnQuery: ->

  #use copy from populateList for async update Items
  # updateList: (items) ->

  confirmed: (item) =>
    if item.entrie.isDirectory()
      if @filterDir instanceof RegExp
        @callBackNow item.entrie if @filterDir.test item.entrie.getBaseName()
      else if @filterDir
        @callBackNow item.entrie
    else
      if @filterFile instanceof RegExp
        @callBackNow item.entrie if @filterFile.test item.entrie.getBaseName()
      else if @filterFile
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
    @emitter.dispose()
    @detach()

  getElement: ->
    @element

  setSate: (state) ->

  schedulePopulateList: -> #call from super
    clearTimeout(@scheduleTimeout)
    populateCallback = =>
      @updateListOnQuery() if @isOnDom()
    @scheduleTimeout = setTimeout(populateCallback,  @inputThrottle)

  toggle: ->
    if @panel.isVisible()
      @panel.hide()
    else @panel.show()
