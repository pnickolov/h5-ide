#############################
#  View Mode for component/stateeditor
#############################

define [ 'jquery', 'underscore', 'MC', 'UI.errortip' ], () ->




    Message = {}

    Validator =
        # main validators [ return null or message ]

        # 'required', 'stateAllowed'
        command: ( val, param, elem, represent ) ->
            val = Helper.trim val
            map = param.dataMap

            if not @required val
                return 'Command Name is required.'
            if not @stateAllowed val, map
                return "State #{param.command} isn't supported."
            null



        parameter: ( value, param, elem, represent ) ->


        # sub validators [ return true or false ]
        required: ( val ) ->
            @notnull( val ) and @notblank( val )

        notnull: ( val ) ->
            val.length > 0

        notblank: ( val ) ->
            'string' is typeof val and '' isnt val.replace( /^\s+/g, '' ).replace( /\s+$/g, '' )

        isBool: ( val ) ->
            _.isBoolean val

        stateAllowed: ( val, map ) ->
            val in Helper.getAllowCommands( map )




    Helper =
        getAllowCommands: ( map ) ->
            _.keys map
        trim: ( val ) ->
            $.trim val

    Action =

        displayError: ( msg, elem, represent ) ->
            if represent
                elem = represent

            errortip.createError msg, elem

        clearError: ( elem, represent ) ->
            if represent
                elem = represent

            if errortip.hasError elem
                errortip.removeError elem

    # Interface
    validate = ( value, param, elem, represent ) ->
        res = Validator[ param.type ] value, param, elem, represent
        if res
            Action.displayError res, elem, represent
        else
            Action.clearError elem, represent

        res



    validate




