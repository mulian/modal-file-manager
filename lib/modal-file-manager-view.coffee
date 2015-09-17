{$,SelectListView} = require 'atom-space-pen-views'

module.exports =
class ModalFileManagerView extends SelectListView
  #constructor: (serializedState) ->

  initialize: (@attr) ->
    super
    #@addClass('overlay from-top')
    @title = $('<div />',{text: 'Title',id:'title'})
    @setItems([{title:'Hello'}, {title:'World'}])
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()
    #console.log @element
    $(@element).prepend @title

  getFilterKey: () ->
    "title"
  viewForItem: (item) ->
    "<li class='check-list-item'>#{item.title}<input type='checkbox'/></li>"

  confirmed: (item) ->
    console.log("#{item.title} was selected")

  cancelled: ->
    console.log("This view was cancelled")

  show: ->
    console.log @getElement()
    if not @isVisible()
      @show()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  setSate: (state) ->
