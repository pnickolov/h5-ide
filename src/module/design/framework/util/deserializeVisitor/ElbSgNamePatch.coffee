
define [ "Design", "constant" ], ( Design, constant )->

  Design.registerDeserializeVisitor ( data, layout_data, version )->

    if version >= "2014-02-11" then return

    TYPE = constant.RESTYPE

    elbs = []
    sgs  = []

    for uid, comp of data
      # Collect all Elb and all Sg
      if comp.type is TYPE.ELB
        elbs.push comp
      else if comp.type is TYPE.SG
        sgs.push comp

    # Change #{elb}-sg to elbsg-#{elb}
    for elb in elbs
      sgName = elb.name + "-sg"
      for sg in sgs
        if sg.name is sgName
          sg.name = "elbsg-" + elb.name
          # Also update resource.GroupName
          if sg.resource.GroupName is sgName
            sg.resource.GroupName = sg.name
          break
    null

  null
