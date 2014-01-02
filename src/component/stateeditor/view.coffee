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
            'focus .editable-area': 'onFocusInput'
            'click .state-toolbar .state-id': 'onStateIdClick'
            'click .state-toolbar .state-add': 'onStateAddClick'
            'click .state-toolbar .state-remove': 'onStateRemoveClick'
            'click .state-save': 'onStateSaveClick'
            'click .parameter-item .parameter-remove': 'onParaRemoveClick'

        initialize: () ->

            this.compileTpl()
            this.initData()

        closedPopup: () ->
            @trigger 'CLOSE_POPUP'

        render: () ->

            that = this

            # show modal
            modal that.editorModalTpl(), false
            @setElement $( '#state-editor-model' ).closest '#modal-wrap'
            that.$stateList = that.$el.find('.state-list')
            that.$cmdDsec = $('#state-description')

            # hide autocomplete when click document
            $(document).on('mousedown', that.onDocumentMouseDown)
            $('#state-editor').on('scroll', () ->
                $('.atwho-view').hide()
            )

            compStateData = that.compData.state
            stateObj = that.loadStateData(compStateData)
            that.refreshStateList(stateObj)
            that.refreshStateViewList()
            that.bindStateListSortEvent()

        initData: () ->

            that = this
            that.cmdParaMap = that.model.get('cmdParaMap')
            that.cmdParaObjMap = that.model.get('cmdParaObjMap')
            that.cmdModuleMap = that.model.get('cmdModuleMap')
            that.moduleCMDMap = that.model.get('moduleCMDMap')
            that.refObjAry = [{
                name: '{host1.privateIP}',
                value: '{host1.privateIP}'
            }, {
                name: '{host1.keyName}',
                value: '{host1.keyName}'
            }, {
                name: '{host2.instanceId}',
                value: '{host1.instanceId}'
            }, {
                name: '{host2.instanceId}',
                value: '{host1.instanceId}'
            }]
            that.compData = that.model.get('compData')
            # that.refObjAry = JSON.parse(localStorage['state_editor_list'])

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

            # create new array input box
            $lastArrayInputList = $stateItemList.find('.parameter-item.array .parameter-value')
            _.each $lastArrayInputList, (lastArrayInput) ->
                that.onArrayInputChange({
                    currentTarget: lastArrayInput
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
            cmdValue = $cmdValueElem.text()
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

                    $keyInput = $paraItem.find('.parameter-dict-item:first-child .key')
                    $valueInput = $paraItem.find('.parameter-dict-item:first-child .value')

                    keyValue = $keyInput.text()
                    valueValue = $valueInput.text()

                    paraValue = keyValue + '=' + valueValue

                else if paraType is 'array'

                    $valueInput = $paraItem.find('.parameter-value:first-child')
                    valueValue = $valueInput.text()
                    paraValue = valueValue

                else if paraType in ['line', 'text', 'bool', 'state']

                    $valueInput = $paraItem.find('.parameter-value')
                    valueValue = $valueInput.text()
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
                return {'name': value}

            $cmdValueItem.atwho({
                at: '',
                tpl: that.paraCompleteItemHTML
                data: cmdNameAry,
                onSelected: (value) ->
                    $that = $(this)
                    $stateItem = $that.parents('.state-item')
                    $stateItem.attr('data-command', value)
                    that.refreshDescription(value)
                    $paraListElem = $stateItem.find('.parameter-list')
                    that.refreshParaList($paraListElem, value)
                    that.refreshStateView($stateItem)
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
                $keyInput = $paraItem.find('.key')
                $valueInput = $paraItem.find('.value')

                atwhoOption = {
                    at: '@',
                    tpl: that.paraCompleteItemHTML
                    data: that.refObjAry
                }

                if paraOptionAry
                    $valueInput.atwho({
                        at: '',
                        tpl: that.paraCompleteItemHTML
                        data: paraOptionAry
                    })

                $keyInput.atwho(atwhoOption)
                $valueInput.atwho(atwhoOption)

            else if paraType in ['line', 'text', 'array', 'state']
                $inputElem = $paraItem.find('.parameter-value')

                if paraOptionAry
                    $inputElem.atwho({
                        at: '',
                        tpl: that.paraCompleteItemHTML
                        data: paraOptionAry
                    })

                $inputElem.atwho({
                    at: '@',
                    tpl: that.paraCompleteItemHTML
                    data: that.refObjAry
                })

            else if paraType is 'bool'
                $inputElem = $paraItem.find('.parameter-value')
                $inputElem.atwho({
                    at: '',
                    tpl: that.paraCompleteItemHTML
                    data: [{
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

                if paraObj.type in ['line', 'text', 'bool', 'state']
                    newParaObj.para_value = ''
                else if paraObj.type is 'dict'
                    newParaObj.para_value = [{
                        key: '',
                        value: ''
                    }]
                else if paraObj.type is 'array'
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
                $stateItem.attr('data-id', currentStateId)
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

            paraObj = that.getParaObj($currentInputElem)

            $currentDictItemElem = $currentInputElem.parent('.parameter-dict-item')
            nextDictItemElemAry = $currentDictItemElem.next()

            if not nextDictItemElemAry.length

                $currentDictItemContainer = $currentDictItemElem.parents('.parameter-container')

                $keyInput = $currentDictItemElem.find('.key')
                $valueInput = $currentDictItemElem.find('.value')

                keyInputValue = $keyInput.text()
                valueInputValue = $valueInput.text()

                if keyInputValue or valueInputValue
                    newDictItemHTML = that.paraDictListTpl({
                        para_value: [{
                            key: '',
                            value: ''
                        }]
                    })
                    $currentDictItemContainer.append(newDictItemHTML)
                    that.bindParaItemEvent($currentDictItemContainer, paraObj)

        onDictInputBlur: (event) ->

            # remove empty dict item

            $currentInputElem = $(event.currentTarget)

            $currentDictItemContainer = $currentInputElem.parents('.parameter-container')
            allInputElemAry = $currentDictItemContainer.find('.parameter-dict-item')
            _.each allInputElemAry, (itemElem, idx) ->
                inputElemAry = $(itemElem).find('.parameter-value')
                isAllInputEmpty = true
                _.each inputElemAry, (inputElem) ->
                    if $(inputElem).text()
                        isAllInputEmpty = false
                    null
                if isAllInputEmpty and idx isnt allInputElemAry.length - 1
                    $(itemElem).remove()
                null

        onArrayInputChange: (event) ->

            # append new array item

            that = this

            $currentInputElem = $(event.currentTarget)

            paraObj = that.getParaObj($currentInputElem)

            nextInputElemAry = $currentInputElem.next()

            if not nextInputElemAry.length

                $currentArrayInputContainer = $currentInputElem.parents('.parameter-container')

                currentInput = $currentInputElem.text()

                if currentInput
                    newArrayItemHTML = that.paraArrayListTpl({
                        para_value: ['']
                    })
                    $currentArrayInputContainer.append(newArrayItemHTML)
                    that.bindParaItemEvent($currentArrayInputContainer, paraObj)

        onArrayInputBlur: (event) ->

            # remove empty array item

            $currentInputElem = $(event.currentTarget)
            $currentArrayItemContainer = $currentInputElem.parents('.parameter-container')
            allInputElemAry = $currentArrayItemContainer.find('.parameter-value')
            _.each allInputElemAry, (itemElem, idx) ->
                inputValue = $(itemElem).text()
                if not inputValue and idx isnt allInputElemAry.length - 1
                    $(itemElem).remove()
                null

        onFocusInput: (event) ->

            that = this

            $currentInput = $(event.currentTarget)

            # add default value

            if $currentInput.hasClass('parameter-value')

                currentValue = $currentInput.text()

                paraObj = that.getParaObj($currentInput)

                if paraObj and paraObj.default isnt undefined
                    defaultValue = String(paraObj.default)
                    if not currentValue and defaultValue and not $currentInput.hasClass('key')
                        $currentInput.html(defaultValue)

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
                $stateItemList.addClass('view')
                $stateItem.removeClass('view')
            else
                that.refreshStateView($stateItem)
                $stateItem.addClass('view')

        onStateAddClick: (event) ->

            that = this

            $currentElem = $(event.currentTarget)
            $stateItem = $currentElem.parents('.state-item')

            stateId = Number($stateItem.attr('data-id'))

            newStateId = ++stateId

            newStateHTML = that.stateListTpl({
                state_list: [{
                    state_id: newStateId
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

        submitValidate: () ->
            $contentEditable = @$stateList.find '[contenteditable="true"]'

            result = true
            $contentEditable.each ->
                if $( @ ).parent( '[contenteditable="true"]' ).size()
                    return true

                res = validate @

                if not res and result
                    result = false

                true


            result


        saveStateData: () ->
            if not @submitValidate()
                return false

            that = this

            $stateItemList = that.$stateList.find('.state-item')

            stateObj = {}

            _.each $stateItemList, (stateItem, idx) ->

                $stateItem = $(stateItem)

                cmdName = $stateItem.attr('data-command')
                stateId = $stateItem.attr('data-id')

                moduleObj = that.cmdModuleMap[cmdName]

                #empty module direct return
                if not moduleObj
                    return

                stateObj[stateId] = {
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
                        $paraItem.hasClass('text') or
                        $paraItem.hasClass('state')

                            $paraInput = $paraItem.find('.parameter-value')
                            paraValue = $paraInput.text()

                    else if $paraItem.hasClass('dict')

                        $dictItemList = $paraItem.find('.parameter-dict-item')
                        dictObj = {}

                        _.each $dictItemList, (dictItem) ->

                            $dictItem = $(dictItem)
                            $keyInput = $dictItem.find('.key')
                            $valueInput = $dictItem.find('.value')

                            keyValue = $keyInput.text()
                            valueValue = $valueInput.text()

                            if keyValue
                                dictObj[keyValue] = valueValue

                            null

                        paraValue = dictObj

                    else if $paraItem.hasClass('array')

                        $arrayItemList = $paraItem.find('.parameter-value')
                        arrayObj = []

                        _.each $arrayItemList, (arrayItem) ->

                            $arrayItem = $(arrayItem)
                            arrayValue = $arrayItem.text()

                            arrayObj.push(arrayValue)

                            null

                        paraValue = arrayObj

                    stateObj[stateId]['parameter'][paraName] = paraValue

                    null

                null

            return stateObj

        loadStateData: (stateObj) ->

            that = this

            renderObj = {
                state_list: []
            }

            _.each stateObj, (state, stateId) ->

                cmdName = that.moduleCMDMap[state.module]
                paraModelObj = that.cmdParaObjMap[cmdName]

                paraListObj = state.parameter

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
                        para_disabled: false,
                        required: paraModelRequired
                    }

                    renderParaObj['type_' + paraModelType] = true

                    paraValue = paraListObj[paraModelName]

                    if paraValue is undefined and not paraModelRequired
                        renderParaObj.para_disabled = true

                    renderParaValue = null
                    if paraModelType in ['line', 'text', 'bool', 'state']

                        renderParaValue = paraValue

                        if not paraValue
                            renderParaValue = ''

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

                    else if paraModelType is 'array'

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

                        if paraObj1.required is paraObj2.required
                            if paraObj1.para_name > paraObj1.para_name
                                return false

                        return true
                    )

                    null

                renderObj.state_list.push(stateRenderObj)

                null

            return renderObj

        onStateSaveClick: (event) ->

            # test getPlainTxt
            #@getPlainTxt()
            #@setPlainTxt localStorage[ 'new_str' ]

            that = this
            stateData = that.saveStateData()

            if stateData

                that.compData.state = stateData

                that.closedPopup()

            # localStorage[ 'state_data' ] = JSON.stringify data

            # renderData = that.loadStateData(data)
            # console.log(renderData)

            # that.refreshStateList(renderData)
            # that.refreshStateViewList(renderData)

        onParaRemoveClick: (event) ->

            that = this

            $currentElem = $(event.currentTarget)
            $paraItem = $currentElem.parents('.parameter-item')

            if $paraItem.hasClass('disabled')
                $paraItem.removeClass('disabled')
            else
                $paraItem.addClass('disabled')

            null

        onDocumentMouseDown: (event) ->

            that = this
            $currentElem = $(event.target)
            $parentElem = $currentElem.parents('.editable-area')

            if not $parentElem.length and not $currentElem.hasClass('editable-area')
                $('.editable-area').blur()

        getParaObjByInput: (inputElem) ->

            that = this
            $inputElem = $(inputElem)
            $paraItem = $inputElem.parents('.parameter-item')
            $stateItem = $paraItem.parents('.state-item')

            paraName = $paraItem.attr('data-para-name')
            cmdName = $stateItem.attr('data-command')

            currentParaMap = that.cmdParaObjMap[cmdName]
            paraObj = currentParaMap[paraName]

            return paraObj

        getPlainTxt : ->
            console.log 'getPlainTxt', $ '#xxxxx'

            $dom        = $ '#xxxxx'
            $conent_arr = $dom.children()
            new_str     = ''

            $conent_arr.each ( index, item ) ->
                $item  = $ item

                $item.each ( index, values ) ->
                    $values = $ values
                    new_str += $values.html().replace( /<span>/igm, '' )
                                             .replace( /<\/span>/igm, '' )
                                             .replace( /<span contenteditable="true">/igm, '' )
                                             .replace( /<span contenteditable="true" class="atwho-view-flag atwho-view-flag-@">/igm, '' )
                                             .replace( /&lt;/igm, '<' )
                                             .replace( /&gt;/igm, '>' )
                                             .replace( /<br>/igm, '\n' )
                                             .replace( /&nbsp;/igm, ' ' )

            console.log 'new_str', new_str
            localStorage[ 'new_str' ] = new_str
            new_str

        setPlainTxt : ( str ) ->
            console.log 'setPlainTxt', str

            new_str = str.replace( /</igm, '&lt;' )
                         .replace( />/igm, '&gt;' )
                         .replace( /\n/igm, '<br>' )
                         .replace( /\s+/igm, '&nbsp;' )

            console.log 'new_str', new_str
            new_str

    }

    return StateEditorView
