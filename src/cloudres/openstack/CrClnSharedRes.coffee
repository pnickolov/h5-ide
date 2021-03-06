
define [
  "../CrCollection"
  "CloudResources"
  "ApiRequestOs"
  "constant"
  "./CrModelKeypair"
  "./CrModelSnapshot"
], ( CrCollection, CloudResources, ApiRequest, constant, CrModelKeypair, CrModelSnapshot )->


  ### Keypair ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsKeypairCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSKP
    model : CrModelKeypair

    doFetch : ()-> ApiRequest("os_keypair_List", {region : @region()})
    parseFetchData : (res)->
      data = res?.keypairs || []
      rlt  = []
      for i in data || []
        i = i.keypair
        if i
          i.id = i.name
          rlt.push i
        null
      rlt

  }

  ### Snapshot ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsSnapshotCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSSNAP
    model : CrModelSnapshot

    doFetch : ()-> ApiRequest("os_snapshot_List", {region : @region()})
    parseFetchData : (res)->
      res?.snapshots || []

  }
