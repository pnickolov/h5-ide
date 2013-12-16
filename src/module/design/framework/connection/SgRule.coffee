
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  # SgRuleConnection is used to represent the connection between two SecurityGroup or Sg and Ip
  SgRule = ConnectionModel.extend {

    type : "SgRule"

    default :
      direction : ""
      fromPort  : "0"
      toPort    : "65535"
      protocol  : "-1"

    setDirection : ( direction )->
      console.assert( direction is SgRule.DIRECTION.BIWAY or direction is SgRule.DIRECTION.IN or direction is SgRule.DIRECTION.OUT, "Invalid direction for sgrule")

      @set "direction", direction
      null

    addDirection : ( direction )->
      console.assert( direction is SgRule.DIRECTION.BIWAY or direction is SgRule.DIRECTION.IN or direction is SgRule.DIRECTION.OUT, "Invalid direction for sgrule")

      current_dir = @get("direction")
      # The direction is the same
      if current_dir is direction then return

      if current_dir is ""
        @set "direction", direction
      else
        @set "direction", SgRule.DIRECTION.BIWAY
      null
  }

  SgRule.DIRECTION = {
    BIWAY : "biway"
    IN    : "in"
    OUT   : "out"
  }

  SgRule


