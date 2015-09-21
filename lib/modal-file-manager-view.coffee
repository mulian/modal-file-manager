{$,SelectListView} = require 'atom-space-pen-views'
{Directory,File} = require 'atom'

module.exports =
class ModalFileManagerView extends SelectListView
  callback: undefined

  constructor: (options) ->
    super
    @setOptions options

  schedulePopulateList: ->
    #do nothing!

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
  setOptions: (options) ->
    @deep = options?.deep ? 0
    @showHidden = options?.showHidden ? false
    @serializedState = options?.serializedState
    @callback = options?.callback
    #dir,file could be an regular Expression only files how pass will comfirmed
    @filterDir = options?.filterDir ? true
    @filterFile = options?.filterFile ? true

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
    showSubFolderFromFirst= ""
    itemClass = ""
    if item.subFromFirst?
      if item.subFromFirst.length>35
        item.subFromFirst = item.subFromFirst.substring 0,35
        item.subFromFirst = "#{item.subFromFirst}..."
      showSubFolderFromFirst= "<div class='pull-right'><kbd class='subFolder'>#{item.subFromFirst}</kbd></div>"
    if not item.entrie?
      console.log item
    if item.entrie.isDirectory()
      iconClass = "icon-file-directory"
      bindArrow = "<div class='pull-right'><kbd class='key-binding'>→</kbd></div>"
    else
      iconClass = "icon icon-file-text"
    if item.entrie.isDirectory() and @lastWatchedDirectory?.getRealPathSync() ==item.entrie.getRealPathSync()
      console.log "set lastWatchedClass: #{item.title}"
      itemClass= "lastWatchedDirectory"
      @lastWatchedDirectory=undefined
    "<li class='modal-file-manager-item directory #{itemClass}' >
      <span class='#{iconClass}
         modal-file-manager-item-title'>
        #{item.title}
      </span> #{showSubFolderFromFirst}#{bindArrow}
    </li>"

  currentPath: null

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

  #async collectItems
  #it updates the items on every async callback
  collectItems: (dir,start=false,deep=@deep) ->
    if start
      @collectionItems = []
      @currentDir = dir
      @currentPath = @currentDir.getRealPathSync()
      #Set suptitle text to current Path Url and reset Filter Query
      @subtitle.text @currentPath
      @setFilterQuery ""
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
          #@selectItemViewLastWatched()
        else
          @updateList localItems
        #@update()
      else atom.notifications.addInfo "#{@currentDir.getBaseName()}: Permission denied"

  selectItemView: (item) ->
    lastWatchedItem = @list.find('li.lastWatchedDirectory')
    if lastWatchedItem.length==1
      item = lastWatchedItem
    super item

  selectItemViewLastWatched: ->
    @selectItemView $('#lastWatchedDirectory')
    # listItem = $('#lastWatchedDirectory')
    # if listItem.length==1
    #
    #   @list.find('.selected').removeClass('selected')
    #   listItem.addClass('selected')
  addItems: (items) ->
    @items.push items
    #@populateList()
    #@setLoading()

  #use copy from populateList TODO
  updateList: (items) ->
    return unless items? or (@items not instanceof Array) or not @panel.isVisible() #stop if pane is invisible

    #@list.empty()
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

        #@selectItemViewLastWatched()
    else
      @setError(@getEmptyMessage(preClassItemLength, items.length))


  reOpen: ->
    @open @currentDir

  rightArrow: (item) ->
    @collectItems item.entrie, true if item.entrie.isDirectory()
    #@open item.entrie if item.entrie.isDirectory()
  leftArrow: (item) ->
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
    console.log "destroy"
    @destroy()

  getElement: ->
    @element

  setSate: (state) ->
