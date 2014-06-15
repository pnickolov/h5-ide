#############################
#  View Mode for design/property/eni
#############################

define [ '../base/model', 'Design', 'constant', "CloudResources" ], ( PropertyModel, Design, constant, CloudResources ) ->

    EniAppModel = PropertyModel.extend {

        init : ( uid )->

          group          = []
          myEniComponent = Design.instance().component( uid )

          if not myEniComponent
            allEni = Design.modelClassForType( 'AWS.VPC.NetworkInterface' ).allObjects()

            for e in allEni
              if e.get( 'appId' ) is uid
                myEniComponent = e
                myEniComponentJSON = e?.toJSON()
                break
              else
                for mIndex, m of e.groupMembers()
                  if m.appId is uid
                    memberIndex = +mIndex + 1
                    myEniComponent = e
                    myEniComponentJSON = m
                    break

          else
            myEniComponentJSON = myEniComponent?.toJSON()

          appData = CloudResources(constant.RESTYPE.ENI,Design.instance().region()).get(eni_comp.appId)?.toJSON()

          if @isGroupMode
            group = [ myEniComponentJSON ].concat myEniComponent.groupMembers()

          else
            group.push myEniComponentJSON




          formated_group = []

          for index, eni_comp of group

            if appData
              eni = $.extend true, {}, appData
            else
              eni = { privateIpAddressesSet : { item : [] } }

            for i in eni.privateIpAddressesSet.item
              i.primary = i.primary is true

            eni.id              = eni_comp.appId
            eni.name            = if eni_comp.name then "#{eni_comp.name}-0" else "#{myEniComponent.get 'name'}-#{memberIndex or index}"
            eni.idx             = memberIndex or index
            eni.sourceDestCheck = if eni.sourceDestCheck then 'enabled' else 'disabled'

            formated_group.push eni


          if @isGroupMode

            @set 'group',       _.sortBy formated_group, 'idx'
            @set 'readOnly',    true
            @set 'isGroupMode', true
            @set 'name',        myEniComponent.get 'name'
          else
            eni = formated_group[0]

            eni.readOnly    = true
            eni.isGroupMode = false
            eni.id          = uid
            eni.uid         = if myEniComponent then myEniComponent.id else uid
            @set eni


          null

    }

    new EniAppModel()
