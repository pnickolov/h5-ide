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
            'keyup .parameter-item.dict .parameter-value': 'onDictInputChange'
            'blur .parameter-item.dict .parameter-value': 'onDictInputBlur'
            
            'keyup .parameter-item.array .parameter-value': 'onArrayInputChange'
            'blur .parameter-item.array .parameter-value': 'onArrayInputBlur'
            'keyup .parameter-item.state .parameter-value': 'onArrayInputChange'
            'blur .parameter-item.state .parameter-value': 'onArrayInputBlur'

            'focus .editable-area': 'onFocusInput'
            'click .state-toolbar .state-id': 'onStateIdClick'
            'click .state-toolbar .state-add': 'onStateAddClick'
            'click .state-toolbar .state-remove': 'onStateRemoveClick'
            'click .state-save': 'onStateSaveClick'
            'click .state-cancel': 'onStateCancelClick'
            'click .parameter-item .parameter-remove': 'onParaRemoveClick'
            'click .state-desc-toggle': 'onDescToggleClick'

        initialize: () ->

            this.compileTpl()
            this.initData()

        closedPopup: () ->
            @trigger 'CLOSE_POPUP'

        render: () ->

            that = this

            # show modal
            modal that.editorModalTpl({
                res_name: that.resName,
                supported_platform: that.supportedPlatform
            }), false

            setTimeout(() ->

                that.setElement $( '#state-editor-model' ).closest '#modal-wrap'
                that.$stateList = that.$el.find('.state-list')
                that.$cmdDsec = $('#state-description')

                # hide autocomplete when click document
                $(document).on('mousedown', that.onDocumentMouseDown)
                $('#state-editor').on('scroll', () ->
                    $('.atwho-view').hide()
                )

                compStateData = that.model.getStateData()
                stateObj = that.loadStateData(compStateData)
                that.refreshStateList(stateObj)
                that.refreshStateViewList()
                that.bindStateListSortEvent()

            , 1)

        initData: () ->

            that = this
            that.cmdParaMap = that.model.get('cmdParaMap')
            that.cmdParaObjMap = that.model.get('cmdParaObjMap')
            that.cmdModuleMap = that.model.get('cmdModuleMap')
            that.moduleCMDMap = that.model.get('moduleCMDMap')
            that.langTools = ace.require("ace/ext/language_tools")
            that.resAttrDataAry = that.model.get('resAttrDataAry')
            that.resStateDataAry = that.model.get('resStateDataAry')

            that.resName = that.model.getResName()
            that.supportedPlatform = that.model.get('supportedPlatform')

        compileTpl: () ->

            # generate template
            tplRegex = /(\<!-- (.*) --\>)(\n|\r|.)*?(?=\<!-- (.*) --\>)/ig
            tplHTMLAry = template.match(tplRegex)
            htmlMap = {}
            _.each tplHTMLAry, (tplHTML) ->
                commentHead = tplHTML.split('\n')[0]
                tplType = commentHead.replace(/(<!-- )|( -->)/g, '')
                htmlMap[tplType] = tplHTML
                null

            editorModalHTML = htmlMap['state-template-editor-modal']
            stateListHTML = htmlMap['state-template-state-list']
            paraListHTML = htmlMap['state-template-para-list']
            paraViewListHTML = htmlMap['state-template-para-view-list']
            paraDictItemHTML = htmlMap['state-template-para-dict-item']
            paraArrayItemHTML = htmlMap['state-template-para-array-item']
            paraCompleteItemHTML = '<li data-value="${atwho-at}${name}">${name}</li>'

            this.stateListTpl = Handlebars.compile(stateListHTML)

            Handlebars.registerPartial('state-template-para-list', paraListHTML)
            Handlebars.registerPartial('state-template-para-view-list', paraViewListHTML)
            Handlebars.registerPartial('state-template-para-dict-item', paraDictItemHTML)
            Handlebars.registerPartial('state-template-para-array-item', paraArrayItemHTML)

            this.paraListTpl = Handlebars.compile(paraListHTML)
            this.paraViewListTpl = Handlebars.compile(paraViewListHTML)
            this.paraDictListTpl = Handlebars.compile(paraDictItemHTML)
            this.paraArrayListTpl = Handlebars.compile(paraArrayItemHTML)
            this.editorModalTpl = Handlebars.compile(editorModalHTML)

        bindStateListSortEvent: () ->

            that = this

            # state item sortable
            that.$stateList.dragsort({
                itemSelector: '.state-item',
                dragSelector: '.state-drag',
                dragBetween: true,
                placeHolderTemplate: '<div class="state-item state-placeholder"></div>',
                dragEnd: () ->
                    that.refreshStateId()
            })

        refreshStateList: (stateListObj) ->

            that = this

            if not (stateListObj and stateListObj.state_list.length)

                stateListObj = {
                    state_list: [{
                        state_id: 1,
                        cmd_value: ''
                    }]
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

                that.bindParaListEvent($paraListItem, currentCMD)

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
            moduleObj = that.cmdModuleMap[cmdName]

            descMarkdown = ''
            if moduleObj.reference
                descMarkdown = moduleObj.reference['en']

            descHTML = ''
            if descMarkdown
                descHTML = $.markdown(descMarkdown)

            that.$cmdDsec.html(descHTML).attr('data-command', cmdName)

            null

        refreshParaList: ($paraListElem, currentCMD) ->

            that = this
            currentParaMap = that.cmdParaObjMap[currentCMD]
            currentParaAry = that.cmdParaMap[currentCMD]

            newParaAry = []

            _.each currentParaAry, (paraObj) ->

                newParaObj = {
                    para_name: paraObj.name,
                    required: paraObj.required
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

        refreshStateId: () ->

            that = this

            $stateItemList = that.$stateList.find('.state-item')

            _.each $stateItemList, (stateItem, idx) ->

                currentStateId = idx + 1
                $stateItem = $(stateItem)
                $stateItem.find('.state-id').text(currentStateId)

                null

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

            # refresh module description

            $stateItem = $currentInput.parents('.state-item')
            cmdName = $stateItem.attr('data-command')

            currentDescCMDName = that.$cmdDsec.attr('data-command')
            if cmdName and currentDescCMDName isnt cmdName
                that.refreshDescription(cmdName)

        onStateIdClick: (event) ->

            that = this

            $stateIdElem = $(event.currentTarget)
            $stateItem = $stateIdElem.parents('.state-item')

            $stateItemList = that.$stateList.find('.state-item')

            if $stateItem.hasClass('view')

                # remove other item view
                _.each $stateItemList, (otherStateItem) ->
                    $otherStateItem = $(otherStateItem)
                    if not $stateItem.is($otherStateItem) and not $stateItem.hasClass('view')
                        that.refreshStateView($otherStateItem)
                    null

                $stateItemList.addClass('view')
                $stateItem.removeClass('view')

                # refresh description
                cmdName = $stateItem.attr('data-command')
                if cmdName
                    that.refreshDescription(cmdName)
            else
                that.refreshStateView($stateItem)
                $stateItem.addClass('view')

        onStateAddClick: (event) ->

            that = this

            $currentElem = $(event.currentTarget)
            $stateItem = $currentElem.parents('.state-item')

            stateIdStr = $stateItem.find('.state-id').text()
            stateId = Number(stateIdStr)

            newStateId = ++stateId

            newStateHTML = that.stateListTpl({
                state_list: [{
                    state_id_show: newStateId
                }]
            })

            $stateItem.after(newStateHTML)

            $newStateItem = $stateItem.next()

            $cmdValueItem = $newStateItem.find('.command-value')
            that.bindCommandEvent($cmdValueItem)


            $stateItemList = that.$stateList.find('.state-item')
            $stateItemList.addClass('view')

            $newStateItem.removeClass('view')
            $cmdValueItem.focus()

            that.refreshStateId()

        onStateRemoveClick: (event) ->

            that = this

            $currentElem = $(event.currentTarget)
            $stateItem = $currentElem.parents('.state-item')

            $stateItem.remove()

            that.refreshStateId()

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

            newOldStateIdMap = {}

            _.each $stateItemList, (stateItem, idx) ->

                $stateItem = $(stateItem)

                cmdName = $stateItem.attr('data-command')

                # stateId = $stateItem.find('data-id')
                # for state item sort
                newStateId = $stateItem.find('.state-id').text()
                oldStateId = $stateItem.attr('data-id')
                if oldStateId and newStateId isnt oldStateId
                    newOldStateIdMap[oldStateId] = newStateId

                moduleObj = that.cmdModuleMap[cmdName]

                #empty module direct return
                if not moduleObj
                    return

                stateItemObj = {
                    stateid: String(idx + 1),
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
                                dictObj[keyValue] = valueValue

                            null

                        paraValue = dictObj

                    else if $paraItem.hasClass('array') or $paraItem.hasClass('state')

                        $arrayItemList = $paraItem.find('.parameter-value')
                        arrayObj = []

                        _.each $arrayItemList, (arrayItem) ->

                            $arrayItem = $(arrayItem)
                            arrayValue = that.getPlainText($arrayItem)

                            if arrayValue
                                arrayObj.push(arrayValue)

                            null

                        paraValue = arrayObj

                    stateItemObj['parameter'][paraName] = paraValue

                    null

                stateObjAry.push(stateItemObj)

                null

            # update all state id ref
            that.updateStateIdBySort(newOldStateIdMap)

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
                stateId = state.stateid

                stateRenderObj = {
                    state_id: stateId,
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

                    else if paraModelType is 'dict'

                        renderParaValue = []
                        _.each paraValue, (paraValueStr, paraKey) ->

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
                            renderParaValue.push(paraValueStr)
                            null

                        if not paraValue
                            renderParaValue = ['']

                    renderParaObj.para_value = renderParaValue

                    stateRenderObj.parameter_list.push(renderParaObj)

                    paraListAry = stateRenderObj.parameter_list

                    stateRenderObj.parameter_list = paraListAry.sort((paraObj1, paraObj2) ->
                        if paraObj1.required and not paraObj2.required
                            return false

                        if paraObj1.required is paraObj2.required and paraObj1.required is false
                            if paraObj1.para_name < paraObj2.para_name
                                return false

                        return true
                    )

                    null

                renderObj.state_list.push(stateRenderObj)

                null

            return renderObj

        onStateSaveClick: (event) ->

            that = this
            stateData = that.saveStateData()

            if stateData
                that.model.setStateData(stateData)
                that.closedPopup()

        onStateCancelClick: (event) ->

            that = this
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
            if $descPanel.is(':visible')
                $stateEditor.addClass('full')
                $descPanel.hide()
            else
                $stateEditor.removeClass('full')
                $descPanel.show()

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

            if not editorElem then return

            $editorElem = $(editorElem)
            editor = ace.edit(editorElem)
            $editorElem.data('editor', editor)

            editor.hintObj = hintObj

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

            editor.commands.on("afterExec", (e) ->

                thatEditor = e.editor
                currentValue = thatEditor.getValue()
                hintDataAryMap = thatEditor.hintObj

                if e.command.name is "insertstring"
                    if /^@$/.test(e.args) and hintDataAryMap['at']
                        that.setEditorCompleter(thatEditor, hintDataAryMap['at'])
                        thatEditor.execCommand("startAutocomplete")

                if e.command.name in ["backspace"] and hintDataAryMap['focus']
                    that.setEditorCompleter(thatEditor, hintDataAryMap['focus'])
                    thatEditor.execCommand("startAutocomplete")

                if e.command.name is "autocomplete_confirm"
                    if $editorElem.hasClass('command-value')
                        value = e.args
                        $stateItem = $editorElem.parents('.state-item')
                        $stateItem.attr('data-command', value)
                        that.refreshDescription(value)
                        $paraListElem = $stateItem.find('.parameter-list')
                        that.refreshParaList($paraListElem, value)
                        that.refreshStateView($stateItem)
            )

            editor.on("focus", (e, thatEditor) ->

                hintDataAryMap = thatEditor.hintObj
                currentValue = thatEditor.getValue()
                if not currentValue and hintDataAryMap['focus']
                    that.setEditorCompleter(thatEditor, hintDataAryMap['focus'])
                    thatEditor.execCommand("startAutocomplete")
            )

        setEditorCompleter: (editor, dataAry) ->

            editor.completers = [{
                getCompletions: (editor, session, pos, prefix, callback) ->
                    if dataAry and dataAry.length
                        callback(null, dataAry.map((ea) ->
                            return {
                                name: ea.name,
                                value: ea.value,
                                score: ea.value,
                                meta: "command"
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
                represent = $stateItem.find '.state-toolbar .command-view-value'
            else
                $paraItem = $input.closest('.parameter-item')
                paramName = $paraItem.data('paraName')

                represent = $stateItem.find ".state-toolbar [data-para-#{paramName}]"

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

            retVal

        getPlainText: (inputElem) ->

            $inputElem = $(inputElem)
            editor = $inputElem.data('editor')

            if editor
                return editor.getValue()
            else
                return ''

        setPlainText: (inputElem, content) ->

            $inputElem = $(inputElem)
            editor = $inputElem.data('editor')
            if editor then editor.setValue(content)

        updateStateIdBySort: (newOldStateIdMap) ->

            that = this

            _.each newOldStateIdMap, (newStateId, oldStateId) ->
                oldStateIdRef = "@{#{that.resName}.state.#{oldStateId}}"
                newStateIdRef = "@{#{that.resName}.state.#{newStateId}}"
                that.model.updateAllStateRef(oldStateIdRef, newStateIdRef)

    }

    return StateEditorView
