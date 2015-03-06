define ['../base/view'
        './container'
        './template/stack'
        'i18n!/nls/lang.js'
        'constant'
        'UI.modalplus'
], (PropertyView, Container, Tpl, lang, constant) ->
  view = PropertyView.extend

    events:
      'click .open-container'                    : 'openContainer'
      'click #mesos-add-health-check'            : 'addHealthCheck'
      'click .mesos-health-check-item-remove'    : 'removeHealthCheck'
      'change .mesos-name'                       : 'updateAttribute'
      'change .mesos-cpus'                       : 'updateAttribute'
      'change .mesos-mem'                        : 'updateAttribute'
      'change .mesos-instances'                  : 'updateAttribute'
      'change #property-res-desc'                : 'updateAttribute'
      'change .mesos-update-min-health-capacity' : "updateAttribute"
      'change .mesos-update-max-over-capacity'   : "updateAttribute"
      "change .execution-command"                : "updateExecutionSetting"
      'change [data-name="argument"]'            : "updateExecutionSetting"
      "OPTION_CHANGE #property-execution-setting": "updateExecutionSetting"
      "change #mesos-health-checks-list li input.input": "updateHealthCheck"
      "OPTION_CHANGE .mesos-health-check-protocol":      "updateHealthCheck"
      "change .mesos-constraints input"          : "updateConstraints"
      "change .mesos-constraints select"         : "updateConstraints"

    initialize   : (options) ->

    openContainer: ()->
      @container = new Container(model: @model).render()

    render: ()->
      data = @model.toJSON()

      #Switch Command/Arguments
      data.isCommand = data.cmd and not data.args?.length || true

      @$el.html Tpl data
      @model.get 'name'

    addHealthCheck: ()->
      $healthList = @$el.find("#mesos-health-checks-list")
      $newHealthCheck = $healthList.find("li.template").eq(0).clone().show()
      $newHealthCheck.find('.mesos-health-check-protocol .selection').text('HTTP')
      .end().find('.mesos-health-check-path').val("").show()
      .end().find('.mesos-health-check-port-index').val("0").show()
      .end().find(".health-check-command").val("").hide()
      .end().find('.mesos-health-check-grace-period').val("300")
      .end().find('.mesos-health-check-interval').val("60")
      .end().find('.mesos-health-check-timeout').val("20")
      .end().find('mesos-health-check-max-fail').val("0")
      .end().appendTo $healthList
      @updateHealthCheck()

    removeHealthCheck: (evt)->
      $(evt.currentTarget).parents('li').remove()
      @updateHealthCheck()

    updateAttribute: (evt)->
      if evt
        $target = $(evt.currentTarget)
        # update data-bind attr directly
        if $target.data('bind')

          if $target.data('bind') in ["maximumOverCapacity", 'minimumHealthCapacity']
            upgradeStrategyData = @model.get("upgradeStrategy") || {}
            upgradeStrategyData[$target.data('bind')] = $target.val()
            @model.set("upgradeStrategy", upgradeStrategyData)
          else
            @model.set $target.data('bind'), $target.val()

    updateConstraints: ()->
      constraints = []
      @$el.find(".mesos-constraints .multi-ipt-row").each (index, row)->
        attribute = $(row).find(".mesos-constraints-attribute").val()
        operator = $(row).find(".mesos-constraints-operator").val()
        value  = $(row).find(".mesos-constraints-value").val()
        if attribute isnt "" or value isnt ""
          constraints.push [attribute, operator, value]

    updateHealthCheck     : (evt)->
      if evt then $target = $(evt.currentTarget)
      if $target?.hasClass('mesos-health-check-protocol')
        $scope = $target.parents('li')
        protocol = $scope.find(".mesos-health-check-protocol").find('.selection').text()
        if  protocol is 'HTTP'
          $scope.find(".health-check-option").show()
          $scope.find(".health-check-command").hide()
        else if protocol is 'TCP'
          $scope.find(".health-check-option").hide()
          $scope.find(".health-check-port-index").show()
        else
          $scope.find(".health-check-option").hide()
          $scope.find(".health-check-command").show()

      healthChecks = []

      @$el.find("#mesos-health-checks-list>li").not(".template").each (index, li)->
        $li = $ li
        protocol = $li.find('.mesos-health-check-protocol .selection').text()
        path = $li.find('.mesos-health-check-path').val()
        portIndex = $li.find(".mesos-health-check-port-index").val()
        gracePeriodSeconds = $li.find(".mesos-health-check-grace-period").val()
        intervalSeconds = $li.find(".mesos-health-check-interval").val()
        timeoutSeconds = $li.find(".mesos-health-check-timeout").val()
        maxConsecutiveFailures = $li.find(".mesos-health-check-max-fail").val()
        command = {value: $li.find(".mesos-health-check-command").val()}
        healthCheck = {
          protocol, path, portIndex, gracePeriodSeconds, intervalSeconds, timeoutSeconds, maxConsecutiveFailures, command
        }

        if protocol is 'HTTP'
          delete healthCheck.command
        if protocol is 'TCP'
          delete healthCheck.command
          delete healthCheck.path
        if protocol is 'COMMAND'
          delete healthCheck.path
          delete healthCheck.portIndex

        healthChecks.push healthCheck

      @model.set 'healthChecks', healthChecks

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
        $(".multi-ipt-row").not(".template").find('input').each (index, input)->
          if input.value then args.push(input.value)
        self.model.set('args', args)
        self.model.set('cmd', '')

  new view()