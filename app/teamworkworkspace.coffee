class TeamworkWorkspace extends CollaborativeWorkspace

  constructor: (options = {}, data) ->
    
    if appView.sessionKey
      options.sessionKey = appView.sessionKey
    
    super options, data

  createLoader: ->
    @container.addSubView @loader = new KDCustomHTMLView
      cssClass   : "teamwork-loader"
      tagName    : "img"
      attributes :
        src      : "https://koding-cdn.s3.amazonaws.com/teamwork/loading.gif"