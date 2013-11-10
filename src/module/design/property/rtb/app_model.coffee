#############################
#  View Mode for design/property/rtb
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    RTBAppModel = PropertyModel.extend {

        init : ( rtb_uid )->

          # uid might be a line connecting RTB and other resource
          connection = MC.canvas_data.layout.connection[ rtb_uid ]
          if connection
              data = {}
              for uid, value of connection.target
                  component = MC.canvas_data.component[ uid ]
                  if component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
                      data.subnet = component.name
                      has_subnet = true
                  else if component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
                      data.rtb  = component.name
                      rtb_uid = uid

              if has_subnet
                  this.set 'association', data
                  this.set 'name', 'Subnet-RT Association'
                  return

          components = MC.canvas_data.component

          myRTBComponent = components[ rtb_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          rtb = $.extend true, {}, appData[ myRTBComponent.resource.RouteTableId ]
          rtb.name = myRTBComponent.name

          if rtb.associationSet and rtb.associationSet.item and rtb.associationSet.item[0] and rtb.associationSet.item[0].main == "true"
            rtb.main = "Yes"
          else
            rtb.main = "No"

          for i in rtb.routeSet.item
            if i.state == "active"
              i.active = true

          propagate = {}

          # Find out which route is propagated.
          if rtb.propagatingVgwSet and rtb.propagatingVgwSet.item
            for i in rtb.propagatingVgwSet.item
              propagate[ i.gatewayId ] = true

          for value, key in rtb.routeSet.item
            if propagate[ value.gatewayId ]
              value.propagate = true

          this.set rtb
    }

    new RTBAppModel()
