# todo: Change langu define
langu = ->
    'en-us'

# route function
userRoute = (routes)->
    hashArray = window.location.hash.split('#').pop().split('/')
    pathArray = window.location.pathname.split('/')
    pathArray.shift()
    @pathArray = pathArray
    @hashArray = hashArray
    # run routes func
    routes[pathArray[0]]?(pathArray, hashArray);

# register i18n handlebars helper
Handlebars.registerHelper 'i18n', (str)->
    i18n?(str) || str


# temp i18n load function
tempI18n = $.ajax({
    url: './nls/' + langu() + '/lang.js'
    jsonp: false
    dataType: "jsonp"
    jsonpCallback: "define"
    beforeSend: ->
        template = Handlebars.compile $("#loading-template").html()
        $("#main-body").html template()
    success: (data)->
        window.langsrc = data
        console.log 'Success', data
    error: (error)->
        # todo: change error handler
        console.log error, "error"
}).done ->
    console.log('Loaded!', langsrc)
    init()
i18n = (str) ->
    langsrc['reset'][str]

# init function
init = ->
    userRoute(
        "reset": (pathArray, hashArray)->
            hashTarget = hashArray[0]
            if hashTarget == 'password'
                console.log hashArray[1]
            else if hashTarget == "expire"
                console.log hashTarget
            else
                template = Handlebars.compile($("#email-template").html())
                console.log template()
                $("#main-body").html template()
    )