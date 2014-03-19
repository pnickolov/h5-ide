###
This file use for validate state.
###

define [ 'constant', 'MC', 'i18n!nls/lang.js' ], ( CONST, MC, lang ) ->

    ########## Functional Method ##########
    #errors = []

    __componentTipMap =
        'AWS.EC2.Instance': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_INSTANCE
        'AWS.AutoScaling.LaunchConfiguration': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_ASG

    __getCompTip = ( compType, str1, str2, str100 ) ->
        tip = __componentTipMap[ arguments[ 0 ] ]

        sprintf.apply @, [].concat tip, Array.prototype.slice.call arguments, 1


    __genError = ( tip, stateId ) ->

        level   : CONST.TA.ERROR
        info    : tip
        uid     : "refinexsit:#{stateId}"

    # return  Array
    __findReference = ( str ) ->
        reg = CONST.REGEXP.stateEditorOriginReference
        ret = []

        while ( resArr = reg.exec str ) isnt null
            refObj = attr: resArr[ 3 ], uid: resArr[ 2 ], ref: resArr[ 1 ], str: resArr[ 0 ]
            ret.push refObj

        ret

    __isUid = ( uid ) ->
        CONST.REGEXP.uid.lastIndex = 0
        CONST.REGEXP.uid.test uid

    __getComp = ( uid ) ->
        component = MC.canvas_data.component[ uid ]
        component

    __getRef = ( obj, data ) ->
        ref = []

        if _.isString obj
            if obj.length is 0
                return []
            ref = ref.concat __findReference obj
        else
            for key, value of obj
                ref = ref.concat __getRef value, data

        ref

    __legalExist = ( legalRef, ref ) ->
        _.some legalRef, ( legal ) ->
            legal.ref is ref.ref

    __legalState = ( ref ) ->
        arr = ref.attr.split '.'
        state = arr[ 0 ]
        stateId = arr[ 1 ]

        comp = __getComp ref.uid
        if comp and comp[ state ] and _.where( comp[ state ], id: stateId ).length
            true
        else
            false

    __refState = ( ref ) ->
        ref.attr.indexOf('.' ) isnt -1



    Message =

        illegal: ( ref ) ->
            comp = __getComp ref.uid
            if comp
                refName = "#{comp.serverGroupName or comp.name}.#{ref.attr}"
            else if __isUid ref.uid
                refName = "unknown.#{r.attr}"
            else
                refName = ref.ref

            refName

        state: ( ref ) ->
            refName = Message.illegal ref
            arr = refName.split '.'
            # etc. "state-F3CEEEB9-3CFD-4FA9-8DBE-1C8F8E0C2C1E" display as unknow
            if arr[ 2 ].length is 42
                arr[ 2 ] = 'unknown'

            arr.join '.'


    ########## Public Method ##########

    checkRefExist = ( obj, data ) ->
        ref = __getRef obj, data
        error = []
        if ref.length
            legalRef = MC.aws.aws.genAttrRefList data.comp, MC.canvas_data.component

        for r in ref
            if __refState r
                if not __legalState r
                    refName = Message.state r
            else
                if not __legalExist( legalRef, r )
                    refName = Message.illegal r

            if refName
                tip = __getCompTip data.type, data.name, data.stateId, refName
                error.push __genError tip, data.stateId

        error

    takeplace = ->
        null


    checkRefExist

