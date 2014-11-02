define [
    'constant'
    '../OsPropertyView'
    './stack'
    './app'
    'CloudResources'
    '../oshm/view'
    'UI.selection'
    '../validation/ValidationBase'
], ( constant, OsPropertyView, TplStack, TplApp, CloudResources, HmView, bindSelection, ValidationBase ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]": "updateAttribute"

            "select_dropdown_button_click .item-list": "addItem"
            "click .item-list .item": "editItem"
            "click .item-readable-list .item": "viewItem"
            "click .item-list .item .item-remove": "removeItem"

        initialize: (options) ->
            @targetModel = options.targetModel
            @isApp = options.isApp
            if @isApp
                @appModelList = @targetModel
                delete @targetModel

            that = @
            @selectTpl =
                button: () ->
                    return that.getTpl().addButton()

                getItem: (item) ->
                    that.getTpl().item( that.getItemData item )

        getModelForMode: -> @targetModel

        getItemData: ( item ) -> Design.instance().component( item.value ).toJSON()

        getAppData: () ->
            HmClass = Design.modelClassForType constant.RESTYPE.OSHM
            _.map @appModelList, ( model ) ->
                json = model.toJSON()
                oshm = HmClass.find ( hm ) -> hm.get( 'appId' ) is json.id
                json.name = oshm?.get 'name'
                json

        getSingleAppData: ( id ) -> _.findWhere @getAppData(), id: id

        getTpl: ->
            if @isApp
                TplApp
            else
                TplStack

        render: ->

            HMValid = ValidationBase.getClass(constant.RESTYPE.OSHM)
            bindSelection(@$el, @selectTpl, new HMValid({
                view: @
            }))

            if @isApp
                @renderApp()
            else
                @refreshList()

            @

        refreshList: () ->

            list = @targetModel.get("healthMonitors").map (hm)-> hm.toJSON()
            @$el.html @getTpl().stack({
                activeList: @targetModel.get("healthMonitors").map( (hm) -> hm.id ).join ','
                list: list
                mustShowList: (not @isApp)
            })

        renderApp: -> @$el.html @getTpl().stack list: @getAppData()

        getSelectItemModel: ( $item ) ->
            uid = $item.data('value')
            Design.instance().component uid

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

        addItem: (event, value) ->
            monitor = @targetModel.addNewHm(value)
            @refreshList()
            $newItem = @$el.find('.item-list .item[data-value="' + monitor.get('id') + '"]')
            $newItem.click()

        editItem: (event) ->
            $target = $(event.currentTarget)

            model = @getSelectItemModel($target)
            view = @reg new HmView model: model, isApp: @isApp

            @listenTo model, 'change', @refreshList
            @showFloatPanel(view.render().el)

        viewItem: ( event ) ->
            $target = $ event.currentTarget
            $( '.item-readable-list .item' ).removeClass 'focus'
            $target.addClass 'focus'

            id = $target.data 'id'
            modelData = @getSingleAppData id
            view = @reg new HmView modelData: modelData, isApp: @isApp

            @showFloatPanel(view.render().el)

        removeItem: (event) ->
            $target = $ event.currentTarget

            id = $target.closest( '.item' ).data 'value'
            @targetModel.removeHm id

            @refreshList()
            @hideFloatPanel()

            false

    }, {
        handleTypes: [ 'ossglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
