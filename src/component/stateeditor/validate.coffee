#############################
#  View Mode for component/stateeditor
#############################

define [ 'constant', 'i18n!nls/lang.js', 'jquery', 'underscore', 'MC', 'UI.errortip' ], ( constant, lang ) ->


    # TA Component temporary begin
    TA = (() ->
        _componentTipMap =
            'AWS.EC2.Instance': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_INSTANCE
            'AWS.AutoScaling.Group': lang.ide.TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_ASG

        _getCompTip = ( compType, str1, str2, str100 ) ->
            tip = _componentTipMap[ arguments[ 0 ] ]

            arguments[ 0 ] = tip

            sprintf.apply @, arguments


        _buildTAErr = ( tip, uid, refUid ) ->

            level   : constant.TA.ERROR
            info    : tip
            uid     : "#{uid}:#{refUid}"

        # return  Array
        _findReference = ( str ) ->
            reg = constant.REGEXP.stateEditorReference
            ret = []

            while ( resArr = reg.exec str ) isnt null
                ret.push { uid: resArr[ 1 ], ref: resArr[ 0 ] }

            ret


        checkComponentExist = ( obj, data ) ->
            errs = []

            if _.isString obj
                if obj.length is 0
                    return errs

                refs = _findReference obj

                for ref in refs
                    component = Design.instance().component( ref.uid )
                    if not component
                        if data
                            tip = _getCompTip data.type, data.name, data.stateId, ref.ref
                            TAError = _buildTAErr tip, data.uid, ref.uid

                            errs.push TAError
                        else
                            errs.push 'error'

            else
                for key, value of obj
                    errs = errs.concat checkComponentExist value, data

            errs

        checkComponentExist: checkComponentExist
        )()

    # TA Component temporary end


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

            else if not @isBool val, true
                result = "invalid boolean value: \"#{val}\""

            result



        # sub validators [ return true or false ]
        required: ( val ) ->
            @notnull( val ) and @notblank( val )

        notnull: ( val ) ->
            val.length > 0

        notblank: ( val ) ->
            'string' is typeof val and '' isnt val.replace( /^\s+/g, '' ).replace( /\s+$/g, '' )

        isBool: ( val, allowEmpty ) ->
            _.isBoolean val or allowEmpty and val is ''




        stateAllowed: ( val, map ) ->
            val in Helper.getAllowCommands( map )




    Helper =
        getAllowCommands: ( map ) ->
            _.keys map
        trim: ( val ) ->
            $.trim val

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




