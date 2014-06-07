
define [
  "Design"
  "../template/TplStatusBar"
  "constant"
  "backbone"
], ( Design, template, constant )->


  items = [
    {
      name: 'lastSaved'
      visible: true
      updateEvent: (workspace) -> [ workspace.opsModel, 'jsonDataSaved' ]
      update: ( $ ) ->
        # 1.set current time
        save_time = $.now() / 1000

        # 2.clear interval
        clearInterval @timer

        # 3.set textTime
        $item    = $('.stack-save-time')
        $item.text MC.intervalDate save_time
        $item.attr 'data-tab-id',    MC.data.current_tab_id
        $item.attr 'data-save-time', save_time

        # 4.loop
        @timer = setInterval ( ->

            $item    = $('.stack-save-time')
            if $item.attr( 'data-tab-id' ) is MC.data.current_tab_id
                $item.text MC.intervalDate $item.attr 'data-save-time'

        ), 500
        #
        null
      click: ( event ) ->

    }
    {
      name: 'ta'
      visible: true
      update: ( $ ) ->
    }

  ]

  itemView =  Backbone.View.extend
    render: ->
      @$el.html @template()
      @
    toggle: (showOrHide) ->
      @$el.toggle showOrHide



  Backbone.View.extend

    initialize : (options)->
      #@listenTo @opsModel, 'jsonDataSaved', @updateDisableItems
      @workspace = options.workspace
      @opsModel = @workspace.opsModel




    render : ()->
      @$el.html template.frame()
      @renderItem()
      $( '#OEPanelBottom' ).html @el
      @

    renderItem: () ->
      for item, index in items
        view = new itemView()
        view.delegateEvents click: item.click
        view.template = template[ item.name ]

        if _.isArray view.updateEvent
          updateEvent = view.updateEvent
        else if _.isFunction view.updateEvent
          updateEvent = view.updateEvent @workspace

        if updateEvent
          view.listenTo updateEvent[ 0 ], updateEvent[ 1 ], item.update

        if _.isFunction item.visible
          item.visible(view.toggle)
        else
          view.toggle item.visible

        null


        @$el.append view.render().el
        @

    updateStatusBarSaveTime : () ->
      console.log 'updateStatusBarSaveTime'

      # 1.set current time
      save_time = $.now() / 1000

      # 2.clear interval
      clearInterval @timer

      # 3.set textTime
      $item    = $('.stack-save-time')
      $item.text MC.intervalDate save_time
      $item.attr 'data-tab-id',    MC.data.current_tab_id
      $item.attr 'data-save-time', save_time

      # 4.loop
      @timer = setInterval ( ->

          $item    = $('.stack-save-time')
          if $item.attr( 'data-tab-id' ) is MC.data.current_tab_id
              $item.text MC.intervalDate $item.attr 'data-save-time'

      ), 500
      #
      null

    statusBarTAClick : ( event ) ->
          console.log 'statusbarTAClick'
          btnDom = $(event.currentTarget)
          currentText = 'Validate'
          btnDom.text('Validating...')

          setTimeout () ->
              MC.ta.validAll()
              btnDom.text(currentText)
              #status = _.last $(event.currentTarget).attr( 'class' ).split '-'
              require [ 'component/trustedadvisor/main' ], ( trustedadvisor_main ) -> trustedadvisor_main.loadModule 'statusbar', null
          , 50

    statusBarClick : ( event ) ->
        stateStatusMain.loadModule()

    updateStatusbar : ( type, level ) ->
        console.log 'updateStatusbar, level = ' + level + ', type = ' + type
        #
        # $new_status = $( '.icon-statusbar-' + level.toLowerCase() )
        # outerHTML   = $new_status.get( 0 ).outerHTML
        # count       = $new_status.parent().html().replace( outerHTML, '' )
        # if type is 'add'
        #     count   = parseInt( count, 10 ) + 1
        # else if type is 'delete'
        #     count   = parseInt( count, 10 ) - 1
        # #
        # $new_status.parent().html outerHTML + count
        #
        ide_event.trigger ide_event.UPDATE_TA_MODAL
        null

    renderStateBar: ( stateList ) ->
        succeed = failed = 0

        if not _.isArray stateList
            stateList = [ stateList ]

        for state in stateList
            # Show current app only
            if state.app_id isnt MC.common.other.canvasData.data( 'origin' ).id
                continue
            if state.status
                for status in state.status
                    if status.result is 'success'
                        succeed++
                    else if status.result is 'failure'
                        failed++

        $stateBar = $ '.statusbar-btn'
        $stateBar
            .find( '.state-success b' )
            .text succeed

        $stateBar
            .find( '.state-failed b' )
            .text failed

    loadStateStatusBar: ( state ) ->
        # Sub Event
        ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA, @updateStateBar
        ide_event.onLongListen ide_event.UPDATE_STATE_STATUS_DATA, @updateStateBar, @

        ide_event.offListen ide_event.UPDATE_APP_STATE, @updateStateBarWhenStateChanged
        ide_event.onLongListen ide_event.UPDATE_APP_STATE, @updateStateBarWhenStateChanged, @

        appStoped = ( state or MC.canvas_data.state ) is 'Stopped'
        #appStoped = MC.common.other.canvasData.data( 'origin' ).state is 'Stopped'

        $btnState = $( '#main-statusbar .btn-state' )

        if Tabbar.current in ['app', 'appedit']
            if appStoped
                $btnState.hide()

        if appStoped
            return

        if Tabbar.current is 'appview'
            $btnState.hide()
        else
            $btnState.show()

        stateList = App.WS.collection.status.find().fetch()
        @renderStateBar stateList


    updateStateBarWhenStateChanged: ( state ) ->
        if state is 'Stopped'
            stateList = []
            @unloadStateStatusBar()
        else if state is 'Running'
            @loadStateStatusBar( state )
            stateList = App.WS.collection.status.find().fetch()
            @renderStateBar stateList


    updateStateBar: ( type, idx, statusData ) ->
        stateList = App.WS.collection.status.find().fetch()
        @renderStateBar stateList


    unloadStateStatusBar: ->
        $( '#main-statusbar .btn-state' ).hide()
        ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA

    hideStatusbar :  ->
        console.log 'hideStatusbar'

        # hide
        if Tabbar.current in [ 'app', 'appview' ]
            $( '#main-statusbar .btn-ta-valid' ).hide()
            @loadStateStatusBar()


        else if ( Tabbar.current is 'appedit' )
            $( '#main-statusbar .btn-ta-valid' ).show()
            @loadStateStatusBar()
        # show
        else

            $( '#main-statusbar .btn-ta-valid' ).show()
            @unloadStateStatusBar()

        if Tabbar.current is 'appedit'
            $( '#canvas' ).css 'bottom', 24


        null

