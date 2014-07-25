#############################
#  View(UI logic) for component/sgrule
#############################

define [ './template', 'i18n!/nls/lang.js', "UI.modalplus", "constant", "Design" ], ( template, lang, Modal, constant, Design ) ->

  Backbone.View.extend {

    events :
      "click .dbsgppp-subnet" : "updateSelected"

    initialize : () ->
      self = @

      design  = @model.design()
      subnets = []

      for subnet in design.componentsOfType( constant.RESTYPE.SUBNET )
        subnets.push {
          az   : subnet.parent().get("name")
          id   : subnet.id
          name : subnet.get("name")
          cidr : subnet.get("cidr")
          idx  : subnets.length
        }

      modal = new Modal({
        title        : "Select Subnet for Subnet Group"
        template     : template( _.groupBy(subnets, "az") )
        confirm      : { text : "Save" }
        disableClose : true
        onCancel     : ()-> self.cancel()
        onConfirm : ()->
          self.apply()
          modal.close()
      })

      @setElement modal.tpl
      @updateSelected()
      return

    updateSelected : ()->
      btn = @$el.closest(".modal-box").find(".modal-confirm")

      if @$el.find(".dbsgppp-subnet:checked").length > 1
        btn.removeAttr("disabled")
      else
        btn.attr("disabled", "disabled")

      return

    cancel : ()->
      if @model.connectionTargets("SubnetgAsso").length is 0
        @model.remove()
      return

    apply : ()->
      subnets = {}
      for cb in @$el.find(".dbsgppp-subnet:checked")
        subnets[ $(cb).attr("data-id") ] = true

      existSb = {}
      for sbAsso in @model.connections("SubnetgAsso")
        id = sbAsso.getTarget( constant.RESTYPE.SUBNET ).id
        if not subnets[ id ]
          sbAsso.remove()
        else
          existSb[ id ] = true

      SubnetGAsso = Design.modelClassForType( "SubnetgAsso" )
      design = @model.design()
      for sb, value of subnets
        if not existSb[ sb ]
          new SubnetGAsso( @model, design.component( sb ) )
      return

  }
