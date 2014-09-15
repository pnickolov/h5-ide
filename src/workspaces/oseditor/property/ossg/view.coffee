define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
], ( constant, OsPropertyView, template, CloudResources ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateAttribute"

        render: ->

            @$el.html template.stack()
            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

    }, {
        handleTypes: [ 'sgrule' ]
        handleModes: [ 'stack', 'appedit' ]
    }
