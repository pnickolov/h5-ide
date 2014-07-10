define [
    'constant'
    'CloudResources'
    'toolbar_modal'
    './component/optiongroup/ogTpl'
    'i18n!/nls/lang.js'
    'event'
    'UI.modalplus'

], ( constant, CloudResources, toolbar_modal, template, lang, ide_event, modalplus ) ->

    Backbone.View.extend
        tagName: 'section'
        id: 'modal-option-group'
        className: 'modal-toolbar'

        events:

            'click .option-item .switcher': 'optionChanged'

            'click .cancel': 'cancel'

        getModalOptions: ->
            title: "Edit Option Group"
            classList: 'option-group-manage'
            context: that

        initModal: (tpl) ->
            options =
                template        : tpl
                title           : "Edit Option Group"
                disableFooter   : true
                disableClose    : true
                width           : '855px'
                height          : '473px'
                compact         : true

            @__modalplus = new modalplus options
            @__modalplus.on 'closed', @close, @

        initialize: (option) ->

            window.ogManage = @
            optionCol = CloudResources(constant.RESTYPE.DBENGINE, Design.instance().region())
            engineOptions = optionCol.getEngineOptions(option.engine)
            @ogOptions = engineOptions[option.version] if engineOptions

        render: ->

            @$el.html template.og_modal {}
            @renderModal()
            @renderOptionList()
            @

        renderModal: ->
            @initModal @el
            @

        renderOptionList: ->

            @$el.find('.option-list').html template.og_option_item({
                ogOptions: @ogOptions
            })

        slide: ( option ) ->

            #if not option.DefaultPort and not option.OptionGroupOptionSettings
            #    return false

            @renderSlide option
            @$('.slidebox').addClass 'show'

        cancel: -> @$('.slidebox').removeClass 'show'


        renderSlide: ( option ) ->
            option = jQuery.extend(true, {}, option)

            option.sgs = Design.modelClassForType(constant.RESTYPE.SG).map ( obj ) -> obj.toJSON()

            for s in option.OptionGroupOptionSettings
                if s.AllowedValues.indexOf('-') >= 0
                    arr = s.AllowedValues.split '-'
                    start = +arr[0]
                    end = +arr[1]
                    if end - start < 10
                        s.items = _.range start, end + 1
                else if s.AllowedValues.indexOf(',') >= 0
                    s.items = s.AllowedValues.split ','


            @$('.content').html template.og_slide option or {}

        processCol: () ->
            @renderList({})

        renderList: ( data ) ->
            @modal.setContent( template.modal_list data )

        renderNoCredential: () ->
            @modal.render('nocredential').toggleControls false

        renderSlides: ( which, checked ) ->
            tpl = template[ "slide_#{which}" ]
            slides = @getSlides()
            slides[ which ]?.call @, tpl, checked

        close: -> @remove()

        quickCreate: ->

        optionChanged: (event) ->

            $switcher = $(event.currentTarget)
            $switcher.toggleClass('on')
            
            $optionItem = $switcher.parents('.option-item')
            optionIdx = Number($optionItem.data('idx'))

            if $switcher.hasClass('on')
                @slide @ogOptions[optionIdx]
