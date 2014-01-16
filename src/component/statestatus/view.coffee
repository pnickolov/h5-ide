#############################
#  View(UI logic) for component/statestatus
#############################

define [ 'event'
       , 'text!./template.html'
       , 'backbone'
       , 'jquery'
       , 'handlebars'

], ( ide_event, template ) ->

    StateStatusView = Backbone.View.extend

        template: {}

        events:
            'click .modal-close': 'closePopup'

        initialize: () ->
            @items = @model.get( 'items' )
            @listenTo @items, 'add', @renderItem
            @listenTo @model, 'change:items', @renderAllItem
            #@listenTo @items, 'remove', @

            @compileTpl()
            @registerHelper()

            @itemView = @customView()

        customView: () ->
            parent = @
            Backbone.View.extend
                tagName: 'li'
                className: 'state-status-item'
                template: parent.template.item

                initialize: () ->
                    @listenTo @model, 'change', @render

                render: () ->
                    @$el.html @template @model.toJSON()
                    @

        render: () ->

            @$statusModal = @$el

            @$el.html @template.modal
            @$( '.modal-state-statusbar' ).html @template.content

            @renderAllItem()

            $( '#status-bar-modal' )
                .html( @el )
                .show()

            @

        renderAllItem: () ->
            items = @items
            # test
            appStoped = Design.instance().getState() is 'Stopped'

            if items.length and not appStoped
                @renderContainer()
                items.each @renderItem, this

            else
                @renderPending()

        renderContainer: () ->
            @$( '.scroll-content' ).html @template.container


        renderItem: ( model, index ) ->
            view = new @itemView model: model
            @$( '.state-status-list' ).append view.render().el

        renderPending: () ->
            @$( '.scroll-content' ).html @template.pending

        registerHelper: () ->
            Handlebars.registerHelper 'UTC', ( text ) ->
                new Handlebars.SafeString new Date( text ).toUTCString()

        compileTpl: () ->
            # generate template
            tplRegex = /(\<!-- (.*) --\>)(\n|\r|.)*?(?=\<!-- (.*) --\>)/ig
            tplHTMLAry = template.match tplRegex
            htmlMap = {}

            _.each tplHTMLAry, ( tplHTML ) ->
                commentHead = tplHTML.split( '\n' )[ 0 ]
                tplType = commentHead.replace( /(<!-- )|( -->)/g, '' )
                htmlMap[ tplType ] = tplHTML
                null

            stateStatusModalHTML = htmlMap[ 'statestatus-template-modal' ]
            stateStatusContentHTML = htmlMap[ 'statestatus-template-status-content' ]
            stateStatusItemHTML = htmlMap[ 'statestatus-template-status-item' ]

            pending = htmlMap[ 'statestatus-template-status-pending' ]
            container = htmlMap[ 'statestatus-template-status-item-container' ]

            @template.modal     = stateStatusModalHTML
            @template.content   = stateStatusContentHTML
            @template.item      = Handlebars.compile stateStatusItemHTML

            @template.pending      = pending
            @template.container = container

            @template

        closePopup : ->
            $( '#status-bar-modal' ).hide()
            @trigger 'CLOSE_POPUP'


    StateStatusView