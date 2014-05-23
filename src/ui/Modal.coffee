#
# *********************************************************
# Filename: UI.modalPlus
# Creator: Cyril Hou
# Description: UI.modalPlus
# Date: 2014-05-23
# **********************************************************
# (c) Copyright 2014 MadeiraCloud  All Rights Reserved
# **********************************************************
#
# Usage:
#   modal = new Modal option
#   subModal = modal.next option
#
#   option:
#      title: Modal.header title                                        [required]
#      template: Modal.body content                                     [required]
#      width: set the width of modal                                    [default: 520px]
#      maxHeight: set the Modal body "max-height" css attribute.        [default: 400px]
#      delay: animate delay time.                                       [default: 300ms]
#      disableClose: if can be closed when it's a single modal.         [default: false]
#      disableFooter: if this Modal has footer.                         [default: false]
#      dragAble: if the modal is dragAble                               [default: false]
#      confirm: confirm button of Modal footer.                         [default: {text: :"Submit", color: "blue"}]
#      cancel: cancel button of Modal                                   [default: "Cancel"]
#      onClose: function to exec then the modal close.                  [Function]
#      onConfirm: function to exec then the confirm button is clicked   [Function]
#      onCancel: function to exec when the cancel button is clicked     [Function]
#      onShow: function to exec then the modal is shown.                [Function]
#   Event:
#       on "show","next", "next", "close", "confirm", "cancel"
#   Method:
#       next( option )  ====> return new subModal
#       back()          ====> remove Last modal, back to the last but one modal.
#       getLast()       ====> return the last modal in modalGroup
#       getFirst()      ====> return the first modal in modalGroup
#       getLastButOne() ====> return the last but one modal in modalGroup
#   Property:
#       tpl             ====> the jQuery Dom element of the modal
#       modalGroup      ====> the modalGroup
#
define [], ()->
    class Modal
        constructor: (@option)->
            _.extend @, Backbone.Events
            @wrap = if $('#modal-wrap').size() > 0 then $("#modal-wrap") else $("<div id='modal-wrap'>").appendTo $('body')
            @tpl = $(MC.template.modalTemplate
                title: @option.title || ""
                closeAble : !@option.disableClose
                template: @option.template||""
                confirm: @option.confirm
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
                ,@option.delay || 300
                newModal
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
                ,@option.delay || 300
        _fadeOut: ->
            @tpl.animate
                left: "-="+ $(window).width()
            ,@option.delay || 300
        _fadeIn: ->
            @tpl.animate
                left: "+="+ $(window).width()
            ,@option.delay || 300
        _slideIn: ->
            @tpl.animate
                left: "-="+ $(window).width()
            ,@option.delay || 300
        _slideOut: ->
            @tpl.animate
                left: "+="+ $(window).width()
            ,@option.delay || 300
    Modal