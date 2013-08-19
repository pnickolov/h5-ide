#############################
#  View(UI logic) for design/property
#############################

define [ './temp_view',
         'event'
         'backbone', 'jquery', 'handlebars',
         'UI.modal', 'UI.selectbox', 'UI.tooltip', 'UI.notification', 'UI.scrollbar', 'UI.toggleicon', 'UI.multiinputbox', 'MC.validate', 'UI.parsley'
], ( temp_view, ide_event ) ->

    PropertyView = Backbone.View.extend {

        el         : '#property-panel'

        back_dom   : 'none'

        initialize : ->
            #listen
            $( document.body ).on( 'click',           '#hide-property-panel', this.togglePropertyPanel                )
                              .on( 'click',           '.option-group-head',   this.toggleOption                       )
                              .on( 'click',           '#hide-second-panel',   _.bind( this.hideSecondPanel, this     ))
                              .on( 'DOMNodeInserted', '.property-wrap',       this, _.debounce( this.domChange, 200, false ))

            #                  .on('transitionEnd webkitTransitionEnd transitionend oTransitionEnd msTransitionEnd', '.option-group', this.optionToggle)

        render     : ( template ) ->
            console.log 'property render'
            this.$el.html template
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            console.log 're-property render'
            if $.trim( this.$el.html() ) is 'loading...' then $( '#property-panel' ).html template

        togglePropertyPanel : ( event ) ->
            console.log 'togglePropertyPanel'
            $( '#property-panel' ).toggleClass 'hiden'
            $( '#canvas-panel' ).toggleClass 'right-hiden'
            false

        refresh : ->
            console.log 'refresh'
            selectbox.init()
            temp_view.ready()

        updateHtml : ( back_dom ) ->
            console.log 'update property html'
            $( '#property-panel' ).html back_dom
            null

        toggleOption : ( event ) ->
            $target = $(event.target)
            if $target.is("button") or $target.is("a")
                return

            $toggle = $(this)
            hide    = $toggle.hasClass("expand")
            $target = $toggle.next()

            if hide
                $target.css("display", "block").slideUp(200)
            else
                $target.slideDown(200)
            $toggle.toggleClass("expand")
            return false

            # if hide
            #     h = $target.innerHeight()
            #     $target.css({
            #             "max-height" : h
            #             "overflow"   : "hidden"
            #         })
            #         .toggleClass("transition", false)

            #     setTimeout ()->
            #         $target.toggleClass("transition", true).css("max-height", 0)
            #     , 10
            # else
            #     $target.removeClass("transition").css {
            #         position     : "absolute"
            #         visibility   : "hidden"
            #         "max-height" : "100000px"
            #         overflow     : "hidden"
            #     }
            #     h = $target.innerHeight()
            #     $target.css("max-height", "0")
            #     setTimeout () ->
            #         $target.toggleClass("transition", true).css {
            #             position     : ""
            #             visibility   : ""
            #             "max-height" : h
            #         }

            #     , 10

            # $toggle.toggleClass("expand")


            # return false

        optionToggle : ( event ) ->
            $target = $(this)
            $toggle = $target.prev()
            if $toggle.hasClass "expand"
                $target.removeClass("transition").css({
                    "max-height" : "100000px"
                    "overflow"   : "visible"
                })



        setTitle : ( title ) ->
            $("#property-title").html( title )

        showSecondPanel : ( data ) ->
            $("#property-second-title").html( data.title ).attr( "data-id", data.id )
            $("#hide-second-panel").data("tooltip", "Back to " + $("#property-title").text())

            $("#property-second-panel").show().animate({left:"0px"}, 200).find(".property-content").html( data.dom )
            $("#property-first-panel").animate {left:"-30%"}, 200, ()->
                $("#property-first-panel").hide()


        hideSecondPanel : () ->
            $panel = $("#property-second-panel")
            $panel.animate {left:"100%"}, 200, ()->
                $("#property-second-panel").hide()
            $("#property-first-panel").show().animate {left:"0px"}, 200

            this.trigger "HIDE_SUBPANEL", $("#property-second-title").attr( "data-id" )
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

        domChange : ( event ) ->
            console.log 'listen DOMNodeInserted'
            #console.log event.target
            #console.log event.data.back_dom
            #
            back_dom = event.data.back_dom
            #
            return if back_dom is 'none'
            ###
            temp = $( event.data.back_dom ).find( '#property-second-panel' ).find( '.property-content' ).html()
            if temp isnt ''
                event.data.back_dom = 'none'
                $( '.property-content' ).html temp
            ###
            event.data.back_dom = 'none'
            $( '#property-panel' ).html back_dom

            null
    }

    return PropertyView
