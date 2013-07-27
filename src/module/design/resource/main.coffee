####################################
#  Controller for design/resource module
####################################

define [ 'jquery',
         'text!/module/design/resource/template.html',
         'text!/module/design/resource/template_data.html',
         'event',
         'MC.ide.template'
], ( $, template, template_data, ide_event ) ->

    #private
    loadModule = () ->

        #compile partial template
        MC.IDEcompile 'design-resource', template_data, { '.availability-zone-data' : 'availability-zone-tmpl', '.resoruce-snapshot-data' : 'resoruce-snapshot-tmpl', '.quickstart-ami-data' : 'quickstart-ami-tmpl', '.my-ami-data' : 'my-ami-tmpl', '.favorite-ami-data' : 'favorite-ami-tmpl', '.community-ami-btn':'community-ami-tmpl', '.resource-vpc-select-list' : 'resource-vpc-tmpl' }

        #
        require [ './module/design/resource/view', './module/design/resource/model', 'UI.bubble' ], ( View, model ) ->

            #view
            view       = new View()
            view.render template
            view.listen model
            view.model = model

            #listen SWITCH_TAB
            #ide_event.onLongListen ide_event.SWITCH_TAB, ( type, target, region_name ) ->
            #    console.log 'resource:SWITCH_TAB, type = ' + type + ', target = ' + target + ', region_name = ' + region_name
            #    if type is 'NEW_STACK'
            #        model.describeAvailableZonesService region_name
            #    null

            #view.on 'RESOURCE_SELECET', ( id ) ->
            #    console.log 'RESOURCE_SELECET = ' + id
            #    if id is 'my-ami'       then model.myamiService model.get 'region_name'
            #    #if id is 'favorite-ami' then

            #listen RELOAD_RESOURCE
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name, type, current_platform ) ->
                console.log 'resource:RELOAD_RESOURCE'
                #
                #if type is 'OPEN_APP' then return
                #check re-render
                view.reRender template
                #
                model.describeAvailableZonesService region_name, type
                model.describeSnapshotsService      region_name
                model.quickstartService             region_name
                #model.myAmiService                  region_name
                #model.favoriteAmiService            region_name
                view.region = region_name
                view.communityAmiBtnRender()
                view.resourceVpcRender( current_platform, type )
                null

            view.on 'LOADING_COMMUNITY_AMI', ( region_name, state ) ->
                name = $('#community-ami-input').val()
                platform = $($('#selectbox-ami-platform').find('.selected a')[0]).data('id')
                architecture = radiobuttons.data($('#filter-ami-32bit-64bit'))
                rootDeviceType = radiobuttons.data($('#filter-ami-EBS-Instance'))
                page = parseInt $('#community_ami_page_current').attr("page"), 10
                totalPage = parseInt $('#community_ami_page_current').attr("totalPage"), 10
                if state == 0
                    pageNum = 1
                    model.describeCommunityAmiService region_name, name, platform, architecture, rootDeviceType, null, pageNum
                if state == -1 and page>1
                    pageNum = page-1
                    model.describeCommunityAmiService region_name, name, platform, architecture, rootDeviceType, null, pageNum

                if state == 1 and totalPage> page
                    pageNum = page+1
                    model.describeCommunityAmiService region_name, name, platform, architecture, rootDeviceType, null, pageNum

            model.on 'change:availability_zone', () ->
                ide_event.trigger ide_event.RELOAD_AZ, model.get 'availability_zone'

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
