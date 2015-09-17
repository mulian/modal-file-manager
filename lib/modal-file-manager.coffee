ModalFileManagerView = require './modal-file-manager-view'
{CompositeDisposable} = require 'atom'

module.exports = ModalFileManager =
  modalFileManagerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @modalFileManagerView = new ModalFileManagerView(state.modalFileManagerViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @modalFileManagerView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'modal-file-manager:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @modalFileManagerView.destroy()

  serialize: ->
    modalFileManagerViewState: @modalFileManagerView.serialize()

  toggle: ->
    console.log 'ModalFileManager was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
