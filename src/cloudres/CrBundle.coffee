
define [
  "CloudResources"
  "./aws/CrClnSharedRes"
  "./aws/CrClnCommonRes"
  "./aws/CrClnOpsResource"
  "./aws/CrClnAmi"
  "./aws/CrClnRds"
  "./aws/CrClnRdsParam"
], ( CloudResources )->
  ### env:dev ###
  require ["./cloudres/aws/CloudImportVpc"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["./cloudres/aws/CloudImportVpc"], ()->
  ### env:debug:end ###

  CloudResources
