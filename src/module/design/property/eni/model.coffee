#############################
#  View Mode for design/property/eni
#############################

define [ 'constant','backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    ENIModel = Backbone.Model.extend {

        defaults :
            'sg_display'     : null
            'eni_display'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getENIDisplay : ( uid ) ->

            me = this

            eni_component = $.extend true, {}, MC.canvas_data.component[uid]

            if eni_component.resource.SourceDestCheck == 'true' or eni_component.resource.SourceDestCheck == true then eni_component.resource.SourceDestCheck = true else eni_component.resource.SourceDestCheck = false

            me.set 'eni_display', eni_component

            eni_sg = {}

            eni_sg.detail = []

            eni_sg.all_sg = []

            eni_sg.rules_detail_ingress = []

            eni_sg.rules_detail_egress = []

            sg_ids = (g.GroupId for g in MC.canvas_data.component[ uid ].resource.GroupSet)

            sg_id_no_ref = []

            _.map sg_ids, ( sg_id ) ->

                sg_uid = (sg_id.split ".")[0][1...]

                sg_id_no_ref.push sg_uid

                _.map MC.canvas_property.sg_list, ( value, key ) ->

                    if value.uid == sg_uid

                        sg_detail = {}

                        sg_detail.uid = sg_uid

                        sg_detail.parent = uid

                        sg_detail.members = value.member.length

                        sg_detail.rules = MC.canvas_data.component[sg_uid].resource.IpPermissions.length + MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress.length

                        sg_detail.name = MC.canvas_data.component[sg_uid].resource.GroupName
                        
                        sg_detail.desc = MC.canvas_data.component[sg_uid].resource.GroupDescription

                        eni_sg.rules_detail_ingress = eni_sg.rules_detail_ingress.concat MC.canvas_data.component[sg_uid].resource.IpPermissions

                        eni_sg.rules_detail_egress = eni_sg.rules_detail_egress.concat MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress

                        eni_sg.detail.push sg_detail

            _.map MC.canvas_property.sg_list, (sg) ->
                
                if sg.uid not in sg_id_no_ref

                    tmp = {}

                    tmp.name = sg.name

                    tmp.uid = sg.uid

                    eni_sg.all_sg.push tmp

            eni_sg.total = eni_sg.detail.length

            array_unique = ( origin_ary )->

                if origin_ary.length == 0

                    return []

                ary = origin_ary.slice 0


                $.each ary, (idx, value)->

                    ary[idx] = JSON.stringify value

                    null

                ary.sort()

                tmp = [ary[0]]

                _.map ary, ( val, i ) ->

                    if val != tmp[tmp.length - 1]

                        tmp.push(val)
                

                
                return (JSON.parse node for node in tmp)


            eni_sg.rules_detail_ingress = array_unique eni_sg.rules_detail_ingress
            eni_sg.rules_detail_egress = array_unique eni_sg.rules_detail_egress

            me.set 'sg_display', eni_sg

        setEniDesc : ( uid , value ) ->

            MC.canvas_data.component[uid].resource.Description = value

            null

        setSourceDestCheck : ( uid, value ) ->

            MC.canvas_data.component[uid].resource.SourceDestCheck = value

            null
    }

    model = new ENIModel()

    return model