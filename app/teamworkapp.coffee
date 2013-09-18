class TeamworkApp extends KDObject

  constructor: (options = {}, data) ->
    
    super options, data
    
    @teamwork             = new TeamworkWorkspace
      name                : "Teamwork"
      version             : "0.1"
      joinModalTitle      : "Join a coding session"
      joinModalContent    : "<p>Paste the session key that you received and start coding together.</p>"
      shareSessionKeyInfo : "<p>This is your session key, you can share this key with your friends to work together.</p>"
      firebaseInstance    : "teamwork-local"
      enableChat          : yes
      panels              : [
        title             : "Teamwork"
        hint              : "<p>This is a collaborative coding environment where you can team up with others and work on the same code.</p>"
        buttons           : [
          {
            title         : "Tools"
            cssClass      : "clean-gray"
            callback      : (panel, workspace) => @showToolsModal panel, workspace
          }
        ]
        layout            : 
          direction       : "vertical"
          sizes           : [ "25%", null ]
          views           : [
            {
              type        : "finder"
              name        : "finder"
            }
            {
              type        : "split"
              options     :
                direction : "horizontal"
                sizes     : [ "50%", null ]
              views       : [
                {
                  type    : "tabbedEditor"
                  name    : "editor"
                }
                {
                  type    : "terminal"
                  name    : "terminal"
                }
              ]
            }
          ]
      ]

  showToolsModal: (panel, workspace) ->
    modal       = new KDModalView
      cssClass  : "teamwork-tools-modal"
      title     : "Teamwork Tools"
      overlay   : yes
      width     : 600
    
    modal.addSubView new TeamworkTools { modal, panel, workspace, twApp: this }
      
  showImportWarning: (url) ->
    modal           = new KDModalView
      title         : "Import File"
      cssClass      : "modal-with-text"
      overlay       : yes
      content       : """
        <p>This Teamwork URL wants to download a file to your VM from <strong>#{url}</strong></p>
        <p>Would you like to import and start working with these files?</p>
      """
      buttons       : 
        Import      : 
          title     : "Import"
          cssClass  : "modal-clean-green"
          callback  : => @importContent url, modal
        DontImport  :
          title     : "Don't import anything"
          cssClass  : "modal-cancel"
          callback  : -> modal.destroy()
    
  importContent: (url, modal) ->
    fileName     = "file#{Date.now()}.zip"
    root         = "Web/Teamwork"
    path         = "#{root}/tmp"
    vmController = KD.getSingleton "vmController"
    vmName       = vmController.defaultVmName
    notification = new KDNotificationView
      type       : "mini"
      title      : "Fetching zip file..."
      duration   : 200000
  
    vmController.run "mkdir -p #{path}; cd #{path} ; wget -O #{fileName} #{url}", (err, res) =>
      return warn err if err
      notification.notificationSetTitle "Extracting zip file..."
      vmController.run "cd #{path} ; unzip #{fileName} ; rm #{fileName} ; rm -rf __MACOSX", (err, res) =>
        return warn err if err
        notification.notificationSetTitle "Checking folders..."
        FSHelper.glob "#{path}/*", vmName, (err, folders) =>
          #TODO: fatihacet - multiple folders
          folderName = FSHelper.getFileNameFromPath folders[0]
          FSHelper.exists "#{root}/#{folderName}", vmName, (err, res) =>
            if res is yes
              modal.destroy()
              modal          = new KDModalView
                title        : "Folder Exist"
                cssClass     : "modal-with-text"
                overlay      : yes
                content      : "<p>This folder is alrady exist. Do you want to overwrite it?</p>"
                buttons      :
                  Confirm    :
                    title    : "Overwrite"
                    cssClass : "modal-clean-red"
                    callback : =>
                      @handleZipImportDone_ vmController, root, folderName, path, modal, notification, url
                  Cancel     :
                    title    : "Cancel"
                    cssClass : "modal-cancel"
                    callback : =>
                      modal.destroy()
                      vmController.run "rm -rf #{path}"
                      notification.destroy()
                      @setVMRoot "#{root}/#{folderName}"
            else
              @handleZipImportDone_ vmController, root, folderName, path, modal, notification, url
              
  handleZipImportDone_: (vmController, root, folderName, path, modal, notification, url) ->
    vmController.run "rm -rf #{root}/#{folderName} ; mv #{path}/#{folderName} #{root}", (err, res) =>
      return warn err if err
      modal.destroy()
      vmController.run "rm -rf #{path}"
      notification.destroy()
      @setVMRoot "#{root}/#{folderName}"
  
  setVMRoot: (path) ->
    vmController       = KD.getSingleton "vmController"
    {finderController} = @teamwork.getActivePanel().getPaneByName "finder"
    finderController.updateVMRoot vmController.defaultVmName, path
