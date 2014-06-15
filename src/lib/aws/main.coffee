define ['MC', "constant", 'lib/aws/aws'], (MC, constant, aws_handler) ->
  MC.aws = { aws: aws_handler }

  MC.aws.ami = {
    getInstanceType : ( ami ) ->

      if not ami then return []

      try
        region = MC.canvas_data.region
        instance_type = MC.data.instance_type[region]
        region_instance_type = MC.data.region_instance_type
        current_region_instance_type = null

        if region_instance_type
          current_region_instance_type = region_instance_type[region]

        currentTypeData = instance_type

        if current_region_instance_type and ami.osFamily
          currentTypeData = current_region_instance_type

        if !currentTypeData
          return []

        if current_region_instance_type
          key = ami.osFamily
          if not key
            osType = ami.osType
            key = constant.OS_TYPE_MAPPING[osType]

          currentTypeData = currentTypeData[key]
        else
          if ami.osType == 'windows'
            currentTypeData = currentTypeData.windows
          else
            currentTypeData = currentTypeData.linux

        if ami.rootDeviceType == 'ebs'
          currentTypeData = currentTypeData.ebs
        else
          currentTypeData = currentTypeData['instance store']
        if ami.architecture == 'x86_64'
          currentTypeData = currentTypeData["64"]
        else
          currentTypeData = currentTypeData["32"]

        # According to property/instance/model, if ami.virtualizationType is undefined.
        # It defaults to "paravirtual"
        currentTypeData = currentTypeData[ami.virtualizationType || "paravirtual"]
      catch err
        currentTypeData = []

      if not currentTypeData or currentTypeData.length <= 0
        currentTypeData = MC.data.config[region].region_instance_type

      if not currentTypeData
        currentTypeData = []

      return currentTypeData
  }

  MC.aws
