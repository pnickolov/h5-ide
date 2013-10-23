#############################
#  View(UI logic) for design/property
#############################

define [ 'event',
         'text!./template.html'
         'backbone', 'jquery', 'handlebars'
], ( ide_event, template ) ->

    PropertyView = Backbone.View.extend {

        el         : '#property-panel'

        propertyHeadStateMap : {}

        initialize : ->

            ##########################
            # Handlebar helper
            ##########################

            Handlebars.registerHelper 'ifCond', ( v1, v2, options ) ->
                return options.fn this if v1 is v2
                return options.inverse this

            Handlebars.registerHelper 'emptyStr', ( v1 ) ->
                if v1 then new Handlebars.SafeString v1 else '-'

            Handlebars.registerHelper 'timeStr', ( v1 ) ->
                d = new Date( v1 )

                if isNaN( Date.parse( v1 ) ) or not d.toLocaleDateString or not d.toTimeString
                    if v1
                        return new Handlebars.SafeString v1
                    else
                        return '-'

                d = new Date( v1 )
                d.toLocaleDateString() + " " + d.toTimeString()

            #listen
            $( document.body )
                .on( 'click', '#hide-property-panel', this.togglePropertyPanel )
                .on( 'click', '.option-group-head', _.bind( this.toggleOption, this ))
                .on( 'click', '#hide-second-panel', _.bind( this.hideSecondPanel, this ))

            null

        render     : () ->
            this.$el.html( template )
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE
            null

        getCurrentCompUid : () ->
            event = {}
            @trigger "GET_CURRENT_UID", event
            event.uid


        togglePropertyPanel : ( event ) ->
            console.log 'togglePropertyPanel'
            $( '#property-panel' ).toggleClass( 'hiden' ).toggleClass( 'transition', true )
            $( '#canvas-panel' ).toggleClass 'right-hiden'
            $( '#hide-property-panel' ).toggleClass 'icon-caret-left'
            $( '#hide-property-panel' ).toggleClass 'icon-caret-right'
            false

        toggleOption : ( event ) ->
            $toggle = $(event.currentTarget)

            if $toggle.is("button") or $toggle.is("a")
                return

            hide    = $toggle.hasClass("expand")
            $target = $toggle.next()

            if hide
                $target.css("display", "block").slideUp(200)
            else
                $target.slideDown(200)

            $toggle.toggleClass("expand")

            stackId = MC.canvas_data.id
            if !@propertyHeadStateMap[stackId]
                @propertyHeadStateMap[stackId] = {}

            if $('#property-second-panel').is(':hidden')
                # added by song ######################################
                # record head state
                headElemAry = $('#property-panel').find('.option-group-head')
                headExpandStateAry = []
                headCompUID = @getCurrentCompUid()
                if !headCompUID then headCompUID = stackId

                _.each headElemAry, (headElem) ->
                    $headElem = $(headElem)
                    expandState = $headElem.hasClass('expand')
                    headExpandStateAry.push(expandState)
                    null

                if headCompUID
                    @propertyHeadStateMap[stackId][headCompUID] = headExpandStateAry

                console.log(headExpandStateAry)
                # added by song ######################################

            return false

        optionToggle : ( event ) ->
            $target = $(this)
            $toggle = $target.prev()
            if $toggle.hasClass "expand"
                $target.removeClass("transition").css({
                    "max-height" : "100000px"
                    "overflow"   : "visible"
                })

        # This method is used to show the panel immediately if the panel is hidden.
        forceShow : () ->
            $( '#canvas-panel' ).removeClass 'right-hiden'
            $( '#property-panel' ).removeClass 'hiden transition'
            $( '#hide-property-panel' ).removeClass( 'icon-caret-left' ).addClass( 'icon-caret-right' )
            null

        showSecondPanel : () ->
            $("#hide-second-panel").data("tooltip", "Back to " + $("#property-title").text())

            $("#property-second-panel").show().animate({left:"0%"}, 200)

            $("#property-first-panel").animate {left:"-30%"}, 200, ()->
                $("#property-first-panel").hide()

        hideSecondPanel : () ->
            $panel = $("#property-second-panel")
            $panel.animate {left:"100%"}, 200, ()->
                $("#property-second-panel").hide()
            $("#property-first-panel").show().animate {left:"0%"}, 200

            this.trigger "HIDE_SUBPANEL"
            false

        immHideSecondPanel : () ->
            $("#property-second-panel").css {
                display : "none"
                left    : "100%"
            }

            $("#property-first-panel").css {
                display : "block"
                left    : "0px"
            }
            null

        load : () ->
            # 1. Force to lost focus, so that value can be saved. Better than $("input:focus").
            $( document.activeElement ).filter( 'input, textarea' ).blur()

            # 2. Hide second panel if there's any
            @immHideSecondPanel()
            null

        afterLoad : ()->
            stackId = MC.canvas_data.id
            if $('#property-second-panel').is(':hidden')
                # added by song ######################################
                # restore head state
                headCompUID = @getCurrentCompUid()
                if !headCompUID then headCompUID = stackId

                headExpandStateAry = null
                if @propertyHeadStateMap[stackId]
                    headExpandStateAry = @propertyHeadStateMap[stackId][headCompUID]

                if headExpandStateAry
                    headElemAry = $('#property-panel').find('.option-group-head')
                    _.each headElemAry, (headElem, i) ->
                        $headElem = $(headElem)
                        if headExpandStateAry[i]
                            $headElem.addClass('expand')
                        else
                            $headElem.removeClass('expand')
                        null

                # clear invalid state in map
                if @propertyHeadStateMap[stackId]
                    _.each @propertyHeadStateMap[stackId], (stateAry, compUID) ->
                        if !MC.canvas_data.component[compUID] and compUID isnt stackId and compUID.indexOf('i-') isnt 0
                            delete @propertyHeadStateMap[stackId][compUID]
                        null
                # added by song ######################################
            null
    }

    return PropertyView
