define [
    'constant'
    '../OsPropertyView'
    './stack'
    'CloudResources'
], ( constant, OsPropertyView, stackTpl, CloudResources ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateAttribute"

        render: ->

            @$el.html stackTpl({})
            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            @model.set(attr, value)

        }, {
            handleTypes: [ constant.RESTYPE.OSPORT ]
            handleModes: [ 'stack', 'appedit' ]
        }
