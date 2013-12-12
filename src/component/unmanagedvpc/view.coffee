#############################
#  View(UI logic) for component/unmanagedvpc
#############################

define [ 'event',
         'text!./component/unmanagedvpc/template.html',
         'constant',
         'backbone', 'jquery', 'handlebars',
         'UI.modal'
], ( ide_event, template, constant ) ->

    UnmanagedVPCView = Backbone.View.extend {

        events   :
            'closed' : 'closedPopup'
            'click .unmanaged-VPC-resource-item' : 'resourceItemClickEvent'

        initialize : ->

            # is no unmanaged
            Handlebars.registerHelper 'is_unmanaged', ( value, options ) ->

                # is object
                if _.isObject value

                    # is empty object {}
                    if _.isEmpty value
                        options.fn this
                    else
                        options.inverse this
                else
                    options.inverse this

            # city code
            Handlebars.registerHelper 'city_code', ( text ) ->
                new Handlebars.SafeString constant.REGION_SHORT_LABEL[ text ]

            # city area
            Handlebars.registerHelper 'city_area', ( text ) ->
                new Handlebars.SafeString constant.REGION_LABEL[ text ]

            # convert string
            Handlebars.registerHelper 'convert_string', ( key, value ) ->

                # set unmanaged vpc list
                MC.forge.other.addUnmanagedVpc key, value

                new Handlebars.SafeString JSON.stringify value

            # vpc_list
            Handlebars.registerHelper 'vpc_list', ( items, options ) ->

                new_item = ''
                prefix   = '<li><span class="unmanaged-resource-number">'
                infix    = '</span><span class="unmanaged-resource-name">'
                suffix   = '</span></li>'

                try
                    _.each items, ( value, key ) ->

                        count = _.keys( value ).length
                        type  = ''

                        switch key

                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
                                type = ' subnets'

                            when constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
                                type = ' eip'

                            when constant.AWS_RESOURCE_TYPE.AWS_ELB
                                type = ' load balancer'

                            # instance include running and stopped
                            when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

                                running = 0
                                stopped = 0
                                type    = ' instance'

                                _.each _.values( value ), ( item ) ->

                                    if item.instanceState.name is 'running'
                                        running = running + 1
                                    else if item.instanceState.name is 'stopped'
                                        stopped = stopped + 1

                                if running > 0
                                    count = running
                                    type  = ' running instance'

                                if stopped > 0
                                    count = stopped
                                    type  = ' stopped instance'

                        if type
                            new_item += prefix + count + infix + type + suffix


                catch error
                    console.log 'unmanagedvpc view vpc_id', items
                finally
                    new Handlebars.SafeString new_item

                new Handlebars.SafeString new_item

        render     :  ->
            console.log 'pop-up:unmanaged vpc render'

            # popup
            modal Handlebars.compile( template )( @model.attributes ), true

            # set element
            @setElement $( '#unmanaged-VPC-modal-body' ).closest '#modal-wrap'

            null

        closedPopup : ->
            console.log 'closedPopup'
            @trigger 'CLOSE_POPUP'

        resourceItemClickEvent : ( event ) ->
            console.log 'resourceItemClickEvent', event

            try

                # get vpc_id and region
                $item   = $ event.currentTarget
                vpc_id  = $item.attr 'data-vpc-id'
                #vpc_obj= JSON.parse $item.attr 'data-vpc-obj'
                region  = $item.parent( 'ul' ).parent( 'li' ).attr 'data-region-name'

                # push OPEN_DESIGN_TAB
                ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'NEW_APPVIEW', vpc_id, region, vpc_id

                # close
                @closedPopup()

                # modal.close()
                modal.close()

            catch error
              console.log 'current found error ' + error

            null

    }

    return UnmanagedVPCView