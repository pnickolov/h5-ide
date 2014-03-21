####################################
#  Controller for design/resource module
####################################

define [ 'event', 'constant' ], ( ide_event, constant ) ->

    #private
    loadModule = () ->
        #
        require [ './module/design/resource/view', './module/design/resource/model', 'UI.bubble' ], ( View, model ) ->

            view       = new View()
            view.render()
            view.listen model
            view.model = model

            #listen OPEN_DESIGN
            ide_event.onLongListen ide_event.OPEN_DESIGN, ( region_name, type, current_platform ) ->
                console.log 'resource:OPEN_DESIGN, region_name ' + region_name + ', type = ' + type + ', current_platform = ' + current_platform
                # check re-render
                view.reRender()

                # init resoruce service count
                model.service_count = 0
                model.set 'check_required_service_count', -1

                # init resouceapi array
                # resource api same [ 'describeAvailableZonesService:OLD', 'quickstartService:OLD' ]
                MC.data.resouceapi = []

                # listen ide_event
                ide_event.onListen ide_event.RESOURCE_QUICKSTART_READY, ( region_name ) ->
                    console.log 'resource:RESOURCE_QUICKSTART_READY'
                    model.describeAvailableZonesService region_name
                    model.describeSnapshotsService      region_name

                # model
                model.quickstartService                 region_name
                model.describeSubnetInDefaultVpc        region_name

                # view
                view.region = region_name
                view.resourceVpcRender( current_platform, type )
                view.communityAmiBtnRender()

                null

            ide_event.onLongListen ide_event.ENABLE_RESOURCE_ITEM, ( type, filter ) ->
                view.enableItem type, filter

            ide_event.onLongListen ide_event.DISABLE_RESOURCE_ITEM, ( type, filter ) ->
                view.disableItem type, filter

            ide_event.onLongListen ide_event.UPDATE_RESOURCE_STATE, ( type ) ->
                #view.updateResourceState type
                view.hideResourcePanel type

            ide_event.onLongListen ide_event.SWITCH_TAB, ( type, tab_id ) ->
                console.log 'resource:SWITCH_TAB', type, tab_id
                if type.split('_')[0] is 'OLD'

                    # get object
                    obj = MC.common.other.searchStackAppById tab_id

                    # set region
                    region_name = obj.region if obj

                    # favoriate service
                    model.favoriteAmiService region_name

                    null

            # when app update discard refresh az and vpc item
            ide_event.onLongListen ide_event.UPDATE_RESOURCE_STATE, ( type ) ->
                console.log 'resource:UPDATE_RESOURCE_STATE', type
                if type is 'hide'
                    view.resourceVpcRender MC.common.other.canvasData.get( 'platform' ), 'OPEN_APP'
                    model.describeAvailableZonesService MC.common.other.canvasData.get( 'region' )

            #when add resource
            Design.on Design.EVENT.AddResource, ( comp )->

                res_type = constant.AWS_RESOURCE_TYPE
                if comp and comp.type in [res_type.AWS_EC2_AvailabilityZone, res_type.AWS_VPC_InternetGateway, res_type.AWS_VPC_VPNGateway]
                    name   = comp.get("name")
                    filter = ( data ) -> data and data.option and data.option.name is name
                    view.disableItem comp.type, filter

                    console.log "Design.EVENT.AddResource: " + comp.type

                null

            #when remove resource
            Design.on Design.EVENT.RemoveResource, ( comp )->

                res_type = constant.AWS_RESOURCE_TYPE
                if comp and comp.type in [res_type.AWS_EC2_AvailabilityZone, res_type.AWS_VPC_InternetGateway, res_type.AWS_VPC_VPNGateway]
                    name   = comp.get("name")
                    filter = ( data ) -> data and data.option and data.option.name is name
                    view.enableItem comp.type, filter

                    console.log "Design.EVENT.RemoveResource: " + comp.type
                null

            view.on 'LOADING_COMMUNITY_AMI', ( region, name, platform, isPublic, architecture, rootDeviceType, perPageNum, pageNum ) ->
                console.log 'LOADING_COMMUNITY_AMI'
                model.describeCommunityAmiService region, name, platform, isPublic, architecture, rootDeviceType, perPageNum, pageNum

            view.on 'TOGGLE_FAV', ( region_name, action, amiId ) ->
                if action is 'add'
                    model.addFav region_name, amiId
                else if action is 'remove'
                    model.removeFav region_name, amiId

            model.on 'change:availability_zone', () ->
                console.log 'resource availability_zone change'
                ide_event.trigger ide_event.RELOAD_AZ, model.get 'availability_zone'

            model.on 'change:check_required_service_count', () ->
                console.log 'check_required_service_count, count = ' + model.get 'check_required_service_count'

                # set false
                is_true = false

                # return
                if model.get( 'check_required_service_count' ) is -1
                    return

                # SWITCH_MAIN → GET_STATE_MODULE
                if MC.common.cookie.getCookieByName('has_cred') is 'false' and model.get( 'check_required_service_count' ) is 1    # not set credential then use quickstart data
                    console.log 'not set credential and described quickstart service'
                    is_true = true

                else if model.get( 'check_required_service_count' ) is 3      # has setted credential
                    console.log 'set credential and described require service'
                    is_true = true

                if is_true
                    #ide_event.trigger ide_event.GET_STATE_MODULE if MC.data.current_tab_type isnt 'OPEN_APP'
                    ide_event.trigger ide_event.RESOURCE_API_COMPLETE
                    model.service_count = 0

                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
