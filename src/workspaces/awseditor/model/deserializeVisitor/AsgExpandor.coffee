
define [ "../DesignAws"], ( Design )->

  Design.registerDeserializeVisitor ( data, layout_data, version )->

    if version < "2014-01-25" then return

    for uid, comp of layout_data
      # Generate Component for expanded Asg
      if comp.type is "ExpandedAsg"
        data[ uid ] = {
          type : "ExpandedAsg"
          uid  : uid
        }

  null
