{CompositeDisposable} = require 'atom'
ModalFileManagerView = require './modal-file-manager-view'

module.exports = ModalFileManager =
  config:
    deep:
      type: 'integer'
      default: 0
      minimum: 0
      maximum: 3
      description: "Collect the (default:) first(1) sub-directorys (0-3)."
    showHidden:
      type: 'boolean'
      default: false
      descroption: 'show hidden files/folders (unix .-prefix)'

  activate: (state) ->
    @modalFileManagerView = new ModalFileManagerView

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'modal-file-manager:toggle': =>
      @modalFileManagerView.toggle()

  regEvents: ->
    atom.config.observe "modal-file-manager.deep", (newValue) =>
      @modalFileManagerView.setOptions {deep:newValue}
    atom.config.observe "modal-file-manager.showHidden", (newValue) =>
      @modalFileManagerView.setOptions {showHidden:newValue}

  deactivate: ->
    @subscriptions.dispose()
    @modalFileManagerView.destroy()

  serialize: ->
    modalFileManagerViewState: @modalFileManagerView.serialize()
