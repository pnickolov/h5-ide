
define [ "constant", "../ConnectionModel", "CanvasManager", "Design" ], ( constant, ConnectionModel, CanvasManager, Design )->

  # SgAsso is used to represent that one Resource is using on SecurityGroup
  SgAsso = ConnectionModel.extend {
    type : "SgAsso"

    # SgAsso doesn't have portDefs, so the basic validation implemented in ConnectionModel won't work.
    # Here, we do our own job.
    assignCompsToPorts : (p1Comp, p2Comp)->
      if p1Comp.type is constant.RESTYPE.SG
        @__port1Comp = p1Comp
        @__port2Comp = p2Comp
      else if p2Comp.type is constant.RESTYPE.SG
        @__port1Comp = p2Comp
        @__port2Comp = p1Comp
      else
        return false

      true

    isVisual : ()-> true

    remove : ()->
      ConnectionModel.prototype.remove.apply this, arguments

      # When an SgAsso is removed because of an SecurityGroup is removed.
      # If this SgAsso is the last SgAsso of some resources, attach DefaultSg to these resources.
      resource = @getOtherTarget( constant.RESTYPE.SG )
      if resource.isRemoved() # and resource.type is 'ExpandedAsg'
        return

      # When A is removed, and A delete an Sg ( SgA ) while removing,
      # and if B only connects to SgA.
      # Then B will be detached from SgA and then connects to DefaultSG
      # If this behaviour results in creating an SgLine between A & B.
      # Then the SgLine is actually connecting to an removing resource : A.
      # Currently the ComplexResModel can hanlde : after SgLine is created, A continues
      # to disconnect its connection, thus the newly created SgLine will be removed.
      # But this is a flaw of design of Connection, because I think it makes
      # ComplexResModel/ConnectionModel and its subclass strong coupling.
      # Maybe we could work out a better solution about this later.

      resource = @getOtherTarget( constant.RESTYPE.SG )
      if resource.connections("SgAsso").length == 0
        defaultSg = Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg()
        if defaultSg
          new SgAsso( resource, defaultSg )
      null

    sortedSgList : ()->

      resource = @getOtherTarget( constant.RESTYPE.SG )

      sgAssos = resource.connections("SgAsso")

      # Sort the SG
      sgs = _.map sgAssos, ( a )->
        a.getTarget( constant.RESTYPE.SG )

      sgs.sort ( a_sg, b_sg )->
        if a_sg.isDefault() then return -1
        if b_sg.isDefault() then return 1

        a_nm = a_sg.get("name")
        b_nm = b_sg.get("name")

        if a_nm <  b_nm then return -1
        if a_nm == b_nm then return 0
        if a_nm >  b_nm then return 1
  }

  SgAsso


