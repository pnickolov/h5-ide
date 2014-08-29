#############################
#  View(UI logic) for component/sgrule
#############################

define [ './template', 'i18n!/nls/lang.js', "Design", "event" ], ( template, lang, Design, ide_event ) ->

    SGRulePopupView = Backbone.View.extend {

        events    :
          'click .sg-rule-create-add'        : 'addRule'
          'click .sg-rule-create-readd'      : 'readdRule'
          'OPTION_CHANGE #sg-create-proto'   : 'onProtocolChange'
          'click .sg-rule-delete'            : 'deleteRule'
          'OPTION_CHANGE #sg-proto-icmp-sel' : 'onICMPChange'
          "click .btn-modal-close"           : 'onModalClose'

        render : () ->

          modal template( @model.attributes ), true

          # In case there's two modal dialog in the page, although it is ALMOST
          # not possible
          # And `closed` event is send to '#modal-wrap'
          this.setElement $('#sg-rule-create-modal').closest '#modal-wrap'

          @updateSidebar()
          null

        addRule : ( event ) ->
          # Extract the data from the view
          data = @extractRuleData( event )

          if not data then return

          # Add Rule
          ruleCount = @model.addRule( data )

          # Show add complete info
          if ruleCount is 0 then return

          # Generate Ouput Info
          out_target = $("#sg-create-sg-out").find(".selected").text()
          in_target  = $("#sg-create-sg-in").find(".selected").text()
          action     = $("#sg-create-direction").find(".selected").text()

          $("#sg-rule-self-ref").hide()

          if ruleCount is 1
            info = sprintf lang.PROP.MSG_SG_CREATE, out_target, out_target, action, in_target

          else if data.target is data.relation
            info = sprintf lang.PROP.MSG_SG_CREATE_SELF, ruleCount, out_target, out_target
            $("#sg-rule-self-ref").show()

          else
            info = sprintf lang.PROP.MSG_SG_CREATE_MULTI, ruleCount, out_target, in_target, out_target, action, in_target

          $("#sg-rule-create-msg").text info

          # Switch to done view.
          this.$el.find('#modal-box').toggleClass('done', true)

          @updateSidebar()

        readdRule : () ->
          this.$el.find('#modal-box').toggleClass('done', false)

        deleteRule : ( event ) ->

          $li = $( event.currentTarget ).closest( "li" )

          data =
            ruleSetId : $li.attr("data-uid")
            protocol  : $li.attr("data-protocol")
            relation  : $li.attr("data-relation")
            port      : $li.attr("data-port")
            direction : $li.attr("data-direction")

          $parent = $li.parent()
          $li.remove()
          if $parent.children().length == 0
            $parent.prev().remove()
            $parent.remove()

          @model.delRule( data )

          $count = $("#sgRuleCreateCount")
          c = parseInt( $("#sgRuleCreateCount").text().replace("(",""), 10 ) - 1
          if c < 0 then c = 0
          $count.text( "(#{c})" )
          false

        onDirChange : () ->
          $(".sg-rule-direction").html( if $("#sg-rule-create-dir-i").is(":checked") then lang.IDE.POP_SGRULE_LBL_SOURCE else lang.IDE.POP_SGRULE_LBL_DEST )

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
          for group in @model.attributes.groups || []
            ruleCount += group.rules.length
            group.rules.deletable = true
            group.content = MC.template.sgRuleList( group.rules )

          $sidebar = $("#sgRuleCreateSidebar").html( MC.template.groupedSgRuleList( @model.attributes ) )
          $("#sgRuleCreateCount").text("(#{ruleCount})")

          $modal   = this.$el.find('#modal-box')
          $sidebar = $sidebar.closest(".sg-rule-create-sidebar")

          isShown = $sidebar.hasClass "shown"

          if ruleCount is 0
            if isShown
              $sidebar.removeClass( "shown" ).animate({ left : "0" })
              $modal.animate({left:'-=100px'}, 300)
          else
            if not isShown
              $sidebar.addClass( "shown" ).animate({ left : "-200px" })
              $modal.animate({left:'+=100px'}, 300)

        onModalClose : ()->
          modal.close()

          lineId = @model.get("lineId")
          comp = Design.instance().component( lineId )
          if comp
            ide_event.trigger ide_event.OPEN_PROPERTY, comp.type, lineId

          return false

        extractRuleData : ( event ) ->

          tcp_port_dom        = $('#sg-proto-ipt-tcp input')
          udp_port_dom        = $('#sg-proto-ipt-udp input')
          custom_protocal_dom = $('#sg-proto-ipt-custom input')

          protocol_type       = $("#sg-create-proto").find( ".selected" ).attr("data-id")

          # validation #####################################################
          validateMap =
            'custom':
              dom: custom_protocal_dom
              method: ( val ) ->
                if not MC.validate.portRange(val)
                  return lang.PARSLEY.MUST_BE_A_VALID_FORMAT_OF_NUMBER
                if Number(val) < 0 or Number(val) > 255
                  return lang.PARSLEY.THE_PROTOCOL_NUMBER_RANGE_MUST_BE_0_255
                null
            'tcp':
                dom: tcp_port_dom
                method: ( val ) ->
                  portAry = MC.validate.portRange(val)
                  if not portAry
                      return lang.PARSLEY.MUST_BE_A_VALID_FORMAT_OF_PORT_RANGE
                  if not MC.validate.portValidRange(portAry)
                      return lang.PARSLEY.PORT_RANGE_BETWEEN_0_65535
                  null
            'udp':
                dom: udp_port_dom
                method: ( val ) ->
                  portAry = MC.validate.portRange(val)
                  if not portAry
                      return lang.PARSLEY.MUST_BE_A_VALID_FORMAT_OF_PORT_RANGE
                  if not MC.validate.portValidRange(portAry)
                      return lang.PARSLEY.PORT_RANGE_BETWEEN_0_65535
                  null

          if protocol_type of validateMap
            needValidate = validateMap[ protocol_type ]
            needValidate.dom.parsley 'custom', needValidate.method

          if needValidate and not needValidate.dom.parsley 'validate'
            return
          # validation #####################################################

          rule = {
            protocol  : protocol_type
            direction : $("#sg-create-direction").find(".selected").attr("data-id")
            fromPort  : ""
            toPort    : ""
            target    : $("#sg-create-sg-out").find(".selected").attr("data-id")
            relation  : $("#sg-create-sg-in").find(".selected").attr("data-id")
          }


          $protoIptWrap = $("#sg-proto-ipt-#{rule.protocol}")
          $protoIpt     = $protoIptWrap.find("input")
          portValue     = $protoIpt.val()


          switch protocol_type
            when "tcp", "udp"
              ports = portValue.split("-")
              rule.fromPort = ports[0].trim()
              if ports.length >= 2 then rule.toPort = ports[1].trim()

            when "icmp"
              portValue = $("#sg-proto-icmp-sel").find(".selected").attr("data-id")
              rule.fromPort = portValue
              if portValue is "3" or portValue is "5" or portValue is "11" or portValue is "12"
                rule.toPort = $("#sg-proto-input-sub-#{portValue}").find(".selected").attr("data-id")
              else
                rule.toPort = "-1"

            when "custom"
              rule.protocol = portValue

          return rule
    }

    SGRulePopupView
