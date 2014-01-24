define [ 'constant', 'MC', 'i18n!nls/lang.js' ], ( constant, MC, lang ) ->

    ########## Functional Method ##########
    #errors = []

    __componentTipMap =
        'AWS.EC2.Instance': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_INSTANCE
        'AWS.AutoScaling.Group': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_ASG

    __getCompTip = ( compType, str1, str2, str100 ) ->
        tip = __componentTipMap[ arguments[ 0 ] ]

        arguments[ 0 ] = tip

        sprintf.apply @, arguments


    __buildTAErr = ( tip, uid, refUid ) ->

        level   : constant.TA.ERROR
        info    : tip
        uid     : refUid

    # return  Array
    __findReference = ( str ) ->
        reg = constant.REGEXP.stateEditorReference
        ret = []

        while ( resArr = reg.exec str ) isnt null
            ret.push { uid: resArr[ 1 ], ref: resArr[ 0 ] }

        ret

    ########## Public Method ##########
    checkRefExist = ( obj, data ) ->
        errs = []

        if _.isString obj
            if obj.length is 0
                return errs

            refs = __findReference obj

            for ref in refs
                component = MC.canvas_data.component[ ref.uid ]
                if not component
                    if data
                        tip = __getCompTip data.type, data.name, data.stateId, ref.ref
                        TAError = __buildTAErr tip, data.uid, ref.uid

                        errs.push TAError
                    else
                        errs.push 'error'

        else
            for key, value of obj
                errs = errs.concat checkRefExist value, data

        errs


    checkRefExist

