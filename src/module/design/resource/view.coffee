#############################
#  View(UI logic) for design/resource
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.fixedaccordion', 'UI.selectbox', 'UI.toggleicon', 'UI.searchbar', 'UI.filter', 'UI.radiobuttons', 'UI.modal', 'UI.table'
], ( ide_event, Backbone, $ ) ->

    ResourceView = Backbone.View.extend {

        el         : $ '#resource-panel'

        availability_zone_tmpl : Handlebars.compile $( '#availability-zone-tmpl' ).html()
        resoruce_snapshot_tmpl : Handlebars.compile $( '#resoruce-snapshot-tmpl' ).html()
        quickstart_ami_tmpl    : Handlebars.compile $( '#quickstart-ami-tmpl' ).html()
        my_ami_tmpl            : Handlebars.compile $( '#my-ami-tmpl' ).html()
        favorite_ami_tmpl      : Handlebars.compile $( '#favorite-ami-tmpl' ).html()
        community_ami_tmpl     : Handlebars.compile $( '#community-ami-tmpl' ).html()
        

        initialize : ->
            #listen
            $( window   ).on 'resize', fixedaccordion.resize
            $( document ).on 'ready',  toggleicon.init
            $( document ).on 'ready',  searchbar.init
            $( document ).on 'ready',  selectbox.init
            $( document ).on 'ready',  radiobuttons.init
            #listen
            $( document ).delegate '#hide-resource-panel', 'click',         this.toggleResourcePanel
            $( document ).delegate '#resource-select',     'OPTION_CHANGE', this, this.resourceSelectEvent
            $( document ).delegate '#resource-panel',     'SEARCHBAR_SHOW', this.searchBarShowEvent
            $( document ).delegate '#resource-panel',     'SEARCHBAR_HIDE', this.searchBarHideEvent
            $( document ).delegate '#resource-panel',   'SEARCHBAR_CHANGE', this.searchBarChangeEvent
            $( document ).delegate '#btn-browse-community-ami',   'click' , this, this.openBrowseCommunityAMIsModal
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.hideResourcePanel

        render   : ( template, attrs ) ->
            console.log 'resource render'
   
            $( this.el ).html template
            #
            fixedaccordion.resize()
            null

        listen   : ( model ) ->
            #set this.model
            this.model = model
            #listen model
            this.listenTo this.model, 'change:availability_zone', this.availabilityZoneRender
            this.listenTo this.model, 'change:resoruce_snapshot', this.resourceSnapshotRender
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
            fixedaccordion.show.call($($(this).parent().find('.fixedaccordion-head')[0]))
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

        toggleResourcePanel : ( event ) ->
            console.log 'toggleResourcePanel'
            #
            $( '#resource-panel' ).toggleClass 'hiden'
            $( event ).children().first().toggleClass( 'icon-double-angle-left' ).toggleClass 'icon-double-angle-right'
            $( '#canvas-panel' ).toggleClass 'left-hiden'

        hideResourcePanel : ( type ) ->
            console.log 'hideResourcePanel = ' + type

            if type is 'OPEN_APP'
                $( '#hide-resource-panel' ).trigger 'click'
                $( '#hide-resource-panel' ).hide()
            else
                #
                fixedaccordion.resize()

            if type is 'OPEN_STACK' or type is 'NEW_STACK'
                if $( '#resource-panel' ).attr( 'class' ).indexOf( 'hide' ) isnt -1 then $( '#hide-resource-panel' ).trigger 'click'
                $( '#hide-resource-panel' ).show()

        availabilityZoneRender : () ->
            console.log 'availabilityZoneRender'
            console.log this.model.attributes.availability_zone
            $( '.availability-zone' ).html this.availability_zone_tmpl this.model.attributes
            null

        resourceSnapshotRender : () ->
            console.log 'resourceSnapshotRender'
            console.log this.model.attributes.resoruce_snapshot
            $( '.resoruce-snapshot' ).append this.resoruce_snapshot_tmpl this.model.attributes
            null

        quickstartAmiRender : () ->
            console.log 'quickstartAmiRender'
            console.log this.model.attributes.quickstart_ami
            $( '.quickstart-ami-list' ).html this.quickstart_ami_tmpl this.model.attributes
            null

        myAmiRender : () ->
            console.log 'myAmiRender'
            console.log this.model.attributes.my_ami
            $( '.my-ami-list' ).html this.my_ami_tmpl this.model.attributes
            null

        favoriteAmiRender : () ->
            console.log 'favoriteAmiRender'
            console.log this.model.attributes.favorite_ami
            $( '.favorite-ami-list' ).html this.favorite_ami_tmpl this.model.attributes
            null

        communityAmiBtnRender : () ->
            console.log 'communityAmiRender'
            console.log this.model.attributes.community_ami
            $( '.community-ami' ).html this.community_ami_tmpl this
            null

        openBrowseCommunityAMIsModal : ( event ) ->

            console.log 'openBrowseCommunityAMIsModal'

            modal(MC.template.browseCommunityAmi(''), false)

            #event.data.trigger 'LOADING_COMMUNITY_AMI', event.data.region

        communityAmiRender : () ->

            modal(MC.template.browseCommunityAmi(this.model.attributes), false)
            $($('#selectbox-ami-platform').find('.cur-value')[0]).html($($('#selectbox-ami-platform').find('.selected')[0]).html())
            $('#community-ami-input').on 'keyup', (event)->
                filter.update $('#community-ami-filter'), {
                    value: $(this).val()
                    type:{
                        publicprivate: radiobuttons.data($('#filter-ami-public-private'))
                        ebs: radiobuttons.data($('#filter-ami-EBS-Instance'))
                        bit: radiobuttons.data($('#filter-ami-32bit-64bit'))
                        platform: $($('#selectbox-ami-platform').find('.selected a')[0]).data('id')
                    }
                }
                
            $('#filter-ami-public-private').on 'RADIOBTNS_CLICK', (event, cur_radion) ->

                    result_set = {
                        value:$('#community-ami-input').val()
                        type:{
                            publicprivate:cur_radion
                            ebs: radiobuttons.data($('#filter-ami-EBS-Instance'))
                            bit: radiobuttons.data($('#filter-ami-32bit-64bit'))
                            platform: $($('#selectbox-ami-platform').find('.selected a')[0]).data 'id'
                        }
                    }

                    filter.update($('#community-ami-filter'), result_set)

            $('#filter-ami-EBS-Instance').on 'RADIOBTNS_CLICK', (event, cur_radion) ->
                
                    result_set = {
                        value:$('#community-ami-input').val(),
                        type:{
                            publicprivate: radiobuttons.data($('#filter-ami-public-private'))
                            ebs: cur_radion
                            bit: radiobuttons.data($('#filter-ami-32bit-64bit'))
                            platform: $($('#selectbox-ami-platform').find('.selected a')[0]).data('id')
                        }
                    }

                    filter.update($('#community-ami-filter'), result_set)

            $('#filter-ami-32bit-64bit').on 'RADIOBTNS_CLICK', (event, cur_radion) ->
                    result_set = {
                        value:$('#community-ami-input').val()
                        type:{
                            publicprivate: radiobuttons.data($('#filter-ami-public-private'))
                            ebs: radiobuttons.data($('#filter-ami-EBS-Instance'))
                            bit: cur_radion
                            platform: $($('#selectbox-ami-platform').find('.selected a')[0]).data('id')
                        }
                    }
                    filter.update($('#community-ami-filter'), result_set)

            $('#selectbox-ami-platform').on 'OPTION_CHANGE', (event, id) ->
                result_set = {
                    value:$('#community-ami-input').val(),
                    type:{
                        publicprivate: radiobuttons.data($('#filter-ami-public-private')),
                        ebs: radiobuttons.data($('#filter-ami-EBS-Instance')),
                        bit: radiobuttons.data($('#filter-ami-32bit-64bit')),
                        platform: id
                    } }

                filter.update($('#community-ami-filter'), result_set)
            null

    }

    return ResourceView
