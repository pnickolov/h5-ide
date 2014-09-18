define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    '../ossg/view'
    'UI.selection'
], ( constant, OsPropertyView, template, CloudResources, SgView, bindSelection ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateAttribute"

            "select_dropdown_button_click .item-list": "addItem"
            "click .item-list .item": "editItem"

            "select_item_add .item-list": "attachItem"
            "select_item_remove .item-list": "unAttachItem"
            "click .item-list .item .item-remove": "unAttachItemClick"
            "mousedown .item-list .item .item-remove": "unAttachItemMousedown"

        initialize: (options) ->

            that = @
            @targetModel = options.targetModel
            @panel = options.panel

            @selectTpl =

                button: () ->
                    return template.addButton()

                sgItem: (item) ->

                    return template.item({
                        name: item.text
                    })

                sgOption: (data) ->

                    sgModel = Design.instance().component(data.value)
                    return template.option({
                        name: data.text,
                        ruleCount: sgModel.get('rules').length,
                        memberCount: sgModel.getMemberList().length,
                        description: sgModel.get('description')
                    })

        render: ->

            bindSelection(@$el, @selectTpl)
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

            @refreshRemoveState()

        refreshRemoveState: () ->

            attachedSGModels = @targetModel.connectionTargets("OsSgAsso")
            if attachedSGModels.length <= 1
                @$el.find('.item-list .item-remove').addClass('hide')
            else
                @$el.find('.item-list .item-remove').removeClass('hide')

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
            sgUID = oSSGModel.get('id')
            @attachItem(null, sgUID)
            @refreshList()
            $newItem = @$el.find('.item-list .item[data-value="' + sgUID + '"]')
            $newItem.click()
            return false

        editItem: (event) ->

            $target = $(event.currentTarget)
            sgModel = @getSelectItemModel($target)

            sgView = new SgView({
                sgModel: sgModel,
                listView: @
            })

            @showFloatPanel(sgView.render().el)
            return false

        attachItem: (event, sgUID) ->

            sgModel = Design.instance().component(sgUID)
            sgModel.attachSG(@targetModel)
            @refreshRemoveState()

        unAttachItem: (event, sgUID) ->

            sgModel = Design.instance().component(sgUID)
            sgModel.unAttachSG(@targetModel)
            @refreshRemoveState()

        unAttachItemClick: (event) ->

            $target = $(event.currentTarget)
            $sgItem = $target.parents('.item')
            sgModel = @getSelectItemModel($sgItem)
            sgModel.unAttachSG(@targetModel)
            @refreshList()
            return false

        unAttachItemMousedown: () ->

            return false

    }, {
        handleTypes: [ 'ossglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
