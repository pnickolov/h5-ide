#############################
#  validation
#############################

define [ 'constant', 'event', './validation/main', './validation/result_vo',
         'jquery', 'underscore'
], ( constant, ide_event, validation_main, resultVO ) ->

    # private

    # debug validation method, if exist anyother method will not be called
    _validDebug = ''


    _componentTypeToFileMap =
        'AWS.AutoScaling.Group'     : 'asg'
        'AWS.EC2.SecurityGroup'     : 'sg'
        'AWS.VPC.VPNGateway'        : 'vpn'
        'AWS.VPC.VPNGateway'        : 'vpn'
        'AWS.VPC.InternetGateway'   : 'igw'

    _globalList =
        eip: [ 'isHasIGW' ]
        az: [ 'isAZAlone' ]



    ########## functional method and field ##########

    _state = {}

    _global = ( type ) ->
        state = _state[ "global_#{type}" ]
        if not state
            state = true
            return true
        false

    _init = () ->
        resultVO.reset()
        _state = {}


    _isGlobal = ( filename, method ) ->
        _globalList[ filename ] and _.contains _globalList[ filename ], method


    _isNeeded = ( obj, key, params ) ->
        not obj[ key ] or obj[ key ]( params )

    _getFilename = ( componentType ) ->
        if _componentTypeToFileMap[ componentType ]
            return _componentTypeToFileMap[ componentType ]

        filename = _.last componentType.split '.'
        filename = filename.toLowerCase()
        filename

    _pushResult = ( result, method, uid ) ->
        if result
            resultVO.add method, result.level, result.info, uid
        null

    ########## will be public ##########

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

                if !result
                    resultVO.del type
                    true
                else
                    resultVO.add type, result.level, result.info, result.uid
                    false
                return result
            else
                console.log 'func not found'

        catch error
            console.log "validComp error #{ error }"

    validAll = ->

        components = MC.canvas_data.component

        _init()

        _.each components, ( component , uid ) ->
            filename = _getFilename component.type
            _.each validation_main[ filename ], ( func, method ) ->
                if not _isGlobal filename, method
                    result = validation_main[ filename ][ method ]( uid )
                    _pushResult result, method

        _.each _globalList, ( methods, filename ) ->
            _.each methods, ( method ) ->
                result = validation_main[ filename ][ method ]()
                _pushResult result, method

        resultVO.result()


    #public
    validComp : validComp
    validAll  : validAll

