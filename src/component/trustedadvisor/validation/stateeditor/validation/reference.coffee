###
This file use for validate state.
###

define [ 'constant', 'MC', 'i18n!nls/lang.js' ], ( constant, MC, lang ) ->

    ########## Functional Method ##########
    #errors = []

    __componentTipMap =
        'AWS.EC2.Instance': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_INSTANCE
        'AWS.AutoScaling.LaunchConfiguration': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_ASG

    __getCompTip = ( compType, str1, str2, str100 ) ->
        tip = __componentTipMap[ arguments[ 0 ] ]

        sprintf.apply @, [].concat tip, Array.prototype.slice.call arguments, 1


    __genError = ( tip, stateId ) ->

        level   : constant.TA.ERROR
        info    : tip
        uid     : "refinexsit:#{stateId}"

    # return  Array
    __findReference = ( str ) ->
        reg = constant.REGEXP.stateEditorOriginReference
        ret = []

        while ( resArr = reg.exec str ) isnt null
            refObj = attr: resArr[ 3 ], uid: resArr[ 2 ], ref: resArr[ 1 ], str: resArr[ 0 ]
            ret.push refObj

        ret

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


    ########## Public Method ##########

    checkRefExist = ( obj, data ) ->
        ref = __getRef obj, data
        error = []
        if ref.length
            legalRef = MC.aws.aws.genAttrRefList data.comp, MC.canvas_data.component


        for r in ref
            hitLegal = null
            exist = _.some legalRef, ( legal ) ->
                legal.ref is r.ref

            if not exist
                comp = __getComp r.uid
                if comp
                    refName = "#{comp.name}.#{r.attr}"
                else
                    refName = "unknown.#{r.attr}"

                tip = __getCompTip data.type, data.name, data.stateId, refName
                error.push __genError tip, data.stateId

        error

    takeplace = ->
        null


    checkRefExist

