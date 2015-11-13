{$,SelectListView} = require 'atom-space-pen-views'
{Directory,File,Emitter} = require 'atom'

fuzzyFilter=null

module.exports =
class ModalFileManagerView extends SelectListView
  callback: undefined
  currentPath: null

  constructor: (options) ->
    super
    @setOptions options

  #Set Options for example:
  # {}=
  #   deep: 1
  #   showHidden: false
  #   serializedState: state
  #   callback: (file) ->
  #     console.log file.getBaseName()
  #   comfirmFilter:
  #     dir: /.app$/
  #     file: false
  #   dir: '/'
  setOptions: (option) ->
    @deep = option?.deep ? 0
    @showHidden = option?.showHidden ? false
    @serializedState = option?.serializedState
    @callback = option?.callback
    #dir,file could be an regular Expression only files how pass will comfirmed
    @filterDir = filterDir ? true
    @filterFile = filterFile ? true

  initialize: (@attr) ->
    super
    @initEmitter()
    @panel ?= atom.workspace.addModalPanel(item: @element)

    @addClass "modal-file-manager" #for test
    @panel.hide()
    @initTitle()
    @initKeyFunctions()
    @emitter.on "did-finished-collect", =>
      # @selectItemViewLastWatched()
      # console.log "finisehd:"
      # console.log @getSelectedItem()
      lastWatchedDir = @list.find('li.lastWatchedDirectory')
      # console.log lastWatchedDir.length
      @selectItemView lastWatchedDir

  initTitle: ->
    @sub = $("<div/>",{id:'modal-file-manager-subtitle'})
    @subtitle = $("<h2 />",{text: 'none'})
    @subBefore = $("<div class='pull-right'><kbd class='key-binding'>←</kbd></div>")
    # @title = $('<h1 />',{text: 'File Manager',id:'modal-file-manager-title'})
    @sub.append @subBefore
    @sub.append @subtitle
    @prepend @sub
    # @prepend @title

  initEmitter: ->
    @emitter = new Emitter
    @keydown (event) =>
      switch event.keyCode
        when 37 then @emitter.emit 'did-press-left-arrow', @getSelectedItem(), event
        when 39 then @emitter.emit 'did-press-right-arrow', @getSelectedItem(), event

  initKeyFunctions: ->
    #currently there is no move-right or left event from atom maby later?
    @emitter.on 'did-press-right-arrow', @rightArrow
    @emitter.on 'did-press-left-arrow', @leftArrow

    #@rightArrow() if @rightArrow?
    #@leftArrow() if @leftArrow?

  getFilterKey: () ->
    "title"
  viewForItem: (item) -> #class: status-ignored if . icon-file-text
    #TODO: rewrite
    iconClass = ""
    bindArrow = ""
    showSubFolderFromFirst= ""
    itemClass = ""
    if item.subFromFirst?
      if item.subFromFirst.length>35
        item.subFromFirst = item.subFromFirst.substring 0,35
        item.subFromFirst = "#{item.subFromFirst}..."
      showSubFolderFromFirst= "<div class='pull-right'><kbd class='subFolder'>#{item.subFromFirst}</kbd></div>"
    #if not item.entrie?
      #console.log item
    if item.entrie.isDirectory()
      iconClass = "icon-file-directory"
      bindArrow = "<div class='pull-right'><kbd class='key-binding'>→</kbd></div>"
    else
      iconClass = "icon icon-file-text"
    if item.entrie.isDirectory() and @lastWatchedDirectory?.getRealPathSync() ==item.entrie.getRealPathSync()
      #console.log "set lastWatchedClass: #{item.title}"
      itemClass= "lastWatchedDirectory"
      @lastWatchedDirectory=undefined
    "<li class='modal-file-manager-item directory #{itemClass}' >
      <span class='#{iconClass}
         modal-file-manager-item-title'>
        #{item.title}
      </span> #{showSubFolderFromFirst}#{bindArrow}
    </li>"

  #open Directory and show file Manager
  #open with (dir, callback) or like constructor (one parameter)
  #dir could be string or an Directory object
  open: (dir,callback) ->
    @callback=callback if callback?
    @currentDir=dir if dir?
    @setOptions dir if dir instanceof Object
    @currentDir = new Directory @currentDir if @currentDir not instanceof Directory #==string

    @collectItems @currentDir, true

    if not @panel.isVisible()
      @panel.show()
    @focusFilterEditor()

  #it updates the items on every async callback, with updateList
  collectItems: (dir,start=false,deep=@deep) ->
    if start
      @collectionItems = []
      @currentDir = dir
      @currentPath = @currentDir.getRealPathSync()
      #Set suptitle text to current Path Url and reset Filter Query
      @subtitle.text @currentPath
      @setFilterQuery ""
      @subProcessCound = 0
    dir.getEntries (error,entries) =>
      atom.notifications.addError "error on collectItems" if error
      if entries?
        #console.log "deep #{deep}: #{dir.getRealPathSync()}"
        localItems = []
        for entrie in entries
          #show/hide hidden files AND on start show directory, if not start then no directorys
          if (@showHidden or not (entrie.getBaseName().charAt(0)=='.'))
            if parseInt(deep)>0 and entrie.isDirectory()
              #console.log "collect: #{entrie.getRealPathSync()}"
              @collectItems entrie,false, (parseInt(deep)-1)
              @subProcessCound++
            if start or not entrie.isDirectory()
              #console.log dir.getRealPath().substring @currentPath.length,entrie.relativize().length
              item =
                title: entrie.getBaseName()
                entrie: entrie
              if not start
                item.subFromFirst= dir.getRealPathSync().substring @currentPath.length,dir.getRealPathSync().lenght
              #@collectionItems.push item
              localItems.push item
        if start
          @setItems localItems
          @emitter.emit "did-finished-collect" if @subProcessCound==0
          #@selectItemViewLastWatched()
        else
          @updateList localItems
        #@update()
      else atom.notifications.addInfo "#{@currentDir.getBaseName()}: Permission denied"

  #override super.selectItemView to define the right selectItem for this Project
  # selectItemView: (item) ->
  #   lastWatchedItem = @list.find('li.lastWatchedDirectory')
  #   if item? and lastWatchedItem.length==1
  #     item = lastWatchedItem
  #   else if item?
  #     item = @list.find('li:first')
  #   super item

  selectItemViewLastWatched: ->
    @selectItemView $('#lastWatchedDirectory')

  updateListOnQuery: ->
    return unless @items?

    filterQuery = @getFilterQuery()
    if filterQuery.length
      fuzzyFilter = require('fuzzaldrin').filter
      filteredItems = fuzzyFilter(@items, filterQuery, key: @getFilterKey())

      @list.empty()
      if filteredItems.length
        @setError(null)

        for i in [0...Math.min(filteredItems.length, @maxItems)]
          item = filteredItems[i]
          itemView = $(@viewForItem(item))
          itemView.data('select-list-item', item)
          @list.append(itemView)
      else
        @setError(@getEmptyMessage(@items.length, filteredItems.length))

  #use copy from populateList for async update Items
  updateList: (items) ->
    return  unless items? or
            (@items not instanceof Array) or
            not @panel.isVisible() #stop if pane is invisible

    if items.length
      @setError(null)

      preClassItemLength=@items.length
      for i in [preClassItemLength...Math.min((preClassItemLength+items.length), @maxItems)]
        index= i-preClassItemLength
        item = items[index]
        itemView = $(@viewForItem(item))
        #console.log "#{item.entrie.getRealPathSync()}: index(#{index})"
        itemView.data('select-list-item', item)
        @list.append(itemView)
        @items.push item
    else
      @setError(@getEmptyMessage(preClassItemLength, items.length))


    criticalPart = =>
      @subProcessCound--
      if @subProcessCound==0
        @emitter.emit "did-finished-collect"
    criticalPart()


  rightArrow: (item=@getSelectedItem()) =>
    @collectItems item.entrie, true if item.entrie.isDirectory()
    #@open item.entrie if item.entrie.isDirectory()
  leftArrow: (item=@getSelectedItem()) =>
    @lastWatchedDirectory = @currentDir
    @collectItems @currentDir.getParent(), true
    #console.log "set "
    #@open @currentDir.getParent()
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
