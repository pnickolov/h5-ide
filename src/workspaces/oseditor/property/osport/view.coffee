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

            value = _.extend {
                hasFloatIP: !!@model.getFloatingIp()
            }, @model.toJSON()
            
            @$el.html stackTpl(value)
            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            if attr is 'float_ip'
                @model.setFloatingIp(value)
            else
                @model.set(attr, value)

        }, {
            handleTypes: [ constant.RESTYPE.OSPORT ]
            handleModes: [ 'stack', 'appedit' ]
        }
