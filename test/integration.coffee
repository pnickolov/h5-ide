
browser = require('./env/Browser')
window = browser.window

$ = window.$
App = window.App
Design = window.Design

stackJsons = require('./stack/requireStacks')
#stackJsons = [ require('./stack/an-instance') ]

describe "VisualOps Integration Testing", ()->
    stackModel = null
    appModel = null
    opsModelState = null

    watchAppProcess = ( ops, callback ) ->
        callTimes = 0

        insideCallback = () ->
            if callTimes is 0
                callTimes++
                callback.apply null, arguments

        ops.on 'change:progress', () ->
            console.log "Progress: %#{ops.get('progress')}"

        ops.on 'change:state', () ->
            state = ops.get 'state'

            if state is opsModelState.RollingBack
                throw 'Operation faild and Rolling back'
                return

            insideCallback state

        ops.on 'destroy', () ->
            insideCallback state

    unwatchAppProcess = ( ops ) ->
        ops.off 'change:progress'
        ops.off 'change:state'
        ops.off 'destroy'



    console.log '------------------------'
    console.log 'Integration Testing for Stacks'
    console.log '------------------------'

    for stackJson in stackJsons

        # Import Stack
        it "Import and Save Stack", (done)->
            console.log 'Import and Save Stack Testing ...'

            stackModel = App.sceneManager.activeScene().project.createStackByJson( stackJson )
            opsModelState = stackModel.constructor.State

            App.loadUrl( stackModel.url() )

            stackModel.on 'change:state', () ->

                if stackModel.id
                    done()
                else
                    throw new Error('Import Stack Failed')

            return

        it "Run Stack", (done) ->
            console.log 'Run Stack Testing'

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
            console.log 'Stop App Testing'

            watchAppProcess appModel, ( state ) ->
                if state is opsModelState.Stopped
                    unwatchAppProcess appModel
                    done()

            appModel.stop().fail () ->
                throw new Error(err)


        it "Start App", (done) ->
            console.log 'Start App Testing'

            watchAppProcess appModel, ( state ) ->
                if state is opsModelState.Running
                    unwatchAppProcess appModel
                    done()

            appModel.start().fail () ->
                throw new Error(err)


        it "Terminate App", (done) ->
            console.log 'Terminate App Testing'

            watchAppProcess appModel, ( state ) ->
                if state is opsModelState.Terminating
                    unwatchAppProcess appModel
                    done()

            appModel.terminate().fail () ->
                throw new Error(err)

        it "Delete Stack", (done) ->
            console.log 'Delete Stack Testing'

            stackModel.remove().then ->
                done()
            , ( err ) ->
                throw new Error err







