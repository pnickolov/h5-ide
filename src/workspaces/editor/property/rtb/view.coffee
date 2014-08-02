#############################
#  View(UI logic) for design/property/rtb
#############################

define [ '../base/view', './template/stack' ], ( PropertyView, template ) ->

    RTBView = PropertyView.extend {

        events   :

            'REMOVE_ROW  .multi-input'        : 'removeIp'
            'ADD_ROW     .multi-input'        : 'processParsley'
            'BEFORE_REMOVE_ROW  .multi-input' : 'beforeRemoveIp'
            'change #rt-name'                 : 'changeName'
            'click #set-main-rt'              : 'setMainRT'
            'change .propagation'             : 'changePropagation'

            "focus .ipt-wrapper .input"      : 'onFocusCIDR'
            "keypress .ipt-wrapper .input"   : 'onPressCIDR'
            "blur .ipt-wrapper .input"       : 'onBlurCIDR'

        render     : () ->
            @$el.html template @model.attributes
            @model.attributes.title

        processParsley: ( event ) ->
            $( event.currentTarget )
            .find( 'input' )
            .last()
            .focus()
            .removeClass( 'parsley-validated' )
            .removeClass( 'parsley-error' )
            .next( '.parsley-error-list' )
            .remove()
            null


        beforeRemoveIp : ( event ) ->

            $nonEmptyInputs = $( event.currentTarget ).find("input").filter ()->
                this.value.length

            # If we only have valid item and user is trying to remove it.
            # prevent deletion
            if $nonEmptyInputs.length <= 1 and event.value
                return false

            null

        removeIp : ( event ) ->
            $target = $(event.currentTarget)

            newIps  = _.map $target.find("input"), ( input )-> input.value

            @model.setRoutes $target.attr("data-ref"), _.uniq( newIps )
            null

        changeName : ( event ) ->

            target = $ event.currentTarget
            name = target.val()

            if PropertyView.checkResName( @model.get('uid'), target, "Route Table" )
                @model.setName name
                @setTitle name

        setMainRT : () ->
            if @model.isAppEdit
                @model.setMainRT()
                @render()
            else
                $("#set-main-rt").hide().parent().find("p").show()
                @model.setMainRT()
            null

        changePropagation : ( event ) ->
            @model.setPropagation $( event.target ).is(":checked")
            null

        onPressCIDR : ( event ) ->
            if (event.keyCode is 13)
                $(event.currentTarget).blur()

        onFocusCIDR : ( event ) ->
            @disabledAllOperabilityArea(true)
            null

        onBlurCIDR : ( event ) ->

            inputElem = $(event.currentTarget)
            inputValue = inputElem.val()
            parentElem = inputElem.closest(".multi-input")

            dataRef = parentElem.attr("data-ref")

            ips = []
            parentElem.find("input").each ()->
                if this isnt event.currentTarget and this.value
                    ips.push this.value
                null

            allCidrAry = _.uniq( ips )
            parentElem.closest("li").siblings().each ()->
                otherGroupIps = []
                $(this).find("input").each ()->
                    if this.value then otherGroupIps.push this.value
                    null
                allCidrAry = allCidrAry.concat _.uniq( otherGroupIps )
                null


            if !inputValue
                if inputElem.closest('.multi-ipt-row').siblings().length == 0
                    mainContent = 'CIDR block is required.'
                    descContent = 'Please provide a IP ranges for this route.'
            else if !MC.validate 'cidr', inputValue
                mainContent = "#{inputValue} is not a valid form of CIDR block."
                descContent = 'Please provide a valid IP range. For example, 10.0.0.1/24.'
            # Right now we do not check if "0.0.0.0/0" conflicts with other cidr
            else
                for cidr in allCidrAry
                    if inputValue is cidr or ( cidr isnt "0.0.0.0/0" and @model.isCidrConflict( inputValue, cidr ) )
                        mainContent = "#{inputValue} conflicts with other route."
                        descContent = 'Please choose a CIDR block not conflicting with existing route.'
                        break

            if not mainContent
                if inputValue then ips.push inputValue

                @model.setRoutes dataRef, _.uniq( ips )
                @disabledAllOperabilityArea(false)
                return

            dialog_template = MC.template.setupCIDRConfirm {
                remove_content : 'Remove Route'
                main_content : mainContent
                desc_content : descContent
            }

            that = this
            modal dialog_template, false, () ->

                $('.modal-close').click () -> inputElem.focus()

                $('#cidr-remove').click () ->
                    Design.instance().component( dataRef ).remove()
                    that.disabledAllOperabilityArea(false)
                    modal.close()

            , {
                $source: $(event.target)
            }

            null

    }

    new RTBView()
