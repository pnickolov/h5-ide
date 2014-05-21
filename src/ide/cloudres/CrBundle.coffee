
define [
  "constant"
  "CloudResources"
  "./CrDhcpCollection"
  "./CrSslcertCollection"
], ( constant, CloudResources )->

  # SnsCollection = CloudResources( constant.RESTYPE.SUBSCRIPTION, "us-east-1" )

  # console.info SnsCollection
  # console.assert SnsCollection is  CloudResources( constant.RESTYPE.SUBSCRIPTION )

  DhcpCollection = CloudResources( constant.RESTYPE.DHCP, "us-east-1" )

  DhcpCollection.fetch()
  DhcpCollection.fetch()
  DhcpCollection.fetch()
  DhcpCollection.fetch()

  DhcpCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info DhcpCollection

  # DhcpCollection.create({
  #   "domain-name-servers" : ["AmazonProvidedDNS"]
  #   "id" : "dopt-aabbccdd"
  # }).destroy()

  window.CloudResources = CloudResources
