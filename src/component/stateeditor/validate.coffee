#############################
#  View Mode for component/stateeditor
#############################

define [ 'validation', 'constant', 'i18n!nls/lang.js', 'jquery', 'underscore', 'MC', 'UI.errortip' ], ( validationTA, constant, lang ) ->

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
                return 'Command Name is required.'
            if not @stateAllowed val, map
                return "State \"#{val}\" isn't supported."
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
                result = TA.checkComponentExist val
                if result.length
                    result = "resource not exist"
                else
                    result = null

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

            names = ""

            for ref in refs
                if not Helper.nameExist ref.name
                    names = names + ref.name + ", "
                    continue

            if names
                names.slice 0, -2
                return "Reference #{names} don't exist."

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
            for uid, component of MC.canvas_data.component
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




