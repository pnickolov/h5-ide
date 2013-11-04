#############################
#  View(UI logic) for design
#############################

define [ 'event', 'text!./module/design/template.html', 'backbone', 'jquery', 'handlebars' ], ( ide_event, template ) ->

    DesignView = Backbone.View.extend {

        el          : '#tab-content-design'

        events      :
            'click .btn-ta-valid' : 'statusbarClick'

        render   : () ->
            console.log 'design render'
            #render
            this.$el.html template
            #push DESIGN_COMPLETE
            this.trigger 'DESIGN_COMPLETE'
            #
            $( '#statusbar-panel' ).html MC.template.statusbar()

        listen   : ( model ) ->
            #set this.model
            this.model = model
            #listen model
            this.listenTo this.model, 'change:snapshot', this.writeOldDesignHtml

        html : ->
            data =
                resource : $( '#resource-panel' ).html()
                property : $( '#property-panel' ).html()
                canvas   : $( '#canvas-panel'   ).html()
                statusbar: $( '#statusbar-panel' ).html()
            data

        writeOldDesignHtml : ( event ) ->
            console.log 'writeOldDesignHtml'
            return if _.isNumber event.attributes.snapshot
            #
            $( '#canvas-panel' ).one( 'DOMNodeInserted', '.canvas-svg-group', this, _.debounce( this.canvasChange, 200, true ))
            #
            $( '#resource-panel' ).html this.model.get( 'snapshot' ).resource
            $( '#canvas-panel'   ).html this.model.get( 'snapshot' ).canvas
            $( '#statusbar-panel' ).html this.model.get( 'snapshot' ).statusbar
            ###
            this.$el.empty().html this.model.get 'snapshot'
            $( '#property-panel' ).html this.model.get( 'snapshot' ).property
            $( '#property-panel' ).empty()
            ###
            null

        canvasChange : ( event ) ->
            console.log 'canvas:listen DOMNodeInserted'
            console.log MC.data.current_tab_type
            if MC.data.current_tab_type is 'OLD_APP' or MC.data.current_tab_type is 'OLD_STACK'
                ide_event.trigger ide_event.SWITCH_WAITING_BAR
                MC.data.current_tab_type = null
            null

        statusbarClick : ( event ) ->
            console.log 'statusbarClick'
            btnDom = $(event.currentTarget)
            currentText = btnDom.text()
            btnDom.text('Verifying...')
            #
            MC.ta.validAll()
            #
            btnDom.text(currentText)
            status = _.last $(event.currentTarget).attr( 'class' ).split '-'
            require [ 'component/trustedadvisor/main' ], ( trustedadvisor_main ) -> trustedadvisor_main.loadModule 'statusbar', status

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
    }

    return DesignView
