#############################
#  View Mode for design/property/rtb
#############################

define [ '../base/model', 'constant', 'Design', 'CloudResources' ], ( PropertyModel, constant, Design, CloudResources ) ->

    RTBAppModel = PropertyModel.extend {

        processTarget : ( rtb )->
          console.log rtb
          rtb.routeSet.item = _.map rtb.routeSet.item, ( item ) ->
            item.target = item.instanceId || item.networkInterfaceId || item.gatewayId

            if item.target isnt "local"
              Design.instance().eachComponent ( component )->
                if component.get("appId") is item.target
                  item.target = component.get("name")
                  return
                null

            item
          null

        init : ( rtb_uid )->

          # uid might be a line connecting RTB and other resource
          rtbOrConn = Design.instance().component( rtb_uid )

          if rtbOrConn.type is constant.RESTYPE.RT #routeTable
            routeTable = rtbOrConn

          else # connection
            data = {}
            connectedTo = rtbOrConn.getOtherTarget constant.RESTYPE.RT
            routeTable = rtbOrConn.getTarget constant.RESTYPE.RT

            if connectedTo.type is constant.RESTYPE.SUBNET
              data.subnet = connectedTo.get 'name'
              has_subnet = true


            data.rtb  = routeTable.get 'name'
            rtb_uid = routeTable.id

            if has_subnet
              this.set 'association', data
              this.set 'name', 'Subnet-RT Association'
              return



          rtb  = CloudResources(constant.RESTYPE.RT, Design.instance().region()).get(routeTable.get('appId')).toJSON()

          if not rtb
            return false

          rtb = $.extend true, {}, rtb
          rtb.name = routeTable.get 'name'

          has_main = false

          if rtb.associationSet and rtb.associationSet.item

            for asso in rtb.associationSet.item

              if asso.main is true

                has_main = true

          if has_main
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
