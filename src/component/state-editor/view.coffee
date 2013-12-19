StateEditorView = Backbone.View.extend({

	el: '#state-editor'

	model: new StateEditorModel()

	editorHTML: $('#state-template-main').html()
	paraListHTML: $('#state-template-para-list').html()
	paraDictItemHTML: $('#state-template-para-dict-item').html()
	paraArrayItemHTML: $('#state-template-para-array-item').html()
	paraCompleteItemHTML: '<li data-value="${atwho-at}${name}">${name}</li>'

	events:

		'keyup .parameter-item.dict .parameter-value': 'onDictInputChange'
		'blur .parameter-item.dict .parameter-value': 'onDictInputBlur'

		'keyup .parameter-item.array .parameter-value': 'onArrayInputChange'
		'blur .parameter-item.array .parameter-value': 'onArrayInputBlur'

		'focus .editable-area': 'onFocusInput'

	initialize: () ->

		this.compileTpl()
		this.initData()
		this.render()

	render: () ->

		this.refreshStateList()

	compileTpl: () ->

		this.editorTpl = Handlebars.compile(this.editorHTML)

		Handlebars.registerPartial('state-template-para-list', this.paraListHTML)
		Handlebars.registerPartial('state-template-para-dict-item', this.paraDictItemHTML)
		Handlebars.registerPartial('state-template-para-array-item', this.paraArrayItemHTML)

		this.paraListTpl = Handlebars.compile(this.paraListHTML)
		this.paraDictListTpl = Handlebars.compile(this.paraDictItemHTML)
		this.paraArrayListTpl = Handlebars.compile(this.paraArrayItemHTML)

	refreshStateList: () ->

		that = this

		stateListObj = {
			state_list: [{
				state_id: 1,
				cmd_value: 'apt pkg',
				parameter_list: [{
					para_name: 'name',
					type_dict: true,
					required: true,
					para_value: [{
						key: 'name',
						value: 'xxx'
					}, {
						key: 'abc',
						value: 'xxx'
					}]
				}, {
					para_name: 'fromrepo',
					type_array: true,
					required: true,
					para_value: [
						'qqq',
						'qqq',
						'qqq'
					]
				}, {
					para_name: 'verify_gpg',
					type_text: true,
					required: true,
					para_value: 'ssh apt@211.98.26.7/pot'
				}, {
					para_name: 'debconf',
					type_line: true,
					required: false,
					para_value: 'what'
				}]
			}]
		}

		that.$el.html(this.editorTpl(stateListObj))

		that.bindStateListEvent()

	initData: () ->

		that = this
		that.$stateEditor = that.$el
		that.cmdParaMap = that.model.get('cmdParaMap')
		that.cmdParaObjMap = that.model.get('cmdParaObjMap')
		that.refObjAry = [{
			name: '{host1.privateIP}',
			value: '{host1.privateIP}'
		}, {
			name: '{host1.keyName}',
			name: '{host1.keyName}'
		}, {
			name: '{host2.instanceId}',
			name: '{host1.instanceId}'
		}]

	bindStateListEvent: () ->

		that = this
		that.$stateEditor = that.$el

		$stateItems = that.$stateEditor.find('.state-item')

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
				$that.attr('data-value', value)
				$paraListElem = $that.parent('.state-item').find('.parameter-list')
				that.refreshParaList($paraListElem, value)
		})

	bindParaListEvent: ($paraListElem, currentCMD) ->

		that = this

		$paraItemList = $paraListElem.find('.parameter-item')

		currentParaMap = that.cmdParaObjMap[currentCMD]

		_.each $paraItemList, (paraItem) ->
			
			$paraItem = $(paraItem)
			currentParaName = $paraItem.attr('data-para-name')
			paraObj = currentParaMap[currentParaName]
			that.bindParaItemEvent($paraItem, paraObj.type)

			null

	bindParaItemEvent: ($paraItem, paraType) ->

		that = this

		if paraType is 'dict'
			$keyInput = $paraItem.find('.key')
			$valueInput = $paraItem.find('.value')
			
			atwhoOption = {
				at: '@',
				tpl: that.paraCompleteItemHTML
				data: that.refObjAry
			}

			$keyInput.atwho(atwhoOption)
			$valueInput.atwho(atwhoOption)

		else if paraType in ['line', 'text', 'array']
			$inputElem = $paraItem.find('.parameter-value')
			$inputElem.atwho({
				at: '@',
				tpl: that.paraCompleteItemHTML
				data: that.refObjAry
			})

		else if paraType is 'bool'
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
			else if paraObj.type is 'array'
				newParaObj.para_value = ['']

			newParaAry.push(newParaObj)

			null

		$paraListElem.html(that.paraListTpl({
			parameter_list: newParaAry
		}))

		that.bindParaListEvent($paraListElem, currentCMD)

	onDictInputChange: (event) ->

		# append new dict item

		that = this

		$currentInputElem = $(event.currentTarget)
		$currentDictItemElem = $currentInputElem.parent('.parameter-dict-item')
		nextDictItemElemAry = $currentDictItemElem.next()

		if not nextDictItemElemAry.length

			$currentDictItemContainer = $currentDictItemElem.parents('.parameter-container')

			$keyInput = $currentDictItemElem.find('.key')
			$valueInput = $currentDictItemElem.find('.value')

			leftInputValue = $keyInput.text()
			rightInputValue = $valueInput.text()

			if leftInputValue or rightInputValue
				newDictItemHTML = that.paraDictListTpl({
					para_value: [{
						key: '',
						value: ''
					}]
				})
				$currentDictItemContainer.append(newDictItemHTML)
				that.bindParaItemEvent($currentDictItemContainer, 'dict')

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
		nextInputElemAry = $currentInputElem.next()

		if not nextInputElemAry.length

			$currentArrayInputContainer = $currentInputElem.parents('.parameter-container')

			currentInput = $currentInputElem.text()

			if currentInput
				newArrayItemHTML = that.paraArrayListTpl({
					para_value: ['']
				})
				$currentArrayInputContainer.append(newArrayItemHTML)
				that.bindParaItemEvent($currentArrayInputContainer, 'array')

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

		$currentInput = $(event.currentTarget)
		# document.execCommand('selectAll', false, null)

})

window.StateEditorView = StateEditorView