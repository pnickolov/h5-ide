#############################
#  View Mode for design/property/stack
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'constant' ], (Backbone, $, _, ide_event, MC, constant) ->

    StackModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null
            'stack_detail'  : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getStack : ->
            me = this

            stack_detail = {}
            stack_detail.name = MC.canvas_data.name
            stack_detail.region = constant.REGION_LABEL[MC.canvas_data.region]
            stack_detail.type = me.getStackType
            stack_detail.isVPC = true if stack_detail.type and stack_detail.type != 'ec2-classic'
            stack_detail.sg = me.getSecurityGroup
            if stack_detail.isVPC
                stack_detail.acl = me.getNetworkACL

            stack_detail.cost = me.getStackCost

            me.set 'stack_detail', stack_detail

        getStackType : ->
            type = MC.canvas_data.platform

            if type == 'ec2-classic'
                return 'EC2 Classic'
            else if type == 'ec2-vpc'
                return 'EC2 VPC'
            else if type == 'default-vpc|custom-vpc'
                return 'Default VPC'
            else if type == 'custom-vpc'
                return 'Custom VPC'

        getSecurityGroup : ->
            sg_list = []
            _.map MC.canvas_property.sg_list, ( sg ) ->
                uid = sg.uid
                desc = MC.canvas_data.component[uid].resource.GroupDescription
                sg_list.push { 'uid' : sg.uid, 'name' : sg.name, 'description' : desc,  'rule_count' : sg.rules.length, 'member_count' : sg.member.length }
            
            sg_list

        deleteSecurityGroup : (uid) ->
            #delete

        getNetworkACL : ->

        getStackCost : ->

    }

    model = new StackModel()

    return model