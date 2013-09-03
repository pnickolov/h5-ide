#############################
#  View(UI logic) for design/resource
#############################

define [ 'event',
         'constant'
         'backbone', 'jquery', 'handlebars',
         'UI.selectbox', 'UI.toggleicon', 'UI.searchbar', 'UI.filter', 'UI.radiobuttons', 'UI.modal', 'UI.table'
], ( ide_event, constant, Backbone, $ ) ->

    ResourceView = Backbone.View.extend {

        el                     : $ '#resource-panel'

        availability_zone_tmpl : Handlebars.compile $( '#availability-zone-tmpl' ).html()
        resource_snapshot_tmpl : Handlebars.compile $( '#resoruce-snapshot-tmpl' ).html()
        quickstart_ami_tmpl    : Handlebars.compile $( '#quickstart-ami-tmpl' ).html()
        my_ami_tmpl            : Handlebars.compile $( '#my-ami-tmpl' ).html()
        favorite_ami_tmpl      : Handlebars.compile $( '#favorite-ami-tmpl' ).html()
        community_ami_tmpl     : Handlebars.compile $( '#community-ami-tmpl' ).html()
        resource_vpc_tmpl      : Handlebars.compile $( '#resource-vpc-tmpl' ).html()


        initialize : ->

            #listen
            $( document )
                .on( 'click',            '#hide-resource-panel',                      this.toggleResourcePanel )
                .on( 'OPTION_CHANGE',    '#resource-select',                    this, this.resourceSelectEvent )
                .on( 'SEARCHBAR_SHOW',   '#resource-select',                          this.searchBarShowEvent )
                .on( 'SEARCHBAR_HIDE',   '#resource-select',                          this.searchBarHideEvent )
                .on( 'SEARCHBAR_CHANGE', '#resource-select',                          this.searchBarChangeEvent )
                .on( 'click',            '#btn-browse-community-ami',           this, this.openBrowseCommunityAMIsModal )
                .on( 'click',            '#btn-search-ami',                     this, this.searchCommunityAmiCurrent )
                .on( 'click',            '#community_ami_page_preview',         this, this.searchCommunityAmiPreview )
                .on( 'click',            '#community_ami_page_next',            this, this.searchCommunityAmiNext )
                .on( 'click',            '#community_ami_table .toggle-fav',    this, this.toggleFav )
                .on( 'click',            '.favorite-ami-list .faved',           this, this.removeFav )
                .on( 'keypress',         '#community-ami-input',                this, this.searchCommunityAmiCurrent)

            $( window ).on "resize", _.bind( this.resizeAccordion, this )
            $( "#tab-content-design" ).on "click", ".fixedaccordion-head", this.updateAccordion


            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.hideResourcePanel

        render   : ( template, attrs ) ->
            console.log 'resource render'
            $( '#resource-panel' ).html Handlebars.compile template
            #
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

            this.recalcAccordion()
            null

        reRender   : ( template ) ->
            console.log 're-resource render'
            if $.trim( this.$el.html() ) is 'loading...' then $( '#resource-panel' ).html Handlebars.compile template

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

            height = $accordionParent.outerHeight() - $accordionWrap.position().top - $accordionWrap.children(":visible").length * $target.outerHeight()

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
                $accordion = $accordions.eq(0)

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

        searchBarShowEvent : ( event ) ->
            console.log 'searchBarShowEvent'
            $($(this).find('.search-panel')[0]).show()

        searchBarHideEvent : ( event ) ->
            console.log 'searchBarHideEvent'
            $($(this).find('.search-panel')[0]).hide()

        searchBarChangeEvent : ( event, value ) ->
            console.log 'searchBarChangeEvent'
            filter.update($($(this).find('.search-panel')[0]), value)

        toggleFav : ( event ) ->
            resourceView = event.data
            # remove
            if $( @ ).hasClass( 'faved' )
                resourceView.trigger 'TOGGLE_FAV', resourceView.region, 'remove', $( @ ).data( 'id' )
            else
                resourceView.trigger 'TOGGLE_FAV', resourceView.region, 'add', $( @ ).data( 'id' )

            ( $ ( @ ) ).toggleClass( 'faved' )

        removeFav : ( event ) ->
            resourceView = event.data
            target = $ event.currentTarget
            #target.trigger 'mouseleave' )
            id = target.data( 'id' )
            resourceView.trigger 'TOGGLE_FAV', resourceView.region, 'remove', id

        toggleResourcePanel : ( event ) ->
            console.log 'toggleResourcePanel'
            #
            $( '#resource-panel' ).toggleClass 'hiden'
            $( '#canvas-panel' ).toggleClass 'left-hiden'
            $( '#hide-resource-panel' ).toggleClass 'icon-caret-left'
            $( '#hide-resource-panel' ).toggleClass 'icon-caret-right'
            console.log $( '#resource-panel' ).attr( 'class' )

            if $( '#resource-panel' ).hasClass("hidden") then state = 'hiden' else state = 'show'
            $( '#hide-resource-panel' ).attr 'data-current-state', state

        hideResourcePanel : ( type ) ->
            console.log 'hideResourcePanel = ' + type
            #
            if type is 'OPEN_APP'
                $( '#hide-resource-panel' ).attr 'data-current-state', 'hiden'
                $( '#hide-resource-panel' ).trigger 'click'
                $( '#hide-resource-panel' ).hide()
            else
                #
                this.recalcAccordion()
            #
            if type is 'OPEN_STACK' or type is 'NEW_STACK'
                $( '#hide-resource-panel' ).attr 'data-current-state', 'show'
                if $( '#resource-panel' ).hasClass("hiden") then $( '#hide-resource-panel' ).trigger 'click'
                $( '#hide-resource-panel' ).show()

            if type is 'OLD_STACK'
                $( '#hide-resource-panel' ).show()
                if $( '#hide-resource-panel' ).attr( 'data-current-state' ) is 'show'
                    if $( '#resource-panel' ).hasClass("hiden")
                        $( '#hide-resource-panel' ).trigger 'click'
                else
                    if not $( '#resource-panel' ).hasClass("hiden")
                        $( '#hide-resource-panel' ).trigger 'click'
            else if type is 'OLD_APP'
                $( '#hide-resource-panel' ).hide()
                if not $( '#resource-panel' ).hasClass("hiden")
                    $( '#hide-resource-panel' ).trigger 'click'
            #
            console.log $( '#hide-resource-panel' ).attr 'data-current-state'
            null

        availabilityZoneRender : () ->
            console.log 'availabilityZoneRender'
            console.log this.model.attributes.availability_zone
            return if !this.model.attributes.availability_zone
            $( '.availability-zone' ).html this.availability_zone_tmpl this.model.attributes
            null

        resourceSnapshotRender : () ->
            console.log 'resourceSnapshotRender'
            console.log this.model.attributes.resource_snapshot
            return if !this.model.attributes.resource_snapshot
            $( '.resoruce-snapshot' ).append this.resource_snapshot_tmpl this.model.attributes
            null

        quickstartAmiRender : () ->
            console.log 'quickstartAmiRender'
            console.log this.model.attributes.quickstart_ami
            return if !this.model.attributes.quickstart_ami
            $( '.quickstart-ami-list' ).html this.quickstart_ami_tmpl this.model.attributes
            null

        myAmiRender : () ->
            console.log 'myAmiRender'
            console.log this.model.attributes.my_ami
            return if !this.model.attributes.my_ami
            $( '.my-ami-list' ).html this.my_ami_tmpl this.model.attributes
            null

        favoriteAmiRender : () ->
            console.log 'favoriteAmiRender'
            console.log this.model.attributes.favorite_ami
            return if !this.model.attributes.favorite_ami
            $( '.favorite-ami-list' ).html this.favorite_ami_tmpl this.model.attributes
            null

        communityAmiBtnRender : () ->
            console.log 'communityAmiRender'
            console.log this.model.attributes.community_ami
            #return if !this.model.attributes.community_ami
            $( '.community-ami' ).html this.community_ami_tmpl this
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
            $( ".ami-right-col .scroll-content" ).hide()
            $( ".show-loading" ).show()
            $( "#btn-search-ami" ).text( "Searching..." ).attr( "disabled", "" )
            $( "#community-ami-page>div" ).hide()
            $("#ami-count").empty().html("Total: 0")

        # todo
        communityShowContent: () ->
            $( ".show-loading" ).hide()
            $( ".ami-right-col .scroll-content" ).show()
            $( "#btn-search-ami" ).text( "Search" ).removeAttr( "disabled" )
            $( "#community-ami-page>div" ).show()

        communityPagerRender: ( current_page, max_page, total ) ->
            resourceView = @
            $( '.page-tip' ).text "Showing #{if total > 50 then 50 else total} of #{total} results"

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
                page_string: '{current_page} of {max_page}'
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
                    fav_class = if value.favorite then 'faved' else ''
                    bit         = if value.architecture == 'i386' then '32' else '64'
                    visibility  = if value.isPublic then 'public' else 'private'
                    this_tr += '<tr class="item" data-id="'+key+' '+value.name+'" data-publicprivate="public" data-platform="'+value.osType+'" data-ebs="'+value.rootDeviceType+'" data-bit="'+bit+'">'
                    this_tr += '<td class="ami-table-fav"><div class="toggle-fav tooltip ' + fav_class + '" data-tooltip="Add to Favorite" data-id="'+key+'"></div></td>'
                    this_tr += '<td class="ami-table-id">'+key+'</td>'
                    this_tr += '<td class="ami-table-info"><span class="ami-table-name">' + value.name + '</span><div class="ami-meta"><i class="icon-ubuntu icon-ami-os"></i><span>' + visibility + ' | ' + value.architecture + ' | ' + value.rootDeviceType + '</span></div></td>'
                    this_tr += "<td class='ami-table-arch'>#{bit}</td></tr>"
                    # <tr class="item" data-id="{{id}} {{name}}" data-publicprivate="public" data-platform="{{platform}}" data-ebs="{{rootDeviceType}}" data-bit="{{architecture}}">
                    #                     <td><div class="toggle-fav tooltip" data-tooltip="add to Favorite" data-id="{{id}}"></div></td>
                    #                     <td>{{id}}</td>
                    #                     <td>
                    #                         <div><i class="icon-ubuntu icon-ami-os"></i>{{name}}</div>
                    #                         <div class="ami-meta">{{isPublic}} | {{architecture}} | {{rootDeviceType}}</div>
                    #                     </td>
                    #                     <td>32</td>
                    #                 </tr>
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

                current_platform = MC.canvas_data.platform

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

            $list = $( '.resource-vpc-list' ).html this.resource_vpc_tmpl data
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

            me.trigger 'LOADING_COMMUNITY_AMI' , MC.canvas_data.region, name, platform, isPublic, architecture, rootDeviceType, null, pageNum

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

    res_type = constant.AWS_RESOURCE_TYPE
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
