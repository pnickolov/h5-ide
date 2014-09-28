
define [ "constant", "ComplexResModel", "ConnectionModel"  ], ( constant, ComplexResModel, ConnectionModel )->

  KeypairUsage = ConnectionModel.extend {
    type : "KeypairUsage"
    oneToMany : constant.RESTYPE.OSKP


    serialize : ( components )->
      kp = @getTarget( constant.RESTYPE.OSKP )

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



  KeypairModel = ComplexResModel.extend {
    type : constant.RESTYPE.OSKP

    defaults :
      fingerprint : ""
      isSet: false # true if the user have set defaultKp

    isVisual : ()-> false

    isDefault: () ->
      @get( 'name' ) is 'DefaultKP'

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
        if c.getOtherTarget( constant.RESTYPE.OSKP ) is target
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
        if a.name is "DefaultKP" then return -1
        if b.name is "DefaultKP" then return 1
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
      _.find KeypairModel.allObjects(), ( obj )-> obj.get("name") is "DefaultKP"

    setDefaultKP: ( keyName, fingerprint ) ->
      defaultKP = _.find KeypairModel.allObjects(), ( obj )-> obj.get("name") is "DefaultKP"
      defaultKP.set( 'appId', keyName or '' )
      defaultKP.set( 'fingerprint', fingerprint or '' )
      defaultKP.set( 'isSet', true )

    diffJson : ()-> # Disable diff for thie Model

    handleTypes : constant.RESTYPE.OSKP
    deserialize : ( data, layout_data, resolve )->
      new KeypairModel({
        id          : data.uid
        name        : data.name
      #appId       : if data.resource.KeyFingerprint then data.resource.KeyName else '' #no fingerprint is old data
        appId       : data.resource.KeyName
        fingerprint : data.resource.KeyFingerprint
      })
      null
  }

  KeypairModel
