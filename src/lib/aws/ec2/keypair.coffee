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

    kp_list = Design.modelClassForType("AWS.EC2.KeyPair").allObjects()

    kps = []
    for idx, kp of kp_list

      using_kps[ kp.attributes.id ] = true
      name = kp.attributes.name
      kp_uid = kp.attributes.id

      kp_item = {
        name     : name
        using    : using_kps.hasOwnProperty kp_uid
        selected : kp_uid is check_uid
      }

      if name is "DefaultKP"
        kps[0] = kp_item
      else
        kps.push kp_item

    kps

  #public
  add     : add
  del     : del
  getList : getList
