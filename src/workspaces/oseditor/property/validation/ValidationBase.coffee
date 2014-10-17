define [
  'constant'
  'backbone'
], ( constant, Backbone ) ->

    __handleTypes = {}

    Backbone.Model.extend {
        initialize: ( options ) ->
            _.extend @, options

        # Consumer will call this method first to initialize validation.
        init: () ->

        limit:
            name: /[a-zA-Z0-9]/

        # Method name is the name of attribute need to validate.
        name: () ->
            # TODO
            # Prevent duplicate name

            # Return null means evething is ok, it passes the validation
            null

            # Or return a error message means the attribute data is invalid, the message will present to user.
            # e.g.
            # "The name is duplicate."

    }, {
        extend : ( protoProps, staticProps ) ->
            childClass = Backbone.Model.extend.apply @, arguments

            delete childClass.register
            delete childClass.getClass

            if staticProps
                handleTypes  = staticProps.handleTypes
                @register handleTypes, childClass

            childClass

        register: ( handleTypes, modelClass ) ->
            for type in handleTypes
                __handleTypes[ type ] = modelClass

            null

        getClass: ( type ) -> __handleTypes[ type ]

    }



