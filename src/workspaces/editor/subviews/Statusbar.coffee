
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


      update: ( $ ) ->
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
        , 500
        #
        null
      click: ( event ) ->
        null
    }

    {
      name: 'ta'
      className: 'status-bar-btn'
      visible: ( toggle) ->
        mode = workspace.design.mode()
        # hide
        if mode in [ 'app', 'appview' ]
          isVisible = false
        else
          isVisible = true

        toggle?(isVisible)
        isVisible

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
      visible: ( toggle ) ->
        mode = workspace.design.mode()
        appStoped = workspace.opsModel.testState( OpsModel.State.Stopped )
        isVisible = false

        if mode in ['app', 'appedit']
          isVisible = not appStoped
        else if mode is 'appview'
          isVisible = false

        toggle?(isVisible)
        isVisible



      events:
        changeVisible: [ { obj: ide_event, event: ide_event.UPDATE_APP_STATE} ]
        update: [ { obj: ide_event, event: ide_event.UPDATE_STATE_STATUS_DATA} ]


      update: ( $ ) ->
        data = @renderData()
        $( '.state-success b' ).text data.successCount
        $( '.state-failed b' ).text data.failCount

      renderData: () ->
        if not @visible() then return {}

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
    render: ->
      @$el.html @template @data
      @
    toggle: (showOrHide) ->
      @$el.toggle showOrHide

    clearGarbage: []

    remove: () ->
      @$el.remove()
      @stopListening()
      for garbage in @clearGarbage
        garbage()
      @



  Backbone.View.extend

    initialize : (options)->
      #@listenTo @opsModel, 'jsonDataSaved', @updateDisableItems
      workspace = @workspace = options.workspace

    itemViews: []

    render : ()->
      @setElement @workspace.view.$el.find(".OEPanelBottom").html template.frame()
      @renderItem()
      @

    renderItem: () ->
      that = @

      for item, index in items.reverse()
        view = new itemView()
        view.delegateEvents click: item.click
        view.template = template[ item.name ]
        view.data = item.renderData?() or {}

        view.$el.addClass item.className

        for type, event of item.events
          if not _.isArray(event) then continue

          for e in event
            if type is 'update'
              wrapUpdate = _.bind item.update, item, wrap$

              if e.obj is ide_event
                ide_event.onLongListen e.event, wrapUpdate
                view.clearGarbage.push -> ide_event.offListen e.event, wrapUpdate
              else
                wrap$ = _.bind view.$, view
                view.listenTo e.obj, e.event, wrapUpdate
            else if type is 'changeVisible'
                wrapToggle = _.bind view.toggle, view
                wrapVisible = _.bind item.visible, item, wrapToggle

              if e.obj is ide_event
                ide_event.onLongListen e.event, wrapVisible
                view.clearGarbage.push -> ide_event.offListen e.event, wrapVisible
              else
                view.listenTo e.obj, e.event, wrapVisible


          window.tmpView = view
          window.ide_event = ide_event

        if _.isFunction item.visible
          item.visible view.toggle
        else
          view.toggle item.visible

        @itemViews.push view

        null


        @$('ul').append view.render().el
        @

      remove: () ->
        @$el.remove()
        @stopListening()
        for view in @itemViews
          view.remove()
        @


