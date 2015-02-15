
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
  CloudResources
