
define [
  "../CrCollection"
  "CloudResources"
  "ApiRequestOs"
  "constant"
  "./CrModelKeypair"
], ( CrCollection, CloudResources, ApiRequest, constant, CrModelKeypair )->


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
 
