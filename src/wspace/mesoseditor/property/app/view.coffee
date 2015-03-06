define [ '../base/view'
         './container'
         './template/stack'
         'i18n!/nls/lang.js'
         'constant'
         'UI.modalplus'
], ( PropertyView, Container, Tpl, lang, constant ) ->

    view = PropertyView.extend

        events:
            'click .open-container': 'openContainer'
            'click #mesos-add-health-check': 'addHealthCheck'
            'click .mesos-health-check-item-remove': 'removeHealthCheck'

        initialize: ( options ) ->

        openContainer: ()->
            @container = new Container( model: @model ).render()

        render: ()->
            @model.set('healthChecks', [{path: "/path/to/healthcheck", protocol: "HTTP"}])
            @$el.html Tpl @model.toJSON()
            console.log @model.toJSON()
            @model.get 'name'

        addHealthCheck: ()->
            $healthList = @$el.find("#mesos-health-checks-list")
            $newHealthCheck = $healthList.find("li").eq(0).clone()
            $newHealthCheck.find('.mesos-health-check-protocol .selection').text('HTTP')
            .end().find('.mesos-health-check-path').text("")
            .end().find('.mesos-health-check-port-index').text("0")
            .end().find('.mesos-health-check-grace-period').text("")
            .end().find('.mesos-health-check-interval').text("60")
            .end().find('.mesos-health-check-timeout').text("20")
            .end().find('mesos-health-check-max-fail').text("0")
            .end().appendTo $healthList

        removeHealthCheck: (evt)->
            $(evt.currentTarget).parents('li').remove()
            @updateAttribute()

        updateAttribute: ()->


    new view()