define [
    'constant'
    '../OsPropertyView'
    './stack'
    './app'
    'CloudResources'
    '../oshm/view'
], ( constant, OsPropertyView, TplStack, TplApp, CloudResources, HmView ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]": "updateAttribute"

            "select_dropdown_button_click .item-list": "addItem"
            "click .item-list .item": "editItem"
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

                getItem: (item) -> that.getTpl().item( Design.instance().component( item.value ).toJSON() )

        getTpl: ->
            if @isApp
                TplApp
            else
                TplStack

        render: ->
            if @isApp
                @renderApp()
            else
                @refreshList()

            @

        refreshList: () ->
            @$el.html @getTpl().stack({
                activeList: @targetModel.get("healthMonitors").map( (hm) -> hm.id ).join ','
                list: @targetModel.get("healthMonitors").map (hm)-> hm.toJSON()
            })

        renderApp: ->
            @$el.html @getTpl().stack({
                activeList: _.pluck( @appModelList, 'id' ).join ','
                list: _.map @appModelList, ( model ) -> model.toJSON()
                isApp: true
            })

        getSelectItemModel: ( $item ) ->
            uid = $item.data('value')
            Design.instance().component uid

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

        addItem: (event) ->
            @targetModel.addNewHm()
            @refreshList()

        editItem: (event) ->
            $target = $(event.currentTarget)

            model = @getSelectItemModel($target)
            view = @reg new HmView model: model, isApp: @isApp

            @listenTo model, 'change', @refreshList
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
