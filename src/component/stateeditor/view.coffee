#############################
#  View(UI logic) for component/stateeditor
#############################

define [ 'event',
         'text!./component/stateeditor/template.html',
         './component/stateeditor/validate',
         'UI.errortip'

], ( ide_event, template , validate ) ->

    StateEditorView = Backbone.View.extend {

        events      :

            'closed': 'closedPopup'
            'keydown .parameter-item.dict .parameter-value': 'onDictInputChange'
            'blur .parameter-item.dict .parameter-value': 'onDictInputBlur'

            'keydown .parameter-item.array .parameter-value': 'onArrayInputChange'
            'blur .parameter-item.array .parameter-value': 'onArrayInputBlur'
            'keydown .parameter-item.state .parameter-value': 'onArrayInputChange'
            'blur .parameter-item.state .parameter-value': 'onArrayInputBlur'

            'blur .command-value': 'onCommandInputBlur'

            'focus .editable-area': 'onFocusInput'
            'blur .editable-area': 'onBlurInput'
            # 'click .state-toolbar .state-id': 'onStateIdClick'
            'click .state-toolbar': 'onStateToolbarClick'
            # 'click .state-toolbar .state-add': 'onStateAddClick'
            'click .state-toolbar .state-remove': 'onStateRemoveClick'
            'click .state-save': 'onStateSaveClick'
            'click .state-cancel': 'onStateCancelClick'
            'click .state-close': 'onStateCancelClick'
            'click .parameter-item .parameter-remove': 'onParaRemoveClick'
            'click .state-desc-toggle': 'onDescToggleClick'
            'click .state-log-toggle': 'onLogToggleClick'
            'click .state-item-add': 'onStateItemAddClick'

            'OPTION_CHANGE .state-editor-res-select': 'onResSelectChange'

            'keydown .parameter-item.optional .parameter-value': 'onOptionalParaItemChange'

        initialize: () ->

            this.compileTpl()
            this.initData()

            $(document).on 'keydown', {target: this}, this.keyEvent

        closedPopup: () ->
            @trigger 'CLOSE_POPUP'
            $(document).off 'keydown', this.keyEvent

        render: () ->

            that = this

            # show modal
            modal that.editorModalTpl({
                res_name: that.resName,
                supported_platform: that.supportedPlatform,
                current_state: that.currentState
            }), false

            # setTimeout(() ->

            that.setElement $( '#state-editor-model' ).closest '#modal-wrap'
            that.$editorModal = that.$el
            that.$stateList = that.$editorModal.find('.state-list')
            that.$stateLogList = that.$editorModal.find('.state-log-list')
            that.$cmdDsec = $('#state-description')

            # hide autocomplete when click document
            $(document).on('mousedown', that.onDocumentMouseDown)
            $('#state-editor').on('scroll', () ->
                $('.ace_editor.ace_autocomplete').hide()
            )

            stateObj = that.loadStateData(that.originCompStateData)
            that.refreshStateList(stateObj)
            that.refreshStateViewList()
            that.bindStateListSortEvent()

            if that.readOnlyMode
                that.setEditorReadOnlyMode()

            that.refreshDescription()

            that.initResSelect()

            # refresh state log
            $resSelectElem = that.$editorModal.find('.state-editor-res-select')
            if that.currentState is 'stack'
                $resSelectElem.hide()
            else
                that.onResSelectChange({
                    target: $resSelectElem[0]
                })

            if that.isShowLogPanel
                that.showLogPanel()

            if that.currentState is 'stack'
                $logPanelToggle = that.$editorModal.find('.state-log-toggle')
                $logPanelToggle.hide()

            # , 1)

        initData: () ->

            that = this
            that.cmdParaMap = that.model.get('cmdParaMap')
            that.cmdParaObjMap = that.model.get('cmdParaObjMap')
            that.cmdModuleMap = that.model.get('cmdModuleMap')
            that.moduleCMDMap = that.model.get('moduleCMDMap')

            that.langTools = ace.require('ace/ext/language_tools')
            that.Tokenizer = ace.require("ace/tokenizer").Tokenizer

            that.resAttrDataAry = that.model.get('resAttrDataAry')
            that.resStateDataAry = that.model.get('resStateDataAry')
            that.groupResSelectData = that.model.get('groupResSelectData')
            that.originCompStateData = that.model.getStateData()

            that.resName = that.model.getResName()
            that.supportedPlatform = that.model.get('supportedPlatform')

            that.currentState = that.model.get('currentState')
            currentAppState = that.model.get('currentAppState')

            that.resAttrRegexStr = that.model.get('resAttrRegexStr')

            if that.currentState is 'app'
                that.readOnlyMode = true
                that.isShowLogPanel = true

            if that.currentState is 'appedit'
                that.readOnlyMode = false
                that.isShowLogPanel = true
                if that.groupResSelectData and that.groupResSelectData.length
                    if not that.groupResSelectData[0].res_id
                        that.isShowLogPanel = false

            else if that.currentState is 'stack'
                that.readOnlyMode = false
                that.isShowLogPanel = false

        compileTpl: () ->

            # generate template
            tplRegex = /(\<!-- (.*) --\>)(\n|\r|.)*?(?=\<!-- (.*) --\>)/ig
            tplHTMLAry = template.match(tplRegex)
            htmlMap = {}
            _.each tplHTMLAry, (tplHTML) ->
                commentHead = tplHTML.split('\n')[0]
                tplType = commentHead.replace(/(<!-- )|( -->)|\r|\n/g, '')
                tplType = $.trim(tplType)
                htmlMap[tplType] = tplHTML
                null

            editorModalHTML = htmlMap['state-template-editor-modal']
            stateListHTML = htmlMap['state-template-state-list']
            paraListHTML = htmlMap['state-template-para-list']
            paraViewListHTML = htmlMap['state-template-para-view-list']
            paraDictItemHTML = htmlMap['state-template-para-dict-item']
            paraArrayItemHTML = htmlMap['state-template-para-array-item']
            stateLogItemHTML = htmlMap['state-template-log-item']
            stateLogInstanceItemHTML = htmlMap['state-template-log-instance-item']
            stateResSelectHTML = htmlMap['state-template-res-select']
            paraCompleteItemHTML = '<li data-value="${atwho-at}${name}">${name}</li>'

            this.stateListTpl = Handlebars.compile(stateListHTML)

            Handlebars.registerPartial('state-template-para-list', paraListHTML)
            Handlebars.registerPartial('state-template-para-view-list', paraViewListHTML)
            Handlebars.registerPartial('state-template-para-dict-item', paraDictItemHTML)
            Handlebars.registerPartial('state-template-para-array-item', paraArrayItemHTML)
            Handlebars.registerPartial('state-template-log-item', stateLogItemHTML)
            Handlebars.registerPartial('state-template-log-instance-item', stateLogInstanceItemHTML)
            Handlebars.registerPartial('state-template-res-select', stateResSelectHTML)

            this.editorModalTpl = Handlebars.compile(editorModalHTML)
            this.paraListTpl = Handlebars.compile(paraListHTML)
            this.paraViewListTpl = Handlebars.compile(paraViewListHTML)
            this.paraDictListTpl = Handlebars.compile(paraDictItemHTML)
            this.paraArrayListTpl = Handlebars.compile(paraArrayItemHTML)
            this.stateLogItemTpl = Handlebars.compile(stateLogItemHTML)
            this.stateLogInstanceItemTpl = Handlebars.compile(stateLogInstanceItemHTML)
            this.stateResSelectTpl = Handlebars.compile(stateResSelectHTML)

        genStateUID: () ->

            return 'state-' + MC.guid()

        initResSelect: () ->

            that = this

            $resSelect = that.$editorModal.find('.state-editor-res-select')

            if that.groupResSelectData and that.groupResSelectData.length

                resSelectHTML = that.stateResSelectTpl({
                    res_selects: that.groupResSelectData
                })

                $resSelect.html(resSelectHTML)

                if that.groupResSelectData.length is 1

                    $resSelect.hide()

            else

                $resSelect.hide()

        bindStateListSortEvent: () ->

            that = this

            # state item sortable
            # that.$stateList.dragsort({
            #     itemSelector: '.state-item',
            #     dragSelector: '.state-drag',
            #     dragBetween: true,
            #     placeHolderTemplate: '<div class="state-item state-placeholder"></div>',
            #     dragEnd: () ->
            #         that.refreshStateId()
            # })
            
            dragsort.init({
                dragStart: () ->
                    $stateItem = this
                    # $stateItemList = that.$stateList.find('.state-item')
                    $stateItem.addClass('view')
                    return true
                dragEnd: () ->
                    $stateItem = this
                    that.refreshLogItemNum()
                    null
            })

        refreshStateList: (stateListObj) ->

            that = this

            if not (stateListObj and stateListObj.state_list.length)

                stateListObj = {
                    state_list: []
                    # state_list: [{
                    #     state_id: that.genStateUID(),
                    #     state_id_show: '1',
                    #     cmd_value: ''
                    # }]
                }

            that.$stateList.html(this.stateListTpl(stateListObj))

            that.bindStateListEvent()

        refreshStateViewList: () ->

            that = this

            $stateItemList = that.$stateList.find('.state-item')

            _.each $stateItemList, (stateItem) ->

                $stateItem = $(stateItem)
                that.refreshStateView($stateItem)

                null

            if not that.readOnlyMode

                # create new dict input box
                $lastDictInputList = $stateItemList.find('.parameter-item.dict .parameter-dict-item:last .key')
                _.each $lastDictInputList, (lastDictInput) ->
                    that.onDictInputChange({
                        currentTarget: lastDictInput
                    })

                # create new array/state input box
                $lastArrayInputListAry = $stateItemList.find('.parameter-item.array .parameter-value:last').toArray()
                $lastStateInputListAry = $stateItemList.find('.parameter-item.state .parameter-value:last').toArray()

                $lastInputListAry = $lastArrayInputListAry.concat($lastStateInputListAry)

                _.each $lastInputListAry, (lastInput) ->
                    that.onArrayInputChange({
                        currentTarget: lastInput
                    })

        refreshStateView: ($stateItem) ->

            that = this

            cmdName = $stateItem.attr('data-command')
            currentParaMap = that.cmdParaObjMap[cmdName]

            $cmdViewValueElem = $stateItem.find('.command-view-value')
            $paraListElem = $stateItem.find('.parameter-list')
            $paraViewListElem = $stateItem.find('.parameter-view-list')
            $paraItemList = $paraListElem.find('.parameter-item')

            $cmdValueElem = $stateItem.find('.state-edit .command-value')
            cmdValue = that.getPlainText($cmdValueElem)
            $cmdViewValueElem.text(cmdValue)

            paraListViewRenderAry = []

            _.each $paraItemList, (paraItemElem) ->

                $paraItem = $(paraItemElem)
                paraName = $paraItem.attr('data-para-name')
                paraObj = currentParaMap[paraName]

                paraType = paraObj.type
                paraName = paraObj.name

                paraDisabled = false
                if $paraItem.hasClass('disabled')
                    paraDisabled = true

                viewRenderObj = {
                    para_name: paraName,
                    para_disabled: paraDisabled
                }

                viewRenderObj['type_' + paraType] = true

                paraValue = ''

                if paraType is 'dict'

                    $paraDictItems = $paraItem.find('.parameter-dict-item')

                    paraValueAry = []
                    _.each $paraDictItems, (paraDictItem) ->
                        $paraDictItem = $(paraDictItem)
                        $keyInput = $paraDictItem.find('.key')
                        $valueInput = $paraDictItem.find('.value')
                        keyValue = that.getPlainText($keyInput)
                        valueValue = that.getPlainText($valueInput)
                        if keyValue and valueValue
                            paraValueAry.push(keyValue + ':' + valueValue)
                        if keyValue and not valueValue
                            paraValueAry.push(keyValue)
                        null

                    paraValue = paraValueAry.join(', ')

                else if paraType in ['array', 'state']

                    $valueInputs = $paraItem.find('.parameter-value')

                    paraValueAry = []
                    _.each $valueInputs, (valueInput) ->
                        $valueInput = $(valueInput)
                        valueValue = that.getPlainText($valueInput)
                        if valueValue
                            paraValueAry.push(valueValue)

                    paraValue = paraValueAry.join(', ')

                else if paraType in ['line', 'text', 'bool', 'state']

                    $valueInput = $paraItem.find('.parameter-value')
                    valueValue = that.getPlainText($valueInput)
                    paraValue = valueValue

                viewRenderObj.para_value = paraValue

                paraListViewRenderAry.push(viewRenderObj)

                null

            $paraViewListElem.html(that.paraViewListTpl({
                parameter_view_list: paraListViewRenderAry
            }))

        bindStateListEvent: () ->

            that = this

            $stateItems = that.$stateList.find('.state-item')

            _.each $stateItems, (stateItem) ->

                $stateItem = $(stateItem)
                currentCMD = $stateItem.attr('data-command')

                $paraListItem = $stateItem.find('.parameter-list')
                $cmdValueItem = $stateItem.find('.command-value')

                that.bindCommandEvent($cmdValueItem)

                null

        bindCommandEvent: ($cmdValueItem) ->

            that = this

            cmdNameAry = _.keys(that.cmdParaMap)

            cmdNameAry = _.map cmdNameAry, (value, i) ->
                return {
                    'name': value,
                    'value': value
                }

            that.initCodeEditor($cmdValueItem[0], {
                focus: cmdNameAry
            })

        bindParaListEvent: ($paraListElem, currentCMD) ->

            that = this

            $paraItemList = $paraListElem.find('.parameter-item')

            currentParaMap = that.cmdParaObjMap[currentCMD]

            _.each $paraItemList, (paraItem) ->

                $paraItem = $(paraItem)
                currentParaName = $paraItem.attr('data-para-name')
                paraObj = currentParaMap[currentParaName]
                that.bindParaItemEvent($paraItem, paraObj)

                null

        bindParaItemEvent: ($paraItem, paraObj) ->

            that = this

            paraType = paraObj.type
            paraOption = paraObj.option

            paraOptionAry = null
            if paraOption
                if _.isString(paraOption)
                    paraOptionAry = [paraOption]
                else if _.isArray(paraOption)
                    paraOptionAry = paraOption
                paraOptionAry = _.map paraOptionAry, (valueStr) ->
                    return {
                        name: valueStr
                        value: valueStr
                    }

            if paraType is 'dict'

                atwhoOption = {
                    at: '@',
                    tpl: that.paraCompleteItemHTML
                    data: that.resAttrDataAry
                }

                _.each $paraItem, (paraDictItem) ->

                    $paraDictItem = $(paraDictItem)

                    $keyInputs = $paraDictItem.find('.key')
                    $valueInputs = $paraDictItem.find('.value')

                    _.each $keyInputs, (keyInput) ->
                        that.initCodeEditor(keyInput, {})

                    _.each $valueInputs, (valueInput) ->
                        that.initCodeEditor(valueInput, {
                            focus: paraOptionAry,
                            at: that.resAttrDataAry
                        })

            else if paraType in ['line', 'text', 'array']

                $inputElemAry = $paraItem.find('.parameter-value')

                if not $inputElemAry.length
                    $inputElemAry = $paraItem.nextAll('.parameter-value')

                _.each $inputElemAry, (inputElem) ->
                    that.initCodeEditor(inputElem, {
                        focus: paraOptionAry,
                        at: that.resAttrDataAry
                    })

            else if paraType is 'state'

                $inputElemAry = $paraItem.find('.parameter-value')

                if not $inputElemAry.length
                    $inputElemAry = $paraItem.nextAll('.parameter-value')

                haveAtDataAry = _.map that.resStateDataAry, (stateRefObj) ->
                    return {
                        name: '@' + stateRefObj.name,
                        value: '@' + stateRefObj.value
                    }

                _.each $inputElemAry, (inputElem) ->
                    that.initCodeEditor(inputElem, {
                        focus: haveAtDataAry,
                        at: that.resStateDataAry
                    })

            else if paraType is 'bool'
                $inputElem = $paraItem.find('.parameter-value')
                that.initCodeEditor($inputElem[0],  {
                    focus: [{
                        name: 'true',
                        value: 'true'
                    }, {
                        name: 'false',
                        value: 'false'
                    }]
                })

        refreshDescription: (cmdName) ->

            that = this

            descMarkdown = ''

            if cmdName
                moduleObj = that.cmdModuleMap[cmdName]
                if moduleObj.reference
                    descMarkdown = moduleObj.reference['en']
                that.$cmdDsec.attr('data-command', cmdName)
            else
                descMarkdown = 'Get Started with Conﬁguration Manager Conﬁguration manager is blah blah blah... You can use following command...'

            descHTML = ''
            if descMarkdown
                descHTML = $.markdown(descMarkdown)

            that.$cmdDsec.html(descHTML)

            null

        refreshParaList: ($paraListElem, currentCMD) ->

            that = this
            currentParaMap = that.cmdParaObjMap[currentCMD]
            currentParaAry = that.cmdParaMap[currentCMD]

            newParaAry = []

            _.each currentParaAry, (paraObj) ->

                paraDisabled = false
                if not paraObj.required
                    paraDisabled = true

                newParaObj = {
                    para_name: paraObj.name,
                    required: paraObj.required,
                    para_disabled: paraDisabled
                }

                newParaObj['type_' + paraObj.type] = true

                if paraObj.type in ['line', 'text', 'bool']
                    newParaObj.para_value = ''
                else if paraObj.type is 'dict'
                    newParaObj.para_value = [{
                        key: '',
                        value: ''
                    }]
                else if paraObj.type in ['array', 'state']
                    newParaObj.para_value = ['']

                newParaAry.push(newParaObj)

                null

            $paraListElem.html(that.paraListTpl({
                parameter_list: newParaAry
            }))

            that.bindParaListEvent($paraListElem, currentCMD)

        # refreshStateId: () ->

        #     that = this

        #     $stateItemList = that.$stateList.find('.state-item')

        #     _.each $stateItemList, (stateItem, idx) ->

        #         currentStateId = idx + 1
        #         $stateItem = $(stateItem)
        #         $stateItem.find('.state-id').text(currentStateId)

        #         null

        getParaObj: ($inputElem) ->

            that = this

            $stateItem = $inputElem.parents('.state-item')
            $paraItem = $inputElem.parents('.parameter-item')

            currentCMD = $stateItem.attr('data-command')
            currentParaName = $paraItem.attr('data-para-name')

            currentParaMap = that.cmdParaObjMap[currentCMD]
            paraObj = currentParaMap[currentParaName]

            return paraObj

        onDictInputChange: (event) ->

            # append new dict item

            that = this

            $currentInputElem = $(event.currentTarget)

            currentValue = that.getPlainText($currentInputElem)
            if currentValue
                $currentInputElem.removeClass('disabled')

            paraObj = that.getParaObj($currentInputElem)

            $currentDictItemElem = $currentInputElem.parent('.parameter-dict-item')
            nextDictItemElemAry = $currentDictItemElem.next()

            if not nextDictItemElemAry.length

                $currentDictItemContainer = $currentDictItemElem.parents('.parameter-container')

                $keyInput = $currentDictItemElem.find('.key')
                $valueInput = $currentDictItemElem.find('.value')

                keyInputValue = that.getPlainText($keyInput)
                valueInputValue = that.getPlainText($valueInput)

                if keyInputValue or valueInputValue
                    newDictItemHTML = that.paraDictListTpl({
                        para_value: [{
                            key: '',
                            value: ''
                        }]
                    })
                    $dictItemElem = $(newDictItemHTML).appendTo($currentDictItemContainer)
                    $paraDictItem = $dictItemElem.nextAll('.parameter-dict-item')
                    that.bindParaItemEvent($paraDictItem, paraObj)
                    $paraValueAry = $paraDictItem.find('.parameter-value')
                    $paraValueAry.addClass('disabled')

        onDictInputBlur: (event) ->

            # remove empty dict item

            that = this

            $currentInputElem = $(event.currentTarget)

            $currentDictItemContainer = $currentInputElem.parents('.parameter-container')
            allInputElemAry = $currentDictItemContainer.find('.parameter-dict-item')
            _.each allInputElemAry, (itemElem, idx) ->
                inputElemAry = $(itemElem).find('.parameter-value')
                isAllInputEmpty = true
                _.each inputElemAry, (inputElem) ->
                    if that.getPlainText(inputElem)
                        isAllInputEmpty = false
                    null
                if isAllInputEmpty and idx isnt allInputElemAry.length - 1
                    $(itemElem).remove()
                null

            newAllInputElemAry = $currentDictItemContainer.find('.parameter-dict-item')
            if newAllInputElemAry.length is 1
                newInputElemAry = $(newAllInputElemAry[0]).find('.parameter-value')
                newInputElemAry.removeClass('disabled')

        onArrayInputChange: (event) ->

            # append new array item

            that = this

            $currentInputElem = $(event.currentTarget)

            currentValue = that.getPlainText($currentInputElem)
            if currentValue
                $currentInputElem.removeClass('disabled')

            paraObj = that.getParaObj($currentInputElem)

            nextInputElemAry = $currentInputElem.next()

            if not nextInputElemAry.length

                $currentArrayInputContainer = $currentInputElem.parents('.parameter-container')

                currentInput = that.getPlainText($currentInputElem)

                if currentInput
                    newArrayItemHTML = that.paraArrayListTpl({
                        para_value: ['']
                    })
                    $arrayItemElem = $(newArrayItemHTML).appendTo($currentArrayInputContainer)
                    $arrayItemElem.addClass('disabled')
                    that.bindParaItemEvent($arrayItemElem, paraObj)

        onArrayInputBlur: (event) ->

            # remove empty array item

            that = this

            $currentInputElem = $(event.currentTarget)
            $currentArrayItemContainer = $currentInputElem.parents('.parameter-container')
            allInputElemAry = $currentArrayItemContainer.find('.parameter-value')
            _.each allInputElemAry, (itemElem, idx) ->
                inputValue = that.getPlainText(itemElem)
                if not inputValue and idx isnt allInputElemAry.length - 1
                    $(itemElem).remove()
                null

        onFocusInput: (event) ->

            that = this

            $currentInput = $(event.currentTarget)

            # add default value

            if $currentInput.hasClass('parameter-value')

                currentValue = that.getPlainText($currentInput)

                paraObj = that.getParaObj($currentInput)

                if paraObj and paraObj.default isnt undefined
                    defaultValue = String(paraObj.default)
                    if not currentValue and defaultValue and not $currentInput.hasClass('key')
                        that.setPlainText($currentInput, defaultValue)
                        $paraItem = $currentInput.parents('.parameter-item')
                        $paraItem.removeClass('disabled')

                        # auto add new para item
                        # if $currentInput.hasClass('parameter-value')

                        #     $paraItem = $currentInput.parents('.parameter-item')
                        #     if $paraItem.hasClass('dict')
                        #         that.onDictInputChange({
                        #             currentTarget: $currentInput[0]
                        #         })
                        #     else if $paraItem.hasClass('array') or $paraItem.hasClass('state')
                        #         that.onArrayInputChange({
                        #             currentTarget: $currentInput[0]
                        #         })

            # refresh module description

            $stateItem = $currentInput.parents('.state-item')
            cmdName = $stateItem.attr('data-command')

            currentDescCMDName = that.$cmdDsec.attr('data-command')
            if cmdName and currentDescCMDName isnt cmdName
                that.refreshDescription(cmdName)

        onBlurInput: (event) ->

            that = this

            $currentInput = $(event.currentTarget)

            editor =  $currentInput.data('editor')

            if editor then editor.clearSelection()

        onStateToolbarClick: (event) ->

            that = this

            $stateToolbarElem = $(event.currentTarget)

            # if not ($stateToolbarElem.hasClass('state-drag') or
            #         $stateToolbarElem.hasClass('state-add') or
            #         $stateToolbarElem.hasClass('state-remove'))

            that.clearSelectedItem()

            $stateItem = $stateToolbarElem.parents('.state-item')

            $stateItemList = that.$stateList.find('.state-item')

            if $stateItem.hasClass('view')

                currentCMD = $stateItem.attr('data-command')
                $paraListItem = $stateItem.find('.parameter-list')
                that.bindParaListEvent($paraListItem, currentCMD)

                # remove other item view
                _.each $stateItemList, (otherStateItem) ->
                    $otherStateItem = $(otherStateItem)
                    if not $stateItem.is($otherStateItem) and not $otherStateItem.hasClass('view')
                        that.refreshStateView($otherStateItem)
                    null

                $stateItemList.addClass('view')
                $stateItem.removeClass('view')

                # refresh description
                cmdName = $stateItem.attr('data-command')
                if cmdName
                    that.refreshDescription(cmdName)

                $cmdValueItem = $stateItem.find('.command-value')
                cmdEditor = $cmdValueItem.data('editor')
                if cmdEditor
                    setTimeout(() ->
                        cmdEditor.focus()
                    , 0)

                if that.readOnlyMode
                    that.setEditorReadOnlyMode()

                $stateItem.addClass('selected')

            else
                that.refreshStateView($stateItem)
                $stateItem.addClass('view')

        clearSelectedItem: () ->

            that = this
            that.$stateList.find('.selected').removeClass('selected')
            null

        # onStateAddClick: (event) ->

        #     that = this

        #     $currentElem = $(event.currentTarget)
        #     $stateItem = $currentElem.parents('.state-item')

        #     stateIdStr = $stateItem.find('.state-id').text()
        #     stateId = Number(stateIdStr)

        #     newStateId = ++stateId

        #     newStateHTML = that.stateListTpl({
        #         state_list: [{
        #             state_id_show: newStateId
        #         }]
        #     })

        #     $stateItem.after(newStateHTML)

        #     $newStateItem = $stateItem.next()

        #     $cmdValueItem = $newStateItem.find('.command-value')
        #     that.bindCommandEvent($cmdValueItem)

        #     $stateItemList = that.$stateList.find('.state-item')
        #     $stateItemList.addClass('view')

        #     _.each $stateItemList, (otherStateItem) ->
        #         $otherStateItem = $(otherStateItem)
        #         if not $newStateItem.is($otherStateItem) and not $otherStateItem.hasClass('view')
        #             that.refreshStateView($otherStateItem)
        #         null

        #     $newStateItem.removeClass('view')
        #     cmdEditor = $cmdValueItem.data('editor')
        #     if cmdEditor
        #         setTimeout(() ->
        #             cmdEditor.focus()
        #         , 0)

        #     that.refreshStateId()

        onStateItemAddClick: (event) ->

            that = this

            that.addStateItem.call this, event

        addStateItem: (event) ->

            that = this

            $stateItem = that.$stateList.find('.state-item:last')

            newStateIdShow = 1

            if $stateItem.length
                newStateIdShow = $stateItem.index() + 2

            newStateId = that.genStateUID()

            newStateHTML = that.stateListTpl({
                state_list: [{
                    state_id: newStateId,
                    state_id_show: newStateIdShow
                }]
            })

            $newStateItem = $(newStateHTML).appendTo(that.$stateList)

            $cmdValueItem = $newStateItem.find('.command-value')
            that.bindCommandEvent($cmdValueItem)

            $stateItemList = that.$stateList.find('.state-item')

            _.each $stateItemList, (otherStateItem) ->
                $otherStateItem = $(otherStateItem)
                if not $newStateItem.is($otherStateItem) and not $otherStateItem.hasClass('view')
                    that.refreshStateView($otherStateItem)
                null

            $stateItemList.addClass('view')

            $newStateItem.removeClass('view')
            cmdEditor = $cmdValueItem.data('editor')
            if cmdEditor
                setTimeout(() ->
                    cmdEditor.focus()
                , 0)

            that.refreshLogItemNum()

        onStateRemoveClick: (event) ->

            that = this

            $currentElem = $(event.currentTarget)
            $stateItem = $currentElem.parents('.state-item')

            $stateItem.remove()

            that.refreshLogItemNum()

        submitValidate: ( element ) ->

            that = this

            doValidate = ( elem ) ->
                #if $( elem ).parent( '[contenteditable="true"]' ).size()
                #    return true

                value = that.getPlainText elem
                param = that.getParaObjByInput elem
                represent = that.getRepresent elem

                validate value, param, elem, represent

            validateFailed = ( e ) ->
                result = doValidate e.currentTarget
                if not result
                    $( e.currentTarget ).off 'keyup.validate'

            bindValidateFailed = ( elem ) ->
                $( elem ).on 'keyup.validate', validateFailed



            if element
                result = doValidate element
            else
                $editor= @$stateList.find '.editable-area:not(".disabled")'
                elems = $editor.toArray()
                result = true
                _.each elems, ( e ) ->
                    res = doValidate e
                    if res
                        bindValidateFailed e
                        if result
                            result = false

                    result


            result

        saveStateData: () ->
            
            if not @submitValidate()
                return false

            that = this

            $stateItemList = that.$stateList.find('.state-item')

            stateObjAry = []

            # newOldStateIdMap = {}

            _.each $stateItemList, (stateItem, idx) ->

                $stateItem = $(stateItem)

                cmdName = $stateItem.attr('data-command')
                stateId = $stateItem.attr('data-id')

                # for state item sort
                # newStateId = $stateItem.find('.state-id').text()
                # oldStateId = $stateItem.attr('data-id')
                # if oldStateId and newStateId isnt oldStateId
                #     oldStateIdRef = "@{#{that.resName}.state.#{oldStateId}}"
                #     newStateIdRef = "@{#{that.resName}.state.#{newStateId}}"
                #     newOldStateIdMap[oldStateIdRef] = newStateIdRef

                moduleObj = that.cmdModuleMap[cmdName]

                #empty module direct return
                if not moduleObj
                    return

                stateItemObj = {
                    id: stateId,
                    module: moduleObj.module,
                    parameter: {}
                }

                $paraListElem = $stateItem.find('.parameter-list')
                $paraItemList = $paraListElem.find('.parameter-item')

                _.each $paraItemList, (paraItem) ->

                    $paraItem = $(paraItem)

                    if $paraItem.hasClass('disabled')
                        return

                    paraName = $paraItem.attr('data-para-name')

                    paraValue = null

                    if $paraItem.hasClass('line') or
                        $paraItem.hasClass('bool') or
                        $paraItem.hasClass('text')

                            $paraInput = $paraItem.find('.parameter-value')
                            paraValue = that.getPlainText($paraInput)

                            if $paraItem.hasClass('bool')
                                if paraValue is 'true'
                                    paraValue = true
                                else if paraValue is 'false'
                                    paraValue = false
                                else
                                    paraValue = ''

                            if $paraItem.hasClass('line') or $paraItem.hasClass('text')
                                paraValue = that.model.replaceParaNameToUID(paraValue)

                    else if $paraItem.hasClass('dict')

                        $dictItemList = $paraItem.find('.parameter-dict-item')
                        dictObj = {}

                        _.each $dictItemList, (dictItem) ->

                            $dictItem = $(dictItem)
                            $keyInput = $dictItem.find('.key')
                            $valueInput = $dictItem.find('.value')

                            keyValue = that.getPlainText($keyInput)
                            valueValue = that.getPlainText($valueInput)

                            if keyValue
                                valueValue = that.model.replaceParaNameToUID(valueValue)
                                dictObj[keyValue] = valueValue

                            null

                        paraValue = dictObj

                    else if $paraItem.hasClass('array') or $paraItem.hasClass('state')

                        $arrayItemList = $paraItem.find('.parameter-value')
                        isStateParaItem = $paraItem.hasClass('state')
                        arrayObj = []

                        _.each $arrayItemList, (arrayItem) ->

                            $arrayItem = $(arrayItem)
                            arrayValue = that.getPlainText($arrayItem)

                            if arrayValue

                                if isStateParaItem
                                    arrayValue = that.model.replaceStateNameToUID(arrayValue)
                                else
                                    arrayValue = that.model.replaceParaNameToUID(arrayValue)

                                arrayObj.push(arrayValue)

                            null

                        paraValue = arrayObj

                    stateItemObj['parameter'][paraName] = paraValue

                    null

                stateObjAry.push(stateItemObj)

                null

            # update all state id ref
            # that.updateStateIdBySort(newOldStateIdMap)

            return stateObjAry

        loadStateData: (stateObjAry) ->

            that = this

            renderObj = {
                state_list: []
            }

            _.each stateObjAry, (state, idx) ->

                cmdName = that.moduleCMDMap[state.module]
                paraModelObj = that.cmdParaObjMap[cmdName]

                paraListObj = state.parameter
                stateId = state.id

                stateRenderObj = {
                    state_id: stateId,
                    state_id_show: idx + 1,
                    cmd_value: cmdName,
                    parameter_list: []
                }

                _.each paraModelObj, (paraModelValue, paraModelName) ->

                    paraModelType = paraModelValue.type
                    paraModelRequired = paraModelValue.required

                    renderParaObj = {
                        para_name: paraModelName,
                        para_disabled: true,
                        required: paraModelRequired
                    }

                    renderParaObj['type_' + paraModelType] = true

                    paraValue = paraListObj[paraModelName]

                    if paraValue is undefined and not paraModelRequired
                        renderParaObj.para_disabled = true
                    else
                        renderParaObj.para_disabled = false

                    renderParaValue = null
                    if paraModelType in ['line', 'text', 'bool']

                        renderParaValue = String(paraValue)

                        if not paraValue
                            renderParaValue = ''

                        if paraModelType is 'bool' and paraValue is false
                            renderParaValue = 'false'

                        if paraModelType in ['line', 'text']
                            renderParaValue = that.model.replaceParaUIDToName(renderParaValue)

                    else if paraModelType is 'dict'

                        renderParaValue = []
                        _.each paraValue, (paraValueStr, paraKey) ->

                            paraValueStr = that.model.replaceParaUIDToName(paraValueStr)

                            renderParaValue.push({
                                key: paraKey
                                value: paraValueStr
                            })

                            null

                        if not paraValue or _.isEmpty(paraValue)
                            renderParaValue = [{
                                key: '',
                                value: ''
                            }]

                    else if paraModelType in ['array', 'state']

                        renderParaValue = []
                        _.each paraValue, (paraValueStr) ->

                            if paraModelType is 'state'
                                paraValueStr = that.model.replaceStateUIDToName(paraValueStr)
                            else
                                paraValueStr = that.model.replaceParaUIDToName(paraValueStr)
                                
                            renderParaValue.push(paraValueStr)
                            null

                        if not paraValue or not paraValue.length
                            renderParaValue = ['']

                    renderParaObj.para_value = renderParaValue

                    stateRenderObj.parameter_list.push(renderParaObj)

                    paraListAry = stateRenderObj.parameter_list

                    stateRenderObj.parameter_list = that.model.sortParaList(paraListAry, 'para_name')

                    null

                renderObj.state_list.push(stateRenderObj)

                null

            return renderObj

        onStateSaveClick: (event) ->

            that = this
            stateData = that.saveStateData()

            if stateData

                that.model.setStateData(stateData)

                # compare
                compareStateData = null
                otherCompareStateData = null

                # compare state data
                # when data change, trigger data update event
                if that.originCompStateData and stateData

                    if that.originCompStateData.length > stateData.length
                        compareStateData = stateData
                        otherCompareStateData = that.originCompStateData
                    else
                        compareStateData = that.originCompStateData
                        otherCompareStateData = stateData

                    changeAry = []

                    _.each compareStateData, (stateObj, idx) ->
                        originStateObjStr = JSON.stringify(stateObj)
                        currentStateObjStr = JSON.stringify(otherCompareStateData[idx])
                        if originStateObjStr isnt currentStateObjStr
                            changeAry.push(stateObj.id)
                        null

                    resUID = that.model.getCurrentResUID()
                    changeObj = {
                        resUID: resUID,
                        stateIds: changeAry
                    }

                    if changeAry.length
                        ide_event.trigger 'STATE_EDITOR_DATA_UPDATE', changeObj

                that.unloadEditor()

                that.closedPopup()

        onStateCancelClick: (event) ->

            that = this
            that.unloadEditor()
            that.closedPopup()

        onParaRemoveClick: (event) ->

            that = this

            $currentElem = $(event.currentTarget)
            $paraItem = $currentElem.parents('.parameter-item')

            if $paraItem.hasClass('disabled')
                $paraItem.removeClass('disabled')
            else
                $paraItem.addClass('disabled')

            null

        onDescToggleClick: (event) ->

            that = this

            $stateEditor = $('#state-editor')
            $descPanel = $('#state-description')
            $logPanel = $('#state-log')

            $descPanelToggle = that.$editorModal.find('.state-desc-toggle')
            $logPanelToggle = that.$editorModal.find('.state-log-toggle')

            if $descPanel.is(':visible')
                $stateEditor.addClass('full')
                $descPanel.hide()
                $descPanelToggle.removeClass('active')
            else
                $stateEditor.removeClass('full')
                $logPanel.hide()
                $descPanel.show()
                $descPanelToggle.addClass('active')

            $logPanelToggle.removeClass('active')

        onLogToggleClick: (event) ->

            that = this

            $stateEditor = $('#state-editor')
            $descPanel = $('#state-description')
            $logPanel = $('#state-log')

            $descPanelToggle = that.$editorModal.find('.state-desc-toggle')
            $logPanelToggle = that.$editorModal.find('.state-log-toggle')

            if $logPanel.is(':visible')
                $stateEditor.addClass('full')
                $logPanel.hide()
                $logPanelToggle.removeClass('active')
            else
                $stateEditor.removeClass('full')
                $descPanel.hide()
                $logPanel.show()
                $logPanelToggle.addClass('active')

            $descPanelToggle.removeClass('active')

        showLogPanel: () ->

            that = this
            $stateEditor = $('#state-editor')
            $descPanel = $('#state-description')
            $logPanel = $('#state-log')

            $descPanelToggle = that.$editorModal.find('.state-desc-toggle')
            $logPanelToggle = that.$editorModal.find('.state-log-toggle')

            $stateEditor.removeClass('full')
            $descPanel.hide()
            $logPanel.show()

            $logPanelToggle.addClass('active')
            $descPanelToggle.removeClass('active')

            null

        onDocumentMouseDown: (event) ->

            that = this
            $currentElem = $(event.target)
            $parentElem = $currentElem.parents('.editable-area')

            if not $parentElem.length and not $currentElem.hasClass('editable-area')
                $allEditableArea = $('.editable-area')
                _.each $allEditableArea, (editableArea) ->
                    $editableArea = $(editableArea)
                    editor = $editableArea.data('editor')
                    if editor then editor.blur()
                    null

        initCodeEditor: (editorElem, hintObj) ->
            that = this

            # if that.readOnlyMode
            #     return

            if not editorElem then return

            $editorElem = $(editorElem)

            if $editorElem.data('editor')
                return

            editor = ace.edit(editorElem)
            $editorElem.data('editor', editor)

            editor.hintObj = hintObj
            editor.getSession().setMode(that.resRefHighLight)

            # config editor

            # editor.setTheme("ace/theme/monokai")
            editor.renderer.setPadding(4)
            editor.setBehavioursEnabled(false)

            # single/mutil line editor
            editorSingleLine = false
            maxLines = undefined
            if $editorElem.hasClass('line')
                maxLines = 1
                editorSingleLine = true

            editor.setOptions({
                enableBasicAutocompletion: true,
                maxLines: maxLines,
                showGutter: false,
                highlightGutterLine: false,
                showPrintMargin: false,
                highlightActiveLine: false,
                highlightSelectedWord: false,
                enableSnippets: false,
                singleLine: editorSingleLine
            })

            tk = new that.Tokenizer({
                'start': [{
                    token: 'res_ref_correct',
                    regex: that.resAttrRegexStr
                }, {
                    token: 'res_ref',
                    regex: '@\\{(\\w|\\-)+(\\.(\\w+(\\[\\d+\\])*))+\\}'
                }]
            })
            editor.session.$mode.$tokenizer = tk
            editor.session.bgTokenizer.setTokenizer(tk)
            editor.renderer.updateText()

            editor.commands.on("afterExec", (e) ->

                thatEditor = e.editor
                currentValue = thatEditor.getValue()
                hintDataAryMap = thatEditor.hintObj

                if e.command.name is "insertstring"
                    if /^@$/.test(e.args) and hintDataAryMap['at']
                        that.setEditorCompleter(thatEditor, hintDataAryMap['at'], 'reference')
                        thatEditor.execCommand("startAutocomplete")

                if e.command.name is "backspace" and hintDataAryMap['focus']
                    that.setEditorCompleter(thatEditor, hintDataAryMap['focus'], 'command')
                    thatEditor.execCommand("startAutocomplete")

                if e.command.name is "backspace" and hintDataAryMap['at'] and currentValue
                    currentLineContent = thatEditor.getSession().getLine(thatEditor.getCursorPosition().row)
                    if currentLineContent.indexOf('@') >= 0
                        that.setEditorCompleter(thatEditor, hintDataAryMap['at'], 'reference')
                        thatEditor.execCommand("startAutocomplete")

                if e.command.name is "autocomplete_confirm"

                    if $editorElem.hasClass('command-value')

                        value = e.args
                        $stateItem = $editorElem.parents('.state-item')
                        originCMDName = $stateItem.attr('data-command')

                        if originCMDName isnt value

                            $stateItem.attr('data-command', value)
                            that.refreshDescription(value)
                            $paraListElem = $stateItem.find('.parameter-list')
                            that.refreshParaList($paraListElem, value)
                            that.refreshStateView($stateItem)

                    else if $editorElem.hasClass('parameter-value')

                        $paraItem = $editorElem.parents('.parameter-item')
                        if $paraItem.hasClass('dict')
                            that.onDictInputChange({
                                currentTarget: $editorElem[0]
                            })
                        else if $paraItem.hasClass('array') or $paraItem.hasClass('state')
                            that.onArrayInputChange({
                                currentTarget: $editorElem[0]
                            })
            )

            editor.on("focus", (e, thatEditor) ->

                hintDataAryMap = thatEditor.hintObj
                currentValue = thatEditor.getValue()
                if not currentValue and hintDataAryMap['focus']
                    that.setEditorCompleter(thatEditor, hintDataAryMap['focus'], 'command')
                    thatEditor.execCommand("startAutocomplete")
            )

        setEditorCompleter: (editor, dataAry, metaType) ->

            editor.completers = [{
                getCompletions: (editor, session, pos, prefix, callback) ->
                    if dataAry and dataAry.length
                        callback(null, dataAry.map((ea) ->
                            return {
                                name: ea.name,
                                value: ea.value,
                                score: ea.value,
                                meta: metaType
                            }
                        ))
                    else
                        callback(null, [])
            }]

            null

        getRepresent: ( inputElem ) ->
            $input = $ inputElem
            $stateItem = $input.closest '.state-item'
            #$stateToolbar = $stateItem.prev '.state-toolbar'

            if $input.hasClass 'command-value'
                represent = $stateItem.find '.state-view .command-view-value'
            else
                $paraItem = $input.closest('.parameter-item')
                paramName = $paraItem.data('paraName')

                represent = $stateItem.find ".state-view [data-para-name='#{paramName}']"

            represent

        getParaObjByInput: ( inputElem ) ->

            that = this
            $inputElem = $ inputElem
            retVal = {}

            if $inputElem.hasClass 'command-value'
                type = 'command'
                retVal =
                    type: type
                    dataMap: that.cmdParaObjMap
            else
                type = 'parameter'

                $paraItem = $inputElem.closest('.parameter-item')
                $stateItem = $paraItem.closest('.state-item')

                paramName = $paraItem.data('paraName')
                command = $stateItem.data('command')

                currentParaMap = that.cmdParaObjMap[command]
                constraint = currentParaMap[paramName]

                if $inputElem.hasClass 'key'
                    subType = 'key'
                else if $inputElem.hasClass 'value'
                    subType = 'value'

                retVal =
                    type: type
                    subType: subType
                    command: command
                    paramName: paramName
                    constraint: constraint
                    dataMap: that.cmdParaObjMap
                    refList: that.model.genAttrRefList()


            retVal

        getPlainText: (inputElem) ->

            $inputElem = $(inputElem)
            editor = $inputElem.data('editor')

            if editor
                return editor.getValue()
            else
                return $inputElem.text()

        setPlainText: (inputElem, content) ->

            $inputElem = $(inputElem)
            editor = $inputElem.data('editor')
            if editor then editor.setValue(content)

        updateStateIdBySort: (newOldStateIdMap) ->

            that = this
            that.model.updateAllStateRef(newOldStateIdMap)

        refreshStateLogList: () ->

            that = this
            stateLogDataAry = that.model.get('stateLogDataAry')

            if not (stateLogDataAry and stateLogDataAry.length)
                that.showLogListLoading(false, true)

            stateLogViewAry = []
            stateStatusMap = {}
            _.each stateLogDataAry, (logObj, idx) ->
                timeStr = null
                if logObj.time
                    timeStr = MC.dateFormat(new Date(logObj.time), 'yyyy-MM-dd hh:mm:ss')
                stateStatus = logObj.result
                stateId = "#{logObj.state_id}"
                stateNum = ''
                if logObj.state_id isnt 'Agent'
                    stateId = "State #{stateId}"
                    stateStatusMap[logObj.state_id] = stateStatus
                else
                    stateNum = logObj.state_id

                stateLogViewAry.push({
                    state_id: logObj.state_id,
                    state_num: stateNum,
                    log_time: timeStr,
                    state_status: stateStatus,
                    stdout: logObj.stdout,
                    stderr: logObj.stderr
                })
                null

            renderHTML = that.stateLogItemTpl({
                state_logs: stateLogViewAry
            })

            that.refreshStateItemStatus(stateStatusMap)
            that.$stateLogList.append(renderHTML)
            that.refreshLogItemNum()

        setEditorReadOnlyMode: () ->

            that = this

            editableAreaAry = that.$stateList.find('.editable-area')
            _.each editableAreaAry, (editableArea) ->
                $editableArea = $(editableArea)
                editor = $editableArea.data('editor')
                if editor
                    editor.setReadOnly(true)
                null

            that.$stateList.find('.state-drag').hide()
            that.$stateList.find('.state-add').hide()
            that.$stateList.find('.state-remove').hide()
            that.$stateList.find('.parameter-remove').hide()
            that.$editorModal.find('.state-item-add').hide()

            $saveCancelBtn = that.$editorModal.find('.state-save, .state-cancel')
            $saveCancelBtn.hide()

            $closeBtn = that.$editorModal.find('.state-close')
            $closeBtn.css('display', 'inline-block')

        showLogListLoading: (loadShow, infoShow) ->

            that = this

            $logPanel = $('#state-log')
            $loadText = $logPanel.find('.state-log-loading')
            $logInfo = $logPanel.find('.state-log-info')

            if loadShow

                $loadText.show()
                $logInfo.hide()

            else

                $loadText.hide()

                if infoShow
                    $logInfo.show()
                else
                    $logInfo.hide()

        onResSelectChange: (event) ->

            that = this

            selectedResId = $(event.target).find('.selected').attr('data-id')

            # refresh state log
            that.showLogListLoading(true)

            that.model.getResState(selectedResId)
            resState = that.model.get('resState')
            
            that.$stateLogList.empty().html(that.stateLogInstanceItemTpl({
                res_status: resState
            }))
            that.model.genStateLogData(selectedResId, () ->
                that.refreshStateLogList()
                that.showLogListLoading(false)
            )

        onOptionalParaItemChange: (event) ->

            that = this
            $currentInputElem = $(event.currentTarget)
            currentValue = that.getPlainText($currentInputElem)

            if currentValue
                $paraItem = $currentInputElem.parents('.parameter-item')
                $paraItem.removeClass('disabled')

        onCommandInputBlur: (event) ->

            that = this

            $currentElem = $(event.currentTarget)
            $stateItem = $currentElem.parents('.state-item')
            currentValue = that.getPlainText($currentElem)

            moduleObj = that.cmdModuleMap[currentValue]

            if moduleObj

                originCMDName = $stateItem.attr('data-command')

                if originCMDName isnt currentValue

                    $stateItem.attr('data-command', currentValue)
                    that.refreshDescription(currentValue)
                    $paraListElem = $stateItem.find('.parameter-list')
                    that.refreshParaList($paraListElem, currentValue)
                    that.refreshStateView($stateItem)

        refreshStateItemStatus: (stateStatusMap) ->

            that = this

            $stateItemList = that.$stateList.find('.state-item')

            _.each $stateItemList, (stateItem) ->

                $stateItem = $(stateItem)
                stateId = $stateItem.attr('data-id')
                $statusIcon = $stateItem.find('.state-status-icon')
                $statusIcon.removeClass('success').removeClass('failure')
                stateStatus = stateStatusMap[stateId]
                if stateStatus is 'success'
                    $statusIcon.addClass('success')
                else if stateStatus is 'failure'
                    $statusIcon.addClass('failure')
                null

        refreshLogItemNum: () ->

            that = this

            if that.currentState is 'stack'
                return

            stateIdNumMap = {}
            $stateItemList = that.$stateList.find('.state-item')
            _.each $stateItemList, (stateItem, idx) ->
                $stateItem = $(stateItem)
                stateId = $stateItem.attr('data-id')
                stateIdNumMap[stateId] = idx + 1
                null

            $logItemList = that.$stateLogList.find('.state-log-item')

            _.each $logItemList, (logItem, idx) ->

                if idx >= 2

                    $logItem = $(logItem)
                    stateId = $logItem.attr('data-state-id')

                    stateNum = stateIdNumMap[stateId]

                    stateNumStr = 'unknown'
                    if stateNum then stateNumStr = stateNum
                    
                    $logItem.find('.state-log-item-name').text('State ' + stateNumStr)

                null

        unloadEditor: () ->

            that = this

            $editAreaList = that.$stateList.find('.editable-area')

            _.each $editAreaList, (editArea) ->
                $editArea = $(editArea)
                editor = $editArea.data('editor')
                if editor then editor.destroy()
                null

            $aceAutoCompList = $('.ace_editor.ace_autocomplete')
            $aceAutoCompList.remove()

        keyEvent: (event) ->
            that = event.data.target
            keyCode = event.which

            # Remove state item [Ctrl + delete/backspace]
            if event.ctrlKey and (keyCode is 46 or keyCode is 8)
                $('.state-list').find('.selected').remove()
                return false

            # Add state item [Ctrl + +]
            if event.ctrlKey and keyCode is 187
                that.addStateItem.call(that, event)
                return false
            # return false
    }

    return StateEditorView
