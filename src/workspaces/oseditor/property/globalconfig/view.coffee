define [
    'constant'
    '../OsPropertyView'
    './stack'
    './app'
    '../ossglist/view'
], ( constant, OsPropertyView, TplStack, TplApp, SgListView ) ->

    OsPropertyView.extend {

        events:
            'change [data-target]': 'updateAttribute'

        initialize: ->
            @sgListView = @reg new SgListView targetModel: null

        render: ->
            template = switch
                when @mode() is 'app' then TplApp
                else TplStack

            @$el.html template @getRenderData()
            @$el.append @sgListView.render().el
            @

        mode: ->
            mod = Design.instance().mode()
            mod

        getTitle: ->
            if @mode() in [ 'app', 'appedit' ]
                'App Property'
            else
                'Stack Property'

    }, {
        handleTypes: [ 'globalconfig' ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }
