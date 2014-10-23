define [
  'constant'
  'backbone'
  'i18n!/nls/lang.js'
], ( constant, Backbone, LANG ) ->

    __handleTypes = {}

    ValidationBase = Backbone.Model.extend {

        initialize: ( options ) ->
            _.extend @, options

        # Consumer will call this method first to initialize validation.
        init: () ->

        name: (value) ->

            resModel = @model

            return if not resModel

            oldName = resModel.get('name')
            newName = value

            # empty valid
            return '' if newName is ''

            # duplication valid
            nameDup = false
            if oldName isnt newName
                Design.instance().eachComponent (comp) ->
                    if comp isnt resModel and comp.get('name') is newName
                        nameDup = true
                    null
            if nameDup is true
                return sprintf LANG.PARSLEY.TYPE_NAME_CONFLICT, 'The', newName

            # reserved valid
            if newName in ['self', 'this', 'global', 'meta', 'madeira']
                return sprintf LANG.PARSLEY.TYPE_NAME_CONFLICT, 'The', newName

            return null

        port: ( v ) ->
            if 1 <= +v <= 65535
                return null

            return ValidationBase.commonTip 'port'

    }, {
        extend : ( protoProps, staticProps ) ->
            childClass = Backbone.Model.extend.apply @, arguments

            delete childClass.register
            delete childClass.getClass

            if staticProps
                handleTypes  = staticProps.handleTypes
                @register handleTypes, childClass

            if protoProps.limits
                childClass.prototype.limits = _.extend protoProps.limits, @prototype.limits

            childClass

        register: ( handleTypes, modelClass ) ->
            for type in handleTypes
                __handleTypes[ type ] = modelClass

            null

        getClass: ( type ) -> __handleTypes[ type ]

        commonTip   : ( xxx ) -> sprintf LANG.PARSLEY.THIS_VALUE_SHOULD_BE_A_VALID_XXX, xxx
        greaterTip  : ( xxx ) -> sprintf LANG.PARSLEY.THIS_VALUE_SHOULD_BE_GREATER_THAN_XXX, xxx
        lowerTip    : ( xxx ) -> sprintf LANG.PARSLEY.THIS_VALUE_SHOULD_BE_LOWER_THAN_XXX, xxx
        geTip       : ( xxx ) -> sprintf LANG.PARSLEY.THIS_VALUE_SHOULD_BE_GREATER_THAN_OR_EQUAL_TO_XXX, xxx
        leTip       : ( xxx ) -> sprintf LANG.PARSLEY.THIS_VALUE_SHOULD_BE_LOWER_THAN_OR_EQUAL_TO_XXX, xxx
        rangeTip    : ( min, max ) -> sprintf LANG.PARSLEY.THIS_VALUE_MUST_BETWEEN_XXX_XXX min, max

        validation:
            range4G: (nullable) ->
                ValidationBase.validation.range null, 2147483647, nullable

            range: ( min, max, nullable ) ->
                if _.isNumber(min) and _.isNumber(max)
                    ( v ) ->
                        if v < min or v > max
                            return ValidationBase.rangeTip min, max

                        if !nullable and v is '' then return '' else null

                else if _.isNumber(min)
                    ( v ) ->
                        if v < min
                            return ValidationBase.greaterTip min - 1

                        if !nullable and v is '' then return '' else null

                else if _.isNumber(max)
                    ( v ) ->
                        if v > max
                            return ValidationBase.lowerTip max + 1

                        if !nullable and v is '' then return '' else null



        limit:

            positive: '^[1-9]+[0-9]*$'

            nonnegative: '^[0-9]*$'

            portRange: '^[0-9-]*$'

            portICMPRange: '^[0-9/-]*$'

            ipv4: '^[0-9.]*$'

            cidrv4: '^[0-9/.]*$'

            number: '^-?[0-9]*$|^-?[0-9]+\\.[0-9]*$'

    }

    ValidationBase
