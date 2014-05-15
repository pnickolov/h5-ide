####################################
#  Controller for dashboard module
####################################

define [ "component/exporter/Thumbnail", 'jquery', 'event', 'MC', 'base_main', 'vpc_model' ], ( ThumbUtil, $, ide_event, MC, base_main, vpc_model ) ->

    current_region = null
    overview_app    = null
    overview_stack  = null
    should_update_overview = false

    #private
    initialize = ->
        #extend parent
        _.extend this, base_main

    accountIsDemo = -> !App.user.hasCredential()


    initialize()

    # private
    loadModule = () ->

        #set MC.data.dashboard_type default
        MC.data.dashboard_type = 'OVERVIEW_TAB'
        #load remote ./module/dashboard/overview/view.js
        require [ 'dashboard_view', 'dashboard_model', 'constant', 'UI.tooltip' ], ( View, model, constant ) ->
            region_view = null
            #view
            #view       = new View()

            view = loadSuperModule loadModule, 'dashboard', View, null
            return if !view

            view.model = model

            #push DASHBOARD_COMPLETE
            ide_event.trigger ide_event.DASHBOARD_COMPLETE

            model.on 'change:result_list', () ->
                console.log 'dashboard_change:result_list'
                should_update_overview = true
                #refresh view
                view.renderMapResult()
                view.renderRecent()

            model.on 'change:region_classic_list', () ->
                console.log 'dashboard_region_classic_list'
                #set MC.data.supported_platforms
                MC.data.supported_platforms = model.get 'region_classic_list'
                #refresh view
                if MC.data.supported_platforms.length <= 0
                else
                    MC.data.is_loading_complete = true
                    ide_event.trigger ide_event.IDE_AVAILABLE


            model.on 'change:recent_edited_stacks', () ->
                console.log 'dashboard_change:recent_eidted_stacks'
                #model.get 'recent_edited_stacks'
                view.renderRecent()

            model.on 'change:recent_launched_apps', () ->
                console.log 'dashboard_change:recent_launched_apps'
                #model.get 'recent_launched_apps'
                view.renderRecent()

            # global view
            model.on 'change:global_list', () ->
                view.renderGlobalList()

            # region view
            model.on 'change:cur_region_resource', () ->
                view.renderRegionResource()

            ide_event.onLongListen ide_event.SWITCH_MAIN, () ->
                if MC.data.supported_platforms and MC.data.supported_platforms.length
                    model.set 'supported_platforms', true
                    view.enableCreateStack()

            # update aws credential
            ide_event.onLongListen ide_event.UPDATE_AWS_CREDENTIAL, () ->
                if accountIsDemo() #demo case
                    view.enableSwitchRegion()
                    ide_event.trigger ide_event.ACCOUNT_DEMONSTRATE
                    view.hideLoadTime()
                    $( '#global-region-visualize-VPC' ).addClass 'disabled'
                    $( '#global-region-visualize-VPC' ).attr 'disabled', true
                else # normal case
                    view.clearDemo()
                    view.enableSwitchRegion()
                    view.reloadResource( null, true ) if view  #skip_load=true, only show loading progress
                    view.displayLoadTime()
                    $( '#global-region-visualize-VPC' ).removeClass 'disabled'
                    $( '#global-region-visualize-VPC' ).removeAttr  'disabled'

                #reset config data after chagne credential
                MC.data.config = {}
                MC.data.config[r] = {} for r in constant.REGION_KEYS

                # init unmanaged_resource_list
                MC.common.other.initUnmanaged()
                null

            ide_event.onLongListen ide_event.ACCOUNT_DEMONSTRATE, () ->
                view.setDemo()
                view.renderGlobalDemo()
                view.renderRegionDemo()


            vpc_model.on 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->
                model.accountReturnHandler()

                if !result.is_error
                    view.enableSwitchRegion()
                    if accountIsDemo()
                        ide_event.trigger ide_event.ACCOUNT_DEMONSTRATE
                        view.hideLoadTime()
                    else
                        view.displayLoadTime()
                else
                    view.hideLoadTime()

            ide_event.onLongListen ide_event.UPDATE_DASHBOARD, () ->
                console.log 'UPDATE_DASHBOARD'
                view.reloadResource( null,false ) if view  #skip_load=false, do loading resource

            #model
            model.describeAccountAttributesService()


            ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->
                overview_app = result
                #model.describeAWSResourcesService()

                model.updateMap model, overview_app, overview_stack
                model.updateRecentList( model, result, 'recent_launched_apps' )
                view.renderMapResult()
                model.getItemList 'app', current_region, overview_app
                null

            ide_event.onLongListen 'RESULT_STACK_LIST', ( result ) ->
                console.log 'overview RESULT_STACK_LIST'

                overview_stack = result

                model.updateMap model, overview_app, overview_stack
                model.updateRecentList( model, result, 'recent_edited_stacks' )
                view.renderMapResult()

                model.getItemList 'stack', current_region, overview_stack
                null

            ide_event.onLongListen ide_event.NAVIGATION_TO_DASHBOARD_REGION, ( result ) ->
                console.log 'NAVIGATION_TO_DASHBOARD_REGION'
                if result is 'global'
                    ide_event.trigger ide_event.RETURN_OVERVIEW_TAB
                #else
                #    view.trigger 'RETURN_REGION_TAB', result
                null

            # switch region tab
            view.on 'SWITCH_REGION', ( region, fakeSwitch ) ->
                current_region = region
                model.loadResource region
                #model.describeAWSStatusService region
                if not fakeSwitch
                    @model.getItemList 'app', region, overview_app
                    @model.getItemList 'stack', region, overview_stack

            # reload resource
            view.on 'RELOAD_RESOURCE', ( region ) ->
                console.log 'dashboard:RELOAD_RESOURCE'

                view.displayLoadTime()
                model.describeAWSResourcesService region

                # update stack and app
                ide_event.trigger ide_event.UPDATE_STACK_LIST
                ide_event.trigger ide_event.UPDATE_APP_LIST

                # clear cache
                MC.common.other.initUnmanaged()

                null

            model.on 'change:cur_app_list', () ->
                view.renderRegionAppStack( 'app' )

            ide_event.onLongListen ide_event.UPDATE_APP_INFO, ( region, id ) ->
                model.describeAWSResourcesService region

            model.on 'UPDATE_REGION_APP_LIST', () ->
                view.renderRegionAppStack( 'app' )

            model.on 'change:cur_stack_list', () ->
                view.renderRegionAppStack( 'stack' )

            model.on 'REGION_RESOURCE_CHANGED', ( type, data )->
                console.log 'region resource table render'
                view.renderRegionResourceBody type, true

            # update region thumbnail
            ide_event.onLongListen ide_event.UPDATE_REGION_THUMBNAIL, ( url, id ) ->
                console.log 'UPDATE_REGION_THUMBNAIL'

                view.updateThumbnail url, id

                null

            #update region app state when pending
            # ide_event.onLongListen ide_event.UPDATE_DESIGN_TAB_ICON, ( flag, app_id ) ->
            #     console.log 'UPDATE_DESIGN_TAB_ICON'

            #     model.updateAppList flag, app_id

            #     null

            # ide_event.onLongListen ide_event.UPDATE_APP_STATE, (state, tab_name) ->
            #     console.log 'UPDATE_APP_STATE, state:' + state + ', tab_name:' + tab_name

            #     model.updateAppState(state, tab_name)

            #     null

    unLoadModule = () ->

    # public
    loadModule   : loadModule
    unLoadModule : unLoadModule
