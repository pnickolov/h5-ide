
browser = require('./env/Browser')
window = browser.window

$ = window.$
App = window.App
Design = window.Design


describe "Credential Testing", ()->
    console.log '------------------------'
    console.log 'Credential Testing'
    console.log '------------------------'

    getCredential = ->
        App.sceneManager.activeScene().project.credentials().at(0)

    hasApp = ->
        !!App.sceneManager.activeScene().project.get('apps').length

    # Do not run credential test when app exist or credential is demo.
    if getCredential().isDemo() or hasApp()
        return

    # Import Stack
    it "Remove Credential", (done)->
        console.log 'Remove Credential Testing ...'

        credential = getCredential()
        credential.destroy().then ->
            done()
        , ( err ) ->
            throw err

        return

    it "Add Credential", (done) ->
        console.log 'Add Credential Testing ...'

        credential = getCredential()

        credential.set {
          alias         : 'test'
          awsAccount    : 'dev'
          awsAccessKey  : 'AKIAJQGLVV6IPLFSKWCQ'
          awsSecretKey  : '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'
        }

        credential.save().then ->
            done()
        , (err) ->
            throw err

        return






