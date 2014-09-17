define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    '../oshm/view'
], ( constant, OsPropertyView, template, CloudResources, HmView ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]": "updateAttribute"

            "select_dropdown_button_click .item-list": "addItem"
            "click .item-list .item": "editItem"
            "click .item-list .item .item-remove": "removeItem"

        initialize: (options) ->
            @targetModel = options.targetModel

            @selectTpl =
                button: () ->
                    return template.addButton()

                getItem: (item) -> template.item( Design.instance().component( item.value ).toJSON() )

        render: ->
            @refreshList()
            @

        refreshList: () ->
            @$el.html template.stack({
                activeList: @targetModel.get("healthMonitors").map( (hm) -> hm.id ).join( ',' )
                list: @targetModel.get("healthMonitors").map (hm)-> hm.toJSON()
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
            view = @hmView = new HmView model: model

            @listenTo model, 'change', @refreshList
            @showFloatPanel(view.render().el)

        removeItem: (event) ->
            $target = $ event.currentTarget

            id = $target.closest( '.item' ).data 'value'
            @targetModel.removeHm id

            @refreshList()
            @hideFloatPanel()

            false

        remove: ->
            @hmView?.remove()
            OsPropertyView.prototype.remove.apply @, arguments

    }, {
        handleTypes: [ 'ossglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
