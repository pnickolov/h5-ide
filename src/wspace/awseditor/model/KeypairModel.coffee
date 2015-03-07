
define [ "constant", "ComplexResModel", "ConnectionModel", "Design"  ], ( constant, ComplexResModel, ConnectionModel, Design )->

  KeypairUsage = ConnectionModel.extend {
    type : "KeypairUsage"
    oneToMany : constant.RESTYPE.KP


    serialize : ( components )->
      kp = @getTarget( constant.RESTYPE.KP )

      if kp
        otherTarget = @getOtherTarget( kp )
        otherTargetComp = components[ otherTarget.id ]

        if not otherTargetComp then return

        ref = kp.createRef( "KeyName" )

        otherTargetComp.resource.KeyName = ref

        groupMembers = if otherTarget.groupMembers then otherTarget.groupMembers() else []

        for member in groupMembers
          if components[ member.id ] then components[ member.id ].resource.KeyName = ref


      null

  }


  DefaultKpName = 'DefaultKP'

  KeypairModel = ComplexResModel.extend {
    type : constant.RESTYPE.KP

    defaults :
      fingerprint : ""
      isSet: false # true if the user have set defaultKp

    isVisual : ()-> false

    isDefault: () ->
      @get( 'name' ) is DefaultKpName

    remove : ()->
      # When a keypair is removed, make all usage to be DefaultKP
      defaultKp = KeypairModel.getDefaultKP()

      for i in @connectionTargets("KeypairUsage")
        new KeypairUsage( defaultKp, i )

      ComplexResModel.prototype.remove.call this
      null

    assignTo : ( target )-> new KeypairUsage( this, target )

    dissociate: ( target ) ->
      conns = @connections()
      _.each conns, (c) ->
        if c.getOtherTarget( constant.RESTYPE.KP ) is target
          c.remove()

    isSet: ->
      @get( 'appId' ) and @get( 'fingerprint' )


    getKPList : ()->
      kps = []
      for kp in KeypairModel.allObjects()
        kps.push {
          id       : kp.id
          name     : kp.get("name")
          selected : kp is this
          using    : kp.connections("KeypairUsage").length > 1
        }

      _.sortBy kps, ( a, b )->
        if a.name is DefaultKpName then return -1
        if b.name is "DefaultKpName" then return 1
        if a.name > b.name then return 1
        if a.name is b.name then return 0
        if a.name < b.name then return -1


    serialize : ()->
      {
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            KeyFingerprint : @get("fingerprint") or ''
            KeyName        : @get("appId")
      }

  }, {
    getDefaultKP : ()->
      allKp = KeypairModel.allObjects()
      defaultKp = _.find allKp, ( obj )-> obj.get("name") is DefaultKpName
      defaultKp

    setDefaultKP: ( keyName, fingerprint ) ->
      defaultKP = @getDefaultKP()
      defaultKP.set( 'appId', keyName or '' )
      defaultKP.set( 'fingerprint', fingerprint or '' )
      defaultKP.set( 'isSet', true )

    ensureDefaultKp: () ->
      @getDefaultKP() or new KeypairModel( { 'name': DefaultKpName } )

    handleTypes : constant.RESTYPE.KP

    deserialize : ( data, layout_data, resolve )->
      # Keypair component isnt Default is no need yet.
      # Drop old useless keypair component.
      if data.name isnt DefaultKpName then return

      new KeypairModel({
        id          : data.uid
        name        : data.name
        appId       : data.resource.KeyName
        fingerprint : data.resource.KeyFingerprint
      })
      null
  }

  Design.on Design.EVENT.Deserialized, KeypairModel.ensureDefaultKp

  KeypairModel
