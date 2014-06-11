
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  ConnectionModel.extend

    type : "Lc_Asso"

    oneToMany : constant.RESTYPE.ASG

