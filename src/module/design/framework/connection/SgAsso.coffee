
define [ "constant", "../ConnectionModel", "../CanvasManager" ], ( constant, ConnectionModel, CanvasManager )->

  # SgAsso is used to represent that one Resource is using on SecurityGroup
  SgAsso = ConnectionModel.extend {
    type : "SgAsso"

    initialize : ()->
      # Listen to myself's remove event, so that we can update the target's element
      @on "remove", @onRemove, @
      null

    onRemove : ()->

      @set "removing", true
      # Update target's label
      @draw()
      @set "removing", false

      # Update target's line
      null

    sortedSgList : ()->

      resource = @getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )

      sgAssos = resource.connections("SgAsso")

      if not @get "removing"
        # When the connection is created, draw() is called before resource.connect()
        # So sgAssos might not have this SgAsso inside.
        if sgAssos.indexOf( this ) is -1
          sgAssos.push this

      # Sort the SG
      sgs = _.map sgAssos, ( a )->
        a.getTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )

      sgs.sort ( a_sg, b_sg )->
        if a_sg.get("isDefault") then return -1
        if b_sg.get("isDefault") then return 1

        a_nm = a_sg.get("name")
        b_nm = b_sg.get("name")

        if a_nm <  b_nm then return -1
        if a_nm == b_nm then return 0
        if a_nm >  b_nm then return 1


    # Drawing method, drawing method is used to update resource label
    draw : ()->
      resource = @getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
      res_node = document.getElementById( resource.id )

      if not res_node then return

      sgs = @sortedSgList()

      # Update label
      for ch, idx in $(res_node).children(".node-sg-color-group").children()
        if idx < sgs.length
          CanvasManager.update( ch, sgs[idx].color, "color" )
          CanvasManager.addClass( ch, "tooltip")
        else
          CanvasManager.update( ch, "none", "color" )
          CanvasManager.removeClass( ch, "tooltip" )

      null
  }

  SgAsso


