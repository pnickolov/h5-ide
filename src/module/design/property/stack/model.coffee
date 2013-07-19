#############################
#  View Mode for design/property/stack
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'constant' ], (Backbone, $, _, MC, constant) ->

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

            stack_detail = $.extend true, {}, MC.canvas_data
            stack_detail.name = MC.canvas_data.name
            stack_detail.region = constant.REGION_LABEL[MC.canvas_data.region]
            stack_detail.type = me.getStackType()
            stack_detail.is_vpc = true if stack_detail.type and stack_detail.type != 'EC2 Classic'
            stack_detail.sg_list = me.getSecurityGroup()
            if stack_detail.is_vpc
                stack_detail.acl_list = me.getNetworkACL()

            stack_detail.cost = me.getStackCost()

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
                desc = MC.canvas_data.component[sg.uid].resource.GroupDescription
                member_count = if 'member' of sg then sg.member.length else 0
                is_del = if member_count == 0 and MC.canvas_property.sg_list.length > 1 then true else false
                rule_count = if 'rules' of sg then sg.rules.length else 0
                sg_list.push { 'uid' : sg.uid, 'name' : sg.name, 'description' : desc, 'member_count' : member_count, 'rule_count' : rule_count, 'is_del' : is_del }
            
            sg_list

        deleteSecurityGroup : (uid) ->
            #delete sg from MC.canvas_property.sg_list
            _.map MC.canvas_property.sg_list, (sg) ->
                if sg.uid == uid
                    index = MC.canvas_property.sg_list.indexOf(sg)
                    MC.canvas_property.sg_list.splice(index, 1)
            #update instance

        getNetworkACL : ->

        getStackCost : ->


    }

    model = new StackModel()

    return model