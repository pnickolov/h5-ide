#############################
#  validation
#############################

define [ 'constant', 'event', 'component/trustedadvisor/lib/TA.Config', 'component/trustedadvisor/lib/TA.Bundle', 'component/trustedadvisor/lib/TA.Core', 'jquery', 'underscore', "MC" ], ( constant, ide_event, config, TaBundle, TaCore ) ->


    ########## Functional Method ##########

    _init = () ->
        TaCore.reset()

    _isGlobal = ( filename, method ) ->
        config.get( 'globalList' )[ filename ] and _.contains config.get( 'globalList' )[ filename ], method

    _isAsync = ( filename, method ) ->
        config.get( 'asyncList' )[ filename ] and _.contains config.get( 'asyncList' )[ filename ], method

    _getFilename = ( componentType ) ->
        if config.get( 'componentTypeToFileMap' )[ componentType ]
            return config.get( 'componentTypeToFileMap' )[ componentType ]

        filename = _.last componentType.split '.'
        filename = filename.toLowerCase()
        [ filename ]

    _pushResult = ( result, method, filename, uid ) ->
        TaCore.set "#{filename}.#{method}", result, uid

    _syncStart = -> ide_event.trigger ide_event.TA_SYNC_START
    _syncFinish = -> ide_event.trigger ide_event.TA_SYNC_FINISH
    _genSyncFinish = ( times ) -> _.after times, () -> _syncFinish()

    _asyncCallback = ( method, filename, done ) ->
        hasRun = false
        _.delay () ->
            if not hasRun
                hasRun = true
                _pushResult null, method, filename
                done()
                console.error 'Async TA Timeout'
        , config.syncTimeout

        ( result ) ->
            if not hasRun
                hasRun = true
                _pushResult result, method, filename
                done()

    _handleException = ( err ) ->
        console.log 'TA Exception: ', err

    ########## Sub Validation Method ##########

    _validGlobal = ( env ) ->
        _.each config.get( 'globalList' ), ( methods, filename ) ->
            _.each methods, ( method ) ->
                try
                    if method.indexOf( '~' ) is 0
                        if env is 'all'
                            method = method.slice( 1 )
                        else
                            return
                    result = TaBundle[ filename ][ method ]()
                    _pushResult result, method, filename
                catch err
                    _handleException( err )
        null

    _validComponents = () ->
        components = MC.canvas_data.component
        _.each components, ( component , uid ) ->
            filenames = _getFilename component.type
            _.each filenames, ( filename ) ->
                _.each TaBundle[ filename ], ( func, method ) ->
                    if not _isGlobal(filename, method) and not _isAsync(filename, method)
                        try
                            result = TaBundle[ filename ][ method ]( uid )
                            _pushResult result, method, filename, uid
                        catch err
                            _handleException( err )

            # validate state editor
            try
                _validState TaBundle, uid
            catch err
                _handleException( err )
        null

    _validState = ( TaBundle, uid ) ->
        if Design.instance().get('agent').enabled is true
            result = TaBundle.stateEditor( uid )
            _pushResult result, 'stateEditor', 'stateEditor', uid

        null

    _validAsync = ->
        asyncList = config.get( 'asyncList' )

        if not asyncList or not asyncList.length
            _syncFinish()
            return

        finishTimes = _.reduce asyncList, ( memo, arr ) ->
            return memo + arr.length
        ,0

        _syncStart()
        syncFinish = _genSyncFinish( finishTimes )

        _.each asyncList, ( methods, filename ) ->
            _.each methods, ( method ) ->
                try
                    result = TaBundle[ filename ][ method ]( _asyncCallback(method, filename, syncFinish) )
                    _pushResult result, method, filename
                catch err
                    _handleException( err )
        null


    ########## Public Method ##########

    validComp = ( type ) ->

        try

            MC.ta.resultVO = TaCore

            temp     = type.split '.'
            filename = temp[ 0 ]
            method   = temp[ 1 ]
            func     = TaBundle[ filename ][ method ]

            if _.isFunction func

                args = Array.prototype.slice.call arguments, 1
                result = func.apply TaBundle[ filename ], args

                TaCore.set type, result
                return result
            else
                console.log 'func not found'

        catch err
            _handleException( err )
        null

    validRun = ->

        _init()

        _validComponents()

        _validGlobal 'run'

        _validAsync()

        TaCore.result()


    validAll = ->

        _init()

        _validComponents()

        _validGlobal 'all'

        TaCore.result()


    MC.ta =
        validComp   : validComp
        validAll    : validAll
        validRun    : validRun
        stateEditor : TaBundle.stateEditor
        list        : []
        state_list  : {}

    MC.ta
