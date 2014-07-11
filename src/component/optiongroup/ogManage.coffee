define [
    'constant'
    'CloudResources'
    'toolbar_modal'
    './component/optiongroup/ogTpl'
    'i18n!/nls/lang.js'
    'event'
    'UI.modalplus'

], ( constant, CloudResources, toolbar_modal, template, lang, ide_event, modalplus ) ->

    valueInRange = ( start, end ) ->
        ( val ) ->
            val = +val
            if val > end or val < start
                return "The value '#{val}' is not an allowed value."
            null

    Backbone.View.extend

        id: 'modal-option-group'
        tagName: 'section'
        className: 'modal-toolbar'

        events:

            'click .option-item .switcher': 'optionChanged'
            'click .cancel': 'cancel'
            'click .add-option': 'addOption'
            'click .save-btn': 'saveClicked'
            'submit form': 'doNothing'


        doNothing: -> false

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

            null

        initialize: (option) ->

            optionCol = CloudResources(constant.RESTYPE.DBENGINE, Design.instance().region())
            engineOptions = optionCol.getEngineOptions(option.engine)

            @ogOptions = engineOptions[option.version] if engineOptions
            @ogModel = option.model

            # for option data store
            @ogDataStore = {}

            null

        render: ->

            @$el.html template.og_modal @ogModel.toJSON()
            @initModal @el
            @renderOptionList()
            @

        renderOptionList: ->

            @$el.find('.option-list').html template.og_option_item({
                ogOptions: @ogOptions
            })

        slide: ( option, callback ) ->

            if not option.DefaultPort and not option.OptionGroupOptionSettings
                callback {}
                return
            @optionCb = callback
            @renderSlide option
            @$('.slidebox').addClass 'show'

        cancel: ->
            @$('.slidebox').removeClass 'show'
            @optionCb?(null)
            null

        addOption: ->

            form = $ 'form'
            if not form.parsley 'validate'
                @$('.error').html 'Some error occured.'
                return

            data = {
                options: form.serializeArray()
            }

            port = $('#og-port').val()
            sgId = $('#og-sg').val()

            if port then data.port = port
            if sgId then data.sg = Design.instance().component(sgId)?.createRef 'GroupId'

            @optionCb?(data)

            null

        renderSlide: ( option ) ->

            option = jQuery.extend(true, {}, option)

            option.sgs = Design.modelClassForType(constant.RESTYPE.SG).map ( obj ) ->
                json = obj.toJSON()
                json.ruleCount = obj.ruleCount()
                json.memberCount = obj.getMemberList().length
                json

            for s in option.OptionGroupOptionSettings or []
                if s.AllowedValues.indexOf('-') >= 0
                    arr = s.AllowedValues.split '-'
                    start = +arr[0]
                    end = +arr[1]

                    s.start = start
                    s.end = end

                    if end - start < 10
                        s.items = _.range start, end + 1

                else if s.AllowedValues.indexOf(',') >= 0
                    s.items = s.AllowedValues.split ','

            @$('form').html template.og_slide option or {}

            # Parsley
            $('form input').each ->
                $this = $ @
                start = +$this.data 'start'
                end = +$this.data 'end'

                if start and end
                    $this.parsley 'custom', valueInRange start, end

            null

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

        close: ->

            @optionCb = null
            @remove()

        optionChanged: (event) ->

            that = this

            $switcher = $(event.currentTarget)
            $switcher.toggleClass('on')

            $optionItem = $switcher.parents('.option-item')
            optionIdx = Number($optionItem.data('idx'))
            optionName = Number($optionItem.data('name'))

            if $switcher.hasClass('on')
                @slide @ogOptions[optionIdx], (optionData) ->
                    if optionData
                        that.ogDataStore[optionName] = optionData
                    else
                        that.setOption($optionItem, false)

        setOption: ($item, value) ->

            $switcher = $item.find('.switcher')
            if value then $switcher.addClass('on') else $switcher.removeClass('on')

        getOption: ($item) ->

            $switcher = $item.find('.switcher')
            return $switcher.hasClass('on')

        saveClicked: () ->

            that = this

            # set name and desc
            ogName = @$('.og-name').val()
            ogDesc = @$('.og-description').val()
            @ogModel.set('name', ogName)
            @ogModel.set('ogDescription', ogDesc)

            # set option
            ogDataAry = []
            $ogItemList = @$('.option-list .option-item')
            _.each $ogItemList, (ogItem) ->
                $ogItem = $(ogItem)
                option = that.getOption($ogItem)
                if option
                    ogName = $ogItem.data('name')
                    ogData = that.ogDataStore[ogName]
                    ogDataAry.push(ogData)
                null

            @ogModel.set('options', ogDataAry)
            
            @__modalplus.close()
            null
