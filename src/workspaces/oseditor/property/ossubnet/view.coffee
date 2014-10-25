define [
  'constant'
  '../OsPropertyView'
  './template'
], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]" : "updateAttribute"
            "select_dropdown_button_click .item-list": "addItem"
            "click .item-list .item .item-remove": "removeItemClicked"
            "select_item_remove .item-list": "removeItem"

        initialize: () ->

            # that = @

            @selectTpl =

                button: () ->
                    return template.addButton()

                sgItem: (item) ->
                    template.item({
                        value: item.text
                    })

                sgOption: (item) ->
                    template.option({
                        value: item.text
                    })

        render: ->

            if @mode() in ['stack', 'appedit']
                json = @model.toJSON()

                # add name servers list
                nameServerList = []
                nameServers = []
                _.each @model.get('nameservers'), (value) ->
                    nameServers.push(value)
                    nameServerList.push(value)
                nameServerList = nameServerList.join(',')
                json = _.extend(json, {
                    nameServerList: nameServerList,
                    nameServers: nameServers
                })

                # if @mode() is 'appedit'
                json = _.extend(json, @getRenderData())
                @$el.html template.stack(json)
            else
                @$el.html template.app @getRenderData()
            @

        addItem: (event, value) ->
            @model.get('nameservers').push(value) if $.trim(value)
            @render()

        removeItemClicked: (event) ->
            $target = $(event.currentTarget)
            value = $target.parents('.item').find('.item-name').attr('data-value')
            idx = @model.get('nameservers').indexOf(value)
            @model.get('nameservers').splice(idx, 1) if idx > -1
            @render()

        removeItem: (event, value) ->
            idx = @model.get('nameservers').indexOf(value)
            @model.get('nameservers').splice(idx, 1) if idx > -1

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            @model.set(attr, value)
            if attr is 'cidr'
                @model.resetAllChildIP()

            @setTitle(value) if attr is 'name'

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }
