#############################
#  View Mode for component/stateeditor
#############################

define [ 'Design', 'validation', 'constant', 'i18n!/nls/lang.js', 'jquery', 'underscore', 'MC', 'UI.errortip' ], ( Design, validationTA, constant, lang ) ->

    TA = validationTA.state

    Message = {}

    Setup =
        before: () ->

        after: () ->

    Validator =
        # main validators [ return null or message ]

        # 'required', 'stateAllowed'
        command: ( val, param, elem, represent ) ->
            val = Helper.trim val
            map = param.dataMap

            if not @required val
                return 'Command name is required.'
            if not @stateAllowed val, map
                return "Command \"#{val}\" is not supported."
            null



        parameter: ( val, param, elem, represent ) ->
            validateList = [ 'required', 'type' ]
            result = null

            if @[ param.constraint.type ]
                result = @[ param.constraint.type ]( val, param, elem, represent )
            if not result
                result = @componentExist val

            result


        # sub validators [ return null or message ]

        dict: ( val, param, elem, represent ) ->
            subType = param.subType
            result = null

            if param.constraint.required and subType is 'key' and not @required val
                result = 'dict key is required'

            result

        array: ( val, param, elem, represent ) ->
            result = null

            if param.constraint.required and not @required val
                result = 'array value is required'

            result

        line: ( val, param, elem, represent ) ->
            result = null

            if param.constraint.required and not @required val
                result = 'line value is required'

            result

        text: ( val, param, elem, represent ) ->
            result = null

            if param.constraint.required and not @required val
                result = 'text value is required'

            else
                result = @componentExist val

            result

        bool: ( val, param, elem, represent ) ->
            result = null

            if param.constraint.required and not @required val
                result = 'line value is required'

            else if not ( @isBool( val ) or @isStringBool( val, true ) )
                result = "invalid boolean value: \"#{val}\""

            result

        componentExist: ( val ) ->
            refs = Helper.getRefName val
            inexsitCount = 0


            for ref in refs
                if not Helper.nameExist ref.name
                    inexsitCount++


            if inexsitCount
                return "Reference 'unknown' doesn't exist."

            null



        # sub validators [ return true or false ]
        required: ( val ) ->
            @notnull( val ) and @notblank( val )

        notnull: ( val ) ->
            val.length > 0

        notblank: ( val ) ->
            'string' is typeof val and '' isnt val.replace( /^\s+/g, '' ).replace( /\s+$/g, '' )

        isBool: ( val ) ->
            _.isBoolean val

        isStringBool: ( val, allowEmpty ) ->
            /^(true|false)$/i.test val or allowEmpty and val is ''







        stateAllowed: ( val, map ) ->
            val in Helper.getAllowCommands( map )




    Helper =
        getAllowCommands: ( map ) ->
            _.keys map

        trim: ( val ) ->
            $.trim val

        nameExist: ( name ) ->
            allCompData = Design.instance().serialize().component

            for uid, component of allCompData
                if component.name is name
                    return true
            false

        getRefName: ( val ) ->

            reg = constant.REGEXP.stateEditorOriginReference

            ret = []

            while ( resArr = reg.exec val ) isnt null
                ret.push { name: resArr[ 1 ], ref: resArr[ 0 ] }

            ret



    Action =

        displayError: ( msg, elem, represent ) ->
            if not errortip.hasError elem
                errortip.createError msg, elem
                errortip.createError msg, represent
            else
                errortip.changeError msg, elem
                errortip.changeError msg, represent

        clearError: ( elem, represent ) ->
            if errortip.hasError elem
                errortip.removeError elem
                errortip.removeError represent

    # Interface
    validate = ( value, param, elem, represent ) ->
        res = Validator[ param.type ] value, param, elem, represent
        if res
            Action.displayError res, elem, represent
        else
            Action.clearError elem, represent

        res

    # Attach Setup to Interface
    _.extend validate, Setup



    validate




