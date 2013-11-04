#############################
#  validation
#############################

define [ 'constant', 'event', 'ta_conf', './validation/main', './validation/result_vo',
         'jquery', 'underscore'
], ( constant, ide_event, config, validation_main, resultVO ) ->

    ########## Functional Method ##########

    _init = () ->
        resultVO.reset()

    _isGlobal = ( filename, method ) ->
        config.globalList[ filename ] and _.contains config.globalList[ filename ], method

    _isAsync = ( filename, method ) ->
        config.asyncList[ filename ] and _.contains config.asyncList[ filename ], method

    _getFilename = ( componentType ) ->
        if config.componentTypeToFileMap[ componentType ]
            return config.componentTypeToFileMap[ componentType ]

        filename = _.last componentType.split '.'
        filename = filename.toLowerCase()
        filename

    _pushResult = ( result, method, filename, uid) ->
        resultVO.set "#{filename}.#{method}", result, uid

    _asyncCallback = ( method, filename ) ->
        ( result ) ->
            _pushResult result, method, filename


    ########## Sub Validation Method ##########

    _validGlobal = () ->
        _.each config.
        globalList, ( methods, filename ) ->
            _.each methods, ( method ) ->
                result = validation_main[ filename ][ method ]()
                _pushResult result, method, filename

    _validComponents = () ->
        components = MC.canvas_data.component
        _.each components, ( component , uid ) ->
            filename = _getFilename component.type
            _.each validation_main[ filename ], ( func, method ) ->
                if not _isGlobal filename, method and not _isAsync filename, method
                    result = validation_main[ filename ][ method ]( uid )
                    _pushResult result, method, filename, uid

    _validAsync = ->
        _.each config.asyncList, ( methods, filename ) ->
            _.each methods, ( method ) ->
                result = validation_main[ filename ][ method ]( _asyncCallback(method, filename) )
                _pushResult result, method, filename

    ########## Public Method ##########

    validComp = ( type ) ->

        try

            MC.ta.resultVO = resultVO

            temp     = type.split '.'
            filename = temp[ 0 ]
            method   = temp[ 1 ]
            func     = validation_main[ filename ][ method ]

            if _.isFunction func

                args = Array.prototype.slice.call arguments, 1
                result = func.apply validation_main[ filename ], args

                resultVO.set type, result
                return result
            else
                console.log 'func not found'

        catch error
            console.log "validComp error #{ error }"



    validRun = ->

        _init()

        _validAsync()

        validAll()

        resultVO.result()


    validAll = ->

        _init()

        _validComponents()

        _validGlobal()

        resultVO.result()


    #public
    validComp : validComp
    validAll  : validAll
    validRun  : validRun

