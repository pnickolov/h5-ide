# todo: Change langu define
langu = ->
    document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + "lang\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1") || "en-us"

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

render = (tempName)->
    template = Handlebars.compile $(tempName).html()
    $("#main-body").html template()
# init function
init = ->
    userRoute(
        "reset": (pathArray, hashArray)->
            hashTarget = hashArray[0]
            if hashTarget == 'password'
                #todo: checking if password key is valid
                if true
                    render '#password-template'
                else
                    render '#expire-template'

            else if hashTarget == "expire"
                render '#expire-template'
            else
                render '#expire-template'
    )