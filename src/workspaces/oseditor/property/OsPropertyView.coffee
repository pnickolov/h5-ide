define [
  'constant'
], ( constant ) ->

    __propertyViewMap = {
        stack   : {}
        app     : {}
        appedit : {}
    }

    OsPropertyView = Backbone.View.extend {
        constructor: ( options ) ->
            @parent = options?.parent
            Backbone.View.apply @, arguments

        updateAttribute: ( e ) ->
            $target = $ e.currentTarget
            attr = $target.data 'target'

            unless attr then return
            value = $target.getValue()
            @getModelForUpdateAttr( e )?.set(attr, value)

            if attr is 'name' then @setTitle value

        getModelForUpdateAttr: -> @model

        setTitle      : -> @parent?.setTitle.apply @parent, arguments
        showFloatPanel: -> @parent?.showFloatPanel.apply @parent, arguments
        hideFloatPanel: -> @parent?.hideFloatPanel.apply @parent, arguments

        # Overwrite it in subview
        getTitle: -> @model?.get( 'name' )

    }, {
        extend : ( protoProps, staticProps ) ->
            childClass = Backbone.Model.extend.apply @, arguments

            delete childClass.register
            delete childClass.getClass

            if staticProps
                handleTypes  = staticProps.handleTypes
                handleModes  = staticProps.handleModes
                OsPropertyView.register handleTypes, handleModes, childClass

            childClass

        register: ( handleTypes, handleModes, modelClass ) ->
            for mode in handleModes
                for type in handleTypes
                    __propertyViewMap[ mode ][ type ] = modelClass

            null

        getClass: ( mode, type ) -> __propertyViewMap[ mode ][ type ]

    }




    OsPropertyView
