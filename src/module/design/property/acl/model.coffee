#############################
#  View Mode for design/property/acl
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    ACLModel = Backbone.Model.extend {

        defaults :
            'component'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        init : (uid) ->

            allComp = MC.canvas_data.component
            aclObj = MC.canvas_data.component[uid]
            aclObj.name = 'sadasdsadsadsad'
            this.set 'component', aclObj

            null

        addRuleToACL : (uid, ruleObj) ->
            newEntrySet = []

            originEntrySet = MC.canvas_data.component[uid].resource.EntrySet

            currentRuleNumber = ruleObj.rule

            addToACL = true
            _.each originEntrySet, (value, key) ->
                if value.RuleNumber is currentRuleNumber
                    addToACL = false
                null

            if addToACL
                newEntrySet.push {
                    "RuleNumber": ruleObj.rule,
                    "IcmpTypeCode": {
                        "Type": "",
                        "Code": ""
                    },
                    "PortRange": {
                        "To": "",
                        "From": ""
                    },
                    "CidrBlock": ruleObj.source,
                    "Protocol": ruleObj.protocol,
                    "RuleAction": ruleObj.action,
                    "Egress": !ruleObj.inbound
                }

                newEntrySet = originEntrySet.concat newEntrySet

                MC.canvas_data.component[uid].resource.EntrySet = newEntrySet

                this.trigger 'REFRESH_RULE_LIST', MC.canvas_data.component[uid]

            null
    }

    model = new ACLModel()

    return model