
define [ "../DesignOs"], ( Design )->

  Design.registerDeserializeVisitor ( data, layout_data, version )->

    data.ExternalNetwork =
      type : "OS::ExternalNetwork"
      uid  : "ExternalNetwork"

  null
