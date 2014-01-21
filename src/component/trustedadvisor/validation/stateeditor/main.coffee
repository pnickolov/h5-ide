define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

    ########## Functional Method ##########
    #errors = []

    _componentTipMap =
        'AWS.EC2.Instance': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_INSTANCE
        'AWS.AutoScaling.Group': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_ASG

    _getCompTip = ( compType, str1, str2, str100 ) ->
        tip = _componentTipMap[ arguments[ 0 ] ]

        arguments[ 0 ] = tip

        sprintf.apply @, arguments


    _buildTAErr = ( tip, uid, refUid ) ->

        level   : constant.TA.ERROR
        info    : tip
        uid     : "#{uid}:#{refUid}"

    # return  Array
    _findReference = ( str ) ->
        reg = constant.REGEXP.stateEditorReference
        ret = []

        while ( resArr = reg.exec str ) isnt null
            ret.push { uid: resArr[ 1 ], ref: resArr[ 0 ] }

        ret


    # Main Check
    _checkState = ( state, data ) ->
        errs = []

        errs = errs.concat checkComponentExist( state, data )

        errs

    ########## Public Method ##########

    # Sub Check
    checkComponentExist = ( obj, data ) ->
        errs = []

        if _.isString obj
            if obj.length is 0
                return errs

            refs = _findReference obj

            for ref in refs
                component = MC.canvas_data.component[ ref.uid ]
                if not component
                    if data
                        tip = _getCompTip data.type, data.name, data.stateId, ref.ref
                        TAError = _buildTAErr tip, data.uid, ref.uid

                        errs.push TAError
                    else
                        errs.push 'error'

        else
            for key, value of obj
                errs = errs.concat checkComponentExist value, data

        errs

    isStateValid = ( uid ) ->
        component = MC.canvas_data.component[ uid ]

        states = component.state

        data =
            uid     : uid
            type    : component.type
            name    : component.name
            stateId : null

        errs = []

        _.each states, ( state, id ) ->

            errs = errs.concat _checkState state, _.extend {}, data, { stateId: id }

        if not errs.length
            errs = null

        errs


    _.extend isStateValid, checkComponentExist

    isStateValid

