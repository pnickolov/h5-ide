
define [ "../DesignOs", "constant" ], ( Design, constant )->

  Design.registerDeserializeVisitor ( data, layout_data, version )->

    data.ExternalNetwork =
      type : constant.RESTYPE.OSEXTNET
      uid  : "ExternalNetwork"

  null
