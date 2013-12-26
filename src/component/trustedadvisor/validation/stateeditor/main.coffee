define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( CONSTANT, MC, lang, resultVO ) ->

    ########## Functional Method ##########
    errors = []

    findReference = ( str ) ->
        str.match CONSTANT.REGEXP.stateEditorReference

    checkComponentExist = ( obj ) ->
        if _.isString obj
            refs = findReference obj

            #for ref in refs


        #for key, value of obj

    checkState = ( state ) ->
        errors = checkComponentExist( state )

    ########## Public Method ##########

    isStateValid = ( uid ) ->
        component = Design.instance().component( uid )

        states = component.state

        _.each states, ( state, index ) ->
            checkState( state )



    isStateValid: isStateValid
