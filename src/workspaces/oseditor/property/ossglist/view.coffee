define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    '../ossg/view'
], ( constant, OsPropertyView, template, CloudResources, SgView ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateAttribute"

            "select_dropdown_button_click .item-list": "addItem"
            "click .item-list .item": "editItem"

            "select_item_add .item-list": "attachItem"
            "select_item_remove .item-list": "unAttachItem"
            "click .item-list .item .item-remove": "unAttachItemClick"

        initialize: (options) ->
            @targetModel = options.targetModel

            @selectTpl =
                button: () ->
                    return template.addButton()

                sgItem: (item) ->
                    return template.item({
                        name: item.text
                    })

                sgOption: (data) ->

        render: ->

            @refreshList()
            @

        refreshList: () ->

            OSSGModel = Design.modelClassForType(constant.RESTYPE.OSSG)

            # all sg
            allSGModels = OSSGModel.allObjects()
            sgList = []
            _.each allSGModels, (sgModel) ->
                sgName = sgModel.get('name')
                sgUID = sgModel.get('id')
                sgList.push({
                    name: sgName,
                    uid: sgUID
                })

            # attached sg
            attachedSGModels = @targetModel.connectionTargets("OsSgAsso")
            attachedSGList = []
            _.each attachedSGModels, (sgModel) ->
                sgUID = sgModel.get('id')
                attachedSGList.push(sgUID)

            @$el.html template.stack({
                sgList: sgList
                attachedSGList: attachedSGList.join(',')
            })

        getSelectItemModel: ($sgItem) ->

            sgId = $sgItem.data('value')
            sgModel = Design.instance().component(sgId)
            return sgModel

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

        addItem: (event) ->

            OSSGModel = Design.modelClassForType(constant.RESTYPE.OSSG)
            oSSGModel = new OSSGModel({})
            @attachItem(null, oSSGModel.get('id'))
            @refreshList()

        editItem: (event) ->

            $target = $(event.currentTarget)
            sgModel = @getSelectItemModel($target)

            sgView = new SgView({sgModel: sgModel})
            @showFloatPanel(sgView.render().el)
            # return false

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

    }, {
        handleTypes: [ 'ossglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
