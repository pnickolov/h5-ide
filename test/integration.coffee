
browser = require('./env/Browser')
window = browser.window

$ = window.$
App = window.App
Design = window.Design

stackjson = require('./stack/az-subnet-stack.json')

describe "VisualOps Integration Test", ()->
    stackModel = null
    appModel = null
    opsModelState = null

    watchAppProcess = ( ops, callback ) ->
        ops.on 'change:progress', () ->
            console.log "Running Process: %#{ops.get('progress')}"

        ops.on 'change:state', () ->
            state = ops.get 'state'

            console.log 'watch:', state
            if state is opsModelState.RollingBack
                throw 'Operation faild and Rrlling back'
                return

            callback state

        ops.on 'destroy', () ->
            callback ops.get 'state'

    unwatchAppProcess = ( ops ) ->
        console.log 'unwatch'
        ops.off 'change:progress'
        ops.off 'change:state'
        ops.off 'destroy'



      # Import Stack
    it "Import and Save Stack", (done)->
        console.log 'Import and Save Stack Test Start...'

        stackModel = App.sceneManager.activeScene().project.createStackByJson( stackjson )
        opsModelState = stackModel.constructor.State

        App.loadUrl( stackModel.url() )

        stackModel.on 'change:state', () ->
            console.log 'State Changed'

            if stackModel.id
                done()
            else
                throw new Error('Import Stack Failed')

        return

    it "Run Stack", (done) ->
        console.log 'Run Stack Test Start...'

        json = stackModel.getJsonData()
        json.usage = 'testing'
        json.name = stackModel.get 'name'


        stackModel.run(json, json.name).then ( ops ) ->
            appModel = ops
            App.loadUrl ops.url()
            watchAppProcess ops, ( state ) ->
                if state is opsModelState.Running
                    unwatchAppProcess ops
                    done()

        , (err)->
            throw new Error(err)

    it "Stop App", (done) ->
        console.log 'Stop App Test Start...'

        watchAppProcess appModel, ( state ) ->
            console.log 'Stop Log': state
            if state is opsModelState.Stopped
                unwatchAppProcess appModel
                done()

        appModel.stop().fail () ->
            throw new Error(err)


    it "Start App", (done) ->
        console.log 'Start App Test Start...'

        watchAppProcess appModel, ( state ) ->
            console.log 'Start Log: State ', state
            if state is opsModelState.Running
                unwatchAppProcess appModel
                done()

        appModel.start().fail () ->
            throw new Error(err)


    it "Terminate App", (done) ->
        console.log 'Terminate App Test Start...'

        watchAppProcess appModel, ( state ) ->
            if state is opsModelState.Destroyed
                unwatchAppProcess appModel
                done()

        appModel.terminate().fail () ->
            throw new Error(err)

    it "Delete Stack", (done) ->
        console.log 'Terminate App Test Start...'

        stackModel.remove().then ->
            done()
        , ( err ) ->
            throw new Error err







