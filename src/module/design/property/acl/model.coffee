#############################
#  View Mode for design/property/acl
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    ACLModel = Backbone.Model.extend {

        defaults :
            'component'    : null
            'associations' : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        init : (uid) ->

            allComp = MC.canvas_data.component
            aclObj = MC.canvas_data.component[uid]
            this.set 'component', aclObj

            that = this

            associationsAry = []
            _.each aclObj.resource.AssociationSet, (value, key) ->
                subnetInfo = that.getSubnetInfo(value)
                associationsAry.push(subnetInfo)
                null

            this.set 'associations', associationsAry

            null

        getSubnetInfo : (associationObj) ->
            subnetUID = associationObj.SubnetId
            subnetUID = subnetUID.slice(1).split('.')[0]
            subnetComp = MC.canvas_data.component[subnetUID]
            return {
                subnet_name: subnetComp.name,
                subnet_cidr: subnetComp.resource.CidrBlock
            }

        addRuleToACL : (uid, ruleObj) ->
            newEntrySet = []

            originEntrySet = MC.canvas_data.component[uid].resource.EntrySet

            currentRuleNumber = ruleObj.rule

            addToACL = true
            _.each originEntrySet, (value, key) ->
                if value.RuleNumber is currentRuleNumber
                    addToACL = false
                null

            ruleAction = ''
            if ruleObj.action
                ruleAction = 'allow'
            else
                ruleAction = 'deny'

            egress = ''
            if ruleObj.inbound
                egress = 'false'
            else
                egress = 'true'


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
                    "RuleAction": ruleAction,
                    "Egress": egress
                }

                newEntrySet = originEntrySet.concat newEntrySet

                MC.canvas_data.component[uid].resource.EntrySet = newEntrySet

                this.trigger 'REFRESH_RULE_LIST', MC.canvas_data.component[uid]

            null

        removeRuleFromACL : (uid, ruleNum, ruleEngress) ->
            currentEntrySet = MC.canvas_data.component[uid].resource.EntrySet
            newEntrySet = _.filter currentEntrySet, (ruleObj) ->
                if ruleObj.RuleNumber is ruleNum and ruleEngress is ruleObj.Egress
                    return false
                else
                    return true
            MC.canvas_data.component[uid].resource.EntrySet = newEntrySet
            null

        setACLName : (uid, aclName) ->
            MC.canvas_data.component[uid].name = aclName
            null
    }

    model = new ACLModel()

    return model