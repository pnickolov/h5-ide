####################################
#  Controller for dashboard module
####################################

define [ 'jquery', 'event', 'MC', 'base_main', 'vpc_model' ], ( $, ide_event, MC, base_main, vpc_model ) ->

    current_region = null
    overview_app    = null
    overview_stack  = null
    should_update_overview = false

    #private
    initialize = ->
        #extend parent
        _.extend this, base_main

    Helper =
        hasCredential: ->
            MC.forge.cookie.getCookieByName('has_cred') is 'true'

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
            view.render()

            #push DASHBOARD_COMPLETE
            ide_event.trigger ide_event.DASHBOARD_COMPLETE

            model.on 'change:result_list', () ->
                console.log 'dashboard_change:result_list'
                should_update_overview = true
                #refresh view
                view.renderMapResult()

            model.on 'change:region_classic_list', () ->
                console.log 'dashboard_region_classic_list'
                #set MC.data.supported_platforms
                MC.data.supported_platforms = model.get 'region_classic_list'
                #refresh view
                if MC.data.supported_platforms.length <= 0
                else
                    MC.data.is_loading_complete = true
                    ide_event.trigger ide_event.IDE_AVAILABLE

                view.displayLoadTime()

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
                console.log 'dashboard_region:UPDATE_AWS_CREDENTIAL'

                if Helper.hasCredential()
                    view.enableSwitchRegion()
                    view.reloadResource()
                else    # set aws credential
                    view.disableSwitchRegion()
                    view.showCredential()
                    view.renderLoadingFaild()

            vpc_model.on 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', () ->
                if Helper.hasCredential()
                    view.enableSwitchRegion()

            ide_event.onLongListen ide_event.UPDATE_DASHBOARD, () ->
                console.log 'UPDATE_DASHBOARD'
                view.reloadResource() if view

            #model
            model.describeAccountAttributesService()

            #model.describeAWSResourcesService()

            ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->
                overview_app = result
                model.describeAWSResourcesService()

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
                else
                    view.trigger 'RETURN_REGION_TAB', result
                null

            # switch region tab
            view.on 'SWITCH_REGION', ( region ) ->
                current_region = region
                model.loadResource region
                #model.describeAWSStatusService region
                @model.getItemList 'app', region, overview_app
                @model.getItemList 'stack', region, overview_stack

            # reload resource
            view.on 'RELOAD_RESOURCE', ( region ) ->
                view.displayLoadTime()
                model.describeAWSResourcesService region

                ide_event.trigger ide_event.UPDATE_STACK_LIST
                ide_event.trigger ide_event.UPDATE_APP_LIST

            model.on 'change:cur_app_list', () ->
                view.renderRegionAppStack( 'app' )

            ide_event.onLongListen ide_event.UPDATE_APP_RESOURCE, ( region, id ) ->
                model.describeAWSResourcesService region

            model.on 'UPDATE_REGION_APP_LIST', () ->
                view.renderRegionAppStack( 'app' )

            model.on 'change:cur_stack_list', () ->
                view.renderRegionAppStack( 'stack' )

            model.on 'REGION_RESOURCE_CHANGED', ( type, data )->
                console.log 'region resource table render'
                view.reRenderRegionPartial( type, data )

            # update region thumbnail
            ide_event.onLongListen ide_event.UPDATE_REGION_THUMBNAIL, ( url ) ->
                console.log 'UPDATE_REGION_THUMBNAIL'

                view.updateThumbnail url

                null

            #update region app state when pending
            ide_event.onLongListen ide_event.UPDATE_TAB_ICON, ( flag, app_id ) ->
                console.log 'UPDATE_TAB_ICON'

                model.updateAppList flag, app_id

                null

    unLoadModule = () ->

    # public
    loadModule   : loadModule
    unLoadModule : unLoadModule
