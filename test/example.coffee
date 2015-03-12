
window = require("./env/Browser").window



describe "VisualOps testcase example", ()->

  # Sync test
  it "should discover `WS` in App", ()->
    if !window.App.WS
      throw new Error("Cannot find WS in App")
    return

  it "should have a user", ()->
    if !window.App.user
      throw new Error("No user found")
    return

  # Async test
  it "should get response from server", ( done )->
    # The `require("./env/Browser")` in line 2 is node.js's require.
    # Use window.require to access require.js.
    window.require ["ApiRequest"], (ApiRequest)->
      ApiRequest("project_list",{}).then ( res )->
        done()
      , ( err )-> done( new Error( err.msg ) )
    return


  return

