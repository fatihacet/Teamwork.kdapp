appView.sessionKey = null
appView.hasQuery   = null

appView.on "QueryPassedFromRouter", (query) ->
  appView.hasQuery = yes
  
  if query.import
    teamworkApp    = new TeamworkApp
    {teamwork}     = teamworkApp
    appView.addSubView teamwork
    teamwork.on "WorkspaceSyncedWithRemote", =>
      teamworkApp.showImportWarning query.import
  else
    appView.sessionKey = query.sessionKey
    teamworkApp        = new TeamworkApp
    appView.addSubView teamworkApp.teamwork
  
appView.emit "ready"

if not appView.hasQuery
  teamworkApp = new TeamworkApp
  appView.addSubView teamworkApp.teamwork
