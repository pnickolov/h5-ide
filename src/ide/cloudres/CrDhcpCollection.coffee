
define [ "./CrCollection", "./CrDhcpModel", "ApiRequest", "constant" ], ( CrCollection, CrDhcpModel, ApiRequest, constant )->

  CrCollection.extend {
    type  : constant.RESTYPE.DHCP
    model : CrDhcpModel

    doFetch : ()-> ApiRequest("dhcp_DescribeDhcpOptions", {region_name : @category})
    parseFetchData : (res)->
      res = res.DescribeDhcpOptionsResponse.dhcpOptionsSet.item

      for i in res
        i.id = i.dhcpOptionsId
        delete i.dhcpOptionsId

      res

  }
