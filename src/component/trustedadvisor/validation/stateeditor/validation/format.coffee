###
This file use for validate state.
###

define [ 'Design', 'constant', 'i18n!/nls/lang.js', 'jquery', 'underscore', 'MC' ], ( Design, constant, lang ) ->

    Message = {}


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
            if _.isArray( val ) or _.isObject( val )
                not not _.size( val )
            else
                @notnull( val ) and @notblank( val )

        isRef: ( val ) -> constant.REGEXP.stateEditorOriginReference.test val

        notnull: ( val ) -> val.length > 0

        notblank: ( val ) ->
            'string' is typeof val and '' isnt val.replace( /^\s+/g, '' ).replace( /\s+$/g, '' )

        isBool: ( val ) -> _.isBoolean val

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

        buildError: ( tip, stateId, type ) ->

            level   : constant.TA.ERROR
            info    : tip
            uid     : "format_#{type}:#{stateId}"

        getModule: () ->
            stateModuel = Design.instance().get('agent').module
            moduleDataObj = App.model.getStateModule( stateModuel.repo, stateModuel.tag )

            module = {}
            _.each moduleDataObj, ( obj, key ) ->
                _.extend module, obj

            module

        getCommand: ( module, moduleName ) ->
            _.findWhere module, module: moduleName


    __matchModule = ( state, data ) ->
        module = Helper.getModule()
        cmd = Helper.getCommand module, state.module
        if cmd
            error = []
            for name, param of cmd.parameter
                if param.required is true and not Validator.required( state.parameter[ name ] )
                    tip = sprintf lang.ide.TA_MSG_ERROR_STATE_EDITOR_EMPTY_REQUIED_PARAMETER, data.name, data.stateId, name
                    type = 'requiredParameter'
                    error.push Helper.buildError tip, data.stateId, type

                else if cmd.module is 'meta.wait' and name is 'state' and not Validator.isRef( state.parameter[ name ] )
                    tip = sprintf lang.ide.TA_MSG_ERROR_STATE_EDITOR_INVALID_FORMAT, data.name, data.stateId, 'wait'
                    type = 'invalidFormat'
                    error.push Helper.buildError tip, data.stateId, type

            error

    # Interface
    checkFormat = ( state, data ) ->
        __matchModule( state, data )


    checkFormat




