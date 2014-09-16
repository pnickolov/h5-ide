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

            "select_dropdown_button_click .item-list": "addSG"
            "click .item-list .item": "editSG"

            "select_item_add .item-list": "attachSG"
            "select_item_remove .item-list": "unAttachSG"

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
            sgModels = OSSGModel.allObjects()

            sgListData = []
            _.each sgModels, (sgModel) ->
                sgName = sgModel.get('name')
                sgUID = sgModel.get('id')
                sgListData.push({
                    name: sgName,
                    uid: sgUID
                })

            @$el.html template.stack({
                sgListData: sgListData
            })

        getSelectSGModel: ($sgItem) ->

            sgId = $sgItem.data('value')
            sgModel = Design.instance().component(sgId)
            return sgModel

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

        addSG: (event) ->

            OSSGModel = Design.modelClassForType(constant.RESTYPE.OSSG)
            oSSGModel = new OSSGModel({})
            @refreshList()

        editSG: (event) ->

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

        attachSG: (event, sgUID) ->

            sgModel = Design.instance().component(sgUID)
            @targetModel.attachSG(sgModel)

        unAttachSG: (event, sgUID) ->

            sgModel = Design.instance().component(sgUID)
            @targetModel.unAttachSG(sgModel)

    }, {
        handleTypes: [ 'ossglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
