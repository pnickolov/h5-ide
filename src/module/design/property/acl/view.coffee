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
            #handlebars equal logic
            Handlebars.registerHelper 'ifCond', (v1, v2, options) ->
                if v1 is v2
                    return options.fn this
                options.inverse this

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
            'blur #property-acl-name'                    : 'aclNameChanged'

            'OPTION_CHANGE #acl-sort-rule-select' : 'sortACLRule'

        render     : () ->
            console.log 'property:acl render'

            $dom = this.htmlTpl this.model.attributes

            self = this
            setTimeout () ->
                self.refreshRuleList self.model.attributes.component
            , 10

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
                if !selected
                    selected = 'selected'
                    $('#acl-add-model-source-select .selection').text(key)

                selectboxContainer.append(
                    '<li class="item tooltip ' + selected + '" data-id="' + value + '"><div class="main truncate">' + key + '</div></li>'
                )

            selectboxContainer.append('<li class="item tooltip" data-id="custom"><div class="main truncate">Custom</div></li>')

            scrollbar.init()
            return false

        saveRule : () ->

            ruleNumber = $('#modal-acl-number').val()
            action = $('#acl-add-model-action-allow').prop('checked')
            inboundDirection = $('#acl-add-model-direction-inbound').prop('checked')
            source = $.trim($('#acl-add-model-source-select').find('.selected').attr('data-id'))

            if $('#modal-acl-source-input').is(':visible')
                source = $('#modal-acl-source-input').val()

            protocol = $.trim($('#modal-protocol-select').find('.selected').attr('data-id'))

            port = $('#acl-rule-modal-port-input').val()

            icmpType = icmpCode = ''
            if protocol is 'tcp'
                protocol = '6'
                portTo = portFrom = port
            else if protocol is 'udp'
                protocol = '17'
                portTo = portFrom = port
            else if protocol is 'icmp'
                protocol = '1'
                portTo = portFrom = ''
                icmpType = $('#protocol-icmp-main-select').find('.selected').attr('data-id')
                icmpCode = $('#protocol-icmp-sub-select-' + icmpType).find('.selected').attr('data-id')
            else if protocol is 'custom'
                protocol = port
                portTo = portFrom = ''
            else if protocol is 'all'
                protocol = '-1'
                portTo = '0'
                portFrom = '65535'

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

            $('#modal-wrap').trigger('closed').remove()

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
                else
                    newRuleObj.ruleNumber = value.RuleNumber

                if value.Protocol is '-1'
                    newRuleObj.protocol = 'All'
                else
                    newRuleObj.protocol = value.Protocol

                newRuleObj.port = ''

                if value.Protocol is '1'
                    newRuleObj.port = value.IcmpTypeCode.Type + '/' + value.IcmpTypeCode.Code
                else
                    newRuleObj.port = value.PortRange.From + '-' + value.PortRange.To

                    if (value.PortRange.To is '') and (value.PortRange.From is '')
                        newRuleObj.port = 'All'

                newEntrySet.push newRuleObj

                null

            $('.acl-rules').html this.ruleTpl({
                content: newEntrySet
            })

            $('#acl-rule-count').text(newEntrySet.length)

            #sort acl list
            sg_rule_list = $('#acl-rule-list')
            sorted_items = $('#acl-rule-list li')
            orted_items = sorted_items.sort(this._sortNumber)
            sg_rule_list.html sorted_items

        modalRuleSourceSelected : (event) ->
            value = $.trim($(event.target).find('.selected').attr('data-id'))

            if value is 'custom'
                $('#modal-acl-source-input').show()
            else
                $('#modal-acl-source-input').hide()

        removeRuleClicked : (event) ->
            parentElem = $(event.target).parents('li')
            currentRuleNumber = parentElem.attr('rule-num')
            if currentRuleNumber is '*'
                currentRuleNumber = '32767'
            currentRuleEngress = parentElem.attr('rule-engress')
            this.trigger 'REMOVE_RULE_FROM_ACL', currentRuleNumber, currentRuleEngress
            this.refreshRuleList this.model.attributes.component

        aclNameChanged : (event) ->
            aclName = $('#property-acl-name').val()
            this.trigger 'ACL_NAME_CHANGED', aclName

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
            return $(a).find('.acl-rule-source').attr('data-id') >
                $(b).find('.acl-rule-source').attr('data-id')
    }

    view = new ACLView()

    return view
