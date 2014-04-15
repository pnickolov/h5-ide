define ['MC', "constant", 'lib/aws/aws'], (MC, constant, aws_handler) ->
  MC.aws = { aws: aws_handler }

  MC.aws.ami = {
    getOSType : ( ami ) ->

      #return osType by ami.name | ami.description | ami.imageLocation
      if !ami
        return 'unknown'

      if ami.osType
        return ami.osType

      osTypeList = ['centos', 'redhat', 'rhel', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensuse', 'suse','amazon', 'amzn']

      osType = 'linux-other'

      found  = []

      if  ami.platform and ami.platform == 'windows'

        found.push 'windows'

      else

        #check ami.name
        if ami.name
          found = osTypeList.filter (word) -> ~ami.name.toLowerCase().indexOf word

        #check ami.description
        if found.length == 0 and 'description' of ami and ami.description
          found = osTypeList.filter (word) -> ~ami.description.toLowerCase().indexOf word

        #check ami.imageLocation
        if found.length == 0 and 'imageLocation' of ami and ami.imageLocation
          found = osTypeList.filter (word) -> ~ami.imageLocation.toLowerCase().indexOf word

      if found.length > 0
        osType = found[0]

      switch osType
        when 'rhel' then osType = 'redhat'
        when 'amzn' then osType = 'amazon'

      osType

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
