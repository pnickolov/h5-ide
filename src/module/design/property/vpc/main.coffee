####################################
#  Controller for design/property/vpc module
####################################

define [ 'jquery',
         'text!/module/design/property/vpc/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-vpc-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/vpc/view', './module/design/property/vpc/model' ], ( view, model ) ->

            #view
            view.model = model

            #render
            component = MC.canvas_data.component[uid]
            data      =
                name        : component.name
                cidrBlock   : component.resource.CidrBlock
                dnsHosts    : component.resource.EnableDnsHostnames == "true"
                dnsSupport  : component.resource.EnableDnsSupport   == "true"
                defaultTenancy : true
            view.render( data )
            null

        null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
