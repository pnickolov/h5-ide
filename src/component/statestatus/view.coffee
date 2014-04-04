#############################
#  View(UI logic) for component/statestatus
#############################

define [ 'event'
       , './template'
       , 'backbone'
       , 'jquery'
       , 'handlebars'

], ( ide_event, template ) ->

    CustomView = Backbone.View.extend
        tagName: 'li'
        className: 'state-status-item'

        initialize: () ->
            @listenTo @model, 'change', @render

        render: () ->
            @$el.html template.item @model.toJSON()
            @

        events:
            'click .state-status-item-detail': 'openStateEditor'

        openStateEditor: ->
            ide_event.trigger ide_event.OPEN_PROPERTY, null, @model.get( 'uid' ), false, 'state'
            null

    StateStatusView = Backbone.View.extend

        events:
            'click .modal-close'        : 'closePopup'
            'click .state-status-update': 'renderNew'

        initialize: () ->
            @items = @model.get( 'items' )
            @listenTo @model, 'change:items', @renderAllItem
            @listenTo @model, 'change:stop', @renderAllItem
            @listenTo @model, 'change:new', @renderUpdate

            @itemView = CustomView
            null

        render: () ->

            @$statusModal = @$el

            @$el.html template.modal()
            @$( '.modal-state-statusbar' ).html template.content()

            @renderAllItem()

            $( '#status-bar-modal' )
                .html( @el )
                .show()

            @

        renderUpdate: ( model ) ->
            newCount = model.get( 'new' ).length

            if newCount
                @$( '.update-tip' ).html template.update newCount

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
            @$( '.status-item' ).html template.container()

        renderPending: () ->
            @$( '.status-item' ).html template.pending()

        closePopup : ->
            $( '#status-bar-modal' ).hide()
            @trigger 'CLOSE_POPUP'


    StateStatusView
