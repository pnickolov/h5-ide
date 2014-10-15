
define [ "ComplexResModel", "constant", "Design","i18n!/nls/lang.js" ], ( ComplexResModel, constant, Design, lang )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSVOL
    newNameTmpl : "volume"

    defaults :
      size : 1
      bootable : false

    constructor : ( attr, option )->
      if attr.owner
        owner = attr.owner
        delete attr.owner

      ComplexResModel.call this, attr, option

      @attachTo( owner )
      return

    getOwner : ()-> @connectionTargets( "OsVolumeUsage" )[0]

    attachTo : ( owner )->
      if owner
        mountPoint = @getMountPoint(owner)
        if not mountPoint then return false
        @.set("mountPoint", mountPoint)
        VolumeUsage = Design.modelClassForType( "OsVolumeUsage" )
        new VolumeUsage( @, owner )

      return


    getMountPoint : (owner)->

      image = owner.getImage()
      volumes = owner.volumes()
      if !image
        notification "warning", sprintf(lang.NOTIFY.WARN_AMI_NOT_EXIST_TRY_USE_OTHER, imageId), false  unless ami_info
        return null

      else
        console.log image
        #set deviceName
        mountPoint = null
        if image.os_distro isnt "windows"
          mountPoint = ["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        else
          mountPoint = ["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"]

        $.each volumes || [], (key, value) ->
          if value.get('mountPoint').slice(0, 5) is "/dev/"
            k = value.get('mountPoint').slice(-1)
            index = mountPoint.indexOf(k)
            mountPoint.splice index, 1  if index >= 0

        #no valid deviceName
        if mountPoint.length is 0
          notification "warning", lang.NOTIFY.WARN_ATTACH_VOLUME_REACH_INSTANCE_LIMIT, false
          return null

        if image.os_distro isnt "windows"
          mountPoint = "/dev/sd" + mountPoint[0]
        else
          mountPoint = "xvd" + mountPoint[0]

        return mountPoint

    serialize : ()->
      {
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id   : @get("appId")
            name : @get("name")

            snapshot_id : @get("snapshot")
            size        : @get("size")
            mount_point : @get("mountPoint")
            bootable    : @get("bootable")
            server_id   : @connectionTargets( "OsVolumeUsage" )[0].createRef("id")

            display_description : @get("description")
            display_name        : @get("name")
      }

  }, {

    handleTypes  : constant.RESTYPE.OSVOL

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.resource.display_name
        appId : data.resource.id

        snapshot    : data.resource.snapshot_id
        size        : data.resource.size
        mountPoint  : data.resource.mount_point
        bootable    : data.resource.bootable
        owner       : resolve( MC.extractID(data.resource.server_id) )

        description : data.resource.display_description
      })
      return
  }

  Model
