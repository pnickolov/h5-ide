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
            "select_dropdown_button_click .sglist": "addSG"
            "click .sglist .sgitem": "editSG"
            "click .sglist .sgitem .icon-delete": "removeSG"

        initialize: ->

            @selectTpl =

                button: () ->

                    return '<div>Create New Security Group...</div>'

                sgItem: (item) ->

                    return template.sgitem({
                        name: item.text
                    })

                sgOption: (data) ->

        render: ->

            @refreshList()
            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

        addSG: (event) ->

            OSSGModel = Design.modelClassForType(constant.RESTYPE.OSSG)
            oSSGModel = new OSSGModel({})
            @refreshList()

        getSelectSGModel: ($sgItem) ->

            sgId = $sgItem.data('value')
            sgModel = Design.instance().component(sgId)
            return sgModel

        removeSG: (event) ->

            $target = $(event.currentTarget)
            $sgItem = $target.parents('.sgitem')
            sgModel = @getSelectSGModel($sgItem)
            sgModel.remove()
            @refreshList()

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

        editSG: (event) ->

            $target = $(event.currentTarget)
            sgModel = @getSelectSGModel($target)

            sgView = new SgView({sgModel: sgModel})
            @showFloatPanel(sgView.render().el)
            return false

    }, {
        handleTypes: [ 'ossglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
