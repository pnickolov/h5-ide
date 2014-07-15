define [
    'constant'
    'CloudResources'
    './component/optiongroup/ogTpl'
    'i18n!/nls/lang.js'
    'event'
    'UI.modalplus'

], ( constant, CloudResources, template, lang, ide_event, modalplus ) ->

    Backbone.View.extend
        tagName: 'section'
        className: 'modal-toolbar'
        events:
            '': ""

        initModal: (tpl) ->
            options =
                template        : tpl
                title           : "Edit Option Group"
                disableFooter   : true
                disableClose    : true
                width           : '855px'
                height          : '473px'
                compact         : true
                hideClose       : true

            @__modalplus = new modalplus options
            @__modalplus.on 'closed', @close, @

            null

        initialize: (appId) ->
            @appId = appId

            @appData = CloudResources(constant.RESTYPE.DBOG, Design.instance().region()).get(@appId)?.toJSON()
            if not @appData then return false

            @render()

        render: ->
            @$el.html template.og_app_modal @appData
            @initModal @el
            @

        close: ->
            @remove()


