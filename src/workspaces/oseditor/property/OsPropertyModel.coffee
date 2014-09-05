define [
  'constant'
], ( constant ) ->

    __propertyModelMap = {
        stack   : {}
        app     : {}
        appedit : {}
    }

    OsPropertyModel = Backbone.Model.extend {

    }, {
        extend : ( protoProps, staticProps ) ->
            childClass = Backbone.Model.extend.apply @, arguments

            delete childClass.register
            delete childClass.getClass

            if staticProps
                handleTypes  = staticProps.handleTypes
                handleModes  = staticProps.handleModes
                OsPropertyModel.register handleTypes, handleModes, childClass

            childClass

        register: ( handleTypes, handleModes, modelClass ) ->
            for mode in handleModes
                for type in handleTypes
                    __propertyModelMap[ mode ][ type ] = modelClass

            null

        getClass: ( mode, type ) -> __propertyModelMap[ mode ][ type ]

    }




    OsPropertyModel
