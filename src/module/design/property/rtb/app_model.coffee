#############################
#  View Mode for design/property/rtb
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    RTBAppModel = PropertyModel.extend {

        targetMap :
          gatewayId: [ 'InternetGatewayId', 'VpnGatewayId' ]
          instanceId: [ 'InstanceId' ]

        processTarget : ( rtb )->
          console.log rtb
          rtb.routeSet.item = _.map rtb.routeSet.item, ( item ) =>
            if item.gatewayId is 'local'
              item.target = item.gatewayId
            else
              for mapKey, map of @targetMap
                if item[ mapKey ]
                  item.target = @findComonentNameByAWSId( item[ mapKey ], map )
                  break
            item
          null

        findComonentNameByAWSId: ( awsId, awsIdKey )->
          for id, component of MC.canvas_data.component
            for key in awsIdKey
              if component.resource and component.resource[ key ] is awsId
                return component.name


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
          rtb     = appData[ myRTBComponent.resource.RouteTableId ]

          if not rtb
            return false

          rtb = $.extend true, {}, rtb
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

          @processTarget(rtb)

          this.set rtb

    }

    new RTBAppModel()
