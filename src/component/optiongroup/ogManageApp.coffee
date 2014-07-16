define [
    'constant'
    'CloudResources'
    './component/optiongroup/ogTpl'
    'i18n!/nls/lang.js'
    'event'
    'UI.modalplus'

], ( constant, CloudResources, template, lang, ide_event, modalplus ) ->

    Backbone.View.extend
        id: 'modal-option-group'
        tagName: 'section'
        className: 'modal-toolbar modal-option-group-app'
        events:
            'click .toggle-og-detail': "toggleDetail"

        toggleDetail: (e) ->
            $target = $ e.currentTarget
            $li = $target.closest( 'li' )
            $li.toggleClass( 'show-details' )
            $li.find( '.toggle-og-detail' ).toggle()


        initModal: (tpl) ->
            options =
                template        : tpl
                title           : @model.get 'appId'
                width           : '855px'
                height          : '473px'
                compact         : true
                confirm         :
                    hide        : true
                cancel          :
                    text        : 'Close'

            @__modalplus = new modalplus options
            @__modalplus.on 'closed', @close, @

            null

        initialize: ( options ) ->
            appId = @model.get 'appId'
            @appData = CloudResources(constant.RESTYPE.DBOG, Design.instance().region()).get(appId)?.toJSON()
            if not @appData then return false

            @render()

        render: ->
            @$el.html template.og_app_modal @appData
            @initModal @el
            @

        close: ->
            @remove()


