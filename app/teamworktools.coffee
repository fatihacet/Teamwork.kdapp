class TeamworkTools extends JView
    
  constructor: (options = {}, data) ->
    
    options.cssClass = "teamwork-tools-modal"
    
    super options, data
    
    {modal, panel, workspace, twApp} = @getOptions()
    
    key            = @getOptions().workspace.sessionKey 
    @sessionKey    = new KDInputView
      cssClass     : "teamwork-modal-input session-key"
      defaultValue : key
      attributes   :
        readonly   : "readonly"
      click        : => @sessionKey.getDomElement().select()
    
    @joinInput     = new KDHitEnterInputView
      type         : "text"
      cssClass     : "teamwork-modal-input"
      placeholder  : "Paste new session key and hit enter to join"
      callback     : => workspace.handleJoinASessionFromModal @joinInput.getValue(), modal
      
    @importInput   = new KDHitEnterInputView
      type         : "text"
      cssClass     : "teamwork-modal-input"
      placeholder  : "Paste the link of zip file and hit enter"
      validationNotifications: yes
      validate     :
        rules      :
          required : yes
        messages   :
          required : "You must select a Kite!"
      callback     : =>
        twApp.importContent @importInput.getValue(), modal
    
    @exportButton  = new KDButtonView
      title        : "Export a folder and get a link"
      icon         : yes
      iconClass    : "export"
      callback     : => 
        modal.destroy()
        twApp.showExportDialog()
    
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
            <p>Click and copy this code, give it to your friends. Tell them to enter it in the 'Join' box on the right. They will be coding with you right away.<br><br> Remember, you're giving access to your environment, they can see/steal your sensitive information, use it with caution.</p>
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
          <p>This downloads and prepares an environment. This could be course material, or sample code found on other sites. <br><br> Remember you're downloading somebody else's files, think before you execute them. Just importing them is fairly safe.</p>
          {{> @importInput}}
        </div>
        <div class="teamwork-modal-content">
          <p>You can zip a folder of yours, allow others to work on it. <br><br>This is useful when you want someone to help you on Stackoverflow, you want to showcase your Github repo, you're writing a computer book or giving an online course. <br><br> You can create a link here so your audience gets the files they need to work on and their environment will be ready instantly. You're welcome! :)  </p>
          {{> @exportButton}}
        </div>
      </div>
    """
