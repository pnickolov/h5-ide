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

        # Register subview for gc and bind some params
        reg: ( subView ) ->
            if subView in @__subViews then return subView
            if subView is @ then return subView

            @__subViews.push subView
            _.extend subView, _.pick @, 'propertyPanel', 'panel'
            subView.__superView = @

            subView

        remove: ->
            sv?.remove?() for sv in @__subViews
            Backbone.View.prototype.remove.apply @, arguments

        getRenderData: -> _.extend {}, @getExtendJson(), @getModelJson()

        getExtendJson: ->
            {
                modeIsApp       : @modeIsApp()
                modeIsAppEdit   : @modeIsAppEdit()
                modeIsStack     : @modeIsStack()
            }

        getModelJson: ->
            switch
                when @modeIsStack() then @model.toJSON()
                when @modeIsApp() then @appModel?.toJSON()
                when @modeIsAppEdit() then _.extend @model.toJSON(), app: @appModel?.toJSON()

        # Auto Bind 'data-target=attr', you need add a event first like below.
        ###
        events:
            'change [data-target]': 'updateAttribute'
        ###
        updateAttribute: ( e ) ->
            $target = $ e.currentTarget
            attr = $target.data 'target'

            unless attr then return
            value = $target.getValue()
            @getModelForUpdateAttr( e )?.set(attr, value)

            if attr is 'name' then @setTitle value

        # Overwrite it in subview if `updateAttribute`'s model isnt this.model or it is changeable
        getModelForUpdateAttr: -> @model
        getPanel: -> @panel or @__superView?.panel
        getPropertyPanel: -> @propertyPanel or @__superView?.propertyPanel

        # Modes
        getModelForMode: -> @model
        mode: ->
            model = @getModelForMode()
            unless model then return ''

            mod = Design.instance().mode()
            mod = 'stack' if mod is 'appedit' and not model.get( 'appId' )
            mod

        modeIsApp       : -> @mode() is 'app'
        modeIsAppEdit   : -> @mode() is 'appedit'
        modeIsStack     : -> @mode() is 'stack'


        # Overwrite it in subview if the title is not `name` attribute
        getTitle        : -> @model?.get( 'name' )
        setTitle        : -> @getPropertyPanel()?.setTitle.apply @getPropertyPanel(), arguments
        showFloatPanel  : -> @getPanel()?.showFloatPanel.apply @getPanel(), arguments
        hideFloatPanel  : -> @getPanel()?.hideFloatPanel.apply @getPanel(), arguments




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
