class TeamworkTools extends JView
    
  constructor: (options = {}, data) ->
    
    options.cssClass = "teamwork-tools-modal"
    
    super options, data
    
    {modal, panel, workspace, twApp} = @getOptions()
    
    key              = @getOptions().workspace.sessionKey 
    @sessionKey      = new KDInputView
      cssClass       : "teamwork-modal-input session-key"
      defaultValue   : key
      attributes     :
        readonly     : "readonly"
      click          : => @sessionKey.getDomElement().select()
    
    @joinInput       = new KDHitEnterInputView
      type           : "text"
      cssClass       : "teamwork-modal-input"
      placeholder    : "Paste new session key and hit enter to join"
      validationNotifications: yes
      validate       :
        rules        :
          required   : yes
        messages     :
          required   : "Please check the field."
      callback       : => workspace.handleJoinASessionFromModal @joinInput.getValue(), modal
      
    @importInput     = new KDHitEnterInputView
      type           : "text"
      cssClass       : "teamwork-modal-input"
      placeholder    : "Paste the link of zip file and hit enter"
      validationNotifications: yes
      validate       :
        rules        :
          required   : yes
        messages     :
          required   : "Please check the field."
      callback       : =>
        twApp.importContent @importInput.getValue(), modal
    
    @exportButton    = new KDButtonView
      title          : "Click here to select a folder to export"
      icon           : yes
      iconClass      : "export"
      callback       : => @showFinder()
    
    @exportView      = new KDView
      cssClass       : "export-file-tree"
      
    @exportStartButton = new KDButtonView
      title          : "Select a folder and click here to export..."
      cssClass       : "clean-gray hidden exporter"
      callback       : =>
        return if @exporting
        
        [node]       = @finderController.treeController.selectedNodes
        unless node
          return new KD.NotificationView
            title    : "Please select a folder to save!"
            type     : "mini"
            cssClass : "error"
            duration : 4000
        
        vmController = KD.getSingleton "vmController" 
        nodeData     = node.getData()
        fileName     = "#{nodeData.name}.zip"
        path         = FSHelper.plainPath nodeData.path
        notification = new KDNotificationView
          title      : "Exporting file..."
          type       : "mini"
          duration   : 30000
          container  : @finderContainer
        
        vmController.run "cd #{path}/.. ; zip -r #{fileName} #{nodeData.name}", (err, res) =>
          @exporting = yes
          return @updateNotification notification  if err
          
          file = FSHelper.createFileFromPath "#{nodeData.parentPath}/#{fileName}"
          file.fetchContents (err, contents) =>
            return @updateNotification notification  if err
            FSHelper.s3.upload fileName, btoa(contents), (err, res) =>
              return @updateNotification notification  if err
              vmController.run "rm -f #{path}.zip", (err, res) =>
              KD.utils.shortenUrl res, (shorten) =>
                @exporting = no
                notification.notificationSetTitle "Your content has been exported."
                notification.notificationSetTimer 4000
                notification.setClass "success"
                @getOptions().modal.destroy()
                modal          = new KDBlockingModalView
                  title        : "Export done"
                  cssClass     : "modal-with-text"
                  overlay      : yes
                  content      : """
                    <p>Your content has been uploaded and it's ready to share.</p>
                    <p><strong>#{location.origin}/Develop/Teamwork?import=#{shorten}</strong></p>
                  """
                  buttons      :
                    Done       :
                      title    : "Done"
                      cssClass : "modal-clean-gray"
                      callback : -> modal.destroy()
          , no
      
  showFinder: ->
    if @exportView.getSubViews().length is 0
      @finderContainer    = new KDView
      @finderController   = new NFinderController
        nodeIdPath        : "path"
        nodeParentIdPath  : "parentPath"
        foldersOnly       : yes
        contextMenu       : no
        loadFilesOnInit   : yes
  
      @finder = @finderController.getView()
      @finderController.reset()
      @finder.setHeight 320
      @finderContainer.addSubView @finder
      @finderContainer.addSubView @exportStartButton
      @exportView.addSubView @finderContainer

    @exportView.setClass "active"
    @exportButton.hide()
    @exportStartButton.show()
    KD.getSingleton("windowController").addLayer @finderContainer
    @finderContainer.on "ReceivedClickElsewhere", =>
      @exportStartButton.hide()
      @exportButton.show()
      @exportView.unsetClass "active"
    
  updateNotification: (notification) ->
    notification.notificationSetTitle "Something went wrong"
    notification.notificationSetTimer 4000
    notification.setClass "error"
    @exporting = no
    
  pistachio: ->
    """
      <div class="teamwork-modal-header">
        <div class="header invite">
          <span class="icon"></span>
          <span class="text">Invite</span>
        </div>
        <div class="header join">
          <span class="icon"></span>
          <span class="text">Join</span>
        </div>
      </div>
      <div class="teamwork-modal-contents">
        <div class="teamwork-modal-content">
          <div class="invite">
            <span class="icon"></span>
            {{> @sessionKey}}
            <p>Click and copy this code, give it to your friends. Tell them to enter it in the 'Join' box on the right. They will be coding with you right away.</p>
          </div>
        </div>
        <div class="teamwork-modal-content">
          <div class="join">
            <span class="icon"></span>
            {{> @joinInput}}
            <p>If you have received a code from a friend of you, copy and paste it here, hit enter. You will be coding together on your friend's environment.</p>
          </div>
        </div>
      </div>
      <div class="teamwork-modal-header">
        <div class="header full-width">
          <span class="icon"></span>
          <span class="text">Import & Export</span>
        </div>
      </div>
      <div class="teamwork-modal-content full-width">
        <div class="teamwork-modal-content">
          <p>This downloads and prepares an environment. This could be course material, or sample code found on other sites. 
				<br><br> Remember you're downloading somebody else's files, think before you execute them. 
				Just importing them is fairly safe.</p>
          {{> @importInput}}
        </div>
        <div class="teamwork-modal-content">
          <p>You can zip a folder of yours, allow others to work on it. <br><br>This is useful when you want someone to help you on Stackoverflow, you want to showcase your Github repo, you're writing a computer book or giving an online course.</p>
          {{> @exportView}}
          {{> @exportButton}}
        </div>
      </div>
    """
