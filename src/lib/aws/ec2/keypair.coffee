define [ 'constant', 'MC' ], ( constant, MC ) ->

  add = ( keypair_name ) ->

    if MC.canvas_property.kp_list.hasOwnProperty keypair_name
      return false

    data      = $.extend true, {}, MC.canvas.KP_JSON.data
    data.uid  = MC.guid()
    data.name = data.resource.KeyName = keypair_name

    MC.canvas_data.component[ data.uid ] = data

    MC.canvas_property.kp_list[ keypair_name ] = data.uid

    return data.uid

  del = ( keypair_name ) ->

    kp_id = MC.canvas_property.kp_list[ keypair_name ]

    delete MC.canvas_data.component[ kp_id ]
    delete MC.canvas_property.kp_list[ keypair_name ]

  getList = ( check_uid ) ->


    res_type = constant.AWS_RESOURCE_TYPE

    using_kps = {}

    for comp_uid, comp of MC.canvas_data.component
      if comp.type isnt res_type.AWS_EC2_Instance and comp.type isnt res_type.AWS_AutoScaling_LaunchConfiguration
        continue

      using_kps[ comp.resource.KeyName ] = true

    kps = [ null ]
    for name, kp_uid of MC.canvas_property.kp_list

      kp = {
        name     : name
        using    : using_kps.hasOwnProperty "@#{kp_uid}.resource.KeyName"
        selected : kp_uid is check_uid
      }

      if name is "DefaultKP"
        kps[0] = kp
      else
        kps.push kp

    kps

  #public
  add     : add
  del     : del
  getList : getList
