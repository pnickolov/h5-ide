
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
        update: -> [ { obj: null, event: 'jsonDataSaved'} ]

      update: ( $, workspace ) ->
        save_time = jQuery.now() / 1000

        if @timer then clearInterval @timer

        @timer = setInterval ()->
          $item    = $('.stack-save-time')
          new_interval_time = MC.intervalDate save_time
          $item.text new_interval_time if $item.text() isnt new_interval_time
        , 1000

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
            require [ 'component/trustedadvisor/gui/main' ],
              ( trustedadvisor_main ) -> trustedadvisor_main.loadModule 'statusbar', null
        , 50

    }

    {
      name: 'state'
      className: 'status-bar-btn'
      visible: ( toggle, workspace ) ->
        mode = workspace.design.mode()
        appStoped = _.every [ OpsModel.State.Updating
                              OpsModel.State.Running
                              OpsModel.State.Saving ], ( state ) ->

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

  itemView =  Backbone.View.extend
    tagName: 'li'
    initialize: () ->
      _.bindAll @, 'render', 'toggle'
      # Store event will be offListen and remove method of item
      # When the statusBar will be removed
      @clearGarbage = []

      # if an item has changeVisible it's `update` method will push to needUpdate
      # and it will triggered by update method
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
        if _.isArray garbage
          garbage[1].apply garbage[0], garbage.slice(2)
        else
          garbage()

      # Disallocate
      @clearGarbage = []
      @needUpdate = []
      @

    update: () ->
      for needUpdate in @needUpdate
        needUpdate()
      @




  Backbone.View.extend

    initialize : (options)->
      _.extend this, options

      workspace = @workspace
      @itemViews = []

      @setElement @parent.$el.find(".OEPanelBottom").html template.frame()
      @renderItem()

    ready: false

    bindItem: ->
      for item, index in jQuery.extend( true, [], items ).reverse()
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
                view.clearGarbage.push [ ide_event, ide_event.offListen, e.event, wrapUpdate ]
              else
                view.listenTo e.obj or @workspace.opsModel, e.event, wrapUpdate

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


