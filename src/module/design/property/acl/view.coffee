#############################
#  View(UI logic) for design/property/acl
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, template, rule_template ) ->

   ACLView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        htmlTpl  : Handlebars.compile $('#property-acl-tmpl').html()
        ruleTpl  : Handlebars.compile $('#property-acl-rule-tmpl').html()
        rulePopupTpl : Handlebars.compile $('#property-acl-rule-popup-tmpl').html()

        initialize : ->
            $('#sg-protocol-udp').hide()
            $('#sg-protocol-icmp').hide()
            $('#sg-protocol-custom').hide()
            $('#sg-protocol-all').hide()
            $('.protocol-icmp-sub-select').hide()

            null

        events   :
            'click #acl-add-rule-icon'                   : 'showCreateRuleModal'
            'click #acl-modal-rule-save-btn'             : 'saveRule'
            'OPTION_CHANGE #acl-add-model-source-select' : 'modalRuleSourceSelected'
            'OPTION_CHANGE #modal-protocol-select'       : 'modalRuleProtocolSelected'
            'OPTION_CHANGE #protocol-icmp-main-select'   : 'modalRuleICMPSelected'
            'click .property-rule-delete-btn'            : 'removeRuleClicked'
            'change #property-acl-name'                  : 'aclNameChanged'

            'OPTION_CHANGE #acl-sort-rule-select' : 'sortACLRule'

            'change #acl-add-model-direction-outbound'   : 'changeBoundInModal'
            'change #acl-add-model-direction-inbound'    : 'changeBoundInModal'

        render     : () ->
            console.log 'property:acl render'

            $dom = this.htmlTpl this.model.attributes

            self = this
            self.refreshRuleList self.model.attributes.component

            $dom

        showCreateRuleModal : () ->
            modal this.rulePopupTpl({}, true)

            subnetMap = {}

            # subnet list
            _.each MC.canvas_data.component, (value, key) ->
                compType = value.type
                if compType is 'AWS.VPC.Subnet'
                    subnetMap[value.name] = value.resource.CidrBlock
                null

            # load subnet select menu
            selectboxContainer = $('#acl-add-model-source-select .dropdown').empty()
            selected = ''
            _.each subnetMap, (value, key) ->
                # if !selected
                #     selected = 'selected'
                #     $('#acl-add-model-source-select .selection').text(key)

                selectboxContainer.append(
                    '<li class="item tooltip ' + selected + '" data-id="' + value + '"><div class="main truncate">' + key + '</div></li>'
                )

            selectboxContainer.append('<li class="item tooltip" data-id="custom"><div class="main truncate">Custom...</div></li>')

            # scrollbar.init()
            return false

        saveRule : () ->

            that = this
            aclUID = that.model.get('component').uid

            rule_number_dom =  $('#modal-acl-number')
            ruleNumber = $('#modal-acl-number').val()
            action = $('#acl-add-model-action-allow').prop('checked')
            inboundDirection = $('#acl-add-model-direction-inbound').prop('checked')
            source = $.trim($('#acl-add-model-source-select').find('.selected').attr('data-id'))
            custom_source_dom = $('#modal-acl-source-input')

            if custom_source_dom.is(':visible')
                source = custom_source_dom.val()

            protocol_dom = $('#modal-protocol-select').find('.selected')
            protocol = $.trim(protocol_dom.attr('data-id'))
            protocolStr = $.trim(protocol_dom.attr('data-id'))

            port = $('#acl-rule-modal-port-input').val()

            ruleAction = ''
            if action
                ruleAction = 'allow'
            else
                ruleAction = 'deny'

            egress = ''
            if inboundDirection
                egress = 'false'
            else
                egress = 'true'

            # validation #####################################################
            validateMap =
                'tcp':
                    dom: $('#sg-protocol-tcp input')
                    method: ( val ) ->
                        if not MC.validate.portRange(val)
                            return 'Must be a valid format of number.'
                        null
                'udp':
                    dom: $('#sg-protocol-udp input')
                    method: ( val ) ->
                        if not MC.validate.portRange(val)
                            return 'Must be a valid format of port range.'
                        null
                'custom':
                    dom: $('#sg-protocol-custom input')
                    method: ( val ) ->
                        if not MC.validate.port(val)
                            return 'Must be a valid format of port.'
                        null

            if protocolStr of validateMap
                needValidate = validateMap[ protocolStr ]
                needValidate.dom.parsley 'custom', needValidate.method

            custom_source_dom.parsley 'custom', ( val ) ->
                if !MC.validate 'cidr', val
                    return 'Must be a valid form of CIDR block.'
                null

            rule_number_dom.parsley 'custom', ( val ) ->
                if Number(val) > 32767
                    return 'The maximum value is 32767.'
                if that.model.haveRepeatRuleNumber(aclUID, val)
                    return 'The Rule Number have exist one.'
                null

            if (not rule_number_dom.parsley 'validate') or (custom_source_dom.is(':visible') and not custom_source_dom.parsley 'validate') or
                (needValidate and not needValidate.dom.parsley 'validate')
                    return
            # validation #####################################################

            icmpType = icmpCode = ''
            if protocol is 'tcp'
                portRangeStr = $('#sg-protocol-' + protocol + ' input').val()
                portRangeAry = MC.validate.portRange(portRangeStr)
                if portRangeAry.length is 2
                    portFrom = portRangeAry[0]
                    portTo = portRangeAry[1]
                else
                    portTo = portFrom = portRangeAry[0]
                protocol = '6'
            else if protocol is 'udp'
                portRangeStr = $('#sg-protocol-' + protocol + ' input').val()
                portRangeAry = MC.validate.portRange(portRangeStr)
                if portRangeAry.length is 2
                    portFrom = portRangeAry[0]
                    portTo = portRangeAry[1]
                else
                    portTo = portFrom = portRangeAry[0]
                protocol = '17'
            else if protocol is 'icmp'
                portTo = portFrom = ''
                icmpType = $('#protocol-icmp-main-select').find('.selected').attr('data-id')
                icmpCode = $('#protocol-icmp-sub-select-' + icmpType).find('.selected').attr('data-id')
                protocol = '1'
            else if protocol is 'custom'
                protocol = $('#sg-protocol-' + protocol + ' input').val()
                portTo = portFrom = ''
            else if protocol is 'all'
                portTo = '0'
                portFrom = '65535'
                protocol = '-1'

            this.trigger 'ADD_RULE_TO_ACL', {
                rule: ruleNumber,
                action: ruleAction,
                egress: egress,
                source: source,
                protocol: protocol,
                portTo: portTo
                portFrom: portFrom
                type: icmpType
                code: icmpCode
            }

            modal.close()

            null

        refreshRuleList : (value) ->
            entrySet = value.resource.EntrySet

            newEntrySet = []
            _.each entrySet, (value, key) ->
                newRuleObj = {}

                newRuleObj.ruleAction = value.RuleAction
                newRuleObj.cidrBlock = value.CidrBlock
                newRuleObj.egress = value.Egress

                if value.RuleNumber is '32767'
                    newRuleObj.ruleNumber = '*'
                    newRuleObj.isStarRule = true
                else
                    newRuleObj.ruleNumber = value.RuleNumber
                    newRuleObj.isStarRule = false

                # if value.Protocol is '-1'
                #     newRuleObj.protocol = 'All'
                # else
                #     newRuleObj.protocol = value.Protocol

                if value.Protocol is -1 or value.Protocol is '-1'
                    newRuleObj.protocol = 'All'
                else if value.Protocol is 6 or value.Protocol is '6'
                    newRuleObj.protocol = 'TCP'
                else if value.Protocol is 17 or value.Protocol is '17'
                    newRuleObj.protocol = 'UDP'
                else if value.Protocol is 1 or value.Protocol is '1'
                    newRuleObj.protocol = 'ICMP'
                else
                    newRuleObj.protocol = 'Custom(' + value.Protocol + ')'

                newRuleObj.port = ''

                if value.Protocol is '1'
                    newRuleObj.port = value.IcmpTypeCode.Type + '/' + value.IcmpTypeCode.Code
                else
                    newRuleObj.port = value.PortRange.From + '-' + value.PortRange.To

                    if (value.PortRange.To is '') and (value.PortRange.From is '')
                        newRuleObj.port = 'All'

                newEntrySet.push newRuleObj

                null

            $('#acl-rule-list').html this.ruleTpl({
                content: newEntrySet
            })

            $('#acl-rule-count').text(newEntrySet.length)

            #sort acl list
            sg_rule_list = $('#acl-rule-list')
            sorted_items = $('#acl-rule-list li')
            sorted_items = sorted_items.sort(this._sortNumber)
            sg_rule_list.html sorted_items

        modalRuleSourceSelected : (event) ->
            value = $.trim($(event.target).find('.selected').attr('data-id'))

            if value is 'custom'
                $('#modal-acl-source-input').show()
                $('#acl-add-model-source-select .selection').width(68)
            else
                $('#modal-acl-source-input').hide()
                $('#acl-add-model-source-select .selection').width(296)

        removeRuleClicked : (event) ->
            parentElem = $(event.target).parents('li')
            currentRuleNumber = parentElem.attr('rule-num')
            if currentRuleNumber is '*'
                currentRuleNumber = '32767'
            currentRuleEngress = parentElem.attr('rule-engress')
            this.trigger 'REMOVE_RULE_FROM_ACL', currentRuleNumber, currentRuleEngress
            this.refreshRuleList this.model.attributes.component

        aclNameChanged : (event) ->
            target = $ event.currentTarget
            name = target.val()

            id = @model.get( 'component' ).uid

            MC.validate.preventDupname target, id, name, 'ACL'

            if target.parsley 'validate'
                this.trigger 'ACL_NAME_CHANGED', name

        modalRuleProtocolSelected : (event) ->
            protocolSelectElem = $(event.target)
            selectedValue = protocolSelectElem.find('.selected').attr('data-id')
            $('#sg-protocol-select-result .sg-protocol-option-input').hide()
            $('#sg-protocol-' + selectedValue).show()

            icmpSelectElem = $('#protocol-icmp-main-select')
            icmpSelectedValue = icmpSelectElem.find('.selected').attr('data-id')
            if icmpSelectedValue isnt '3' and icmpSelectedValue isnt '5' and icmpSelectedValue isnt '11' and icmpSelectedValue isnt '12'
                $('.protocol-icmp-sub-select').hide()
            null

        modalRuleICMPSelected : (event) ->
            icmpSelectElem = $(event.target)
            selectedValue = icmpSelectElem.find('.selected').attr('data-id')
            subSelectElem = $('#protocol-icmp-sub-select-' + selectedValue)
            $('.protocol-icmp-sub-select').hide()
            subSelectElem.show()
            null

        changeBoundInModal : (event) ->

            inbound = $('#acl-add-model-direction-inbound').prop('checked')
            if inbound
                $('#acl-add-model-bound-label').text('Source')
            else
                $('#acl-add-model-bound-label').text('Destination')

        sortACLRule : ( event ) ->
            sg_rule_list = $('#acl-rule-list')

            sortType = $(event.target).find('.selected').attr('data-id')

            sorted_items = $('#acl-rule-list li')

            if sortType is 'number'
                sorted_items = sorted_items.sort(this._sortNumber)
            else if sortType is 'action'
                sorted_items = sorted_items.sort(this._sortAction)
            else if sortType is 'direction'
                sorted_items = sorted_items.sort(this._sortDirection)
            else if sortType is 'source/destination'
                sorted_items = sorted_items.sort(this._sortSource)

            sg_rule_list.html sorted_items

        _sortNumber : ( a, b) ->
            return $(a).find('.acl-rule-number').attr('data-id') >
                $(b).find('.acl-rule-number').attr('data-id')

        _sortAction : ( a, b) ->
            return $(a).find('.acl-rule-action').attr('data-id') >
                $(b).find('.acl-rule-action').attr('data-id')

        _sortDirection : ( a, b) ->
            return $(a).find('.acl-rule-direction').attr('data-id') >
                $(b).find('.acl-rule-direction').attr('data-id')

        _sortSource : ( a, b) ->
            return $(a).find('.acl-rule-reference').attr('data-id') >
                $(b).find('.acl-rule-reference').attr('data-id')
    }

    view = new ACLView()

    return view
