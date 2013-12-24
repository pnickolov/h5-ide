#############################
#  View(UI logic) for component/sgrule
#############################

define [ 'text!./template.html',
         'text!./list_template.html',
         'text!./delete.html',
         'i18n!nls/lang.js',
         'event'
], ( template, list_template, delete_template, lang, ide_event ) ->

    template        = Handlebars.compile template
    list_template   = Handlebars.compile list_template
    delete_template = Handlebars.compile delete_template

    SGRulePopupView = Backbone.View.extend {

        events    :
          'click .sg-rule-create-add'        : 'addRule'
          'click .sg-rule-create-readd'      : 'readdRule'
          'OPTION_CHANGE #sg-create-proto'   : 'onProtocolChange'
          'click .sg-rule-delete'            : 'deleteRule'
          'OPTION_CHANGE #sg-proto-icmp-sel' : 'onICMPChange'
          'click #confirm-delete-sg-line'    : 'deleteSGLine'

        render : () ->

          modal template( @model.attributes ), true

          # In case there's two modal dialog in the page, although it is ALMOST
          # not possible
          # And `closed` event is send to '#modal-wrap'
          this.setElement $('#sg-rule-create-modal').closest '#modal-wrap'

          @updateSidebar()
          null

        renderDeleteModule : () ->
          modal delete_template( this.model.attributes ), true
          this.setElement $("#confirm-delete-sg-line").closest '.modal-footer'

        addRule : ( event ) ->
          # Extract the data from the view
          data = this.extractRuleData()

          # validation #####################################################
          validateMap =
            'custom':
              dom: $('#sg-proto-ipt-custom input')
              method: ( val ) ->
                if not MC.validate.portRange(val)
                  return 'Must be a valid format of number.'
                if Number(val) < 0 or Number(val) > 255
                  return 'The protocol number range must be 0-255.'
                null
            'tcp':
              dom: $('#sg-proto-ipt-tcp input')
              method: ( val ) ->
                portAry = []
                portAry = MC.validate.portRange(val)
                if not portAry
                  return 'Must be a valid format of port range.'
                if not MC.validate.portValidRange(portAry)
                  return 'Port range needs to be a number or a range of numbers between 0 and 65535.'
                null
            'udp':
              dom: $('#sg-proto-ipt-udp input')
              method: ( val ) ->
                portAry = []
                portAry = MC.validate.portRange(val)
                if not portAry
                  return 'Must be a valid format of port range.'
                if not MC.validate.portValidRange(portAry)
                  return 'Port range needs to be a number or a range of numbers between 0 and 65535.'
                null

          if data.protocol of validateMap
            needValidate = validateMap[ data.protocol ]
            needValidate.dom.parsley 'custom', needValidate.method

          if needValidate and not needValidate.dom.parsley 'validate'
            return
          # validation #####################################################

          # Generate Ouput Info
          if @model.get("isClassic")
            rule_count = 1
          else
            rule_count = 2

          if data.direction == "both"
            rule_count *= 2

          out_target = $("#sg-create-sg-out").find(".selected").text()
          in_target  = $("#sg-create-sg-in").find(".selected").text()
          action     = $("#sg-create-direction").find(".selected").text()

          $("#sg-rule-self-ref").hide()

          if rule_count == 1
            info = sprintf lang.ide.PROP_MSG_SG_CREATE, out_target, out_target, action, in_target

          else if data.inSg is data.outSg
            info = sprintf lang.ide.PROP_MSG_SG_CREATE_SELF, rule_count, out_target, out_target
            $("#sg-rule-self-ref").show()

          else
            info = sprintf lang.ide.PROP_MSG_SG_CREATE_MULTI, rule_count, out_target, in_target, out_target, action, in_target

          $("#sg-rule-create-msg").text info

          # Switch to done view.
          this.$el.find('#modal-box').toggleClass('done', true)

          @model.addRule( data )
          @updateSidebar()

        readdRule : () ->
          this.$el.find('#modal-box').toggleClass('done', false)

        deleteRule : ( event ) ->

          $li = $( event.currentTarget ).closest( "li" )

          data =
            ruleSetId : $li.attr("data-uid")
            protocol  : $li.attr("data-port")
            relation  : $li.attr("data-relation")
            direction : $li.attr("data-direction")

          $parent = $li.parent()
          $li.remove()
          if $parent.children().length == 0
            $parent.prev().remove()
            $parent.remove()

          @model.delRule( data )
          false

        onDirChange : () ->
          $(".sg-rule-direction").html( if $("#sg-rule-create-dir-i").is(":checked") then lang.ide.POP_SGRULE_LBL_SOURCE else lang.ide.POP_SGRULE_LBL_DEST )

        onProtocolChange : ( event, id ) ->
          $(".sg-proto-input").hide()
          $("#sg-proto-ipt-" + id).show()
          if id is 'custom'
            $('#sg-rule-create-modal .sg-create-proto-label-port').text('Protocol')
          else
            $('#sg-rule-create-modal .sg-create-proto-label-port').text('Port')

        onICMPChange : ( event, id ) ->
          $(".sg-proto-input-sub").hide()
          $("#sg-proto-input-sub-" + id).show()

        updateSidebar : () ->

          ruleCount = 0
          for group in @model.attributes.groups
            ruleCount += group.rules.length
            group.rules.deletable = true
            group.content = MC.template.sgRuleList( group.rules )

          @model.attributes.ruleCount = ruleCount

          $sidebar = $("#sgRuleCreateSidebar").html( list_template( @model.attributes ) )

          rule_count = $sidebar.find("li").length
          $modal     = this.$el.find('#modal-box')

          isShown = $sidebar.hasClass "shown"

          if rule_count is 0
            if isShown
              $sidebar.removeClass( "shown" ).animate({ left : "0" })
              $modal.animate({left:'-=100px'}, 300)
          else
            if not isShown
              $sidebar.addClass( "shown" ).animate({ left : "-200px" })
              $modal.animate({left:'+=100px'}, 300)

        extractRuleData : () ->
          outward = if $("#sg-rule-create-tgt-o").is(":checked") then "out" else "in"

          data =
            outSg     : $("#sg-create-sg-out").find(".selected").attr("data-id")
            direction : $("#sg-create-direction").find(".selected").attr("data-id")
            inSg      : $("#sg-create-sg-in").find(".selected").attr("data-id")
            protocol  : $("#sg-create-proto").find( ".selected" ).attr("data-id")

          $protoIptWrap = $("#sg-proto-ipt-"+data.protocol)
          $protoIpt     = $protoIptWrap.find("input")

          if $protoIpt.length
            protocolValue = $protoIpt.val()
          else
            protocolValue = $protoIptWrap.find(".selected").attr("data-id")

          data.protocolValue = protocolValue

          if data.protocol is "icmp"
            if protocolValue == "3" || protocolValue == "5" || protocolValue == "11" || protocolValue == "12"
              data.protocolSubValue = $("#sg-proto-input-sub-" + protocolValue).find(".selected").attr("data-id")
            else
              data.protocolSubValue = "-1"

          data

        deleteSGLine : () ->
          @model.deleteLine()
          modal.close()
          null

    }

    SGRulePopupView
