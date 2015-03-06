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
            'change .mesos-name': 'updateAttribute'
            'change .mesos-cpus': 'updateAttribute'
            'change .mesos-mem': 'updateAttribute'
            'change .mesos-instances': 'updateAttribute'
            'change #property-res-desc': 'updateAttribute'
            'change .mesos-update-min-health-capacity': "updateAttribute"
            'change .mesos-update-max-over-capacity': "updateAttribute"
            "change .execution-command": "updateExecutionSetting"
            'change [data-name="argument"]': "updateExecutionSetting"
            "OPTION_CHANGE #property-execution-setting": "updateExecutionSetting"

        initialize: ( options ) ->

        openContainer: ()->
            @container = new Container( model: @model ).render()

        render: ()->
            data = @model.toJSON()

            #Switch Command/Arguments
            data.isCommand = data.cmd and not data.args?.length || true

            @$el.html Tpl data
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

        updateAttribute: (evt)->
          if evt
            $target = $(evt.currentTarget)

            # update data-bind attr directly
            if $target.data('bind')

              if $target.data('bind') in ["maximumOverCapacity", 'minimumHealthCapacity']
                @model.set("upgradeStrategy", @model.get('upgradeStrategy') || {})
                @model.set("upgradeStrategy." + $target.data('bind'), $target.val())

              @model.set $target.data('bind'), $target.val()


        updateExecutionSetting: ()->
          self = @
          $target = $("#property-execution-setting")
          # if is execution setting
          val = $target.find('.selection').text().toLowerCase()
          $(".selection-command, .selection-arguments").hide()
          $(".selection-" + val).show()
          if val is 'command'
            self.model.set('cmd', $('.execution-command').val())
            self.model.set('args', [])
          else
            args = []
            $(".multi-ipt-row").not(".template").find('input').each (index,input)->
              if input.value then args.push(input.value)
            self.model.set('args', args)
            self.model.set('cmd', '')

    new view()