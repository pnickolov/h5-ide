#############################
#  View(UI logic) for design/property/sglist
#############################

define [ './template/stack' ], ( template ) ->

	SGListView = Backbone.View.extend {

		events   :
			'click #sg-info-list .sg-edit-icon'    : 'openSgPanel'
			'click #add-sg-btn'                    : 'openSgPanel'
			'click .sg-list-association-check'     : 'assignSGToComp'
			'click .sg-list-delete-btn'            : 'deleteSGFromComp'
			'OPTION_CHANGE #sg-rule-filter-select' : 'sortSgRule'

		render     : () ->
			@model.getSGInfoList()

			@setElement $('.sg-group')
			@$el.html template @model.attributes

			$("#sglist-rule-list").html MC.template.sgRuleList @model.attributes.sg_rule_list
			$('#property-head-sg-num').text( @model.attributes.sg_length )

		openSgPanel : ( event ) ->
			if event.currentTarget.id is "add-sg-btn"
				sgUID = @model.createNewSG()
			else
				sgUID = $(event.currentTarget).closest("li").attr("data-uid")

			@trigger 'OPEN_SG', sgUID

		refreshSGList: () ->
			this.render()

		assignSGToComp: (event) ->
			$target  = $(event.currentTarget)
			$checked = $target.closest("#sg-info-list").find(":checked")

			if $checked.length is 0
				return false

			sgUID     = $target.closest("li").attr('data-uid')
			sgChecked = $target.prop('checked')

			@model.assignSG sgUID, sgChecked
			@render()
			null

		deleteSGFromComp : (event) ->

			that = this

			$target = $(event.currentTarget)
			sgUID   = $target.closest('li').attr('data-uid')

			memberNum = Number($target.attr('data-count'))
			sgName    = $target.attr('data-name')

			# show dialog to confirm that delete sg
			if memberNum
				mainContent = "Are you sure you want to delete #{sgName}?"
				descContent = 'The firewall settings of ' + sgName + '\'s member will be affected. Member only has this security group will be using DefaultSG.'

			if mainContent
				tpl = MC.template.modalDeleteSGOrACL {
					title : 'Delete Security Group',
					main_content : mainContent,
					desc_content : descContent
				}
				modal tpl, false, () ->
					$('#modal-confirm-delete').click () ->
						that.model.deleteSG sgUID
						that.render()
						modal.close()
			else
				@model.deleteSG sgUID
				@render()

		sortSgRule : ( event ) ->
			sg_rule_list = $('#sglist-rule-list')

			sortType = $(event.target).find('.selected').attr('data-id')
			@model.sortSGRule( sortType )

			$("#sglist-rule-list").html MC.template.sgRuleList @model.attributes.sg_rule_list
	}

	new SGListView()
