ModalFileManagerView = require './modal-file-manager-view'
{CompositeDisposable} = require 'atom'

module.exports = ModalFileManager =
  modalFileManagerView: null
  modalPanel: null
  subscriptions: null
  isAlreadyOpen: false

  activate: (state) ->
    @modalFileManagerView = new ModalFileManagerView()
    @modalFileManagerView.setSate state.modalFileManagerViewState
    #@modalPanel = atom.workspace.addModalPanel(item: @modalFileManagerView, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'modal-file-manager:show': => @runFileManager()

  runFileManager: ->
    if not @isAlreadyOpen
      @modalFileManagerView.open atom.project.getPaths()[0], (file) => #current Project dir is?
        console.log "path: #{file.getBaseName()}"
        @isAlreadyOpen=false
      @isAlreadyOpen=true
    else @modalFileManagerView.reOpen()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @modalFileManagerView.destroy()

  serialize: ->
    modalFileManagerViewState: @modalFileManagerView.serialize()
