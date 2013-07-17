class Teamwork extends CollaborativeWorkspace

  createLoader: ->
    @container.addSubView @loader = new KDCustomHTMLView
      cssClass   : "teamwork-loader"
      tagName    : "img"
      attributes :
        src      : "https://koding-cdn.s3.amazonaws.com/teamwork/loading.gif"
        
teamwork = new Teamwork
  name                : "Teamwork"
  version             : "0.1"
  joinModalTitle      : "Join a coding session"
  joinModalContent    : "<p>Paste the session key that you received and start coding together.</p>"
  shareSessionKeyInfo : "<p>This is your session key, you can share this key with your friends to work together.</p>"
  # firebaseInstances   : ["kd-prod-1", "kd-prod-2", "kd-prod-3", "kd-prod-4", "kd-prod-5"]
  firebaseInstances   : "kd-prod-1"
  panels: [
    title: "Teamwork"
    hint: "<p>This is a collaborative coding environment where you can team up with others and work on the same code.</p>"
    buttons: [
      title: "Join"
      cssClass: "cupid-green join-button"
      callback: (panel, workspace) ->
        workspace.showJoinModal()
    ]
    panes: [
      { type: "finder"       }, 
      { type: "tabbedEditor" },
      { type: "terminal"     }
    ]
  ]

teamwork.on "PanelCreated", ->
  teamwork.activePanel.splitView.resizePanel "20%", 0

appView.addSubView teamwork