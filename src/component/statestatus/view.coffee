#############################
#  View(UI logic) for component/statestatus
#############################

define [ 'event'
       , 'text!./template.tpl'
       , 'backbone'
       , 'jquery'
       , 'handlebars'

], ( ide_event, template ) ->

    StateStatusView = Backbone.View.extend

        template: {}

        events:
            'click .modal-close'        : 'closePopup'
            'click .state-status-update': 'renderNew'

        initialize: () ->
            @items = @model.get( 'items' )
            @listenTo @model, 'change:items', @renderAllItem
            @listenTo @model, 'change:stop', @renderAllItem
            @listenTo @model, 'change:new', @renderUpdate
            #@listenTo @items, 'remove', @

            @compileTpl()

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

                events:
                    'click .state-status-item-detail': 'openStateEditor'

                openStateEditor: ->
                    ide_event.trigger ide_event.OPEN_PROPERTY, null, @model.get( 'uid' ), false, 'state'
                    null

        render: () ->

            @$statusModal = @$el

            @$el.html @template.modal
            @$( '.modal-state-statusbar' ).html @template.content

            @renderAllItem()

            $( '#status-bar-modal' )
                .html( @el )
                .show()

            @

        renderUpdate: ( model ) ->
            newCount = model.get( 'new' ).length

            if newCount
                @$( '.update-tip' ).html @template.update newCount

            scrollbar.scrollTo @$( '.scroll-wrap' ), 'top': 0

        renderNew: () ->
            @$( '.update-tip div' ).hide()
            @renderAllItem()
            @model.flushNew()

        renderAllItem: () ->
            items = @items

            if @model.get 'stop'
                @renderPending()
                return

            if items.length
                @renderContainer()
                items.each @renderItem, this

        renderItem: ( model, index ) ->
            view = new @itemView model: model
            view.render()
            view.$el.hide()
            @$( '.state-status-list' ).append view.el

            if model in @model.get 'new'
                _.defer ->
                    view.$el.fadeIn 300
            else
                view.$el.show()

        renderContainer: () ->
            @$( '.status-item' ).html @template.container

        renderPending: () ->
            @$( '.status-item' ).html @template.pending


        compileTpl: () ->
            # generate template
            tplRegex = /(\<!-- (.*) --\>)(\n|\r|.)*?(?=\<!-- (.*) --\>)/ig
            tplHTMLAry = template.match tplRegex
            htmlMap = {}

            _.each tplHTMLAry, ( tplHTML ) ->
                commentHead = tplHTML.split( '\n' )[ 0 ]
                tplType = commentHead.replace( /(<!-- )|( -->)/g, '' )
                tplType = $.trim(tplType)
                htmlMap[ tplType ] = tplHTML
                null

            stateStatusModalHTML = htmlMap[ 'statestatus-template-modal' ]
            stateStatusContentHTML = htmlMap[ 'statestatus-template-status-content' ]
            stateStatusItemHTML = htmlMap[ 'statestatus-template-status-item' ]
            stateStatusUpdateHTML = htmlMap[ 'statestatus-template-status-update' ]

            pending = htmlMap[ 'statestatus-template-status-pending' ]
            container = htmlMap[ 'statestatus-template-status-item-container' ]

            @template.modal     = stateStatusModalHTML
            @template.content   = stateStatusContentHTML
            @template.item      = Handlebars.compile stateStatusItemHTML
            @template.update    = Handlebars.compile stateStatusUpdateHTML

            @template.pending      = pending
            @template.container = container

            @template

        closePopup : ->
            $( '#status-bar-modal' ).hide()
            @trigger 'CLOSE_POPUP'


    StateStatusView
