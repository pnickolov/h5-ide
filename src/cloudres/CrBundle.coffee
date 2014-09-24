
define [
  "CloudResources"
  "./CrOpsResource"

  "./aws/CrClnSharedRes"
  "./aws/CrClnCommonRes"
  "./aws/CrClnAmi"
  "./aws/CrClnRds"
  "./aws/CrClnRdsParam"

  "./openstack/CrClnSharedRes"
  "./openstack/CrClnImage"
  "./openstack/CrClnNetwork"
  "./openstack/CrClnCommonRes"
], ( CloudResources )->
  ### env:dev ###
  require ["./cloudres/aws/CloudImportVpc"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["./cloudres/aws/CloudImportVpc"], ()->
  ### env:debug:end ###

  CloudResources
