# modal-file-manager package

A file browser in modal Panel.

![A screenshot of modal file manager v0.1.0](https://raw.githubusercontent.com/mulian/modal-file-manager/master/preview.png)

## Install & Open
1. Install
  * Atom: Preferences -> install -> search "modal file manager" -> install
  * Terminal: `apm install modal-file-manager`
2. Open
  * Type: [⌘+⇧+M]
  * Menu Bar: Packages -> Modal File Manager -> Show

## Navigate
 * arrow key ← to show parent directory
 * arrow key → to show sub directory from selected directory
 * type character to search the current folder
 * comfirm = press enter

## Settings
* Open First Project Path
  * If this is checked, your first Project Path will open on Open Modal File Manager
* Default Open Path
  * This works if Open First Project Path is unselected or are not in any project
  * Choose your own static default path
* Open With
  * atom: will open every comfirmed (enter) file/folder with atom
  * open: will open with terminal statement `open <pathToFileOrDir>`
* Open Directory
  * if you also want to comfirm Directory
* Deep
  * Collect the (default:) first(1) sub-directorys in modal Panel.
  * Turn it of with value 0

## Use the Modal File Manager as lib
You could use this File Manager as lib for Packages like
```coffeescript
  atom.pickDirectory (path) ->
    console.log path
```

### Use Steps
1. add following to your package.json in dependencies:
```coffeescript
    "modal-file-manager": "git+https://github.com/mulian/modal-file-manager.git"
```
2. in your Project root: `npm update`
3. Use the ModalFileManagerView:
```coffeescript
{ModalFileManagerView} = require 'modal-file-manager'
modalFileManagerView = new ModalFileManagerView
  deep: 0 #see Settings
  filterDir : false
  filterFile : true
  showHidden : false

#change options:
modalFileManagerView.setOptions
  deep: 1

modalFileManagerView.open "/", (file) ->
  console.log "selected file-/folder name: #{file.getBaseName()}"
```

#### Comfirmation Filter example
```coffeescript
@modalFileManagerView.setOptions
  filterDir = false
  filterFile = true
```

#### Regular Expression
for example:
```coffeescript
@modalFileManagerView.setOptions
  filterDir = /.app$/
```
Restrict the comfirmation to comfirm only Folder with Foldername.app (usefull for mac os apps)
(same with .file) 

#### Other
Please let me know, if you use this Project as lib.
