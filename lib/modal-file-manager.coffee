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
      description: 'Open your first Project Path'
    defaultOpenPath:
      type: 'string'
      default: 'C:/'
      description: 'When open FileManager if Open First Project Path is false'
    openWith:
      type: 'string'
      enum: ['atom','open']
      default: 'atom'
      description: 'Open selected file with (open works only with mac os)...'
    deep:
      type: 'integer'
      default: 1
      minimum: 0
      maximum: 3
      description: "Collect the (default:) first(1) sub-directorys (0-3)."

  #to get View by using as lib
  ModalFileManagerView: require './modal-file-manager-view'

  modalFileManagerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @modalFileManagerView = new @ModalFileManagerView {}=
      deep: atom.config.get "#{packageName}.deep"
      comfirmFilter:
        dir: atom.config.get "#{packageName}.openDirectory"
      state: state.modalFileManagerViewState
    #@modalPanel = atom.workspace.addModalPanel(item: @modalFileManagerView, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'modal-file-manager:show': => @toggleFileManager()
    @regEvents()

  regEvents: ->
    atom.config.observe "#{packageName}.openDirectory", (newValue) =>
      @modalFileManagerView.setOptions {filterDir: newValue}
    atom.config.observe "#{packageName}.deep", (newValue) =>
      @modalFileManagerView.setOptions {deep:newValue}

  getDir: ->
    if not atom.config.get("#{packageName}.openFirstProjectPath")
      return atom.config.get("#{packageName}.defaultOpenPath")
    else if (atom.project.getPaths()?.length > 0) and atom.config.get("#{packageName}.openFirstProjectPath")
      return atom.project.getPaths()[0]
    else if process.platform == 'win32'
      return "C:/"
    else return "/"

  toggleFileManager: ->
    if @modalFileManagerView.panel.isVisible()
      @modalFileManagerView.panel.hide()
    else
      @modalFileManagerView.open @getDir(), (file) => #current Project dir is?

        if process.platform == "darwin" and atom.config.get("#{packageName}.openWith")=='open' #mac
          @run "open #{file.getRealPathSync()}"
        else
          atom.open #run with atom
            pathsToOpen: [file.getRealPathSync()]

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
    @subscriptions.dispose()
    @modalFileManagerView.destroy()

  serialize: ->
    modalFileManagerViewState: @modalFileManagerView.serialize()
