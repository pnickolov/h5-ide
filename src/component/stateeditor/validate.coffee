#############################
#  View Mode for component/stateeditor
#############################

define [ 'jquery', 'underscore', 'MC', 'UI.errortip' ], () ->




    Message = {}

    Validator =
        # main validators [ return null or message ]

        # 'required', 'stateAllowed'
        command: ( val, param, elem ) ->
            if not @required val
                return 'Command Name is required.'
            if not @stateAllowed val
                return "State #{param.command} isn't supported."
            null



        parameter: ( value, param, elem ) ->


        # sub validators [ return true or false ]
        required: ( val ) ->
            @notnull val and @notblank val

        notnull: ( val ) ->
            val.length > 0

        notblank: ( val ) ->
            'string' is typeof val and '' isnt val.replace( /^\s+/g, '' ).replace( /\s+$/g, '' )

        isBool: ( val ) ->
            _.isBoolean val

        stateAllowed: ( val ) ->
            val in Helper.getAllowCommands( val )




    Helper =
        getAllowCommands: ( map ) ->
            _.keys map

    Action =

        displayError: ( msg, elem ) ->
            errortip.createError msg, elem

        clearError: ( elem ) ->
            if errortip.hasError elem
                errortip.removeError elem

    # Interface
    validate = ( value, param, elem ) ->
        res = Validator[ param.type ] value, param, elem
        if res
            Action.displayError res, elem
        else
            Action.clearError elem

        res



    validate




