#############################
#  View(UI logic) for component/stateeditor
#############################

define [ 'event',
         'i18n!nls/lang.js',
         'text!./component/stateeditor/template.html',
         './component/stateeditor/validate',
         'constant',
         'instance_model',
         'UI.errortip'

], ( ide_event, lang, template , validate, constant, instance_model ) ->

    StateEditorView = Backbone.View.extend {

        events:

            'closed': 'closedPopup'
            'blur .parameter-item.dict .parameter-value': 'onDictInputBlur'

            'keyup .parameter-item.dict .parameter-value': 'onDictInputChange'
            'paste .parameter-item.dict .parameter-value': 'onDictInputChange'
            
            'keyup .parameter-item.array .parameter-value': 'onArrayInputChange'
            'paste .parameter-item.array .parameter-value': 'onArrayInputChange'

            'keyup .parameter-item.state .parameter-value': 'onArrayInputChange'
            'paste .parameter-item.state .parameter-value': 'onArrayInputChange'

            'blur .parameter-item.array .parameter-value': 'onArrayInputBlur'
            'blur .parameter-item.state .parameter-value': 'onArrayInputBlur'
            'blur .command-value': 'onCommandInputBlur'
            'focus .editable-area': 'onFocusInput'
            'blur .editable-area': 'onBlurInput'

            # 'click .state-toolbar .state-id': 'onStateIdClick'
            'click #state-toolbar-add': 'addStateItem'
            'click #state-toolbar-copy-all': 'copyAllState'
            'click #state-toolbar-copy': 'copyState'
            'click #state-toolbar-delete': 'removeState'
            'click #state-toolbar-paste': 'pasteState'
            'click #state-toolbar-undo': 'onUndo'
            'click #state-toolbar-redo': 'onRedo'

            'click #state-toolbar-selectAll': 'onSelectAllClick'

            'click .state-toolbar': 'onStateToolbarClick'

            'click .state-toolbar .checkbox': 'checkboxSelect'
            # 'click .state-toolbar .state-add': 'onStateAddClick'
            'click .state-toolbar .state-remove': 'onStateRemoveClick'
            'click .state-save': 'onStateSaveClick'
            'click .state-cancel': 'onStateCancelClick'
            'click .state-close': 'onStateCancelClick'
            'click .parameter-item .parameter-remove': 'onParaRemoveClick'
            'click .state-desc-toggle': 'onDescToggleClick'
            'click .state-log-toggle': 'onLogToggleClick'
            'click .state-log-refresh': 'onLogRefreshClick'
            'click .state-sys-log-btn': 'openSysLogModal'

            'click .state-item-add': 'onStateItemAddClick'

            'click .state-item-add-btn': 'onStateItemAddBtnClick'

            'click #state-editor': 'onClickBlank'

            'click .state-log-item-header': 'onStateLogItemHeaderClick'

            'click .state-log-item .state-log-item-view-detail': 'onStateLogDetailBtnClick'

            'OPTION_CHANGE .state-editor-res-select': 'onResSelectChange'

            'keyup .parameter-item.optional .parameter-value': 'onOptionalParaItemChange'
            'paste .parameter-item.optional .parameter-value': 'onOptionalParaItemChange'

            'click .parameter-item .parameter-name': 'onParaNameClick'

            'SWITCH_STATE': 'onSwitchState'

            'EXPAND_STATE': 'onExpandState',

            'COLLAPSE_STATE': 'onCollapseState'

            'REMOVE_STATE': 'onRemoveState'

            'ACE_TAB_SWITCH': 'aceTabSwitch'

            'ACE_UTAB_SWITCH': 'aceUTabSwitch'

        editorShow: false

        initialize: () ->
            this.compileTpl()

        initState: () ->

            this.initData()
            this.initUndoManager()

            $(document)
                .off('keydown', this.keyEvent)
                .on('keydown', {target: this}, this.keyEvent)


        closedPopup: () ->

            @trigger 'CLOSE_POPUP'
            $(document).off 'keydown', this.keyEvent

        render: () ->

            that = this
            compData = @model.get 'compData'

            that.initState()

            if that.isWindowsPlatform
                @__renderEmpty('is_windows')
                return that

            if Design.instance().get('agent').enabled
                if compData and compData.type in [constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration]
                    @__renderState()
                else
                    @__renderEmpty()
            else
                @__renderEmpty 'disalbed'

            @

        __renderEmpty: ( type ) ->

            tipSet =
                disalbed : 'VisualOps is disabled.'
                void     : "The component does'nt have state editor."
                group    : 'View states and log by selecting individual instance.'
                default  : 'No state editor here.'
                group_in_app : 'View states and log by selecting individual instance.'
                is_windows : 'Editing state is only available for Linux platform.'

            tip = type and tipSet[ type ] or tipSet.default

            @$el.html @stateEmptyTpl { tip: tip }
            @editorShow = false
            @

        renderStateCount: () ->
            count = @$stateList.find( '.state-item' ).length
            $( '#btn-switch-state b' ).text "(#{count})"

        __renderState: () ->

            @editorShow = true
            that = this

            # show modal
            @$el.html that.editorModalTpl({
                res_name: that.resName,
                supported_platform: that.supportedPlatform,
                current_state: that.currentState,
                no_state: that.resNoState,
                allow_add_state: (that.currentState in ['stack', 'appedit'])
            }), false, null, {opacity: 0.2, conflict: 'loose'}

            # setTimeout(() ->

            #that.setElement $( '#state-editor-model' ).closest '#modal-wrap'
            that.$editorModal = that.$el
            that.$stateList = that.$editorModal.find('.state-list')
            that.$stateLogList = that.$editorModal.find('.state-log-list')
            that.$cmdDsec = that.$('#state-description')
            that.$noStateContainer = that.$editorModal.find('.state-no-state-container')
            that.$haveStateContainer = that.$editorModal.find('.state-have-state-container')
            that.$stateGistPasteArea = @$('#state-gist-paste-area')

            if that.resNoState

                that.$haveStateContainer.hide()
                that.$noStateContainer.show()

            else

                that.$haveStateContainer.show()
                that.$noStateContainer.hide()

            # hide autocomplete when click document
            docMouseDownFunc = jQuery.proxy(that.onDocumentMouseDown, that)
            $(document).off('mousedown', docMouseDownFunc).on('mousedown', docMouseDownFunc)

            onPasteGistData = jQuery.proxy(that.onPasteGistData, that)
            $(document).off('paste', onPasteGistData).on('paste', onPasteGistData)

            that.$('#state-editor').on('scroll', () ->
                that.$('.ace_editor.ace_autocomplete').hide()
            )

            stateObj = that.loadStateData(that.originCompStateData)
            that.refreshStateList(stateObj)

            $stateItemList = that.$stateList.find('.state-item')
            that.refreshStateViewList($stateItemList)

            that.bindStateListSortEvent()

            if that.readOnlyMode
                that.setEditorReadOnlyMode()

            that.refreshDescription()

            # that.initResSelect()

            # refresh state log
            that.onLogRefreshClick()

            if that.isShowLogPanel
                that.showLogPanel()

            $logPanelToggle = that.$editorModal.find('.state-log-toggle')
            $logPanelRefresh = that.$editorModal.find('.state-log-refresh')
            $logSysBtn = that.$editorModal.find('.state-sys-log-btn')

            if that.currentState is 'stack'
                $logPanelToggle.hide()

            else if that.currentState in ['app', 'appedit']
                currentAppState = Design.instance().get('state')
                if currentAppState is 'Stopped'
                    $logPanelToggle.hide()
                    $logPanelRefresh.hide()
                    if not that.currentResId
                        $logSysBtn.hide()

            $aceAutocompleteTip = $('.ace_autocomplete_tip')
            if not $aceAutocompleteTip.length
                $('body').append('<div class="ace_autocomplete_tip">No result matches the input</div>')
            that.$aceAutocompleteTip = $('.ace_autocomplete_tip')

            # , 1)

            that.updateToolbar()

            if $( '#property-panel' ).hasClass('state-wide')
                that.onDescToggleClick()
            @

        initData: () ->

            that = this
            that.cmdNameAry = that.model.get('cmdNameAry')
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
            that.isWindowsPlatform = that.model.get('isWindowsPlatform')

            that.currentResId = that.model.get('resId')

            that.currentState = that.model.get('currentState')
            currentAppState = that.model.get('currentAppState')

            that.resAttrRegexStr = that.model.get('resAttrRegexStr')

            that.generalTip = 'Get Started with Conﬁguration Manager Conﬁguration manager is blah blah blah... You can use following command...'

            that.resNoState = true
            if that.originCompStateData and _.isArray(that.originCompStateData) and that.originCompStateData.length
                that.resNoState = false

            if that.currentState is 'app'
                that.readOnlyMode = true
                that.isShowLogPanel = true
                that.setEditorAppModel()

            if that.currentState is 'appedit'
                that.readOnlyMode = false
                that.isShowLogPanel = true
                that.setEditorAppModel()

            else if that.currentState is 'stack'
                that.readOnlyMode = false
                that.isShowLogPanel = false

        setEditorAppModel: () ->

            that = this

            if (not that.currentResId) and that.groupResSelectData and that.groupResSelectData[0]
                that.currentResId = that.groupResSelectData[0].res_id

            if not that.currentResId
                that.isShowLogPanel = false

            null

        tplMap:
            'state-template-editor-modal'       : 'editorModalTpl'
            'state-template-state-list'         : 'stateListTpl'
            'state-template-para-list'          : 'paraListTpl'
            'state-template-para-view-list'     : 'paraViewListTpl'
            'state-template-para-dict-item'     : 'paraDictListTpl'
            'state-template-para-array-item'    : 'paraArrayListTpl'
            'state-template-log-item'           : 'stateLogItemTpl'
            'state-template-log-instance-item'  : 'stateLogInstanceItemTpl'
            'state-template-res-select'         : 'stateResSelectTpl'
            'state-template-editor-empty'       : 'stateEmptyTpl'
            'state-template-log-detail-modal'   : 'stateLogDetailModal'

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

            for id, html of htmlMap
                Handlebars.registerPartial(id, html)
                @[ @tplMap[ id ] ] = Handlebars.compile html

            Handlebars.registerHelper('breaklines', (text) ->
                text = Handlebars.Utils.escapeExpression(text)
                text = text.replace(/(\r\n|\n|\r)/gm, '<br>')
                return new Handlebars.SafeString(text)
            )

            null

        genStateUID: () ->

            return 'state-' + MC.guid()

        # initResSelect: () ->

        #     that = this

        #     $resSelect = that.$editorModal.find('.state-editor-res-select')

        #     if that.groupResSelectData and that.groupResSelectData.length

        #         resSelectHTML = that.stateResSelectTpl({
        #             res_selects: that.groupResSelectData
        #         })

        #         $resSelect.html(resSelectHTML)

        #         if that.groupResSelectData.length is 1

        #             $resSelect.hide()

        #     else

        #         $resSelect.hide()

        bindStateListSortEvent: () ->

            that = this

            # state item sortable
            that.$stateList.dragsort({
                itemSelector: '.state-item',
                dragSelector: '.state-drag',
                dragBetween: true,
                placeHolderTemplate: '<div class="state-item state-placeholder"></div>',

                dragStart: (stateItem) ->
                    $stateItem = $(stateItem)
                    that.collapseItem($stateItem)

                dragEnd: (stateItem, oldIndex) ->
                    $stateItem = $(stateItem)
                    newIndex = $stateItem.index()
                    stateId = $stateItem.attr('data-id')
                    if oldIndex isnt newIndex
                        that.undoManager.register(stateId, oldIndex, 'sort', newIndex)
                    that.refreshLogItemNum()
            })

            # dragsort.init({
            #     dragStart: () ->
            #         $stateItem = this
            #         that.collapseItem($stateItem)
            #         return true
            #     dragEnd: (event, oldIndex) ->
            #         $stateItem = this
            #         newIndex = $stateItem.index()
            #         stateId = $stateItem.attr('data-id')

            #         if oldIndex isnt newIndex
            #             that.undoManager.register(stateId, oldIndex, 'sort', newIndex)

            #         that.refreshLogItemNum()
            #         null
            #     $el: that.$el
            # })

        onLogRefreshClick: (event) ->

            that = this
            # $resSelectElem = that.$editorModal.find('.state-editor-res-select')
            # if that.currentState is 'stack'
            #     $resSelectElem.hide()
            # else
            #     that.onResSelectChange({
            #         target: $resSelectElem[0]
            #     })

            that.onResSelectChange()

        refreshStateList: (stateListObj) ->

            that = this

            if not (stateListObj and stateListObj.state_list.length)

                stateListObj = {
                    state_list: []
                    # state_list: [{
                    #     id: that.genStateUID(),
                    #     id_show: '1',
                    #     cmd_value: ''
                    # }]
                }

            that.$stateList.html(this.stateListTpl(stateListObj))

            $stateItems = that.$stateList.find('.state-item')

            # that.bindStateListEvent($stateItems)

        refreshStateViewList: ($stateItemList) ->

            that = this

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

            mustShowPara = true
            _.each currentParaMap, (paraObj) ->
                if paraObj.visible
                    mustShowPara = false
                null

            _.each $paraItemList, (paraItemElem) ->

                $paraItem = $(paraItemElem)
                paraName = $paraItem.attr('data-para-name')
                paraObj = currentParaMap[paraName]

                paraType = paraObj.type
                paraName = paraObj.name

                paraNoVisible = true
                if mustShowPara
                    paraNoVisible = false
                else
                    if paraObj.visible
                        if paraObj.required
                            paraNoVisible = false
                        else
                            if not $paraItem.hasClass('disabled')
                                paraNoVisible = false

                viewRenderObj = {
                    para_name: paraName,
                    para_no_visible: paraNoVisible
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

                    if paraType is 'bool'
                        if paraValue is 'true'
                            paraValue = paraName
                        else
                            viewRenderObj.para_no_visible = true

                viewRenderObj.para_value = paraValue
                if paraValue
                    paraListViewRenderAry.push(viewRenderObj)

                null

            $paraViewListElem.html(that.paraViewListTpl({
                parameter_view_list: paraListViewRenderAry
            }))

        bindStateListEvent: ($stateItems) ->

            that = this

            _.each $stateItems, (stateItem) ->

                $stateItem = $(stateItem)
                $cmdValueItem = $stateItem.find('.command-value')
                that.bindCommandEvent($cmdValueItem)

                null

        bindCommandEvent: ($cmdValueItem) ->

            that = this

            cmdNameAry = that.cmdNameAry

            cmdNameAry = _.map cmdNameAry, (value, i) ->

                metaStr = ''
                if value.support is false
                    metaStr = 'not supported'

                return {
                    'name': value.name,
                    'value': value.name,
                    'meta': metaStr,
                    'support': value.support
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

                $commentStateItem = $paraItem.parents('.state-item.comment')
                $firstInput = $commentStateItem.find('.parameter-value')
                firstEditor = $firstInput.data('editor')
                if firstEditor
                    firstEditor.focus()

            else if paraType is 'state'

                $inputElemAry = $paraItem.find('.parameter-value')

                if not $inputElemAry.length
                    $inputElemAry = $paraItem.nextAll('.parameter-value')

                haveAtDataAry = _.map that.resStateDataAry, (stateRefObj) ->
                    return {
                        name: '@' + stateRefObj.name,
                        value: '@' + stateRefObj.value
                        meta: stateRefObj.meta
                    }

                _.each $inputElemAry, (inputElem) ->
                    that.initCodeEditor(inputElem, {
                        focus: haveAtDataAry
                        # at: that.resStateDataAry
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
                descMarkdown = that.generalTip

            descHTML = ''

            setTimeout(() ->
                if descMarkdown
                    descHTML = markdown.toHTML(descMarkdown)
                that.$cmdDsec.html(descHTML)
                that.$cmdDsec.find('em:contains(required)').parents('li').addClass('required')
                that.$cmdDsec.find('em:contains(optional)').parents('li').addClass('optional')
                that.$cmdDsec.scrollTop(0)
            , 0)

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

            setTimeout(() ->
                that.bindParaListEvent($paraListElem, currentCMD)
            , 10)

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

                if paraObj

                    that.highlightParaDesc(paraObj.name)

            #         if paraObj.default isnt undefined
            #             defaultValue = String(paraObj.default)
            #             if not currentValue and defaultValue and not $currentInput.hasClass('key')
            #                 that.setPlainText($currentInput, defaultValue)
            #                 $paraItem = $currentInput.parents('.parameter-item')
            #                 $paraItem.removeClass('disabled')

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

        onParaNameClick: (event) ->

            that = this
            $currentParaName = $(event.currentTarget)
            $paraItem = $currentParaName.parents('.parameter-item')

            $paraFirstVauleInput = $paraItem.find('.parameter-value')
            inputEditor = $paraFirstVauleInput.data('editor')
            if inputEditor then inputEditor.focus()

        onStateToolbarClick: (event) ->

            that = this

            $stateToolbarElem = $(event.currentTarget)

            # if not ($stateToolbarElem.hasClass('state-drag') or
            #         $stateToolbarElem.hasClass('state-add') or
            #         $stateToolbarElem.hasClass('state-remove'))

            that.clearFocusedItem()

            $stateItem = $stateToolbarElem.parents('.state-item')

            $stateItem.addClass('focused')

            # $stateItemList = that.$stateList.find('.state-item')

            if $stateItem.hasClass('view')
                that.expandItem.call this, $stateItem
            else
                that.collapseItem.call this, $stateItem

            return false

        expandItem: ($stateItem) ->

            that = this

            that.clearFocusedItem()

            $stateItemList = that.$stateList.find('.state-item')

            currentCMD = $stateItem.attr('data-command')
            $paraListItem = $stateItem.find('.parameter-list')
            that.bindStateListEvent([$stateItem])

            # remove other item view
            _.each $stateItemList, (otherStateItem) ->
                $otherStateItem = $(otherStateItem)
                if not $stateItem.is($otherStateItem) and not $otherStateItem.hasClass('view')
                    that.refreshStateView($otherStateItem)
                null

            $stateItemList.addClass('view')
            $stateItem.removeClass('view').addClass('focused')

            # that.justScrollToElem that.$stateList, $stateItem

            # refresh description
            cmdName = $stateItem.attr('data-command')
            if cmdName
                that.refreshDescription(cmdName)

            if that.currentState in ['app', 'appedit']
                currentStateId = $stateItem.attr('data-id')
                that.scrollToLogItem(currentStateId)

            $cmdValueItem = $stateItem.find('.command-value')
            cmdEditor = $cmdValueItem.data('editor')
            if cmdEditor
                setTimeout(() ->
                    cmdEditor.focus()
                , 0)

            setTimeout(() ->
                that.bindParaListEvent($paraListItem, currentCMD)
                if that.readOnlyMode
                    that.setEditorReadOnlyMode()
            , 10)

            # $stateItem.addClass('selected')

            # $stateItem.find('.checkbox input').prop('checked', true)

        collapseItem: ($stateItem) ->

            that = this

            that.refreshStateView($stateItem)
            $stateItem.addClass('view')
            that.refreshDescription()

        onExpandState: (event) ->

            that = this

            that.expandItem($('.state-list').find('.focused'))

            return false

        onCollapseState: (event) ->

            that = this

            that.collapseItem($('.state-list').find('.focused'))

            return false

        clearSelectedItem: () ->

            that = this

            that.$stateList.find('.selected').removeClass('selected')

            that.$stateList.find('.checkbox input').prop('checked', false)

            null

        clearFocusedItem: () ->

            that = this

            that.$stateList.find('.focused').removeClass('focused')

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
        #             id_show: newStateId
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

            return false

        addStateItem: (event) ->

            that = this

            if that.currentState is 'app'
                return false

            $stateItem = that.$stateList.find('.state-item:last')

            newStateId = that.genStateUID()

            newStateHTML = that.stateListTpl({
                state_list: [{
                    id: newStateId
                }]
            })

            $focusState = that.$stateList.find('.state-item.focused')
            if $focusState.length
                $newStateItem = $(newStateHTML).insertAfter($focusState)
            else
                $newStateItem = $(newStateHTML).appendTo(that.$stateList)

            that.clearFocusedItem()

            $cmdValueItem = $newStateItem.find('.command-value')
            that.bindCommandEvent($cmdValueItem)

            $stateItemList = that.$stateList.find('.state-item')

            _.each $stateItemList, (otherStateItem) ->
                $otherStateItem = $(otherStateItem)
                if not $newStateItem.is($otherStateItem) and not $otherStateItem.hasClass('view')
                    that.refreshStateView($otherStateItem)
                null

            $stateItemList.addClass('view')

            $newStateItem.removeClass('view').addClass('focused')

            cmdEditor = $cmdValueItem.data('editor')
            if cmdEditor
                setTimeout(() ->
                    cmdEditor.focus()
                , 0)

            that.refreshLogItemNum()

            $stateItems = that.$stateList.find('.state-item')
            if $stateItems.length
                that.$haveStateContainer.show()
                that.$noStateContainer.hide()

            # redo/undo
            statePos = $newStateItem.index()
            that.undoManager.register(newStateId, statePos, 'add')

            that.updateToolbar()

            return false

        onStateRemoveClick: (event) ->

            that = this

            $currentElem = $(event.currentTarget)
            $stateItem = $currentElem.parents('.state-item')

            that.onRemoveState(null, $stateItem)

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

        genStateItemData: ($stateItem) ->

            that = this

            cmdName = $stateItem.attr('data-command')
            stateId = $stateItem.attr('data-id')

            moduleObj = that.cmdModuleMap[cmdName]

            #empty module direct return
            if not moduleObj
                return {
                    id: stateId,
                    module: '',
                    parameter: {}
                }

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
                    dictObjAry = []

                    _.each $dictItemList, (dictItem) ->

                        $dictItem = $(dictItem)
                        $keyInput = $dictItem.find('.key')
                        $valueInput = $dictItem.find('.value')

                        keyValue = that.getPlainText($keyInput)
                        valueValue = that.getPlainText($valueInput)

                        if keyValue
                            valueValue = that.model.replaceParaNameToUID(valueValue)
                            dictObjAry.push({
                                key: keyValue,
                                value: valueValue
                            })

                        null

                    paraValue = dictObjAry

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

            return stateItemObj

        saveStateData: () ->

            # if not @submitValidate()
            #     return false

            that = this

            $stateItemList = that.$stateList.find('.state-item')

            stateObjAry = []

            # newOldStateIdMap = {}

            _.each $stateItemList, (stateItem, idx) ->

                $stateItem = $(stateItem)

                stateItemObj = that.genStateItemData($stateItem)

                if stateItemObj and stateItemObj.module and stateItemObj.id
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

                try

                    cmdName = that.moduleCMDMap[state.module]
                    paraModelObj = that.cmdParaObjMap[cmdName]

                    paraListObj = state.parameter
                    stateId = state.id

                    stateRenderObj = {
                        id: stateId,
                        id_show: idx + 1,
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

                            if _.isArray(paraValue)

                                _.each paraValue, (paraValueObj) ->

                                    paraValueObj.value = that.model.replaceParaUIDToName(paraValueObj.value)

                                    renderParaValue.push({
                                        key: paraValueObj.key
                                        value: paraValueObj.value
                                    })

                                    null

                            # adjust for old format

                            else if _.isObject(paraValue)

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

                            if not _.isArray(paraValue)
                                if not paraValue
                                    paraValue = ''
                                paraValue = [paraValue]

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

                catch err

                    console.log('state editor: resource state data parse failed')

                null

            return renderObj

        onStateSaveClick: (event) ->

            that = this

            stateData = that.saveStateData()

            that.model.setStateData(stateData)

            if stateData

                # compare
                compareStateData = null
                otherCompareStateData = null

                # compare state data
                # when data change, trigger data update event

                changeAry = []

                if that.originCompStateData and stateData

                    if that.originCompStateData.length > stateData.length
                        compareStateData = stateData
                        otherCompareStateData = that.originCompStateData
                    else
                        compareStateData = that.originCompStateData
                        otherCompareStateData = stateData

                    _.each compareStateData, (stateObj, idx) ->
                        if not _.isEqual(stateObj, otherCompareStateData[idx])
                            changeAry.push(stateObj.id)
                        null

                    if that.currentState in ['app', 'appedit']
                        changeObj = {
                            resId: that.currentResId,
                            stateIds: changeAry
                        }
                        if (not _.isEqual(that.originCompStateData, stateData)) or changeAry.length
                            ide_event.trigger ide_event.STATE_EDITOR_DATA_UPDATE, changeObj

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

            expandPanel = $('#property-panel').hasClass('state-wide')
            if expandPanel and $descPanel.hasClass('show')

                $stateEditor.addClass('full')
                # $descPanel.hide()
                # $logPanel.hide()
                $logPanel.removeClass('show')
                $descPanel.removeClass('show')
                $descPanelToggle.removeClass('active')
                $('#property-panel').removeClass 'state-wide'

            else

                $stateEditor.removeClass('full')
                # $logPanel.hide()
                # $descPanel.show()
                $logPanel.removeClass('show')
                $descPanel.addClass('show')
                $descPanelToggle.addClass('active')
                $('#property-panel').addClass 'state-wide'

            $logPanelToggle.removeClass('active')

        onLogToggleClick: (event) ->

            that = this

            if that.currentState in ['app', 'appedit']
                currentAppState = Design.instance().get('state')
                if currentAppState is 'Stopped'
                    return

            $stateEditor = $('#state-editor')
            $descPanel = $('#state-description')
            $logPanel = $('#state-log')

            $descPanelToggle = that.$editorModal.find('.state-desc-toggle')
            $logPanelToggle = that.$editorModal.find('.state-log-toggle')

            expandPanel = $('#property-panel').hasClass('state-wide')
            if expandPanel and $logPanel.hasClass('show')

                $stateEditor.addClass('full')
                # $logPanel.hide()
                # $descPanel.hide()
                $descPanel.removeClass('show')
                $logPanel.removeClass('show')
                $logPanelToggle.removeClass('active')
                $('#property-panel').removeClass 'state-wide'

            else

                $stateEditor.removeClass('full')
                # $descPanel.hide()
                # $logPanel.show()
                $descPanel.removeClass('show')
                $logPanel.addClass('show')
                $logPanelToggle.addClass('active')
                $('#property-panel').addClass 'state-wide'

            $descPanelToggle.removeClass('active')

        showLogPanel: () ->

            that = this
            $stateEditor = $('#state-editor')
            $descPanel = $('#state-description')
            $logPanel = $('#state-log')

            $descPanelToggle = that.$editorModal.find('.state-desc-toggle')
            $logPanelToggle = that.$editorModal.find('.state-log-toggle')

            $stateEditor.removeClass('full')
            $descPanel.removeClass('show')
            $logPanel.addClass('show')

            $logPanelToggle.addClass('active')
            $descPanelToggle.removeClass('active')

            null

        onDocumentMouseDown: (event) ->

            that = this
            $currentElem = $(event.target)
            $parentElem = $currentElem.parents('.editable-area')

            if not $parentElem.length and not $currentElem.hasClass('editable-area') and not $currentElem.hasClass('ace_scrollbar')
                $allEditableArea = $('.editable-area')
                _.each $allEditableArea, (editableArea) ->
                    $editableArea = $(editableArea)
                    editor = $editableArea.data('editor')
                    if editor then editor.blur()
                    null
                # that.refreshDescription()

                setTimeout(() ->
                    that.$stateGistPasteArea.focus()
                , 0)

            that.onMouseDownSaveFromOther(event)

        onMouseDownSaveFromOther: (event) ->

            that = this
            $currentElem = $(event.target)
            $parentElem = $currentElem.parents('.editable-area')
            $stateEditorModel = $('#state-editor-model')
            $parentEditorModel = $currentElem.parents('#state-editor-model')
            if $stateEditorModel.length and (not $parentEditorModel.length)
                if $stateEditorModel.is(':visible')
                    that.onStateSaveClick()
                else
                    if $currentElem.parents('#tabbar-wrapper').length
                        that.onStateSaveClick()

        initCodeEditor: (editorElem, hintObj) ->

            that = this

            if not editorElem then return
            $editorElem = $(editorElem)
            if $editorElem.data('editor')
                return

            _initEditor = () ->

                # if that.readOnlyMode
                #     return

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

                # move cursor to last
                editSession = editor.getSession()
                editRow = editSession.getLength()
                editColumn = editSession.getLine(editRow - 1).length
                editor.gotoLine(editRow, editColumn)

                editor.commands.on("afterExec", (e) ->

                    thatEditor = e.editor
                    currentValue = thatEditor.getValue()
                    hintDataAryMap = thatEditor.hintObj

                    if e.command.name is "insertstring"
                        if /^{$/.test(e.args) and hintDataAryMap['at']

                            editSession = thatEditor.getSession()
                            cursorPos = thatEditor.getCursorPosition()
                            editRow = cursorPos.row
                            editColumn = cursorPos.column
                            lineStr = editSession.getLine(editRow)
                            lastChar = lineStr[editColumn - 2]
                            if lastChar is '@'
                                thatEditor.insert('}')
                                thatEditor.moveCursorTo(editRow, editColumn)
                                that.setEditorCompleter(thatEditor, hintDataAryMap['at'], 'reference')
                                thatEditor.execCommand("startAutocomplete")

                    if e.command.name is "backspace"

                        $stateItem = $editorElem.parents('.state-item')

                        if hintDataAryMap['focus']

                            $paraItem = $editorElem.parents('.parameter-item')

                            if $paraItem.hasClass('bool')
                                that.setPlainText($editorElem, '')

                            that.setEditorCompleter(thatEditor, hintDataAryMap['focus'], 'command')
                            thatEditor.execCommand("startAutocomplete")

                        if currentValue is '' and $stateItem.hasClass('comment')

                            commentCMDEditor = $stateItem.find('.command-value').data('editor')
                            if commentCMDEditor
                                commentCMDEditor.focus()

                    # if e.command.name is "backspace" and hintDataAryMap['at'] and currentValue
                    #     currentLineContent = thatEditor.getSession().getLine(thatEditor.getCursorPosition().row)
                    #     if currentLineContent.indexOf('@') >= 0
                    #         that.setEditorCompleter(thatEditor, hintDataAryMap['at'], 'reference')
                    #         thatEditor.execCommand("startAutocomplete")

                    if e.command.name is "autocomplete_confirm"

                        $stateItem = $editorElem.parents('.state-item')
                        $paraListElem = $stateItem.find('.parameter-list')

                        if $editorElem.hasClass('command-value')

                            value = e.args
                            originCMDName = $stateItem.attr('data-command')

                            if originCMDName isnt value

                                # $stateItem.attr('data-command', value)
                                that.setCMDForStateItem($stateItem, value)
                                that.refreshDescription(value)
                                that.refreshParaList($paraListElem, value)
                                that.refreshStateView($stateItem)

                        if value is '#'

                            $firstInput = $paraListElem.find('.parameter-value')
                            firstEditor = $firstInput.data('editor')
                            if firstEditor
                                firstEditor.focus()

                        else if $editorElem.hasClass('parameter-value')

                            cursorPos = thatEditor.getCursorPosition()
                            thatEditor.moveCursorTo(cursorPos.row, cursorPos.column + 1)

                            $paraItem = $editorElem.parents('.parameter-item')
                            if $paraItem.hasClass('dict')
                                that.onDictInputChange({
                                    currentTarget: $editorElem[0]
                                })
                            else if $paraItem.hasClass('array') or $paraItem.hasClass('state')
                                that.onArrayInputChange({
                                    currentTarget: $editorElem[0]
                                })
                            else if $paraItem.hasClass('line') or $paraItem.hasClass('bool') or $paraItem.hasClass('text')
                                $paraItem.removeClass('disabled')

                    if e.command.name is "autocomplete_match"

                        isShowTip = false

                        if $editorElem.hasClass('parameter-value')

                            $paraItem = $editorElem.parents('.parameter-item')
                            if $paraItem.hasClass('state')
                                isShowTip = true

                        if $editorElem.hasClass('command-value')
                            isShowTip = true

                        if isShowTip

                            if not e.args
                                that.$aceAutocompleteTip.show()
                            else
                                that.$aceAutocompleteTip.hide()
                )

                editor.on("focus", (e, thatEditor) ->

                    $valueInput = $(thatEditor.container)
                    # $stateItem = $valueInput.parents('.state-item')
                    # $paraItem = $valueInput.parents('.parameter-item')

                    that.justScrollToElem(that.$stateList, $valueInput)

                    hintDataAryMap = thatEditor.hintObj
                    currentValue = thatEditor.getValue()
                    if not currentValue and hintDataAryMap['focus']
                        that.setEditorCompleter(thatEditor, hintDataAryMap['focus'], 'command')
                        thatEditor.execCommand("startAutocomplete")

                    inputPosX = $valueInput.offset().left
                    inputPosY = $valueInput.offset().top
                    that.$aceAutocompleteTip.css({
                        left: inputPosX,
                        top: inputPosY + 25
                    })

                )

                editor.on("blur", (e, thatEditor) ->

                    that.$cmdDsec.find('.highlight').removeClass('highlight')
                    that.$aceAutocompleteTip.hide()

                    $valueInput = $(thatEditor.container)
                    $stateItem = $valueInput.parents('.state-item')
                    $paraItem = $valueInput.parents('.parameter-item')

                    currentValue = thatEditor.getValue()

                    if $paraItem and $paraItem[0]
                        if $paraItem.hasClass('bool')
                            if currentValue not in ['true', 'false']
                                that.setPlainText($valueInput, '')
                )

            # if $editorElem.hasClass('command-value')

            _initEditor()

        highlightParaDesc: (paraName) ->

            that = this

            that.$cmdDsec.find('.highlight').removeClass('highlight')
            $paraNameSpan = that.$cmdDsec.find("strong:contains('#{paraName}')")
            paraNameSpan = $paraNameSpan.filter(() ->
                return $(this).text() is paraName
            )
            paraParagraph = paraNameSpan.parents('li')
            paraParagraph.addClass('highlight')

            try

                scrollToPos = paraParagraph.offset().top - that.$cmdDsec.offset().top + that.$cmdDsec.scrollTop() - 15
                that.$cmdDsec.stop(true, true)
                that.$cmdDsec.animate({
                    scrollTop: scrollToPos
                }, 150)

            catch err

                null

        scrollToLogItem: (stateId) ->

            that = this
            $targetStateItem = that.$stateLogList.find(".state-log-item[data-state-id='" + stateId + "']")
            $stateLog = $('#state-log')

            try
                if $targetStateItem[0]

                    scrollToPos = $targetStateItem.offset().top - $stateLog.offset().top + $stateLog.scrollTop()
                    $stateLog.stop(true, true)
                    $stateLog.animate({
                        scrollTop: scrollToPos
                    }, 150)

            catch err

                null

        justScrollToElem: ($parent, $target) ->

            try

                targetOffsetTop = $target.offset().top
                parentOffsetTop = $parent.offset().top

                targetTop = targetOffsetTop + 35
                parentTop = parentOffsetTop + $parent.height()

                if targetTop > parentTop
                    scrollPos = $parent.scrollTop() + targetTop - parentTop + 15

                else if targetOffsetTop < parentOffsetTop
                    scrollPos = $parent.scrollTop() + targetOffsetTop - parentOffsetTop - 15

                $parent.scrollTop(scrollPos)

                # scrollbar.scrollTo $('#state-list-wrap'), {top: 300}

            catch err

                null

        setEditorCompleter: (editor, dataAry, metaType) ->

            editor.completers = [{
                getCompletions: (editor, session, pos, prefix, callback) ->
                    if dataAry and dataAry.length
                        callback(null, dataAry.map((ea) ->
                            return {
                                name: ea.name,
                                value: ea.value,
                                score: ea.value,
                                meta: ea.meta,
                                support: ea.support
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
                if not $inputElem.hasClass('ace_editor')
                    return $inputElem.text()
                return ''

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

            that.stateIdLogContentMap = {}

            stateLogViewAry = []
            stateStatusMap = {}

            stateIdLogViewMap = {}
            $stateLogItems = that.$stateLogList.find('.state-log-item')
            _.each $stateLogItems, (stateLogItem) ->
                $stateLogItem = $(stateLogItem)
                stateId = $stateLogItem.attr('data-state-id')
                stateView = $stateLogItem.hasClass('view')
                if stateId
                    stateIdLogViewMap[stateId] = stateView
                null

            _.each stateLogDataAry, (logObj, idx) ->

                timeStr = null
                if logObj.time
                    timeStr = MC.dateFormat(new Date(logObj.time), 'yyyy-MM-dd hh:mm:ss')
                stateStatus = logObj.result
                stateId = "#{logObj.id}"
                stateNum = ''
                isStateLog = false
                if logObj.id isnt 'Agent'
                    stateId = "State #{stateId}"
                    isStateLog = true
                    stateStatusMap[logObj.id] = stateStatus
                else
                    stateNum = logObj.id

                stdoutStr = ''
                commentStr = ''
                longStdout = false

                if logObj.comment
                    commentStr = $.trim(logObj.comment.replace(/\n\n/g, '\n'))

                if logObj.stdout
                    stdoutStr = $.trim(logObj.stdout.replace(/\n\n/g, '\n'))
                    if stdoutStr.length > 100
                        longStdout = true
                        that.stateIdLogContentMap[logObj.id] = {
                            number: stateNum,
                            content: stdoutStr
                        }

                viewLog = stateIdLogViewMap[logObj.id]
                if viewLog not in [true, false]
                    viewLog = false

                stateLogViewAry.push({
                    id: logObj.id,
                    state_num: stateNum,
                    log_time: timeStr,
                    state_status: stateStatus,
                    stdout: stdoutStr,
                    comment: commentStr,
                    long_stdout: longStdout,
                    view: viewLog,
                    is_state_log: isStateLog
                })
                null

            renderHTML = that.stateLogItemTpl({
                state_logs: stateLogViewAry
            })

            that.refreshStateItemStatus(stateStatusMap)

            resState = that.model.get('resState')
            instanceStateHTML = that.stateLogInstanceItemTpl({
                res_status: resState
            })

            that.$stateLogList.empty().append(instanceStateHTML).append(renderHTML)
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

        onResSelectChange: () ->

            that = this

            selectedResId = that.currentResId
            # $(event.target).find('.selected').attr('data-id')

            # refresh state log
            that.showLogListLoading(true)

            that.model.getResState(selectedResId)

            if not that.isLoadingLogList

                $logPanel = $('#state-log')
                $loadText = $logPanel.find('.state-log-loading')

                $loadText.text('Refresh...')

                that.isLoadingLogList = true

                that.model.genStateLogData(selectedResId, () ->
                    that.refreshStateLogList()
                    that.showLogListLoading(false)
                    that.isLoadingLogList = false
                )

                if that.logRefreshTimer
                    clearTimeout(that.logRefreshTimer)

                that.logRefreshTimer = setTimeout(() ->
                    if that.isLoadingLogList
                        $loadText.text('Request log info timeout, please try again')
                , 5000)

        onStateStatusUpdate: (newStateUpdateResIdAry) ->

            that = this

            selectedResId = that.currentResId

            if newStateUpdateResIdAry
                if newStateUpdateResIdAry.length
                    if selectedResId and selectedResId in newStateUpdateResIdAry
                        that.onLogRefreshClick()
                else
                    that.onLogRefreshClick()
            else
                that.onLogRefreshClick()

        onOptionalParaItemChange: (event) ->

            that = this
            $currentInputElem = $(event.currentTarget)
            currentValue = that.getPlainText($currentInputElem)

            $paraItem = $currentInputElem.parents('.parameter-item')

            if currentValue

                $paraItem.removeClass('disabled')

            else

                # disable the para item when empty value

                if $paraItem.hasClass('line') or
                    $paraItem.hasClass('bool') or
                    $paraItem.hasClass('text')

                        $paraItem.addClass('disabled')

                else if $paraItem.hasClass('dict')

                    needDisable = true

                    $dictItemList = $paraItem.find('.parameter-dict-item')

                    if $dictItemList.length <= 2

                        _.each $dictItemList, (dictItem) ->

                            $dictItem = $(dictItem)
                            $keyInput = $dictItem.find('.key')
                            $valueInput = $dictItem.find('.value')

                            keyValue = that.getPlainText($keyInput)
                            valueValue = that.getPlainText($valueInput)

                            if keyValue or valueValue
                                needDisable = false

                            null

                        if needDisable

                            $paraItem.addClass('disabled')

                else if $paraItem.hasClass('array') or $paraItem.hasClass('state')

                    needDisable = true

                    $arrayItemList = $paraItem.find('.parameter-value')

                    if $arrayItemList.length <= 2

                        _.each $arrayItemList, (arrayItem) ->

                            $arrayItem = $(arrayItem)
                            inputValue = that.getPlainText($arrayItem)

                            if inputValue
                                needDisable = false

                            null

                        if needDisable

                            $paraItem.addClass('disabled')

        onCommandInputBlur: (event) ->

            that = this

            $currentElem = $(event.currentTarget)
            $stateItem = $currentElem.parents('.state-item')
            currentValue = that.getPlainText($currentElem)

            moduleObj = that.cmdModuleMap[currentValue]

            originCMDName = $stateItem.attr('data-command')

            if moduleObj and moduleObj.support

                if originCMDName isnt currentValue

                    # $stateItem.attr('data-command', currentValue)
                    that.setCMDForStateItem($stateItem, currentValue)
                    that.refreshDescription(currentValue)
                    $paraListElem = $stateItem.find('.parameter-list')
                    that.refreshParaList($paraListElem, currentValue)
                    that.refreshStateView($stateItem)

            else

                that.setPlainText($currentElem, originCMDName)

        setCMDForStateItem: ($stateItem, cmdValue) ->

            that = this
            $stateItem.attr('data-command', cmdValue)
            if cmdValue is '#'
                $stateItem.addClass('comment')
            else
                $stateItem.removeClass('comment')

        refreshStateItemStatus: (stateStatusMap) ->

            that = this

            $stateItemList = that.$stateList.find('.state-item')

            _.each $stateItemList, (stateItem) ->

                $stateItem = $(stateItem)
                stateId = $stateItem.attr('data-id')
                $statusIcon = $stateItem.find('.state-status-icon')
                $statusIcon.removeClass('status-green').removeClass('status-red').removeClass('status-yellow')
                stateStatus = stateStatusMap[stateId]
                if stateStatus is 'success'
                    $statusIcon.addClass('status-green')
                else if stateStatus is 'failure'
                    $statusIcon.addClass('status-red')
                else
                    $statusIcon.addClass('status-yellow')
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

        initUndoManager: () ->

            that = this
            that.commandStack = []
            that.commandIndex = -1

            that.undoManager = {

                register: (stateId, statePos, method, stateData) ->

                    that.commandStack.splice(that.commandIndex + 1, that.commandStack.length - that.commandIndex)

                    if method is 'remove'

                        stateDataAry = []
                        statePosAry = statePos
                        _.each stateId, (stateIdValue) ->
                            $stateItem = that.getStateItemById(stateIdValue)
                            stateDataValue = that.getStateItemByData($stateItem)
                            stateDataAry.push(stateDataValue)

                        that.commandStack.push({
                            redo: () ->
                                _.each stateDataAry, (stateDataValue) ->
                                    $stateItem = that.getStateItemById(stateDataValue.id)
                                    that.onRemoveState(null, $stateItem, true)
                            undo: () ->
                                idx = 0
                                _.each stateDataAry, (stateDataValue) ->
                                    that.addStateItemByData([stateDataValue], statePosAry[idx++] - 1)
                                null
                        })

                    if method is 'add'

                        that.commandStack.push({
                            redo: () ->
                                null
                            undo: () ->
                                $stateItem = that.getStateItemById(stateId)
                                stateData = that.getStateItemByData($stateItem)
                                this.redo = () ->
                                    that.addStateItemByData([stateData], statePos - 1)
                                that.onRemoveState(null, $stateItem, true)
                        })

                    if method is 'sort'

                        oldIndex = statePos
                        newIndex = stateData

                        that.commandStack.push({
                            redo: () ->
                                $stateItem = that.getStateItemById(stateId)
                                stateData = that.getStateItemByData($stateItem)
                                that.onRemoveState(null, $stateItem, true)
                                that.addStateItemByData([stateData], newIndex - 1)
                            undo: () ->
                                $stateItem = that.getStateItemById(stateId)
                                stateData = that.getStateItemByData($stateItem)
                                that.onRemoveState(null, $stateItem, true)
                                that.addStateItemByData([stateData], oldIndex - 1)
                        })

                    if method is 'paste'

                        insertPos = statePos
                        stateDataAry = _.map stateData, (data) ->
                            return _.extend({}, data)

                        that.commandStack.push({
                            redo: () ->
                                that.addStateItemByData(stateDataAry, insertPos - 1)
                            undo: () ->
                                _.each stateDataAry, (pasteStateData) ->
                                    pasteStateId = pasteStateData.id
                                    $stateItem = that.getStateItemById(pasteStateId)
                                    that.onRemoveState(null, $stateItem, true)
                                    null
                        })

                    that.commandIndex = that.commandStack.length - 1

                    _.defer _.bind that.renderStateCount, that

                    null

                redo: () ->

                    if that.undoManager.hasRedo()

                        operateCommand = that.commandStack[that.commandIndex + 1]

                        if operateCommand
                            operateCommand.redo()
                            that.commandIndex = that.commandIndex + 1

                        that.renderStateCount()

                    null

                undo: () ->

                    if that.undoManager.hasUndo()

                        operateCommand = that.commandStack[that.commandIndex]

                        if operateCommand
                            operateCommand.undo()
                            that.commandIndex = that.commandIndex - 1

                        that.renderStateCount()

                    null

                hasUndo: () ->

                    return that.commandIndex isnt -1

                hasRedo: () ->

                    return that.commandIndex < (that.commandStack.length - 1)

            }

            null

        getStateItemById: (stateId) ->

            that = this
            $stateItem = that.$stateList.find('.state-item[data-id="' + stateId + '"]')
            return $stateItem

        getStateItemByData: ($stateItem) ->

            that = this
            stateData = that.genStateItemData($stateItem)
            return stateData

        setNewStateIdForStateAry: (stateDataAry) ->

            that = this
            stateDataAry = _.map stateDataAry, (stateData) ->
                stateData.id = that.genStateUID()
                return stateData

            return stateDataAry

        addStateItemByData: (stateDataAry, insertPos) ->

            that = this

            stateListObj = that.loadStateData(stateDataAry)

            newStateItems = that.stateListTpl(stateListObj)
            $currentStateItems = that.$stateList.find('.state-item')

            returnInsertPos = null

            if _.isNumber(insertPos)

                if insertPos <= -1
                    $newStateItems = $(newStateItems).prependTo(that.$stateList)
                    returnInsertPos = -1
                else
                    if $currentStateItems[insertPos]
                        $newStateItems = $(newStateItems).insertAfter($currentStateItems[insertPos])
                        returnInsertPos = insertPos
                    else
                        $newStateItems = $(newStateItems).appendTo(that.$stateList)
                        returnInsertPos = that.$stateList.length - 1

            else

                $newStateItems = $(newStateItems).appendTo(that.$stateList)
                returnInsertPos = that.$stateList.length - 1

            that.bindStateListEvent($newStateItems)

            that.refreshStateViewList($newStateItems)

            $stateItems = that.$stateList.find('.state-item')
            if $stateItems.length
                that.$haveStateContainer.show()
                that.$noStateContainer.hide()

            return returnInsertPos

        keyEvent: (event) ->

            that = this

            if $('.sub-stateeditor').css('display') is "none"
                return true

            target = event.data.target
            status = target.currentState
            is_editable = status is 'appedit' or status is 'stack'
            tagName = event.target.tagName.toLowerCase()
            is_input = tagName is 'input' or tagName is 'textarea'

            keyCode = event.which
            metaKey = event.ctrlKey or event.metaKey
            shiftKey = event.shiftKey
            altKey = event.altKey

            # undo [Ctrl + Z]
            if metaKey and shiftKey is false and altKey is false and keyCode is 90 and is_editable
                target.undoManager.undo()
                return false

            # redo [Ctrl +Y]
            if metaKey and shiftKey is false and altKey is false and keyCode is 89 and is_editable
                target.undoManager.redo()
                return false

            # Copy state item [Ctrl + C]
            if metaKey and shiftKey is false and altKey is false and keyCode is 67 and is_input is false and is_editable
                target.copyState.call target, event
                return false

            # Paste state item [Ctrl + V]
            if metaKey and shiftKey is false and altKey is false and keyCode is 86 and is_editable and is_input is false
                target.pasteState.call target, event
                # return false

            # Remove state item [Ctrl + delete/backspace]
            if metaKey and (keyCode is 46 or keyCode is 8) and shiftKey is false and altKey is false and is_editable
                target.removeState.call target, event
                return false

            # Add state item [Ctrl + enter]
            if metaKey and shiftKey is false and altKey is false and keyCode is 13 and is_editable
                target.addStateItem.call target, event
                return false

            # Move down state item [Ctrl + down]
            if metaKey and shiftKey is false and altKey is false and keyCode is 40 and is_editable
                target.moveState.call target, 'down'
                return false

            # Move up state item [Ctrl + up]
            if metaKey and shiftKey is false and altKey is false and keyCode is 38 and is_editable
                target.moveState.call target, 'up'
                return false

            # CollapseItem state item [Escape]
            if metaKey is false and shiftKey is false and altKey is false and keyCode is 27
                target.collapseItem.call target, $('.state-list .focused')
                return false

            # Toggle document Sidebar [Ctrl + I]
            if metaKey and shiftKey is false and altKey is false and keyCode is 73
                target.onDescToggleClick target, event
                return false

            # Toggle log sidebar [Ctrl + L]
            if metaKey and shiftKey is false and altKey is false and keyCode is 76 and status isnt 'stack'
                target.onLogToggleClick target, event
                return false

            # Select all [Ctrl + A]
            if metaKey and shiftKey is false and altKey is false and keyCode is 65 and is_editable
                target.selectAll target, event
                return false

            # Unselect all [Ctrl + D]
            if metaKey and shiftKey is false and altKey is false and keyCode is 68 and is_editable
                target.unSelectAll target, event
                return false

            # Tab reverse switch [Shift + Tab]
            if keyCode is 9 and shiftKey and metaKey is false
                target.onSwitchState.call target, true
                return false

            # Switch focused state [Up]
            if metaKey is false and shiftKey is false and keyCode is 38
                target.switchFocus.call target, true
                return false

            # Switch focused state [Down]
            if metaKey is false and shiftKey is false and keyCode is 40
                target.switchFocus.call target
                return false

            # Toggle selected [Blankspace]
            if metaKey is false and shiftKey is false and keyCode is 32 and is_input is false and is_editable
                target.toggleSelected.call target
                return false

            # Expand item [Enter]
            if metaKey is false and shiftKey is false and keyCode is 13
                focused = $('#state-editor .state-item.focused')

                if focused[0] isnt null and focused.hasClass('view') is true
                    target.expandItem.call target, focused

                if $(event.target).parent().hasClass('text') is true
                    return true

                return false

            # Tab switch [Tab]
            if metaKey is false and shiftKey is false and keyCode is 9
                target.onSwitchState.call target
                return false

            # Switch to property panel [P]
            if metaKey is false and shiftKey is false and keyCode is 80 and is_input is false
                $canvas.trigger 'SHOW_PROPERTY_PANEL'
                return false

            # Switch to state editor [S]
            if metaKey is false and shiftKey is false and keyCode is 83 and is_input is false
                $canvas.trigger 'SHOW_STATE_EDITOR'
                return false

            # Disable default delete event [delete/backspace]
            if metaKey is false and shiftKey is false and altKey is false and is_input is false and (keyCode is 46 or keyCode is 8)
                return false

        onUndo: () ->

                that = this

                that.undoManager.undo()

                return false

        onRedo: () ->

                that = this

                that.undoManager.redo()

                return false

        copyState: () ->

            that = this

            stack = []

            $('.state-list .selected').each ->
                stack.push(that.getStateItemByData($(this)))

            MC.data.stateClipboard = stack

            that.updateToolbar()

            notification 'info', lang.ide.NOTIFY_MSG_INFO_STATE_COPY_TO_CLIPBOARD

            return true

        copyAllState: () ->

            that = this

            stack = []

            $('.state-list .state-item').each ->
                stack.push(that.getStateItemByData($(this)))

            MC.data.stateClipboard = stack

            that.updateToolbar()

            notification 'info', lang.ide.NOTIFY_MSG_INFO_STATE_COPY_TO_CLIPBOARD

            return true

        moveState: (direction) ->

            that = this

            item = $('#state-editor .state-item.focused')

            focused_index = $('#state-editor .state-item.focused').index('#state-editor .state-list > li')

            if direction is 'down'

                next_item = item.next()

                if next_item.length > 0

                    item.insertAfter next_item

                    new_index = focused_index + 1

                else

                    item.parent().prepend item

                    new_index = 0

            if direction is 'up'

                prev_item = item.prev()

                if prev_item.length > 0

                    item.insertBefore prev_item

                    new_index = focused_index - 1

                else

                    item.parent().append item

                    new_index = $('#state-editor .state-item').length

            state_id = item.data('id')

            that.undoManager.register state_id, focused_index, 'sort', new_index

            return false

        pasteState: () ->

            that = this

            focused_index = $('#state-editor .state-item.focused').index('#state-editor .state-list > li')

            if focused_index is -1
                focused_index = null

            newStateDataAry = that.setNewStateIdForStateAry MC.data.stateClipboard
            insertPos = that.addStateItemByData newStateDataAry, focused_index
            that.undoManager.register null, insertPos, 'paste', newStateDataAry

            that.clearSelectedItem()

            that.clearFocusedItem()

            that.updateToolbar()

            return true

        removeState: () ->

            that = this

            that.onRemoveState null, $('.state-list').find('.selected')

            return true

        toggleSelected: () ->

            that = this

            item = $('#state-editor .state-item.focused')

            if item.hasClass('selected')

                item.removeClass('selected')

                item.find('.checkbox input').prop('checked', false)

            else
                item.addClass('selected')

                item.find('.checkbox input').prop('checked', true)

            that.updateToolbar()

            return false

        switchFocus: (reverse) ->

            that = this

            focused_index = 0

            stack = $('#state-editor .state-item')

            total = stack.length

            focused_index = $('#state-editor .state-item.focused').index('#state-editor .state-list > li')

            that.clearFocusedItem()

            if reverse and reverse is true

                if focused_index > 0
                    target_index = focused_index - 1

                if focused_index < 1
                    target_index = total - 1

            else

                if focused_index + 1 < total
                    target_index = focused_index + 1

                else
                    target_index = 0

            target_item = stack.eq target_index

            target_item.addClass('focused')

            that.justScrollToElem that.$stateList, target_item

            return false

        onSwitchState: (reverse) ->

            that = this

            focused_index = 0

            stack = $('#state-editor .state-item')

            total = stack.length

            focused_index = $('#state-editor .state-item.focused').index('#state-editor .state-list > li')

            that.clearFocusedItem()

            if reverse and reverse is true

                if focused_index > 0
                    target_index = focused_index - 1

                if focused_index < 1
                    target_index = total - 1

            else

                if focused_index + 1 < total
                    target_index = focused_index + 1

                else
                    target_index = 0

            target_item = stack.eq target_index

            that.expandItem.call this, target_item.addClass('focused')

            # that.justScrollToElem that.$stateList, target_item

            return false

        aceTabSwitch: (event, container) ->

            that = this

            if that.currentState is 'app'
                that.onSwitchState.call this, event
                return false

            container_item = $(container)
            index = 0

            if container_item.hasClass('command-value')
                stack = container_item.parents('.state-item').find('.parameter-list .ace_editor')

                if stack.length > 0
                    stack.eq(0).find('.ace_text-input').focus()
                # else
                    # that.onSwitchState.call this, event

            else
                stack = container_item.parents('.parameter-list').find('.ace_editor')

                total = stack.length

                $.each stack, (i, item) ->
                    if container is item
                        index = i

                if index + 1 < total
                    stack.eq(index + 1).find('.ace_text-input').focus()
                else
                    # stack.eq(0).find('.ace_text-input').focus()
                    container_item.parents('.state-item').find('.command-value .ace_text-input').focus()
                    # that.onSwitchState.call this, event

            return false

        aceUTabSwitch: (event, container) ->

            that = this

            if that.currentState is 'app'
                that.onSwitchState.call this, event
                return false

            container_item = $(container)
            index = 0

            if container_item.hasClass('command-value')

                stack = container_item.parents('.state-item').find('.parameter-list .ace_editor')

                total = stack.length

                stack.eq(total - 1).find('.ace_text-input').focus()

                return false
                # focused_index = $('#state-editor .state-item.focused').index('#state-editor .state-list > li')

                # $('#state-editor .state-item.focused').removeClass('focused').addClass('view')

                # if focused_index > 0
                #     stack.eq( focused_index - 1 ).addClass('focused').removeClass('view').find('.command-value .ace_text-input').focus()

                # if focused_index is 0
                #     stack.eq( stack.length - 1 ).addClass('focused').removeClass('view').find('.command-value .ace_text-input').focus()

                # return false

            stack = container_item.parents('.parameter-list').find('.ace_editor')

            total = stack.length

            $.each stack, (i, item) ->
                if container is item
                    index = i

            if index > 0
                stack.eq(index - 1).find('.ace_text-input').focus()

            if index is 0
                container_item.parents('.state-item').find('.command-value .ace_text-input').focus()
                # stack.eq(total - 1).find('.ace_text-input').focus()
                # container_item.parents('.state-item').find('.command-value .ace_text-input').focus()

            return false

        onRemoveState: (event, $targetStates, noRegisterUndo) ->

            that = this

            if that.currentState is 'app'
                return false

            # redo/undo
            if not noRegisterUndo

                stateIdAry = []
                statePosAry = []

                _.each $targetStates, (targetState) ->

                    $targetState = $(targetState)
                    stateId = $targetState.attr('data-id')
                    stateIdAry.push(stateId)
                    statePos = $targetState.index()
                    statePosAry.push(statePos)

                that.undoManager.register(stateIdAry, statePosAry, 'remove')

            _.each $targetStates, (targetState) ->
                $targetState = $(targetState)
                that.collapseItem($targetState)
                null

            $targetStates.remove()

            $stateItems = that.$stateList.find('.state-item')

            if not $stateItems.length
                that.$haveStateContainer.hide()
                that.$noStateContainer.show()
            else
                _.each $stateItems, (stateItem) ->
                    $stateItem = $(stateItem)
                    if not $stateItem.hasClass('view')
                        that.expandItem($stateItem)
                    null

            that.refreshLogItemNum()

            that.updateToolbar()

            return false

        checkboxSelect: (event) ->

            that = this

            checkbox = $(event.currentTarget).find('input')

            item = checkbox.parents('.state-item')

            item.removeClass('selected')

            if checkbox.prop('checked') is false

                checkbox.prop('checked', true)

                item.addClass('selected')

            else

                checkbox.prop('checked', false)

            that.updateToolbar()

            return false

        selectAll: () ->

            that = this

            $('#state-editor .state-item').addClass('selected').find('.checkbox input').prop('checked', true)

            that.updateToolbar()

            return true

        unSelectAll: () ->

            that = this

            $('#state-editor .state-item').removeClass('selected').find('.checkbox input').prop('checked', false)

            that.updateToolbar()

            return true

        onSelectAllClick: () ->

            that = this

            checkbox = $(event.currentTarget).find('input')

            if checkbox.prop('checked') is false

                checkbox.prop('checked', true)

                that.selectAll.call this, event

            else

                checkbox.prop('checked', false)

                that.unSelectAll.call this, event

            return false

        onStateItemAddBtnClick: (event) ->

            that = this
            that.onStateItemAddClick()
            that.$haveStateContainer.show()
            that.$noStateContainer.hide()
            return false

        updateToolbar: () ->

            that = this

            selected_length = that.$('#state-editor .state-item.selected').length
            if selected_length > 0
                that.$('#state-toolbar-copy, #state-toolbar-delete').show()
                that.$('#state-toolbar-copy-all').hide()
                that.$('#state-toolbar-copy-count, #state-toolbar-delete-count').text selected_length
            else
                that.$('#state-toolbar-copy, #state-toolbar-delete').hide()
                that.$('#state-toolbar-copy-all').show()
            if MC.data.stateClipboard.length > 0
                that.$('#state-toolbar-paste').removeClass 'disabled'
            else
                that.$('#state-toolbar-paste').addClass 'disabled'
            if selected_length > 0 and selected_length is that.$('#state-editor .state-item').length
                that.$('#state-toolbar-selectAll').find('input').prop('checked', true)
            else
                that.$('#state-toolbar-selectAll').find('input').prop('checked', false)

            return true

        onClickBlank: (event) ->

            that = this

            target = $(event.target)

            if target.parents('.state-item').length is 0
                that.clearFocusedItem()

            return false

        onPasteGistData: (event) ->

            that = this
            pasteData = event.originalEvent.clipboardData.getData('text/plain')

            try
                pasteDataJSON = JSON.parse(pasteData)
                pasteDataJSON = that.setNewStateIdForStateAry(pasteDataJSON)
                that.addStateItemByData(pasteDataJSON)
            catch err
                null
                # alert('Pasted JSON Data Format Error')

        onStateLogItemHeaderClick: (event) ->

            $currentTarget = $(event.currentTarget)
            $stateLogItem = $currentTarget.parents('.state-log-item')
            $stateLogItem.toggleClass('view')

        openSysLogModal : () ->

            that = this

            instanceId = that.currentResId

            currentRegion = MC.canvas_data.region
            instance_model.GetConsoleOutput {sender: that}, $.cookie('usercode'), $.cookie('session_id'), currentRegion, instanceId

            modal MC.template.modalInstanceSysLog {
                instance_id: instanceId,
                log_content: ''
            }, true

            that.off('EC2_INS_GET_CONSOLE_OUTPUT_RETURN').on 'EC2_INS_GET_CONSOLE_OUTPUT_RETURN', (result) ->

                if !result.is_error
                    console.log(result.resolved_data)
                that.refreshSysLog(result.resolved_data)

            return false

        refreshSysLog : (result) ->

            $('#modal-instance-sys-log .instance-sys-log-loading').hide()

            if result and result.output

                logContent = MC.base64Decode(result.output)
                $contentElem = $('#modal-instance-sys-log .instance-sys-log-content')

                logContentTpl = Handlebars.compile('{{nl2br content}}')
                logContentHTML = logContentTpl({
                    content: logContent
                })
                $contentElem.html(logContentHTML)
                $contentElem.show()

            else

                $('#modal-instance-sys-log .instance-sys-log-info').show()

            modal.position()

        onStateLogDetailBtnClick: (event) ->

            that = this
            $logDetailBtn = $(event.currentTarget)
            $logItem = $logDetailBtn.parents('.state-log-item')
            stateId = $logItem.attr('data-state-id')
            if stateId
                stateLogObj = that.stateIdLogContentMap[stateId]
                if stateLogObj
                    modal that.stateLogDetailModal({
                        number: stateLogObj.number
                        content: stateLogObj.content
                    }), true

    }

    return StateEditorView
