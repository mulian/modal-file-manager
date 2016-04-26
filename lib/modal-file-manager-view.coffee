{$} = require 'atom-space-pen-views'
SelectListViewAsync = require './select-list-view-async'
{Directory,File} = require 'atom'
fuzzyFilter=null
#TODO: Cleanup
module.exports =
class ModalFileManagerView extends SelectListViewAsync

  constructor: (options) ->
    super options

  initialize: ->
    super
    @addClass "modal-file-manager" #for test
    @initTitle()
    @initKeyFunctions()
    @panel ?= atom.workspace.addModalPanel(item: @element)
    @panel.hide()

  initTitle: ->
    @sub = $("<div/>",{id:'modal-file-manager-subtitle'})
    @subtitle = $("<h2 />",{text: 'none'})
    @subBefore = $("<div class='pull-right'><kbd class='key-binding'>←</kbd></div>")
    # @title = $('<h1 />',{text: 'File Manager',id:'modal-file-manager-title'})
    @sub.append @subBefore
    @sub.append @subtitle
    $(@panel).prepend @sub
    console.log @
    # @prepend @title

  initKeyFunctions: ->
    #currently there is no move-right or left event from atom maby later?
    @emitter.on 'did-press-left-arrow', @leftArrow
    @emitter.on 'did-press-right-arrow', @rightArrow

  rightArrow: (item=@getSelectedItem()) =>
    @collectItems item.entrie, true if item.entrie.isDirectory()
    #@open item.entrie if item.entrie.isDirectory()
  leftArrow: (item=@getSelectedItem()) =>
    @lastWatchedDirectory = @currentDir
    @collectItems @currentDir.getParent(), true
