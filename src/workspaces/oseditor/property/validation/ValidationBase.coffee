define [
  'constant'
  'backbone'
  'i18n!/nls/lang.js'
], ( constant, Backbone, lang ) ->

    __handleTypes = {}

    Backbone.Model.extend {

        initialize: ( options ) ->
            _.extend @, options

        # Consumer will call this method first to initialize validation.
        init: () ->

        name: (value) ->

            resModel = @model

            return if not resModel

            oldName = resModel.get('name')
            newName = value

            # duplication valid
            nameDup = false
            if oldName isnt newName
                Design.instance().eachComponent (comp) ->
                    if comp isnt resModel and comp.get('name') is newName
                        nameDup = true
                    null
            if nameDup is true
                return sprintf lang.PARSLEY.TYPE_NAME_CONFLICT, 'The', newName

            # empty valid
            return '' if newName is ''

            # reserved valid
            if newName in ['self', 'this', 'global', 'meta', 'madeira']
                return sprintf lang.PARSLEY.TYPE_NAME_CONFLICT, 'The', newName

            return null

        # limit:
        #     name: '/[a-zA-Z0-9]/'
        #
        # # Method name is the name of attribute need to validate.
        # name: () ->
        #     # TODO
        #     # Prevent duplicate name
        #
        #     # Return null means evething is ok, it passes the validation
        #     null
        #
        #     # Or return a error message means the attribute data is invalid, the message will present to user.
        #     # e.g.
        #     # "The name is duplicate."

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

        limit:

            port: '^[0-9]*$'

            portRange: '^[0-9-]*$'

            portCodeRange: '^[0-9/-]*$'

    }
