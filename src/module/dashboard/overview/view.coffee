#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    current_region = null

    OverviewView = Backbone.View.extend {

        el              : $( '#tab-content-dashboard' )

        #template : Handlebars.compile $( '#overview-tmpl' ).html()

        overview_result: Handlebars.compile $( '#overview-result-tmpl' ).html()
        global_list: Handlebars.compile $( '#global-list-tmpl' ).html()
        region_app_stack: Handlebars.compile $( '#region-app-stack-tmpl' ).html()
        region_resource: Handlebars.compile $( '#region-resource-tmpl' ).html()
        recent: Handlebars.compile $( '#recent-tmpl' ).html()
        recent_launched_app : Handlebars.compile $( '#recent-launched-app-tmpl' ).html()
        recent_stopped_app : Handlebars.compile $( '#recent-stopped-app-tmpl' ).html()
        loading: Handlebars.compile $( '#loading-tmpl' ).html()

        events   :
            'click #global-region-spot > li'            : 'mapRegionClick'
            'click #global-region-create-stack-list li' : 'createStackClick'
            'click .global-region-status-content li a'  : 'openItem'
            'click .global-region-status-tab-item'      : 'switchRecent'
            'click #region-switch-list li'              : 'switchRegion'
            'click #region-resource-tab a'              : 'switchAppStack'
            'click #region-aws-resource-tab a'          : 'switchRegionResource'

            'click .region-resource-thumbnail'          : 'clickRegionResourceThumbnail'


        showLoading: ( selector ) ->
            @$el.find( selector ).html @loading

        switchRegion: ( event ) ->
            target = $ event.currentTarget
            region = target.data 'region'
            regionName = target.find('a').text()

            if regionName is @$el.find( '#region-switch span' ).text()
                return

            @$el.find( '#region-switch span' )
                .text(regionName)
                .data 'region', region

            if region is 'global'
                @$el.find( '#global-region-resource-data-wrap' ).show()
                @$el.find( '#region-view' ).hide()
            else
                @showLoading('#region-resource-wrap')
                @$el.find( '#global-region-resource-data-wrap' ).hide()
                @$el.find( '#region-view' ).show()
                @trigger 'SWITCH_REGION', region
                @renderRegionAppStack()


        switchRecent: ( event ) ->
            target = $ event.currentTarget
            id = target.attr 'id'

            tabContentMap =
                'global-region-status-tab-app': 'global-region-status-app-content'
                'global-region-status-tab-stack': 'global-region-status-stack-content'

            if not target.hasClass 'on'
                _.each tabContentMap, ( cid, tid ) =>
                    if tid is id
                        @$el.find( "##{cid}" ).show()
                        target.addClass 'on'
                    else
                        @$el.find( "##{cid}" )
                            .hide()
                            .end()
                            .find( "##{tid}" )
                            .removeClass 'on'

        switchAppStack: ( event ) ->
            target = $ event.currentTarget
            currentIndex = @$el.find('#region-resource-tab a').index target

            @switchTab event, '#region-resource-tab a', '.region-resource-list'
            ###
            if target.hasClass 'on'
                @$el.find( '#region-resource-tab a' )
                    .eq( 1 - currentIndex )
                    .addClass( 'on' )
                    .end()
                    .eq( currentIndex )
                    .removeClass( 'on' )

                @$el.find( '.region-resource-list')
                    .eq( 1 - currentIndex )
                    .hide()
                    .end()
                    .eq( currentIndex )
                    .show()
            ###

        switchRegionResource: ( event ) ->
            @switchTab event, '#region-aws-resource-tab a', '#region-aws-resource-data div.table-head-fix'


        # switch tab helper
        switchTab: ( event, tabSelector, listSelector ) ->
            tabSelector =  if tabSelector instanceof $ then tabSelector else $( tabSelector )
            listSelector =  if listSelector instanceof $ then listSelector else $( listSelector )

            target = $ event.currentTarget
            currentIndex = @$el.find(tabSelector).index target

            if not target.hasClass 'on'
                tabSelector.each ( index ) ->
                    if index is currentIndex
                        $( @ ).addClass( 'on' )
                    else
                        $( @ ).removeClass( 'on' )

                listSelector.each ( index ) ->
                    if index is currentIndex
                        $( @ ).show()
                    else
                        $( @ ).hide()
            null

        renderGlobalList: ( event ) ->
            tmpl = @global_list @model.toJSON()
            $( this.el ).find('#global-view').html tmpl

        renderRegionAppStack: ( event ) ->
            @regionAppStackRendered = true
            tmpl = @region_app_stack @model.toJSON()
            $( this.el ).find('#region-app-stack-wrap').html tmpl

        renderRegionResource: ( event ) ->
            tmpl = @region_resource @model.toJSON()
            $( this.el ).find('#region-resource-wrap').html tmpl


        renderRegionStatApp : ->
            null

        renderRegionStatStack : () ->
            null




        renderMapResult : ->
            console.log 'dashboard overview-result render'

            cur_tmpl = (this.overview_result this.model.attributes)

            $( this.el ).find('#global-region-spot').html cur_tmpl

            null


        renderRecent: ->
            $( this.el ).find( '#global-region-status-widget' ).html this.recent this.model.attributes
            null

        renderRecentLaunchedApp : ->
            console.log 'dashboard recent launched app render'
            $( this.el ).find( '#recent-launched-app' ).html this.recent_launched_app this.model.attributes
            null

        renderRecentStoppedApp : ->
            console.log 'dashboard recent stopped app render'
            $( this.el ).find( '#recent-stopped-app' ).html this.recent_stopped_app this.model.attributes
            null

        mapRegionClick : ( event ) ->
            region = event.currentTarget.id
            current_region = region

            $( "#region-switch-list li[data-region=#{region}]" ).click()
            scrollbar.scrollTo( $( '#global-region-wrap' ), { 'top': $('#global-region-tabbar-wrap')[0].offsetTop - 80 } )
            false
            #this.trigger 'RETURN_REGION_TAB', region


        createStackClick : ( event ) ->
            console.log 'dashboard region create stack'
            ide_event.trigger ide_event.ADD_STACK_TAB, ($(event.currentTarget).data 'region')

        render : ( template ) ->
            console.log 'dashboard overview render'
            $( this.el ).html template

        openItem : (event) ->
            console.log 'click item'

            me = this
            id = event.currentTarget.id

            if id.indexOf('app-') == 0
                ide_event.trigger ide_event.OPEN_APP_TAB, $("#"+id).data('option').name, $("#"+id).data('option').region, id
            else if id.indexOf('stack-') == 0
                ide_event.trigger ide_event.OPEN_STACK_TAB, $("#"+id).data('option').name, $("#"+id).data('option').region, id

            null

        clickRegionResourceThumbnail : (event) ->
            console.log 'click app/stack thumbnail'

            me = this

            item_info   = $(event.currentTarget).next('.region-resource-info')[0]
            id          = $(item_info).find('.modal')[0].id
            name        = $($(item_info).find('.region-resource-item-name')[0]).text()

            ##check params:region, id, name

            if id.indexOf('app-') is 0
                ide_event.trigger ide_event.OPEN_APP_TAB, name, current_region, id

            else
                ide_event.trigger ide_event.OPEN_STACK_TAB, name, current_region, id

            null

    }

    return OverviewView
