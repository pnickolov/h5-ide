#############################
#  View(UI logic) for design/property
#############################

define [ './temp_view',
         'event'
         'backbone', 'jquery', 'handlebars',
         'UI.fixedaccordion', 'UI.modal', 'UI.selectbox', 'UI.tooltip', 'UI.notification', 'UI.scrollbar', 'UI.toggleicon', 'UI.multiinputbox', 'MC.validate', 'UI.parsley'
], ( temp_view, ide_event ) ->

    PropertyView = Backbone.View.extend {

        el         : '#property-panel'

        initialize : ->
            #listen
            #$( document ).delegate '#hide-property-panel', 'click', this.togglePropertyPanel
            #$( window   ).on 'resize', fixedaccordion.resize
            #listen
            $( document.body ).on('click', '#hide-property-panel', this.togglePropertyPanel)
                              .on('click', ".option-group-head", this.toggleOption)
                              .on('click', "#hide-second-panel", _.bind( this.hideSecondPanel, this) )

                              .on('transitionEnd webkitTransitionEnd transitionend oTransitionEnd msTransitionEnd', '.option-group', this.optionToggle)

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
            $( event ).children().first().toggleClass('icon-double-angle-left').toggleClass('icon-double-angle-right')
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
                h = $target.innerHeight()
                $target.css({
                        "max-height" : h
                        "overflow"   : "hidden"
                    })
                    .toggleClass("transition", false)

                setTimeout ()->
                    $target.toggleClass("transition", true).css("max-height", 0)
                , 10
            else
                $target.removeClass("transition").css {
                    position     : "absolute"
                    visibility   : "hidden"
                    "max-height" : "100000px"
                    overflow     : "hidden"
                }
                h = $target.innerHeight()
                $target.css("max-height", "0")
                setTimeout () ->
                    $target.toggleClass("transition", true).css {
                        position     : ""
                        visibility   : ""
                        "max-height" : h
                    }

                , 10

            $toggle.toggleClass("expand")


            return false

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
            $("#property-second-panel .property-content").html data.dom
            $("#property-panel .property-wrap").addClass "show-second-panel"

            $("#hide-second-panel").data("tooltip", "Back to " + $("#property-title").text())

        hideSecondPanel : () ->
            $("#property-panel .property-wrap").removeClass "show-second-panel"
            this.trigger "HIDE_SUBPANEL", $("#property-second-title").attr( "data-id" )
            false

        immHideSecondPanel : () ->
            if not $("#property-panel .property-wrap").hasClass "show-second-panel"
                return

            # Hide Second Panel immediately
            setTimeout () ->
                $("#property-panel").removeClass "transition"
                $("#property-panel .property-wrap").removeClass "show-second-panel"

                setTimeout ()->
                    $("#property-panel").addClass "transition"
                    null
                , 10

                null
            , 10

            null
    }

    return PropertyView
