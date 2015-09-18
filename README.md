# modal-file-manager package

A file browser in modal Panel.

![A screenshot of your package](https://raw.githubusercontent.com/mulian/modal-file-manager/master/preview.png)

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
 * press enter to start the file (works only on mac right now)
 * type character to search the current folder

## As lib
You could use this File Manager as lib for Packages like
```javascript
  atom.pickDirectory (path) ->
    console.log path
```

### Steps
1. add following to your package.json in dependencies:
```javascript
    "modal-file-manager": "git+https://github.com/mulian/modal-file-manager.git"
```
2. in your Project root: `npm update`
3. Use the ModalFileManagerView:
```javascript
{ModalFileManagerView} = require 'modal-file-manager'
modalFileManager = new ModalFileManager()
modalFileManager.open "/", (file) ->
  console.log "selected file-/folder name: #{file.getBaseName()}"
```
