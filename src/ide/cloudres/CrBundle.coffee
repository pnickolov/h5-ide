
define [
  "constant"
  "CloudResources"
  "./CrSubCollection"
], ( constant, CloudResources )->

  DhcpCollection = CloudResources( constant.RESTYPE.DHCP, "us-east-1" )
  DhcpCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info DhcpCollection

  CertCollection = CloudResources( constant.RESTYPE.IAM, "us-east-1" )
  CertCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info CertCollection

  TopicCollection = CloudResources( constant.RESTYPE.TOPIC, "us-east-1" )
  TopicCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info TopicCollection

  SubsCollection = CloudResources( constant.RESTYPE.SUBSCRIPTION, "us-east-1" )
  SubsCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info SubsCollection

  DhcpCollection.fetch()
  CertCollection.fetch()
  TopicCollection.fetch()
  SubsCollection.fetch()

  # DhcpCollection.create({
  #   "domain-name-servers" : ["AmazonProvidedDNS"]
  #   "id" : "dopt-aabbccdd"
  # }).destroy()

  window.CloudResources = CloudResources
