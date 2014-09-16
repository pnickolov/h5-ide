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

            "select_item_remove .item-list": "unAttachItem"
            "click .item-list .item .item-remove": "unAttachItemClick"

        initialize: (options) ->
            @targetModel = options.targetModel

            @selectTpl =
                button: () ->
                    return template.addButton()

                getItem: (item) ->
                    return template.item({
                        name: item.text
                    })

        render: ->
            @refreshList()
            @

        refreshList: () ->
            @$el.html template.stack({
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

        attachItem: (event, sgUID) ->
            sgModel = Design.instance().component(sgUID)
            @targetModel.attachSG(sgModel)

        unAttachItem: (event, sgUID) ->

            sgModel = Design.instance().component(sgUID)
            @targetModel.unAttachSG(sgModel)

        unAttachItemClick: (event) ->

            $target = $(event.currentTarget)
            $sgItem = $target.parents('.item')
            sgModel = @getSelectItemModel($sgItem)
            @targetModel.unAttachSG(sgModel)
            @refreshList()
            return false

        remove: ->
            @hmView?.remove()
            OsPropertyView.prototype.remove.apply @, arguments

    }, {
        handleTypes: [ 'ossglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
