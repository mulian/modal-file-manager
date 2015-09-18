ModalFileManagerView = require './modal-file-manager-view'
{CompositeDisposable} = require 'atom'
{BufferedProcess} = require 'atom'

module.exports = ModalFileManager =
  ModalFileManagerView: ModalFileManagerView
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
        if process.platform == "darwin" #mac
          @run "open #{file.getRealPathSync()}"
        else
          atom.notifications.addInfo "There is no right open definition for your OS."
        @isAlreadyOpen=false
      @isAlreadyOpen=true
    else if @isAlreadyOpen and @modalFileManagerView.panel.isVisible()
      @modalFileManagerView.panel.hide()
    else @modalFileManagerView.reOpen()


  strToCmd: (str) ->
    res = str.split " "
    return {} =
      command: res.shift(),
      args: res
  run: (cmdStr,cb) ->
    if cmdStr?
      cmd = @strToCmd cmdStr
      command = cmd.command
      args = cmd.args
      stdout = (output) ->
        #if output.indexOf(str) > -1
      exit = (code) =>

      process = new BufferedProcess({command, args, stdout, exit})
    else
      atom.notifications.addInfo "daemon-run/-stop values not set"

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @modalFileManagerView.destroy()

  serialize: ->
    modalFileManagerViewState: @modalFileManagerView.serialize()
