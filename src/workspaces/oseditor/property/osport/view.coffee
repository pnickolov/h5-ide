define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    '../ossglist/view'
], ( constant, OsPropertyView, template, CloudResources, SgListView ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateAttribute"

        render: ->

            if @model.isAttached()
                value = _.extend {
                    hasFloatIP: @model.getFloatingIp()
                }, @model.toJSON()
                @$el.html template.stack(value)
            else
                @$el.html template.unattached(value)

            # append sglist
            sgListView = new SgListView()
            @$el.append sgListView.render().el

            @selectTpl = sgListView.selectTpl

            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            if attr is 'float_ip'
                @model.setFloatingIp(value)
            else
                @model.set(attr, value)

            @setTitle(value) if attr is 'name'

        }, {
            handleTypes: [ constant.RESTYPE.OSPORT ]
            handleModes: [ 'stack', 'appedit' ]
        }
