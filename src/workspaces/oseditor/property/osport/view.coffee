define [
    'constant'
    '../OsPropertyView'
    './stack'
    'CloudResources'
], ( constant, OsPropertyView, stackTpl, CloudResources ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateServerAttr"

        render: ->

            @$el.html stackTpl({})
            @

        updateServerAttr: (event)->

            target = $(event.currentTarget)
            attr = target.data('target')

        }, {
            handleTypes: [ constant.RESTYPE.OSPORT ]
            handleModes: [ 'stack', 'appedit' ]
        }
