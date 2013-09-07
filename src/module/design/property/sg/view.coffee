#############################
#  View(UI logic) for design/property/sg
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars', 'UI.editablelabel' ], ( ide_event, MC ) ->

	InstanceView = Backbone.View.extend {

		el       : $ document
		tagName  : $ '#sg-secondary-panel-wrap'

		template : Handlebars.compile $( '#property-sg-tmpl' ).html()

		app_template : Handlebars.compile $( '#property-sg-app-tmpl' ).html()

		instance_expended_id : 0

		events   :
			#for sg rule
			'click .rule-edit-icon'   : 'showEditRuleModal'
			'click #sg-add-rule-icon' : 'showCreateRuleModal'
			'click .rule-remove-icon' : 'removeRulefromList'

			#for sg modal
			'click #sg-modal-direction input'          : 'radioSgModalChange'
			'OPTION_CHANGE #modal-protocol-select'     : 'sgModalSelectboxChange'
			'OPTION_CHANGE #protocol-icmp-main-select' : 'icmpMainSelect'
			'OPTION_CHANGE .protocol-icmp-sub-select'  : 'icmpSubSelect'
			'click #sg-modal-save'                     : 'saveSgModal'
			'click .editable-label'                    : 'editablelabelClick'
			'change #sg-protocol-tcp input'            : 'tcpValueChange'
			'change #sg-protocol-udp input'            : 'udpValueChange'
			'change #sg-protocol-custom input'         : 'customValueChange'

			#for sg detail
			'change #securitygroup-name'           : 'setSGName'
			'change #securitygroup-description'    : 'setSGDescription'
			'OPTION_CHANGE #sg-rule-filter-select' : 'sortSgRule'

		render     : (is_app_view) ->

			if is_app_view

				$dom = this.app_template this.model.attributes

			else

				if this.model.attributes.sg_detail.component.name == 'DefaultSG'
					this.model.attributes.isDefault = true
				else
					this.model.attributes.isDefault = false

				$dom = this.template this.model.attributes

			# Right now, hack to focus the input. Find a better way later
			setTimeout ()->
				input = $('#securitygroup-name').focus()[0]
				input.focus() if input
			, 200

			$dom

		#SG SecondaryPanel
		showEditRuleModal : (event) ->
			if this.model.get('is_elb_sg') then return
			modal MC.template.modalSGRule {isAdd:false}, true

		showCreateRuleModal : (event) ->
			if this.model.get('is_elb_sg') then return
			isclassic = false
			if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC
				isclassic = true
			modal MC.template.modalSGRule {isAdd:true, isclassic:isclassic}, true
			return false

		removeRulefromList: (event, id) ->
			if this.model.get('is_elb_sg') then return
			rule = {}
			li_dom = $(event.target).parents('li').first()
			rule.inbound = li_dom.data('inbound')
			rule.protocol = li_dom.data('protocol')
			rule.fromport = li_dom.data('fromport')
			rule.toport = li_dom.data('toport')
			rule.iprange = li_dom.data('iprange')
			# sg_uid = $("#sg-secondary-panel").attr "uid"
			this.trigger 'REMOVE_SG_RULE', rule
			$(event.target).parents('li').first().remove()

			ruleCount =$("#sg-rule-list").children().length
			$("#sg-rule-empty").toggle ruleCount == 0
			$("#rule-count").text ruleCount

		radioSgModalChange : (event) ->
			if $('#sg-modal-direction input:checked').val() is "inbound"
				$('#rule-modal-ip-range').text "Source"
			else
				$('#rule-modal-ip-range').text "Destination"

		sgModalSelectboxChange : (event, id) ->
			$('#sg-protocol-select-result').find('.show').removeClass('show')
			$('.sg-protocol-option-input').removeClass("show")
			$('#sg-protocol-' + id).addClass('show')
			$('#modal-protocol-select').data('protocal-type', id)
			null

		icmpMainSelect : ( event, id ) ->
			$("#protocol-icmp-main-select").data('protocal-main', id)
			if id is "3" || id is "5" || id is "11" || id is "12"
				$( '#protocol-icmp-sub-select-' + id).addClass('shown')
			else
				$('.protocol-icmp-sub-select').removeClass('shown')

		icmpSubSelect : ( event, id ) ->
			$("#protocol-icmp-main-select").data('protocal-sub', id)

		setSGName : ( event ) ->
			id = @model.get( 'sg_detail' ).component.uid
			target = $ event.currentTarget
			name = target.val()

			MC.validate.preventDupname target, id, name, 'SG'

			if target.parsley 'validate'
				this.trigger 'SET_SG_NAME', name

		setSGDescription : ( event ) ->
			# sg_uid = $("#sg-secondary-panel").attr "uid"
			this.trigger 'SET_SG_DESC', event.target.value

		saveSgModal : ( event ) ->
			sg_direction = $('#sg-modal-direction input:checked').val()
			descrition_dom = $('#securitygroup-modal-description')
			tcp_port_dom = $('#sg-protocol-tcp input')
			udp_port_dom = $('#sg-protocol-udp input')
			custom_protocal_dom = $( '#sg-protocol-custom input' )
			protocol_type =  $('#modal-protocol-select').data('protocal-type')
			rule = {}
			if descrition_dom.hasClass('input')
				sg_descrition = descrition_dom.val()
			else
				sg_descrition = descrition_dom.html()

			# validation #####################################################

			descrition_dom.parsley('removeConstraint', 'required')

			tcp_port_dom.parsley('removeConstraint', 'required')

			udp_port_dom.parsley('removeConstraint', 'required')

			custom_protocal_dom.parsley('removeConstraint', 'required')

			descrition_dom.parsley('addConstraint', {
				required: true
			})

			tcp_port_dom.parsley('addConstraint', {
				required: true
			})

			udp_port_dom.parsley('addConstraint', {
				required: true
			})

			custom_protocal_dom.parsley('addConstraint', {
				required: true
			})

			if protocol_type is 'icmp'
				tcp_port_dom.parsley('removeConstraint', 'required')
				udp_port_dom.parsley('removeConstraint', 'required')
				custom_protocal_dom.parsley('removeConstraint', 'required')

			else if protocol_type is 'custom'
				tcp_port_dom.parsley('removeConstraint', 'required')
				udp_port_dom.parsley('removeConstraint', 'required')
				custom_protocal_dom.parsley 'custom', ( val ) ->
					if !MC.validate.portRange(val)
						return 'Must be a valid format of number.'
					null
			else if protocol_type is 'tcp'
				custom_protocal_dom.parsley('removeConstraint', 'required')
				udp_port_dom.parsley('removeConstraint', 'required')
				tcp_port_dom.parsley 'custom', ( val ) ->
					if !MC.validate.portRange(val)
						return 'Must be a valid format of port range.'
					null
			else if protocol_type is 'udp'
				custom_protocal_dom.parsley('removeConstraint', 'required')
				tcp_port_dom.parsley('removeConstraint', 'required')
				udp_port_dom.parsley 'custom', ( val ) ->
					if !MC.validate.portRange(val)
						return 'Must be a valid format of port range.'
					null

			descrition_dom.parsley 'custom', ( val ) ->
				if !MC.validate 'cidr', val
					return 'Must be a valid form of CIDR block.'
				null

			if !descrition_dom.parsley 'validateForm'
				return
			# validation #####################################################

			rule.protocol = protocol_type
			protocol_val = $("#protocol-icmp-main-select").data('protocal-main')
			protocol_val_sub = $("#protocol-icmp-main-select").data('protocal-sub')
			switch protocol_type
				when "tcp", "udp"
					protocol_val = $( '#sg-protocol-tcp input' ).val()
					if '-' in protocol_val
						rule.fromport = protocol_val.split('-')[0].trim()
						rule.toport = protocol_val.split('-')[1].trim()
					else
						rule.fromport = protocol_val
						rule.toport = protocol_val

				when "icmp"
					rule.fromport = protocol_val
					rule.toport = protocol_val_sub

				when "custom"
					rule.protocol = $( '#sg-protocol-custom input' ).val()
					rule.fromport = ""
					rule.toport = ""

				when "all"
					rule.protocol = -1
					rule.fromport = ""
					rule.toport = ""

			rule.direction = sg_direction
			rule.ipranges = sg_descrition

			# sg_uid = $("#sg-secondary-panel").attr "uid"
			cur_count = Number $("#rule-count").text()
			cur_count = cur_count + 1
			$("#rule-count").text cur_count
			$("#sg-rule-list").append MC.template.sgRuleItem {rule:rule}

			$("#sg-rule-empty").toggle cur_count == 0

			this.trigger "SET_SG_RULE", rule

			modal.close()

		editablelabelClick : ( event ) ->
			editablelabel.create.call $(event.target)

		tcpValueChange : ( event ) ->
			#protocol_val = $( '#sg-protocol-tcp input' ).val()
			null

		udpValueChange : ( event ) ->
			#protocol_val = $( '#sg-protocol-udp input' ).val()
			null

		customValueChange : ( event ) ->
			#protocol_val = $( '#sg-protocol-custom input' ).val()
			null

		sortSgRule : ( event ) ->
			sg_rule_list = $('#sg-rule-list')

			sortType = $(event.target).find('.selected').attr('data-id')

			sorted_items = $('#sg-rule-list li')
			if sortType is 'direction'
				sorted_items = sorted_items.sort(this._sortDirection)
			else if sortType is 'source/destination'
				sorted_items = sorted_items.sort(this._sortSource)
			else if sortType is 'protocol'
				sorted_items = sorted_items.sort(this._sortProtocol)

			sg_rule_list.html sorted_items

		_sortDirection : ( a, b) ->
			return $(a).attr('data-direction') >
				$(b).attr('data-direction')

		_sortProtocol : ( a, b) ->
			return $(a).attr('data-protocol') >
				$(b).attr('data-protocol')

		_sortSource : ( a, b) ->
			return $(a).attr('data-iprange') >
				$(b).attr('data-iprange')
	}

	view = new InstanceView()

	return view
