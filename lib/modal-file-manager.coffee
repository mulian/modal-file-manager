#ModalFileManagerView =
{CompositeDisposable} = require 'atom'
{BufferedProcess} = require 'atom'
packageName = require('../package.json').name

module.exports = ModalFileManager =
  config:
    openDirectory:
      type: 'boolean'
      default: false
      description: 'Also open Directory'
    openFirstProjectPath:
      type: 'boolean'
      default: true
      description: 'Open your first opened Project Path'
    defaultOpenPath:
      type: 'string'
      default: 'C:/'
      description: 'When open FileManager if Open First Project Path is false'
    openWith:
      type: 'string'
      enum: ['atom','open']
      default: 'atom'
      description: 'Open selected file with (open works only with mac os)...'

  #to get View by using as lib
  ModalFileManagerView: require './modal-file-manager-view'

  modalFileManagerView: null
  modalPanel: null
  subscriptions: null
  isAlreadyOpen: false

  activate: (state) ->
    @modalFileManagerView = new @ModalFileManagerView()
    @modalFileManagerView.setSate state.modalFileManagerViewState
    #@modalPanel = atom.workspace.addModalPanel(item: @modalFileManagerView, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'modal-file-manager:show': => @runFileManager()

  runFileManager: ->
    if not @isAlreadyOpen
      #@modalFileManagerView.comfirmFilter.dir = /.app$/
      dir = atom.project.getPaths()[0]
      console.log "BLAAA" if !(typeof(dir) == 'string')
      if not atom.config.get("#{packageName}.openFirstProjectPath") or not (typeof(dir) == 'string') or (dir.length==0)
        dir = atom.config.get("#{packageName}.defaultOpenPath")
      @modalFileManagerView.comfirmFilter.dir = atom.config.get("#{packageName}.openDirectory")
      @modalFileManagerView.open dir, (file) => #current Project dir is?
        #console.log "path: #{file.getBaseName()}"
        if process.platform == "darwin" and atom.config.get("#{packageName}.openWith")=='open' #mac
          @run "open #{file.getRealPathSync()}"
        else
          #run with atom
          atom.open
            pathsToOpen: [file.getRealPathSync()]
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
