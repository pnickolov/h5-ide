define [
  'constant'
  'backbone'
], ( constant, Backbone ) ->

    __handleTypes = {}

    Backbone.Model.extend {
        initialize: ( options ) ->

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



