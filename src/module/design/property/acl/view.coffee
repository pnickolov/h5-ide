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

        initialize : ->
            #handlebars equal logic
            Handlebars.registerHelper 'ifCond', (v1, v2, options) ->
                if v1 is v2
                    return options.fn this
                options.inverse this

            null

        events   :
            'click .secondary-panel .back' : 'returnMainPanel'
            'click #acl-add-rule-icon' : 'showCreateRuleModal'
            'click #acl-modal-rule-save-btn' : 'saveRule'
            'OPTION_CHANGE #acl-add-model-source-select' : 'modalRuleSourceSelected'
            'click .property-rule-delete-btn' : 'removeRuleClicked'
            'blur #property-acl-name' : 'aclNameChanged'

        instance_expended_id : 0

        render     : (expended_accordion_id, attributes) ->
            console.log 'property:acl render'

            $('#acl-secondary-panel-wrap').html this.htmlTpl(attributes)

            this.refreshRuleList attributes.component

            this.instance_expended_id = expended_accordion_id

            secondary_panel_wrap = $('#acl-secondary-panel-wrap')

            fixedaccordion.resize()

            secondary_panel_wrap.animate({
                right: 0
            }, {
                duration: 200,
                specialEasing: {
                    width: 'linear'
                },
                complete : () ->

                }
            )

        returnMainPanel : () ->
            me = this
            console.log 'returnMainPanel'
            secondary_panel_wrap = $('#acl-secondary-panel-wrap')
            secondary_panel_wrap.animate({
                right: "-280px"
            }, {
                duration: 200,
                specialEasing: {
                    width: 'linear'
                },
                complete : () ->
                    # ide_event.trigger ide_event.OPEN_PROPERTY, 'component', $('#sg-secondary-panel').attr('parent'), me.instance_expended_id
                }
            )
            ide_event.trigger ide_event.RETURN_SUBNET_PROPERTY_FROM_ACL

        showCreateRuleModal : () ->
            modal MC.template.modalAddACL {}, true
            
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
                    '<li class="item tooltip ' + selected + '" data-value="' + value + '"><div class="main truncate">' + key + '</div></li>'
                )

            selectboxContainer.append('<li class="item tooltip" data-value="custom"><div class="main truncate">Custom</div></li>')
                
            scrollbar.init()
            return false

        saveRule : () ->

            ruleNumber = $('#modal-acl-number').val()
            action = $('#acl-add-model-action-allow').prop('checked')
            inboundDirection = $('#acl-add-model-direction-inbound').prop('checked')
            source = $.trim($('#acl-add-model-source-select').find('.selected').attr('data-value'))

            if $('#modal-acl-source-input').is(':visible')
                source = $('#modal-acl-source-input').val()

            protocol = $.trim($('#acl-rule-modal-protocol-select').find('.selected').attr('data-value'))
            port = $('#acl-rule-modal-port-input').val()

            this.trigger 'ADD_RULE_TO_ACL', {
                rule: ruleNumber,
                action: action,
                inbound: inboundDirection,
                source: source,
                protocol: protocol,
                port: port
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
                    newRuleObj.port = value.PortRange.To

                    if (value.PortRange.To is '') and (value.PortRange.From is '')
                        newRuleObj.port = 'All'

                newEntrySet.push newRuleObj

                null

            $('#acl-secondary-panel-wrap .acl-rules').html this.ruleTpl({
                content: newEntrySet
            })

            $('#acl-rule-count').text(newEntrySet.length)

        modalRuleSourceSelected : (event) ->
            value = $.trim($(event.target).find('.selected').attr('data-value'))

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
    }

    view = new ACLView()

    return view