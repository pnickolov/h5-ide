
define [
  "OpsModel"
  "Design"
  "../template/TplStatusbar"
  "constant"
  "backbone"
  "event"

  "state_status"
], ( OpsModel, Design, template, constant, Backbone, ide_event, stateStatus )->

# Just define item below and import need file above
# name used for template, the template you put in TplStatusBar file
# visible can be a boolean or a function
# updateEvent is an array [context, event] or a function return the array
# update is triggerd by updateEvent

  items = [
    {
      name: 'lastSaved'
      className: 'info'
      visible: true
      events:
        update: -> [ { obj: workspace.opsModel, event: 'jsonDataSaved'} ]

      update: ( $, workspace ) ->
        # 1.set current time
        save_time = jQuery.now() / 1000

        # 2.clear interval
        clearInterval @timer

        # 3.set textTime
        $item    = $('.stack-save-time')
        $item.text MC.intervalDate save_time
        $item.attr 'data-save-time', save_time

        # 4.loop
        @timer = setInterval ()->
          $item    = $('.stack-save-time')
          $item.text MC.intervalDate $item.attr 'data-save-time'
        , 1000
        #
        null
      click: ( event ) ->
        null

      remove: -> clearInterval @timer
    }

    {
      name: 'ta'
      className: 'status-bar-btn'
      visible: ( toggle, workspace ) ->
        mode = workspace.design.mode()
        # hide
        if mode in [ 'app', 'appview' ]
          isVisible = false
        else
          isVisible = true

        toggle?(isVisible)
        isVisible

      changeVisible: true

      click: ( event ) ->
        btnDom = $(event.currentTarget)
        currentText = 'Validate'
        btnDom.text('Validating...')

        setTimeout () ->
            MC.ta.validAll()
            btnDom.text(currentText)
            require [ 'component/trustedadvisor/main' ], ( trustedadvisor_main ) -> trustedadvisor_main.loadModule 'statusbar', null
        , 50

    }

    {
      name: 'state'
      className: 'status-bar-btn'
      visible: ( toggle, workspace ) ->
        mode = workspace.design.mode()
        appStoped = _.every [ OpsModel.State.Updating, OpsModel.State.Running, OpsModel.State.Saving ], ( state ) ->
          not workspace.opsModel.testState( state )

        isVisible = false

        if mode in ['app', 'appedit']
          isVisible = not appStoped
        else if mode is 'appview'
          isVisible = false

        toggle?(isVisible)
        isVisible

      events:
        update: [ { obj: ide_event, event: ide_event.UPDATE_STATE_STATUS_DATA} ]

      changeVisible: true


      update: ( $, workspace ) ->
        data = @renderData true, workspace
        $( '.state-success b' ).text data.successCount
        $( '.state-failed b' ).text data.failCount

      renderData: ( visible, @workspace ) ->
        if not visible then return {}

        stateList = App.WS.collection.status.find().fetch()
        succeed = failed = 0

        if not _.isArray stateList
            stateList = [ stateList ]

        for state in stateList
            # Show current app only
            if state.app_id isnt workspace.opsModel.get 'id'
                continue
            if state.status
                for status in state.status
                    if status.result is 'success'
                        succeed++
                    else if status.result is 'failure'
                        failed++

        successCount: succeed
        failCount: failed

      click: ( event ) ->
        stateStatus.loadModule()

    }

  ]


# Function Inside  #
# Don't care #

  workspace = null

  itemView =  Backbone.View.extend
    tagName: 'li'
    initialize: () ->
      _.bindAll @, 'render', 'toggle'
      @clearGarbage = []
      @needUpdate = []

    render: ->
      @$el.html @template @data
      @
    toggle: (showOrHide) ->
      @$el.toggle showOrHide

    remove: () ->
      @$el.remove()
      @stopListening()
      for garbage in @clearGarbage
        garbage()
      @

    update: () ->
      for needUpdate in @needUpdate
        needUpdate()
      @




  Backbone.View.extend

    initialize : (options)->
      workspace = @workspace = options.workspace
      @itemViews = []
      null

    ready: false

    render : ()->
      @setElement @workspace.view.$el.find(".OEPanelBottom").html template.frame()
      @renderItem()
      @

    bindItem: ->
      for item, index in _.clone(items).reverse()
        view = new itemView()
        view.delegateEvents click: item.click
        view.template = template[ item.name ]

        view.$el.addClass item.className

        wrap$ = _.bind view.$, view
        wrapToggle = _.bind view.toggle, view

        wrapVisible = _.bind item.visible, item, wrapToggle, @workspace if _.isFunction item.visible
        wrapUpdate = _.bind item.update, item, wrap$, @workspace if _.isFunction item.update

        for type, event of item.events
          event = event() if _.isFunction event
          continue if not _.isArray(event)

          for e in event
            if type is 'update'
              if e.obj is ide_event
                ide_event.onLongListen e.event, wrapUpdate
                view.clearGarbage.push -> ide_event.offListen e.event, wrapUpdate
              else
                view.listenTo e.obj, e.event, wrapUpdate


        if item.changeVisible
          view.needUpdate.push wrapVisible if item.visible
          view.needUpdate.push wrapUpdate if item.update

        if _.isFunction item.visible
          isVisible = item.visible view.toggle, @workspace
        else
          view.toggle item.visible
          isVisible = item.visible

        view.data = item.renderData?( isVisible, @workspace ) or {}

        view.clearGarbage.push _.bind item.remove, item if item.remove

        @itemViews.push view

      null

    renderItem: () ->
      that = @

      if not @ready
        @bindItem()
        @ready = true

      for view in @itemViews
        @$('ul').append view.render().el

      @

    update: ->
      for view in @itemViews
        view.update()

    remove: () ->
      @$el.remove()
      @stopListening()
      for view in @itemViews
        view.remove()
      @


