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
                return sprintf lang.ide.RDS_VALUE_IS_NOT_ALLOWED, val
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
                title           : lang.ide.RDS_EDIT_OPTION_GROUP
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
            @ogNameOptionMap = {}

            # for option data store
            @ogDataStore = {}
            optionAry = @ogModel.get('options')
            _.each optionAry, (option) ->
                that.ogDataStore[option.OptionName] = option
                null

            # set checked for option list
            _.each @ogOptions, (option) ->

                that.ogNameOptionMap[option.Name] = option

                if that.ogDataStore[option.Name]
                    option.checked = true
                else
                    option.checked = false

                if that.isAppEdit and ( option.Permanent or option.Persistent ) and that.ogModel.get('appId')
                    option.unmodify = true
                else
                    option.unmodify = false

                # if option.OptionsDependedOn and option.OptionsDependedOn.OptionName
                #     option.disabled = true

                null

            null

        render: ->
            ogData = @ogModel.toJSON()
            ogData.isCreate = @isCreate
            ogData.isAppEdit = @isAppEdit
            ogData.engineType = @ogModel.engineType()

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
                @$('.error').html lang.ide.RDS_SOME_ERROR_OCCURED
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
                    s.items = _.map s.AllowedValues.split(','), (v) ->
                        value: v, selected: data and v is data.OptionSettings[i].Value


                else if s.AllowedValues.indexOf('-') >= 0
                    arr = s.AllowedValues.split '-'
                    start = +arr[0]
                    end = +arr[1]

                    s.start = start
                    s.end = end
                    ###
                    if end - start < 10
                        s.items = _.range start, end + 1
                    ###

                # Hidden allowed values when input shown as a dropdown.
                if s.items then s.AllowedValues = ''

                if data
                    s.value = data.OptionSettings[i].Value
                else
                    s.value = s.DefaultValue


            @$('.form').html template.og_slide option or {}
            @$('.error').html ''

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
            @remove()

        optionChanged: (event) ->

            that = this

            $switcher = $(event.currentTarget)
            $optionEdit = $switcher.siblings('.option-edit-btn')

            $switcher.toggleClass('on')

            $optionItem = $switcher.parents('.option-item')
            optionIdx = Number($optionItem.data('idx'))
            optionName = $optionItem.data('name')

            # _switchOptionItem = (optionName, isOn) ->

            #     $ogItemList = @$('.option-list .option-item')
            #     _.each $ogItemList, (ogItem) ->
            #         $ogItem = $(ogItem)
            #         option = that.getOption($ogItem)
            #         if option
            #             ogName = $ogItem.data('name')
            #             ogDefine = that.ogNameOptionMap[ogName]
            #             if ogDefine.OptionsDependedOn and ogDefine.OptionsDependedOn.OptionName
            #                 dependName = ogDefine.OptionsDependedOn.OptionName
            #                 if dependName.indexOf(optionName) isnt -1
            #                     that.setOption($ogItem, isOn)
            #                     if isOn
            #                         $ogItem.removeClass('disabled')
            #                     else
            #                         $ogItem.addClass('disabled')
            #         null

            if $switcher.hasClass('on')

                $optionEdit.removeClass('invisible')

                @slide @ogOptions[optionIdx], (optionData) ->
                    if optionData
                        that.ogDataStore[optionName] = optionData
                    else
                        that.setOption($optionItem, false)
                    null

            else

                $optionEdit.addClass('invisible')

            null

        optionEditClicked: (event) ->

            that = this
            $optionEdit = $(event.currentTarget)
            $optionItem = $optionEdit.parents('.option-item')
            optionIdx = Number($optionItem.data('idx'))
            optionName = $optionItem.data('name')

            @slide @ogOptions[optionIdx], (optionData) ->
                if optionData
                    that.ogDataStore[optionName] = optionData
                null

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

        getOptionByName: (ogName) ->

            $switcher = @$('.option-list .option-item[data-name="' + ogName + '"]').find('.switcher')
            return $switcher.hasClass('on')

        saveClicked: () ->

            that = this

            $ogName = @$('.og-name')
            $ogDesc = @$('.og-description')

            $ogName.parsley 'custom', ( val ) ->

                errTip = 'Option group name invalid'
                if (val[val.length - 1]) is '-' or (val.indexOf('--') isnt -1)
                    return errTip
                if val.length < 1 or val.length > 255
                    return errTip
                if not MC.validate('letters', val[0])
                    return errTip

            $ogDesc.parsley 'custom', ( val ) ->

                errTip = 'Option group description invalid'
                if val.length < 1
                    return errTip

            # check if option is right depend
            isRightDepend = true
            $ogItemList = that.$('.option-list .option-item')
            _.each $ogItemList, (ogItem) ->

                $ogItem = $(ogItem)
                option = that.getOption($ogItem)

                if option

                    ogName = $ogItem.data('name')
                    ogDefine = that.ogNameOptionMap[ogName]

                    if ogDefine.OptionsDependedOn and ogDefine.OptionsDependedOn.OptionName
                        dependName = ogDefine.OptionsDependedOn.OptionName
                        dependAry = dependName.split(',')
                        needAry = []
                        _.each dependAry, (depend) ->
                            isOn = that.getOptionByName(depend)
                            needAry.push(depend) if not isOn
                        if needAry.length
                            isRightDepend = false
                            errTip = "#{ogName} depend on #{needAry.join(',')} option."
                            that.$('.err-tip').text(errTip)
                null

            return if not isRightDepend

            if $ogName.parsley('validate') and $ogDesc.parsley('validate')

                # set name and desc
                ogName = $ogName.val()
                ogDesc = $ogDesc.val()
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