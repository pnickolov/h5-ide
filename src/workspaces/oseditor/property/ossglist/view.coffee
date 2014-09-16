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

        initialize: (options) ->

            @targetModel = options.targetModel

            @selectTpl =

                button: () ->

                    return template.addSGButton()

                sgItem: (item) ->

                    return template.sgitem({
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

        getSelectSGModel: ($sgItem) ->

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
            @refreshList()

        editItem: (event) ->

            $target = $(event.currentTarget)
            sgModel = @getSelectSGModel($target)

            sgView = new SgView({sgModel: sgModel})
            @showFloatPanel(sgView.render().el)
            return false

        removeSG: (event) ->

            $target = $(event.currentTarget)
            $sgItem = $target.parents('.item')
            sgModel = @getSelectSGModel($sgItem)
            sgModel.remove()
            @refreshList()

        attachItem: (event, sgUID) ->

            sgModel = Design.instance().component(sgUID)
            @targetModel.attachSG(sgModel)

        unAttachItem: (event, sgUID) ->

            sgModel = Design.instance().component(sgUID)
            @targetModel.unAttachSG(sgModel)

    }, {
        handleTypes: [ 'ossglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
