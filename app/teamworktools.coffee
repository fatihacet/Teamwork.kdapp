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
      title        : "Export your session as a zip file"
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
            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
          </div>
        </div>
        <div class="teamwork-modal-content">
          <div class="join">
            <span class="icon"></span>
            {{> @joinInput}}
            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do.</p>
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
          <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
          {{> @importInput}}
        </div>
        <div class="teamwork-modal-content">
          <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
          {{> @exportButton}}
        </div>
      </div>
    """