define [
    'constant'
    'i18n!/nls/lang.js'
    './userguideTpl'
], (constant, lang, template) ->

    return Backbone.View.extend

        className: 'user-guide'
        
        tagName: 'section'
        
        initialize: () ->
        
            console.log('init')
        
        events:
        
            'click .guide-card': 'playVideo'
            'click .guide-video': 'closeVideo'
        
        render: () ->
            
            that = @
            @$el.html(template())
            $('.user-guide').remove()
            $('body').append(@$el)
            video = @$el.find('.guide-video video')[0]
            video.addEventListener 'ended', () ->
                that.closeVideo()

        playVideo: () ->

            @$el.find('.guide-video').fadeIn()
            video = @$el.find('.guide-video video')[0]
            video.width = $(document).width()
            video.play()

        closeVideo: () ->

            @$el.find('.guide-video').fadeOut()
            video = @$el.find('.guide-video video')[0]
            video.pause()
            video.currentTime = 0