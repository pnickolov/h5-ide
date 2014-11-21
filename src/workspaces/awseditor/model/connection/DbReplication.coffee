
define [ "constant", "ConnectionModel" ], ( constant, ConnectionModel )->

  # Represent the relationship between a master and slave for MySql Db Instance
  # Master is always the port1Comp()
  ConnectionModel.extend {
    type : "DbReplication"

    portDefs :
      port1 :
        name : "replica"
        type : constant.RESTYPE.DBINSTANCE
      port2 :
        name : "replica"
        type : constant.RESTYPE.DBINSTANCE

    master : ()-> @__port1Comp
    slave  : ()-> @__port2Comp

    isRemovable : ()-> false
  }
