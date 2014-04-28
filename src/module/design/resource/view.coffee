#############################
#  View(UI logic) for design/resource
#############################

define [ 'event',
         'constant'
         './template',
         './template_data',
         'i18n!nls/lang.js', 'backbone', 'jquery', 'handlebars',
         'UI.selectbox',
         'UI.radiobuttons', 'UI.modal', 'UI.table'
], ( ide_event, constant, template, template_data, lang ) ->

    ResourceView = Backbone.View.extend {

        el                     : $ '#resource-panel'

        my_ami_tmpl            : template_data.my_ami_tmpl
        favorite_ami_tmpl      : template_data.favorite_ami_tmpl
        community_ami_tmpl     : template_data.community_ami_tmpl
        resource_vpc_tmpl      : template_data.resource_vpc_tmpl


        initialize : ->

            #listen
            $( document )
                .on( 'click',            '#hide-resource-panel',                      this.toggleResourcePanel )
                .on( 'OPTION_CHANGE',    '#resource-select',                    this, this.resourceSelectEvent )
                # .on( 'SEARCHBAR_SHOW',   '#resource-select',                          this.searchBarShowEvent )
                # .on( 'SEARCHBAR_HIDE',   '#resource-select',                          this.searchBarHideEvent )
                # .on( 'SEARCHBAR_CHANGE', '#resource-select',                          this.searchBarChangeEvent )
                .on( 'click',            '#btn-browse-community-ami',           this, this.openBrowseCommunityAMIsModal )
                .on( 'click',            '#btn-search-ami',                     this, this.searchCommunityAmiCurrent )
                .on( 'click',            '#community_ami_page_preview',         this, this.searchCommunityAmiPreview )
                .on( 'click',            '#community_ami_page_next',            this, this.searchCommunityAmiNext )
                .on( 'click',            '#community_ami_table .toggle-fav',    this, this.toggleFav )
                .on( 'click',            '.favorite-ami-list .faved',           this, this.removeFav )
                .on( 'click',            '.favorite-ami-list .btn-fav-ami.deleted',         this, this.addFav )
                .on( 'keypress',         '#community-ami-input',                this, this.searchCommunityAmiCurrent)

            $( window ).on "resize", _.bind( this.resizeAccordion, this )
            $( "#tab-content-design" ).on "click", ".fixedaccordion-head", this.updateAccordion

        render   : () ->
            console.log 'resource render'
            $( '#resource-panel' ).html template()
            #
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

            this.recalcAccordion()
            null

        reRender   : () ->
            console.log 're-resource render'
            if $.trim( this.$el.html() ) is 'loading...' then $( '#resource-panel' ).html template()

            this.recalcAccordion()

        updateAccordion : ( event, noAnimate ) ->

            $target    = $( event.currentTarget )
            $accordion = $target.closest(".accordion-group")

            if $accordion.hasClass "expanded"
                return false

            $expanded = $accordion.siblings ".expanded"
            $body     = $accordion.children ".accordion-body"

            $accordionWrap   = $accordion.closest ".fixedaccordion"
            $accordionParent = $accordionWrap.parent()

            $visibleAccordion = $accordionWrap.children().filter ()->
                $(this).css('display') isnt 'none'

            height = $accordionParent.outerHeight() - 39 - $visibleAccordion.length * $target.outerHeight()

            $body.outerHeight height

            if noAnimate
                $accordion.addClass "expanded"
                $expanded.removeClass "expanded"
                return false

            $body.slideDown 200, ()->
                $accordion.addClass "expanded"

            $expanded.children(".accordion-body").slideUp 200, ()->
                $expanded.closest(".accordion-group").removeClass "expanded"
            false

        recalcAccordion : () ->
            $accordions = $("#resource-panel").children(".fixedaccordion").children()
            $accordion  = $accordions.filter(".expanded")
            if $accordion.length is 0
                $accordion = $accordions.filter ()->
                    $(this).css('display') isnt 'none'

            if $accordion.length is 0
                return

            $target = $accordion.removeClass( 'expanded' ).children( '.fixedaccordion-head' )
            this.updateAccordion( { currentTarget : $target[0] }, true )

        resizeAccordion : () ->
            if this.__resizeAccdTO
                clearTimeout this.__resizeAccdTO

            self = this
            this.__resizeAccdTO = setTimeout ()->
                self.recalcAccordion()
            , 150

            null

        listen   : ( model ) ->
            #set this.model
            this.model = model
            #listen model
            this.listenTo this.model, 'change:availability_zone', this.availabilityZoneRender
            this.listenTo this.model, 'change:resource_snapshot', this.resourceSnapshotRender
            this.listenTo this.model, 'change:quickstart_ami',    this.quickstartAmiRender
            this.listenTo this.model, 'change:my_ami',            this.myAmiRender
            this.listenTo this.model, 'change:favorite_ami',      this.favoriteAmiRender
            this.listenTo this.model, 'change:community_ami',     this.communityAmiRender
            this.listenTo ide_event,  'SWITCH_TAB',               this.hideResourcePanel

        resourceSelectEvent : ( event, id ) ->
            console.log 'resourceSelectEvent = ' + id
            #if id is 'my-ami' then event.data.myAmiRender()
            #if id is 'favorite-ami' then event.data.myAmiRender()
            if id is 'favorite-ami'
                $( '.favorite-ami-list' ).show()
                $( '.quickstart-ami-list' ).hide()
                $( '.my-ami-list' ).hide()
            else if id is 'my-ami'
                $( '.my-ami-list' ).show()
                $( '.favorite-ami-list' ).hide()
                $( '.quickstart-ami-list' ).hide()
            else if id is 'quickstart-ami'
                $( '.quickstart-ami-list' ).show()
                $( '.favorite-ami-list' ).hide()
                $( '.my-ami-list' ).hide()
            #event.data.trigger 'RESOURCE_SELECET', id
            $( this ).siblings(".fixedaccordion-head").click()
            null

        # searchBarShowEvent : ( event ) ->
        #     console.log 'searchBarShowEvent'
        #     $($(this).find('.search-panel')[0]).show()

        # searchBarHideEvent : ( event ) ->
        #     console.log 'searchBarHideEvent'
        #     $($(this).find('.search-panel')[0]).hide()

        # searchBarChangeEvent : ( event, value ) ->
        #     console.log 'searchBarChangeEvent'
        #     filter.update($($(this).find('.search-panel')[0]), value)

        toggleFav : ( event ) ->
            resourceView = event.data
            $this = $ @
            # remove
            if $this.hasClass( 'faved' )
                resourceView.trigger 'TOGGLE_FAV', resourceView.region, 'remove', $this.data( 'id' )
                $this
                    .removeClass( 'faved' )
                    .data 'tooltip', 'Add to Favorite'

            else
                resourceView.trigger 'TOGGLE_FAV', resourceView.region, 'add', $this.data( 'id' )
                $this
                    .addClass( 'faved' )
                    .data 'tooltip', 'Remove from Favorite'

            # Update the tooltip immediately
            $this.trigger 'mouseleave', event
            $this.trigger 'mouseenter', event


        addFav: ( event ) ->
            resourceView = event.data
            target = $ event.currentTarget
            #target.trigger 'mouseleave' )
            id = target.data( 'id' )
            amiVO = target.data( 'amivo' )
            resourceView.trigger 'TOGGLE_FAV', resourceView.region, 'add', id, amiVO, true

        removeFav : ( event ) ->
            resourceView = event.data
            target = $ event.currentTarget
            #target.trigger 'mouseleave' )
            id = target.data( 'id' )
            resourceView.trigger 'TOGGLE_FAV', resourceView.region, 'remove', id,

        toggleResourcePanel : ->
            console.log 'toggleResourcePanel'
            #
            $( '#resource-panel'      ).toggleClass 'hidden'
            #$( '#canvas-panel'        ).toggleClass 'left-hidden'
            $( '#hide-resource-panel' ).toggleClass 'icon-caret-left'
            $( '#hide-resource-panel' ).toggleClass 'icon-caret-right'
            #
            #if $( '#resource-panel' ).hasClass( 'hidden' ) then state = 'hidden' else state = 'show'
            #$( '#hide-resource-panel' ).attr 'data-current-state', state
            #
            null

        hideResourcePanel : ( type ) ->
            console.log 'hideResourcePanel', type, Tabbar.current

            @recalcAccordion()

            $item   = $ '#hide-resource-panel'
            $panel  = $ '#resource-panel'
            $canvas = $ '#canvas-panel'

            #show hide-resource-panel
            if type.split('_')[1] is 'STACK' or Tabbar.current is 'appedit' or type is 'show'

                # show hide-resource-panel resource-panel
                $item.show()
                $panel.show()

                # show
                if $item.hasClass( 'icon-caret-left' )
                    $panel.removeClass  'hidden'
                    #$canvas.removeClass 'left-hidden'

                # hide
                if $item.hasClass( 'icon-caret-right' )
                    $panel.addClass     'hidden'
                    #$canvas.addClass    'left-hidden'

                #appeidt
                if type is 'show' and $item.hasClass( 'icon-caret-right' ) and $panel.hasClass( 'hidden' )
                    $item.trigger 'click'

            else if type.split('_')[1] is 'APP' or type is 'hide'

                # hide hide-resource-panel resource-panel
                $item.hide()
                $panel.hide()

                # remove left and add right
                $item.removeClass 'icon-caret-left'
                $item.addClass    'icon-caret-right'

                # hide
                $panel.addClass  'hidden'
                #$canvas.addClass 'left-hidden'
            null

        ###updateResourceState : ( type ) ->
            console.log 'updateResourceState, type = ' + type
            # Get all accordion, and make them not `expanded`
            $item = $('.fixedaccordion').children().removeClass("expanded")
            #
            if type is 'show'

                #hide az and scaling
                $item.eq(0).hide()
                $item.eq(3).hide()
                #hide vpc
                $item.eq(4).hide()

                #open images & close volume
                # Need to hide other items first
                # Then recalc the accodion
                @recalcAccordion()

            else if type is 'hide'

                #show all
                $item.show()

            null###

        availabilityZoneRender : () ->
            console.log 'availabilityZoneRender'
            console.log this.model.attributes.availability_zone
            return if !this.model.attributes.availability_zone
            $( '.availability-zone' ).html template_data.availability_zone_data( @model.attributes )
            null

        resourceSnapshotRender : () ->
            console.log 'resourceSnapshotRender'
            console.log this.model.attributes.resource_snapshot
            return if !this.model.attributes.resource_snapshot
            $( '.resoruce-snapshot' ).append template_data.resoruce_snapshot_data( @model.attributes )
            null

        quickstartAmiRender : () ->
            console.log 'quickstartAmiRender'
            console.log this.model.attributes.quickstart_ami
            if !this.model.attributes.quickstart_ami
                $( '.quickstart-ami-list' ).html ''
                return
            $( '.quickstart-ami-list' ).html template_data.quickstart_ami_data( @model.attributes )
            null

        myAmiRender : () ->
            console.log 'myAmiRender'
            console.log this.model.attributes.my_ami
            if !@model.attributes.my_ami or _.isNumber @model.attributes.my_ami
                $( '.my-ami-list' ).html ''
                return
            $( '.my-ami-list' ).html template_data.my_ami_data( @model.attributes )
            null

        favoriteAmiRender : () ->
            console.log 'favoriteAmiRender'
            console.log this.model.attributes.favorite_ami
            return if !this.model.attributes.favorite_ami
            $( '.favorite-ami-list' ).html template_data.favorite_ami_data( @model.attributes )
            null

        communityAmiBtnRender : () ->
            console.log 'communityAmiRender'
            console.log this.model.attributes.community_ami
            #return if !this.model.attributes.community_ami
            $( '.community-ami' ).html template_data.community_ami_btn( this )
            null

        openBrowseCommunityAMIsModal : ( event ) ->

            console.log 'openBrowseCommunityAMIsModal'

            resourceView = event.data

            #modal(MC.template.browseCommunityAmi(''), false)
            #
            require [ 'component/amis/main' ], ( amis_main ) ->
                amis_main.loadModule()
                resourceView.searchCommunityAmi()
                #resourceView.searchCommunityAmiCurrent {data : resourceView}

        # todo
        communityShowLoading: () ->
            $( "#ami-table-wrap .scroll-content" ).hide()
            $( ".show-loading" ).show()
            $( "#btn-search-ami" ).text( lang.ide.AMI_LBL_SEARCHING ).attr( "disabled", "" )
            $( "#community-ami-page>div" ).hide()
            $("#ami-count").empty().html("Total: 0")

        # todo
        communityShowContent: () ->
            $( ".show-loading" ).hide()
            $( "#ami-table-wrap .scroll-content" ).show()
            $( "#btn-search-ami" ).text( lang.ide.AMI_LBL_SEARCH ).removeAttr( "disabled" )
            $( "#community-ami-page>div" ).show()

        communityPagerRender: ( current_page, max_page, total ) ->
            resourceView = @
            pageSize = if total > 50 then 50 else total

            itemBegin = ( current_page - 1 ) * 50 + 1
            itemEnd = itemBegin + pageSize - 1
            itemEnd = total if itemEnd > total

            $( '.page-tip' ).text sprintf lang.ide.AMI_LBL_PAGEINFO, itemBegin, itemEnd, total

            pagination = $ '.pagination'

            if max_page is 0
                pagination.hide()
            else
                pagination.show()

            if pagination.data 'jqPagination'
                pagination.jqPagination 'destroy'
                # init page num
                pagination.find( 'input' ).data('current-page', current_page)


            pagination.jqPagination({
                current_page: current_page,
                max_page: max_page,
                page_string: "{current_page} / {max_page}"
                paged: ((current_page, max_page) ->
                    (page) ->
                        if page isnt current_page and max_page >= page > 0
                            resourceView.searchCommunityAmi page
                    )(current_page, max_page)

            })

        communityAmiRender : () ->
            @communityShowContent()

            totalNum = 0
            if this.model.attributes.community_ami
                this_tr = ""
                _.map this.model.attributes.community_ami.result, ( value, key ) ->
                    value.favorite = false if value.delete
                    fav_class = if value.favorite then 'faved' else ''
                    tooltip = if value.favorite then lang.ide.RES_TIT_REMOVE_FROM_FAVORITE else lang.ide.RES_TIT_ADD_TO_FAVORITE
                    bit         = if value.architecture == 'i386' then '32' else '64'
                    visibility  = if value.isPublic then 'public' else 'private'
                    this_tr += '<tr class="item" data-id="'+key+' '+value.name+'" data-publicprivate="public" data-platform="'+value.osType+'" data-ebs="'+value.rootDeviceType+'" data-bit="'+bit+'">'
                    this_tr += '<td class="ami-table-fav"><div class="toggle-fav tooltip ' + fav_class + '" data-tooltip="' + tooltip + '" data-id="'+key+'"></div></td>'
                    this_tr += '<td class="ami-table-id">'+key+'</td>'
                    this_tr += '<td class="ami-table-info"><span class="ami-table-name">' + value.name + '</span><div class="ami-meta"><i class="icon-' + value.osType + ' icon-ami-os"></i><span>' + visibility + ' | ' + value.architecture + ' | ' + value.rootDeviceType + '</span></div></td>'
                    this_tr += "<td class='ami-table-size'>#{value.imageSize}</td></tr>"

                currentPageNum = this.model.attributes.community_ami.curPageNum
                page = "<div>page #{currentPageNum}</div>"
                totalNum = this.model.attributes.community_ami.totalNum
                totalPageNum = this.model.attributes.community_ami.totalPageNum
                $("#ami-count").empty().html("Total: #{totalNum}")

                @communityPagerRender currentPageNum, totalPageNum, totalNum
                $("#community_ami_table").empty().html(this_tr)

        resourceVpcRender : ( current_platform, type ) ->
            data = {}

            if not current_platform

                # old design flow
                #current_platform = MC.canvas_data.platform

                # new design flow
                current_platform = MC.common.other.canvasData.get 'platform'

            if current_platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

                data.isntClassic = false

            else
                data.isntClassic = true

                if current_platform == MC.canvas.PLATFORM_TYPE.DEFAULT_VPC

                    data.isntDefaultVPC = false

                else
                    data.isntDefaultVPC = true

                    if type != 'NEW_STACK'

                        data.igwIsUsed = this.model.getIgwStatus()

                        data.vgwIsUsed = this.model.getVgwStatus()

            $list = $( '.resource-vpc-list' ).html template_data.resource_vpc_select_list( data )
            $list.toggle $list.children().length > 0

        searchCommunityAmi : ( pageNum ) ->
            me = this
            if not pageNum
                pageNum = 1

            #resourceView = event.data
            me.communityShowLoading()

            name            = $('#community-ami-input').val()
            platform        = $('#selectbox-ami-platform').find('.selected').data('id')

            isPublic        = 'true'
            architecture    = '32-bit'
            rootDeviceType  = 'EBS'
            if $('#filter-ami-type').find('.active').length is 1
                visibility      = radiobuttons.data($('#filter-ami-type'))
                isPublic = if visibility is 'Private' then 'false' else 'true'
            else if $('#filter-ami-type').find('.active').length is 2
                isPublic = null

            if $('#filter-ami-32bit-64bit').find('.active').length is 1
                architecture = radiobuttons.data($('#filter-ami-32bit-64bit'))
            else if $('#filter-ami-32bit-64bit').find('.active').length is 2
                architecture = null

            if $('#filter-ami-EBS-Instance').find('.active').length is 1
                rootDeviceType = radiobuttons.data($('#filter-ami-EBS-Instance'))
            else if $('#filter-ami-EBS-Instance').find('.active').length is 2
                rootDeviceType = null

            # old design flow
            #me.trigger 'LOADING_COMMUNITY_AMI' , MC.canvas_data.region, name, platform, isPublic, architecture, rootDeviceType, null, pageNum

            # new design flow
            me.trigger 'LOADING_COMMUNITY_AMI' , MC.common.other.canvasData.get( 'region' ), name, platform, isPublic, architecture, rootDeviceType, null, pageNum

            #event.data.trigger 'LOADING_COMMUNITY_AMI', event.data.region, pageNum


        searchCommunityAmiCurrent : ( event ) ->

            #check enter key
            if event.keyCode and event.keyCode isnt 13
                return

            resourceView = event.data
            event.data.searchCommunityAmi 0

        searchCommunityAmiNext : ( event ) ->

            resourceView = event.data

            page = parseInt $('#community_ami_page_current').attr("page"), 10

            resourceView.searchCommunityAmi page + 1

        searchCommunityAmiPreview : ( event ) ->

            resourceView = event.data

            page = parseInt $('#community_ami_page_current').attr("page"), 10

            resourceView.searchCommunityAmi page - 1

        enableItem  : ( type, filterFunc ) ->
            this.toggleItem type, filterFunc, true
            null

        disableItem : ( type, filterFunc ) ->
            this.toggleItem type, filterFunc, false
            null

        toggleItem : ( type, filterFunc, enable ) ->
            $(".resource-item[data-type='#{type}']").each ( idx, item )->

                $item = $(item)
                data  = $item.data()

                if filterFunc and not filterFunc.call $item, data
                    return

                $item
                    .data("enable", enable)
                    .attr("data-enable", enable)
                    .toggleClass("resource-disabled", not enable)

                # Update tooltip
                if enable
                    tooltip = itemEnableToolTip[type]
                    $item.toggleClass("tooltip", true)

                    if tooltip
                        $item.data("tooltip", tooltip)
                else
                    tooltip = itemDisableToolTip[type]

                    if tooltip
                        $item.data("tooltip", tooltip)
                             .toggleClass("tooltip", true)
                    else
                        $item.toggleClass("tooltip", false)
            null

    }

    res_type = constant.RESTYPE
    itemDisableToolTip = {}
    itemEnableToolTip  = {}

    ###

    # Don't know if we really need to update the tooltip of the item.

    itemEnableToolTip[  res_type.AWS_VPC_InternetGateway ] = "Drag and drop to canvas to create a new Internet Gateway."
    itemDisableToolTip[ res_type.AWS_VPC_InternetGateway ] = "VPC can only have one IGW. There is already one IGW in current VPC."

    itemEnableToolTip[  res_type.AWS_VPC_VPNGateway ] = "Drag and drop to canvas to create a new VPN Gateway."
    itemDisableToolTip[ res_type.AWS_VPC_VPNGateway ] = "VPC can only have one IGW. There is already one IGW in current VPC."

    ###

    return ResourceView
