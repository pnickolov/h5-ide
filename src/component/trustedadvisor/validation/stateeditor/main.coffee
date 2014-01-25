define [ './register', 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( validators, constant, MC, lang, resultVO ) ->


    __modifyUid = ( result, uid, index ) ->
        if result
            if not _.isArray result
                result = [ result ]

            for r in result or []
                r.uid = "#{uid}:#{index}:#{r.uid}"

        result

    # Main Check
    __checkState = ( state, data ) ->
        results = []

        for index, validator of validators
            result = validator( state, data )
            result = __modifyUid result, data.uid, index

            results = results.concat result

        results


    ########## Public Method ##########

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

            errs = errs.concat __checkState state, _.extend {}, data, { stateId: id }

        if not errs.length
            errs = null

        errs



    isStateValid

