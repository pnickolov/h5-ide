#############################
#  View(UI logic) for design/property/sglist
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars', 'UI.tablist' ], ( ide_event ) ->

	SGListView = Backbone.View.extend {

		el       : $ document
		tagName  : $ '#sg-secondary-panel-wrap'

		template : Handlebars.compile $( '#property-sg-list-tmpl' ).html()

		events   :
			'click #sg-info-list .sg-edit-icon' : 'openSgPanel'
			'click #add-sg-btn' : 'openSgPanel'
			'click .sg-list-association-check' : 'assignSGToComp'
			'click .sg-list-delete-btn' : 'deleteSGFromComp'
			'OPTION_CHANGE #sg-rule-filter-select' : 'sortSgRule'

		render     : () ->
			console.log 'property:sg list render'
			this.model.getSGInfoList()
			this.model.getRuleInfoList()
			$( '.sg-group' ).html this.template this.model.attributes
			$('#property-head-sg-num').text(this.model.attributes.sg_list.length)

		openSgPanel : ( event ) ->
			sgUID = $(event.target).parents('li').attr('sg-uid')
			if !sgUID
				sgUID = MC.aws.sg.createNewSG()
				this.trigger 'ASSIGN_SG_TOCOMP', sgUID, true

			this.trigger 'OPEN_SG', sgUID

		refreshSGList: () ->
			this.render()

		assignSGToComp: (event) ->
			sgUID = $(event.target).attr('sg-uid')
			sgChecked = $(event.target).prop('checked')
			this.trigger 'ASSIGN_SG_TOCOMP', sgUID, sgChecked
			this.render()

		deleteSGFromComp : (event) ->
			sgUID = $(event.target).parents('li').attr('sg-uid')
			this.trigger 'DELETE_SG_FROM_COMP', sgUID
			this.render()

		sortSgRule : ( event ) ->
			sg_rule_list = $('#sglist-rule-list')

			sortType = $(event.target).find('.selected').attr('data-id')

			sorted_items = $('#sglist-rule-list li')
			if sortType is 'direction'
				sorted_items = sorted_items.sort(this._sortDirection)
			else if sortType is 'source/destination'
				sorted_items = sorted_items.sort(this._sortSource)
			else if sortType is 'protocol'
				sorted_items = sorted_items.sort(this._sortProtocol)

			sg_rule_list.html sorted_items

		_sortDirection : ( a, b) ->
			return $(a).find('.rule-direction-icon').attr('data-id') >
				$(b).find('.rule-direction-icon').attr('data-id')

		_sortProtocol : ( a, b) ->
			return $(a).find('.rule-protocol').attr('data-id') >
				$(b).find('.rule-protocol').attr('data-id')

		_sortSource : ( a, b) ->
			return $(a).find('.rule-source').attr('data-id') >
				$(b).find('.rule-source').attr('data-id')
	}

	view = new SGListView()

	return view
