
define [
  "CloudResources"
  "./CrClnSharedRes"
  "./CrClnCommonRes"
  "./CrClnOpsResource"
  "./CrClnAmi"
  "./CrClnRds"
  "./CrClnRdsParam"
], ( CloudResources )->
  ### env:dev ###
  require ["./cloudres/CloudImportVpc"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["./cloudres/CloudImportVpc"], ()->
  ### env:debug:end ###

  CloudResources
