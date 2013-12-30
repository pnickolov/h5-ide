define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( CONSTANT, MC, lang, resultVO ) ->

    ########## Functional Method ##########
    #errors = []

    _componentTipMap =
        'AWS.EC2.Instance': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_INSTANCE
        'AWS.AutoScaling.Group': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_ASG

    _getCompTip = ( compType, str1, str2, str100 ) ->
        tip = _componentTipMap[ arguments[ 0 ] ]

        arguments[ 0 ] = _componentTipMap[ tip ]

        sprintf.apply @, arguments


    _buildTAErr = ( tip, uid, refUid ) ->

        level   : constant.TA.ERROR
        info    : tip
        uid     : "#{uid}:#{refUid}"

    # return  Array
    _findReference = ( str ) ->
        reg = CONSTANT.REGEXP.stateEditorReference
        ret = []

        while ( resArr = reg.exec str ) isnt null
            ret.push { uid: resArr[ 1 ], ref: resArr[ 0 ] }

        ret

    # Sub Check
    _checkComponentExist = ( obj, data ) ->
        errs = []

        if _.isString obj
            refs = _findReference obj

            for ref in refs
                component = Design.instance().component( ref.uid )
                if not component
                    tip = _getCompTip data.type, data.name, data.stateId, ref.ref
                    TAError = _buildTAErr tip, data.uid, ref.uid

                    errs.push TAError

        else
            for key, value of obj
                errs.concat _checkComponentExist value

        errs

    # Main Check
    _checkState = ( state, data ) ->
        errs = []

        errs.concat _checkComponentExist( state, data )

        errs

    ########## Public Method ##########

    isStateValid = ( uid ) ->
        component = Design.instance().component( uid )

        states = component.get 'state'

        data =
            uid     : uid
            type    : component.get 'type'
            name    : component.get 'name'
            stateId : null

        errs = []

        _.each states, ( state, id ) ->

            errs.concat _checkState state, _.extend { stateId: id }, data

        if not errs.length
            errs = null

        errs


    isStateValid: isStateValid
