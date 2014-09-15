define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
], ( constant, OsPropertyView, template, CloudResources ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateAttribute"
            "select_item_add .sglist": "addSG"
            "select_dropdown_button_click .sglist": "addSG"
            "select_item_remove .sglist": "removeSG"

        render: ->

            OSSGModel = Design.modelClassForType(constant.RESTYPE.OSSG)
            sgModels = OSSGModel.allObjects()

            _.each sgModels, (sgModel) ->
                sgModel

            @$el.html template.stack({

            })

            @selectTpl =

                button: () ->

                    return '<div>Create New Security Group...</div>'

                sgItem: (data) ->

                sgOption: (data) ->

            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

        addSG: (event) ->


            oSSGModel = new OSSGModel({})

        removeSG: (event) ->

            null

    }, {
        handleTypes: [ 'sglist' ]
        handleModes: [ 'stack', 'appedit' ]
    }
