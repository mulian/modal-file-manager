ModalFileManagerView = require './modal-file-manager-view'
{CompositeDisposable} = require 'atom'

module.exports = ModalFileManager =
  modalFileManagerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @modalFileManagerView = new ModalFileManagerView()
    @modalFileManagerView.setSate state.modalFileManagerViewState
    #@modalPanel = atom.workspace.addModalPanel(item: @modalFileManagerView, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'modal-file-manager:show': => @modalFileManagerView.show()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @modalFileManagerView.destroy()

  serialize: ->
    modalFileManagerViewState: @modalFileManagerView.serialize()
