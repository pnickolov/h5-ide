define [], ()->
    class Modal
        constructor: (@option)->
            _.extend @, Backbone.Events
            @wrap = if $('#modal-wrap').size() > 0 then $("#modal-wrap") else $("<div id='modal-wrap'>").appendTo $('body')
            @tpl = $(MC.template.modalTemplate
                title: @option.title || ""
                closeAble : !@option.disableClose
                template: @option.template||""
                confirm: @option.confirm || "Submit"
                cancel: @option.cancel|| "Cancel"
                hasFooter: !@option.disableFooter
            )
            @tpl.find(".modal-body")
            .css("max-height":@option.maxHeight||"400px")
            .parent().css(width: @option.width||"520px")
            @tpl.appendTo @wrap
            @modalGroup.push(@)
            if @modalGroup.length == 1
                @trigger "show", @
            @show()
            @bindEvent()
            @
        close: ()->
            if @isMoving
                return false
            if @.parentModal
                return false
            if @modalGroup.length > 1
                @.back()
            else if @modalGroup.length <= 1
                @trigger 'close',@
                @tpl.remove()
                @option.onClose?(@)
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
            @option.onShow?(@)
        bindEvent: ()->
            @tpl.find('#button-confirm').click (e)=>
                @option.onConfirm?(@tpl,e)
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
            $(window).resize =>
                @?.getLast()?.resize()
            if(@option.dragable)
                diffX = 0
                diffY = 0
                dragable = false
                @tpl.find(".modal-header h3").mousedown (e)=>
                    dragable = true
                    originalLayout = @getLast().tpl.offset()
                    diffX = originalLayout.left - e.clientX
                    diffY = originalLayout.top - e.clientY

                $(document).mousemove (e)=>
                    if(dragable)
                        @getLast().tpl.css
                            top: e.clientY + diffY
                            left: e.clientX + diffX
                        if window.getSelection
                            if window.getSelection().empty
                                window.getSelection().empty()
                            else if window.getSelection().removeAllRanges
                                window.getSelection().removeAllRanges()
                            else if (document.selection)
                                document.selection.empty();
                $(document).mouseup (e)=>
                    if dragable
                        top = e.clientY + diffY
                        left = e.clientX + diffX
                        maxHeight = $(window).height() - @.getLast().tpl.height()
                        maxRight = $(window).width() - @.getLast().tpl.width()
                        if  top < 0
                            top = 0
                        if left < 0
                            left = 0
                        if top > maxHeight
                            top = maxHeight
                        if left > maxRight
                            left = maxRight
                        @getLast().tpl.css
                            top: top
                            left: left
                    dragable =false
                    diffX = 0
                    diffY = 0

        resize: (slideIn)->
            windowWidth = $(window).width()
            windowHeight = $(window).height()
            width = @tpl.width()
            height= @tpl.height()
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
            if @.parentModal
                return @.parentModal.getLastButOne()
            else
                return @modalGroup[@modalGroup.length - 2]
        next: (optionConfig)->
            unless @modalGroup?.length < 1
                newModal = new Modal optionConfig
                @trigger "next", @
                lastModal = @.getLastButOne()
                @.getFirst()?.option.onNext?()
                newModal.parentModal = lastModal
                lastModal.childModal = newModal
                lastModal.parentModal?.option.disableClose = true
                @isMoving = true
                window.setTimeout ()=>
                    @isMoving = false
                ,300
            else
                return false
        back: ()->
            if @parentModal or @isMoving
                return false
            if @modalGroup.length == 1
                @modalGroup.pop()
                @close()
                return false
            else
                @trigger "back", @
                @getLastButOne()._fadeIn()
                @getLast()._slideOut()
                toRemove = @modalGroup.pop()
                @getLast().childModal = null
                toRemove.option.onClose?()
                @isMoving = true
                window.setTimeout ()=>
                    toRemove.tpl.remove()
                    @isMoving = false;
                ,300
        _fadeOut: ->
            @tpl.animate
                left: "-="+ $(window).width()
            ,300
        _fadeIn: ->
            @tpl.animate
                left: "+="+ $(window).width()
            ,300
        _slideIn: ->
            @tpl.animate
                left: "-="+ $(window).width()
            ,300
        _slideOut: ->
            @tpl.animate
                left: "+="+ $(window).width()
            ,300
    Modal


#taModal = new Modal
#    title: "TA Modal 1"
#    disableClose: false
#    dragable: true
#    template: "<h1 style='font-size: 100px;line-height:125px;text-align: center'>One</h1>"
#    onClose: ->
#        console.log("Close!")
#window.setTimeout ()->
#    taModal.next
#        title: "TA Modal 2"
#        disableClose: false
#        dragable: true
#        width: "1000px"
#        template: "<h1 style='font-size: 100px;line-height:125px;text-align: center'>Two</h1>"
#        onClose: ->
#            console.log("Close!")
#        onConfirm: ->
#            alert 2
#,1000
#window.setTimeout ()->
#    taModal.next
#        title: "Ta Modal 3"
#        disableClose: true
#        dragable: true
#        template: "<h1 style='font-size: 100px;line-height:125px;text-align: center'>Three</h1>"
#        onCancel: ->
#            alert 3
#,2000
#window.setTimeout ()->
#    taModal.next
#        title: "Ta Modal 4"
#        disableClose: false
#        dragable: true
#        template: "<h1 style='font-size: 100px;line-height:125px;text-align: center'>Four</h1>"
#        onClose: ->
#            console.log("Closed 4")
#,3000
