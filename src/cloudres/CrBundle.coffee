
define [
  "CloudResources"
  "./aws/CrClnSharedRes"
  "./aws/CrClnCommonRes"
  "./aws/CrClnOpsResource"
  "./aws/CrClnAmi"
  "./aws/CrClnRds"
  "./aws/CrClnRdsParam"

  "./openstack/CrClnSharedRes"
  "./openstack/CrClnImage"
  "./openstack/CrClnExtNetwork"
], ( CloudResources )->
  ### env:dev ###
  require ["./cloudres/aws/CloudImportVpc"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["./cloudres/aws/CloudImportVpc"], ()->
  ### env:debug:end ###

  CloudResources
