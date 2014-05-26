####################################
#  Controller for base_main
####################################

define [ 'jquery', 'underscore', 'i18n!nls/lang.js', 'UI.notification' ], ( $, _, lang ) ->

    #error_repeat = 0
    error_repeat = {}
    error_repeat.header     = 0
    error_repeat.tabbar     = 0
    error_repeat.navigation = 0
    error_repeat.dashboard  = 0
    error_repeat.register   = 0
    error_repeat.reset      = 0

    #private
    loadSuperModule = ( target, type, View, callback ) ->

        console.log 'loadSuperModule, type = ' + type

        try
            return new View()
        catch error
            console.log error
            error_repeat[ type ] = error_repeat[ type ] + 1
            if error_repeat[ type ] < 4
                notification 'warning', lang.ide.MODULE_RELOAD_MESSAGE, false
                _.delay () ->
                    target()
                , 5 * 1000
            else
                notification 'error', lang.ide.MODULE_RELOAD_FAILED, true
            return null

        null

    #public
    loadSuperModule   : loadSuperModule
