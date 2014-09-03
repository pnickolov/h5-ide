define [
  "Design"
  "constant"
  'CloudResources'
], ( Design, constant, CloudResources ) ->

  AwsDesign = Design.extend {
    serialize : ( options )->
      json = Design.prototype.serialize.apply this, arguments
      json.property.stoppable = @isStoppable()
      json

    preserveName : ()->
      if not @modeIsAppEdit() then return
      @__preservedNames = {}
      for uid, comp of @__componentMap
        switch comp.type
          when constant.RESTYPE.ELB, constant.RESTYPE.ASG, constant.RESTYPE.LC, constant.RESTYPE.DBINSTANCE
            names = @__preservedNames[ comp.type ] || ( @__preservedNames[ comp.type ] = {} )
            names[ comp.get("name") ] = true

      return

    isStoppable : ()->
      # Previous version will set canvas_data.property.stoppable to false
      # If the stack contains instance-stor ami.
      InstanceModel = Design.modelClassForType( constant.RESTYPE.INSTANCE )
      LcModel = Design.modelClassForType( constant.RESTYPE.LC )
      allObjects = InstanceModel.allObjects( @ ).concat LcModel.allObjects( @ )
      for comp in allObjects
        ami = comp.getAmi() or comp.get("cachedAmi")
        if ami and ami.rootDeviceType is 'instance-store'
          return false

      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).allObjects( @ )
      if vpc.length>0
        vpcId = vpc[0].get("appId")
        instanceAry = CloudResources( constant.RESTYPE.INSTANCE, @region() ).filter ( m ) -> m.get("vpcId") is vpcId
        for ins in instanceAry
          ins = ins.attributes
          for bdm in (ins.blockDeviceMapping || [])
            if bdm.ebs is null and bdm.VirtualName
              #blockDevice is instance-store
              return false
      true
    instancesNoUserData : ()->
      result = true
      instanceModels = Design.modelClassForType(constant.RESTYPE.INSTANCE).allObjects()
      _.each instanceModels , (instanceModel)->
        result = if  instanceModel.get('userData') then false else true
        null
      lcModels = Design.modelClassForType( constant.RESTYPE.LC ).allObjects()
      _.each lcModels , (lcModel)->
        result = if lcModel.get('userData') then false else true
        null
      return result

    getCost : (stopped)->
      costList = []
      totalFee = 0

      priceMap = App.model.getPriceData( @region() )

      if priceMap
        currency = priceMap.currency || 'USD'

        for uid, comp of @__componentMap
          if stopped and not (comp.type in [constant.RESTYPE.EIP, constant.RESTYPE.VOL, constant.RESTYPE.ELB, constant.RESTYPE.CW])
            continue
          if comp.getCost
            cost = comp.getCost( priceMap, currency )
            if not cost then continue

            if cost.length
              for c in cost
                totalFee += c.fee
                costList.push c
            else
              totalFee += cost.fee
              costList.push cost

        costList = _.sortBy costList, "resource"

      { costList : costList, totalFee : Math.round(totalFee * 100) / 100 }
  }

  AwsDesign
