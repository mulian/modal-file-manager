ModalFileManagerView = require '../lib/modal-file-manager-view'
packageName = require('../package.json').name

describe "ModalFileManagerView", ->
  [workspaceElement, activationPromise,modalFileManagerView,defaultCallback,packagePath] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage(packageName)
    packagePath = atom.packages.loadedPackages[packageName].path
    modalFileManagerView = new ModalFileManagerView()
    modalFileManagerView.open packagePath, jasmine.createSpy('comfirmed hook') #save test dir

  describe "Test deep", -> #TODO
    it "Test Deep with 0 (off)", ->
      expect(true).toBe true
    it "Test Deep with 1", ->
      expect(true).toBe true
    it "Test Deep with 2", ->
      expect(true).toBe true
    it "Test Deep with 3", ->
      expect(true).toBe true

  describe "Test if Settings will be used", -> #TODO
    it "Settings use Deep", ->
      expect(true).toBe true

  #Test Moves on Package Folder
  describe "Check Item Moves", ->
    it "move-top on top on list -> top", -> #already in space-pen
      initItem = modalFileManagerView.getSelectedItemView()
      atom.commands.dispatch modalFileManagerView.element, 'core:move-top'
      currentItem = modalFileManagerView.getSelectedItemView()
      expect(currentItem).toBe currentItem
    it "move down", -> #already in space-pen
      initItem = modalFileManagerView.getSelectedItemView()
      atom.commands.dispatch modalFileManagerView, 'core:move-down'
      currentItem = modalFileManagerView.getSelectedItemView()
      expect(initItem).not.toBe currentItem
    it "check spec folder is selected, if move left from spec", ->
      specDir = modalFileManagerView.currentDir
      modalFileManagerView.emitter.on "did-finished-collect", ->
        setTimeout ->
          selectedItem = modalFileManagerView.getSelectedItem()
          expect(specDir).toBe selectedItem.entrie
        , 100
      modalFileManagerView.leftArrow()

    it "on left move select lib not top (keymaps)", ->
      modalFileManagerView.leftArrow()
      expect(modalFileManagerView.list.find('li:first')).not.toHaveClass 'selected'
