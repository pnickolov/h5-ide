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

    capitalizeKey = ( arr ) ->

        returnArr = []

        for a in arr
            obj = {}
            for k, v of a
                newK = k.charAt(0).toUpperCase() + k.substring(1)
                obj[ newK ] = v

            returnArr.push obj

        returnArr

    Backbone.View.extend

        id: 'modal-option-group'
        tagName: 'section'
        className: 'modal-toolbar'

        events:

            'click .option-item .switcher'  : 'optionChanged'
            'click .option-item .option-edit-btn' : 'optionEditClicked'
            'click .cancel'                 : 'cancel'
            'click .add-option'             : 'addOption'
            'click .save-btn'               : 'saveClicked'
            'click .remove-btn'             : 'removeClicked'
            'click .cancel-btn'             : 'cancelClicked'
            'submit form'                   : 'doNothing'
            'click #og-sg input'            : 'changeSg'
            'click .remove-confirm'         : 'removeConfirm'
            'click .remove-cancel'          : 'removeCancel'
            'change #option-apply-immediately': 'changeApplyImmediately'

        changeApplyImmediately: (e) ->
            @model.set 'applyImmediately', e.currentTarget.checked

        changeSg: (e) ->
            checked = e.currentTarget.checked
            sgCbs = $('#og-sg input:checked')
            if not sgCbs.length then return false

            null

        doNothing: -> false

        getModalOptions: ->
            title: "Edit Option Group"
            classList: 'option-group-manage'
            context: that

        initModal: (tpl) ->

            that = this

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

        initialize: (option) ->

            that = this

            @isAppEdit  = Design.instance().modeIsAppEdit()
            @dropdown   = option.dropdown
            @isCreate   = option.isCreate
            @dbInstance = option.dbInstance

            optionCol = CloudResources(constant.RESTYPE.DBENGINE, Design.instance().region())
            engineOptions = optionCol.getOptionGroupsByEngine(Design.instance().region(), option.engine)

            @ogOptions = engineOptions[option.version] if engineOptions
            @ogModel = option.model

            # for option data store
            @ogDataStore = {}
            optionAry = @ogModel.get('options')
            _.each optionAry, (option) ->
                that.ogDataStore[option.OptionName] = option

            # set checked for option list
            _.each @ogOptions, (option) ->
                if that.ogDataStore[option.Name]
                    option.checked = true
                else
                    option.checked = false

                if that.isAppEdit and ( option.Permanent or option.Persistent )
                    option.unmodify = true
                else
                    option.unmodify = false

                null

            null

        render: ->
            ogData = @ogModel.toJSON()
            ogData.isCreate = @isCreate
            ogData.isAppEdit = @isAppEdit

            @$el.html template.og_modal(ogData)
            @initModal @el
            @renderOptionList()
            @__modalplus.resize()
            @

        renderOptionList: ->

            @$el.find('.option-list').html template.og_option_item({
                ogOptions: @ogOptions
                isAppEdit: @isAppEdit
            })

        slide: ( option, callback ) ->

            if not option.DefaultPort and not option.OptionGroupOptionSettings
                callback Port: '', VpcSecurityGroupMemberships: [], OptionSettings: []
                return

            @optionCb = callback
            data = @ogDataStore[ option.Name ]
            @renderSlide option, data
            @$('.slidebox').addClass 'show'

        slideUp: -> @$('.slidebox').removeClass 'show'

        cancel: ->

            @slideUp()
            @optionCb?(null)
            null

        removeConfirm: ->

            @ogModel.remove()
            @dropdown.setSelection @dbInstance.getOptionGroupName()
            @dropdown.refresh()
            @slideUp()
            @__modalplus.close()

        removeCancel: ->

            @slideUp()

        addOption: (e) ->

            optionName = $(e.currentTarget).data 'optionName'

            form = $ 'form'
            if not form.parsley 'validate'
                @$('.error').html 'Some error occured.'
                return

            data = {
                OptionSettings: capitalizeKey form.serializeArray()
            }

            port = $('#og-port').val()
            sgCbs = $('#og-sg input:checked')

            data.Port = port or ''

            data.VpcSecurityGroupMemberships = []
            sgCbs.each () ->
                data.VpcSecurityGroupMemberships.push Design.instance().component($(this).data('uid')).createRef 'GroupId'

            @optionCb?(data)
            @ogDataStore[optionName] = data

            @slideUp()
            null

        renderSlide: ( option, data ) ->

            option = jQuery.extend(true, {}, option)

            if option.OptionGroupOptionSettings and not _.isArray option.OptionGroupOptionSettings
                option.OptionGroupOptionSettings = [ option.OptionGroupOptionSettings ]

            if option.DefaultPort
                option.port = data?.Port or option.DefaultPort
                option.sgs = []
                Design.modelClassForType(constant.RESTYPE.SG).each ( obj ) ->
                    json = obj.toJSON()
                    json.default = obj.isDefault()
                    json.color = obj.color
                    json.ruleCount = obj.ruleCount()
                    json.memberCount = obj.getMemberList().length

                    if data and data.VpcSecurityGroupMemberships
                        if obj.createRef( 'GroupId' ) in data.VpcSecurityGroupMemberships
                            json.checked = true

                    if json.default
                        if not data then json.checked = true
                        option.sgs.unshift json
                    else
                        option.sgs.push json



            for s, i in option.OptionGroupOptionSettings or []

                if s.AllowedValues.indexOf(',') >= 0
                    s.items = s.AllowedValues.split ','
                else if s.AllowedValues.indexOf('-') >= 0
                    arr = s.AllowedValues.split '-'
                    start = +arr[0]
                    end = +arr[1]

                    s.start = start
                    s.end = end

                    if end - start < 10
                        s.items = _.range start, end + 1

                if s.items then s.AllowedValues = ''

                if data
                    s.value = data.OptionSettings[i].Value
                else
                    s.value = s.DefaultValue


            @$('form').html template.og_slide option or {}

            # Parsley
            $('form input').each ->
                $this = $ @
                start = +$this.data 'start'
                end = +$this.data 'end'

                if start and end
                    $this.parsley 'custom', valueInRange start, end

            null

        renderRemoveConfirm: () ->

            @$('.slidebox').addClass 'show'
            @$('form').html template.og_slide_remove {}

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
            # @remove()

        optionChanged: (event) ->

            that = this

            $switcher = $(event.currentTarget)
            $optionEdit = $switcher.siblings('.option-edit-btn')

            $switcher.toggleClass('on')

            $optionItem = $switcher.parents('.option-item')
            optionIdx = Number($optionItem.data('idx'))
            optionName = $optionItem.data('name')

            if $switcher.hasClass('on')

                $optionEdit.removeClass('invisible')

                @slide @ogOptions[optionIdx], (optionData) ->
                    if optionData
                        that.ogDataStore[optionName] = optionData
                    else
                        that.setOption($optionItem, false)

            else

                $optionEdit.addClass('invisible')

        optionEditClicked: (event) ->

            that = this
            $optionEdit = $(event.currentTarget)
            $optionItem = $optionEdit.parents('.option-item')
            optionIdx = Number($optionItem.data('idx'))
            optionName = $optionItem.data('name')

            @slide @ogOptions[optionIdx], (optionData) ->
                if optionData
                    that.ogDataStore[optionName] = optionData

        setOption: ($item, value) ->

            $switcher = $item.find('.switcher')
            $optionEdit = $switcher.siblings('.option-edit-btn')
            if value
                $switcher.addClass('on')
                $optionEdit.removeClass('invisible')
            else
                $switcher.removeClass('on')
                $optionEdit.addClass('invisible')

        getOption: ($item) ->

            $switcher = $item.find('.switcher')
            return $switcher.hasClass('on')

        saveClicked: () ->

            that = this

            # set name and desc
            ogName = @$('.og-name').val()
            ogDesc = @$('.og-description').val()
            @ogModel.set('name', ogName)
            @ogModel.set('description', ogDesc)

            # set option
            ogDataAry = []
            $ogItemList = @$('.option-list .option-item')
            _.each $ogItemList, (ogItem) ->
                $ogItem = $(ogItem)
                option = that.getOption($ogItem)
                if option
                    ogName = $ogItem.data('name')
                    ogData = that.ogDataStore[ogName]
                    ogData.OptionName = ogName
                    ogDataAry.push(ogData)
                null

            @ogModel.set('options', ogDataAry)

            @dropdown.refresh()

            @__modalplus.close()
            null

        removeClicked: () ->

            that = this
            @renderRemoveConfirm()

        cancelClicked: () ->

            that = this
            @ogModel.remove() if @isCreate
            @__modalplus.close()