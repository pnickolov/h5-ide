
define [
  "Credential"
  "ApiRequest"
  "UI.modalplus"
  "./VisualizeTpl"
  "i18n!/nls/lang.js"
  "constant"
  "backbone"
], ( Credential, ApiRequest, Modal, VisualizeTpl, lang, constant )->

  VisualizeVpcParams =
    'AWS.VPC.VPC'    : {}
    'AWS.VPC.Subnet' : {}
    'AWS.EC2.Instance' : {
      'filter' : {
        'instance-state-name' : [ 'pending', 'running', 'stopping', 'stopped' ] # filter terminating and terminated instances
      }
    }
    'AWS.VPC.NetworkInterface' : {}
    'AWS.ELB'                  : {}


  Backbone.View.extend {

    events :
      "click #VisualizeReload"   : "sendRequest"
      "click .visualize-vpc-btn" : "importVpc"

    initialize : (attr)->
      @model = attr.model
      @dialog = attr.dialog
      @dialog ||= new Modal {
        title         : lang.IDE.DASH_IMPORT_VPC_AS_APP
      }

      @dialog.setTitle(lang.IDE.DASH_IMPORT_VPC_AS_APP)
      .setWidth(770)
      .setContent(VisualizeTpl.frame())
      .toggleFooter()
      .compact()
      .resize()

      self = @
      @dialog.on "close", -> self.remove()

      @setElement @dialog.tpl.find("#VisualizeVpcDialog")

      @sendRequest()

      @listenTo App.WS, "visualizeUpdate", @onReceiveData
      return

    render : ()->
      if @fail
        @$el.html VisualizeTpl.failure()
      else if @data
        @$el.html VisualizeTpl.content( @data )
      else
        @$el.html VisualizeTpl.loading()

    remove : ()->
      @stopListening()

      if @timeout
        clearTimeout( @timeout )
        @timeout = null
      return

    sendRequest : ()->
      self = @

      if @timeout then clearTimeout @timeout

      @timeout = setTimeout (()-> self.failToLoad()), 480000

      ApiRequest("aws_resource", {
        region_name : null
        key_id      : @model.credIdOfProvider( Credential.PROVIDER.AWSGLOBAL )
        resources   : VisualizeVpcParams
        addition    : "statistic"
        retry_times : 1
      }).fail ()-> self.failToLoad()

      @fail  = false
      @data  = null
      @render()
      return

    failToLoad : ()->
      @fail  = true
      @data  = null
      @render()

      if @timeout
        clearTimeout( @timeout )
        @timeout = null
      return

    onReceiveData : ( result )->
      @fail = false
      if @timeout
        clearTimeout( @timeout )
        @timeout = null

      @data = @parseVisData( result )
      @render()
      return

    parseVisData : ( data ) ->

      resourceMap = ( res )-> _.keys(res||{})
      instanceMap = ( res, stopped )->
        instances = []
        for id, ami of (res||{})
          state = ami.instanceState?.name || ""
          if stopped
            if state is "stopped" or state is "stopping"
              instances.push id
          else
            if state is "running" or state is "pending"
              instances.push id
        instances

      regions = []
      for region, vpcMap of data

        if region is "_id" or region is "username" or region is "timestamp"
          continue

        vpcs = []
        regions.push {
          id      : region
          name    : constant.REGION_SHORT_LABEL[ region ]
          subname : constant.REGION_LABEL[ region ]
          vpcs    : vpcs
        }
        for vpc, resources of vpcMap
          try
          # Ingore app that is created by us.
            tags = {}
            if resources.Tag and resources.Tag.item
              if resources.Tag.item.length
                for t in resources.Tag.item
                  tags[ t.key ] = t.value
              else
                tags[ resources.Tag.item.key ] = resources.Tag.item.value

            obj =
              id      : vpc
              name    : tags.Name || tags.name
              subnet  : resourceMap resources["AWS|VPC|Subnet"]
              ami     : instanceMap resources["AWS|EC2|Instance"]
              stopped : instanceMap resources["AWS|EC2|Instance"], true
              eni     : resourceMap resources["AWS|VPC|NetworkInterface"]
              eip     : resourceMap resources["AWS|EC2|EIP"]
              elb     : resourceMap resources["AWS|ELB"]
              imported: !!resources.project_id

            vpcs.push obj
          catch e

      regions

    importVpc : ( event )->
      if $(event.currentTarget).hasClass('disabled') then return false
      $tgt = $(event.currentTarget)
      if $tgt.hasClass(".disabled") then return false

      opsmodel = @model.createAppByExistingResource( $tgt.attr("data-vpcid"), $tgt.closest("ul").attr("data-region"), Credential.PROVIDER.AWSGLOBAL )

      @dialog.close()

      App.loadUrl opsmodel.url()
      false
  }
