define [
  'constant'
], ( constant ) ->

    __propertyViewMap = {
        stack   : {}
        app     : {}
        appedit : {}
    }

    OsPropertyView = Backbone.View.extend {
        events:
            'change [data-target]': 'updateAttribute'

        constructor: ( options ) ->
            if options and _.isObject options
                _.extend @, options

            @__subViews = []

            Backbone.View.apply @, arguments

        reg: ( subView ) ->
            if subView in @__subViews then return subView
            if subView is @ then return subView

            @__subViews.push subView
            _.extend subView, _.pick @, 'propertyPanel', 'panel'
            subView

        updateAttribute: ( e ) ->
            $target = $ e.currentTarget
            attr = $target.data 'target'

            unless attr then return
            value = $target.getValue()
            @getModelForUpdateAttr( e )?.set(attr, value)

            if attr is 'name' then @setTitle value

        getModelForUpdateAttr: -> @model

        setTitle      : -> @propertyPanel?.setTitle.apply @propertyPanel, arguments
        showFloatPanel: -> @panel?.showFloatPanel.apply @panel, arguments
        hideFloatPanel: -> @panel?.hideFloatPanel.apply @panel, arguments

        # Overwrite it in subview
        getTitle: -> @model?.get( 'name' )

        remove: ->
            sv?.remove?() for sv in @__subViews
            Backbone.View.prototype.remove.apply @, arguments

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
