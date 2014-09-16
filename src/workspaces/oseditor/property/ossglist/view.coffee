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

        render: ->

            @refreshList()

            @selectTpl =

                button: () ->

                    return '<div>Create New Security Group...</div>'

                sgItem: (item) ->

                    return template.sgitem({
                        name: item.text
                    })

                sgOption: (data) ->

            @

        renderSGEdit: () ->

            sgView = new SgView()
            @$el.append sgView.render().el

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

        addSG: (event) ->

            OSSGModel = Design.modelClassForType(constant.RESTYPE.OSSG)
            oSSGModel = new OSSGModel({})
            @refreshList()

        removeSG: (event) ->

            $target = $(event.currentTarget)
            $sgItem = $target.parents('.sgitem')
            sgId = $sgItem.data('value')
            sgModel = Design.instance().component(sgId)
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
            @renderSGEdit()
            return false

    }, {
        handleTypes: [ 'sglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
