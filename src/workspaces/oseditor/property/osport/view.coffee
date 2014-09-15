define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    '../ossglist/view'
    '../ossg/view'
], ( constant, OsPropertyView, template, CloudResources, SgListView, SgView ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateAttribute"

        render: ->

            if @model.owner()
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

            sgView = new SgView()
            @$el.append sgView.render().el

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
