#############################
#  View(UI logic) for design/property/eni
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/eni_list.html',
         'i18n!nls/lang.js'
], ( PropertyView, template, list_template, lang ) ->

    noop = ()-> null

    template = Handlebars.compile template
    list_template = Handlebars.compile list_template

    ENIView = PropertyView.extend {

        events   :
            "change #property-eni-desc"             : "setEniDesc"
            "change #property-eni-source-check"     : "setEniSourceDestCheck"

            'click .toggle-eip'                     : 'setEip'
            'click #property-eni-ip-add'            : "addIp"
            'click #property-eni-list .icon-remove' : "removeIp"
            'blur .input-ip'                        : 'syncIPList'

        render     : () ->
            @$el.html( template( @model.attributes ) )

            @refreshIpList()

            $("#prop-appedit-eni-list").html list_template @model.attributes

            @model.attributes.name

        setEniDesc : ( event ) ->
            @model.setEniDesc event.target.value
            null

        setEniSourceDestCheck : ( event ) ->
            @model.setSourceDestCheck event.target.checked
            null

        addIp : () ->
            if $("#property-eni-ip-add").hasClass("disabled")
                return

            @model.addIp()
            @refreshIpList()
            null

        setEip : ( event ) ->
            $target = $(event.currentTarget)
            index   = $target.closest("li").index()
            attach  = not $target.hasClass("associated")

            if attach
                tooltip = lang.ide.PROP_INSTANCE_IP_MSG_4
            else
                tooltip = lang.ide.PROP_INSTANCE_IP_MSG_3
            $target.toggleClass("associated", attach).data("tooltip", tooltip)

            @model.attachEip index, attach
            null

        removeIp : (event) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            @model.removeIp( index )
            @updateIPAddBtnState( true )
            null


        syncIPList : (event) ->

            ipItems = $('#property-eni-list .input-ip-item')
            $target = $( event.currentTarget )

            if not @validateIpItem( $target ) then return

            ipVal = $target.val()
            ip = $target.siblings( ".input-ip-prefix" ).text() + ipVal
            autoAssign = ipVal is "x" or ipVal is "x.x"

            @model.setIp $target.closest(".input-ip-item").index(), ip, autoAssign
            null

        refreshIpList : ( event ) ->
            $( '#property-eni-list' ).html( MC.template.propertyIpList( @model.attributes.ips ) )
            @updateIPAddBtnState()
            null

        validateIpItem : ( $item ) ->
            that = this
            $item.parsley "custom", ( val ) ->
                validDOM         = $item
                inputValue       = validDOM.val()
                inputValuePrefix = validDOM.siblings(".input-ip-prefix").text()
                currentInputIP   = inputValuePrefix + inputValue
                prefixAry        = inputValuePrefix.split('.')

                ###### validation format
                ipIPFormatCorrect = false
                # for 10.0.0.
                if prefixAry.length is 4
                    if inputValue is 'x'
                        ipIPFormatCorrect = true
                    else if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
                        ipIPFormatCorrect = true
                # for 10.0.
                else
                    if inputValue is 'x.x'
                        ipIPFormatCorrect = true
                    else if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
                        ipIPFormatCorrect = true

                if !ipIPFormatCorrect
                    return lang.ide.PARSLEY_INVALID_IP_ADDRESS
                else
                    result = that.model.isValidIp( currentInputIP )
                    if result isnt true
                        return result
                null

            result = $item.parsley("validate")
            $item.parsley("custom", noop)
            return result

        updateIPAddBtnState : ( enabled ) ->
            if enabled is undefined
                enabled = @model.canAddIP()

            if enabled is true
                tooltip = "Add IP Address"
            else
                if _.isString enabled
                    tooltip = enabled
                else
                    tooltip = "Cannot add IP address"
                enabled = false

            $("#property-eni-ip-add").toggleClass("disabled", !enabled).data("tooltip", tooltip)
            null

    }

    new ENIView()
