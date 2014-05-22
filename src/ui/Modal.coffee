define [], ()->
    Modal = class Modal
        constructor: (@option)->
            console.log option
            @wrap = if $('#modal-wrap').size() > 0 then $("#modal-wrap") else $("<div id='modal-wrap'>").appendTo $('body')
            @tpl = $(MC.template.modalTemplate
                title: @option.title || ""
                closeAble : !@option.disableClose
                template: @option.template||""
                confirm: @option.confirm || "Submit"
                cancel: @option.cancel|| "Cancel"
                hasFooter: !@option.disableFooter
            ).find(".modal-box>div")
            .css(width: @option.width||"520px")
            .end()
            .appendTo @wrap
            @modalGroup.push(@)
            @show()
            @bindEvent()
            @
        close: ()->
            console.log @option.onClose
            if @.parentModal
                return false
            if @modalGroup.length > 1
                @.back()
            else if @modalGroup.length == 1
                @getLast().tpl.remove()
                @option.onClose?(@)
                @modalGroup.pop()
            if @modalGroup.length < 1
                @wrap.remove()
            null
        show: ()->
            @wrap.removeClass("hide")
            if @modalGroup.length > 1
                @getLast().resize(1)
                @getLast()._slideIn()
                @getLastButOne()._fadeOut()
            else
                @resize()
            console.log @option.onShow
            @option.onShow?(@)
        bindEvent: ()->
            @tpl.find('#button-confirm').click (e)=>
                @option.onConfirm?(@tpl,e)
                console.log @modalGroup
                @modalGroup[0].back()
            @tpl.find('#button-cancel').click (e)=>
                @option.onCancel?(@tpl,e)
                @modalGroup[0].back()
            @tpl.find("i.modal-close").click (e)=>
                @modalGroup[0].back()
            if(!@option.disableClose)
                @wrap.on 'click', (e)=>
                    if(e.target == e.currentTarget)
                        @back()
            if(@option.dragable)
                diffX = 0
                diffY = 0
                dragable = false
                @tpl.find(".modal-header h3").mousedown (e)=>
                    dragable = true
                    originalLayout = @tpl.offset()
                    diffX = originalLayout.left - e.clientX
                    diffY = originalLayout.top - e.clientY

                $(document).mousemove (e)=>
                    if(dragable)
                        @tpl.css
                            top: e.clientY + diffY
                            left: e.clientX + diffX
                        if window.getSelection
                            if window.getSelection().empty
                                window.getSelection().empty()
                            else if window.getSelection().removeAllRanges
                                window.getSelection().removeAllRanges()
                            else if (document.selection)
                                document.selection.empty();
                $(document).mouseup (e)->
                    dragable =false
                    diffX = 0
                    diffY = 0

        resize: (slideIn)->
            windowWidth = $(window).width()
            windowHeight = $(window).height()
            width = @tpl.width()
            height= @tpl.height()
            console.info windowHeight, windowWidth, width, height
            top = (windowHeight - height) / 2
            left = (windowWidth - width) / 2
            if slideIn
                left = windowWidth + left
            @tpl.css
                top:  if top > 0 then top else 10
                left: left
        modalGroup: []
        getFirst: ->
            return @modalGroup?[0]
        getLast: ->
            return @modalGroup[@modalGroup.length - 1]
        getLastButOne: ->
            return @modalGroup[@modalGroup.length - 2]
        next: (optionConfig)->
            newModal = new Modal optionConfig
            lastModal = @.getLastButOne()
            @.getFirst()?.option.onNext?()
            newModal.parentModal = lastModal
            lastModal.childModal = newModal
        back: ()->
            if @parentModal
                return false
            if @modalGroup.length == 1
                @close()
                return false
            else
                @getLastButOne()._fadeIn()
                @getLast()._slideOut()
                toRemove = @modalGroup.pop()
                @getLast().childModal = null
                toRemove.option.onClose?()
                window.setTimeout ()=>
                    toRemove.tpl.remove()
                ,300
        _fadeOut: ->
            console.log "Fading out"
            @tpl.animate
                left: "-="+ $(window).width()
        _fadeIn: ->
            console.log "Fading in"
            @tpl.animate
                left: "+="+ $(window).width()
        _slideIn: ->
            console.log 'Sliding In'
            @tpl.animate
                left: "-="+ $(window).width()
        _slideOut: ->
            console.log 'Sliding Out'
            @tpl.animate
                left: "+="+ $(window).width()
    Modal


#new Modal
#    title: "Title Example"
#    disableClose: false
#    dragable: true
#    template: "<h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1><h1>Hello World!</h1>"
#    onClose: ()->
#        alert "Modal Closed!"
#    onShow: ()->
#        alert "Modal Shown!"
#    onConfirm: ()->
#        alert "Modal Confirm!"
#    onCancel: ()->
#        alert "Modal Canceled!"

