(function() {
  define([], function() {
    var Modal;
    Modal = Modal = (function() {
      function Modal(option) {
        this.option = option;
        console.log(option);
        this.wrap = $('#modal-wrap').size() > 0 ? $("#modal-wrap") : $("<div id='modal-wrap'>").appendTo($('body'));
        this.tpl = $(MC.template.modalTemplate({
          title: this.option.title || "",
          closeAble: !this.option.disableClose,
          template: this.option.template || "",
          confirm: this.option.confirm || "Submit",
          cancel: this.option.cancel || "Cancel",
          hasFooter: !this.option.disableFooter
        })).find(".modal-box>div").css({
          width: this.option.width || "520px"
        }).end().appendTo(this.wrap);
        this.show();
        this.bindEvent();
        this;
      }

      Modal.prototype.close = function() {
        var _base;
        console.log(this.option.onClose);
        if (this.modalGroup.length > 1) {
          this.modalGroup[this.modalGroup.length - 1].tpl.remove();
        }
        if (typeof (_base = this.option).onClose === "function") {
          _base.onClose(this.tpl);
        }
        this.modalGroup.pop();
        if (this.modalGroup.length < 1) {
          this.wrap.remove();
        }
        return null;
      };

      Modal.prototype.show = function() {
        var _base;
        this.wrap.removeClass("hide");
        this.resize();
        console.log(this.option.onShow);
        return typeof (_base = this.option).onShow === "function" ? _base.onShow(this.tpl) : void 0;
      };

      Modal.prototype.bindEvent = function() {
        var diffX, diffY, dragable;
        this.tpl.find('#btn-confirm').click((function(_this) {
          return function(e) {
            var _base;
            if (typeof (_base = _this.option).onConfirm === "function") {
              _base.onConfirm(_this.tpl, e);
            }
            return _this.close();
          };
        })(this));
        this.tpl.find('#btn-cancel').click((function(_this) {
          return function(e) {
            var _base;
            if (typeof (_base = _this.option).onCancel === "function") {
              _base.onCancel(_this.tpl, e);
            }
            return _this.close();
          };
        })(this));
        this.tpl.find("i.modal-close").click((function(_this) {
          return function(e) {
            return _this.close();
          };
        })(this));
        if (!this.option.disableClose) {
          this.wrap.on('click', (function(_this) {
            return function(e) {
              if (e.target === e.currentTarget) {
                return _this.close();
              }
            };
          })(this));
        }
        if (this.option.dragable) {
          diffX = 0;
          diffY = 0;
          dragable = false;
          this.tpl.find(".modal-header h3").mousedown((function(_this) {
            return function(e) {
              var originalLayout;
              dragable = true;
              originalLayout = _this.tpl.offset();
              diffX = originalLayout.left - e.clientX;
              return diffY = originalLayout.top - e.clientY;
            };
          })(this));
          $(document).mousemove((function(_this) {
            return function(e) {
              if (dragable) {
                _this.tpl.css({
                  top: e.clientY + diffY,
                  left: e.clientX + diffX
                });
                if (window.getSelection) {
                  if (window.getSelection().empty) {
                    return window.getSelection().empty();
                  } else if (window.getSelection().removeAllRanges) {
                    return window.getSelection().removeAllRanges();
                  } else if (document.selection) {
                    return document.selection.empty();
                  }
                }
              }
            };
          })(this));
          return $(document).mouseup(function(e) {
            dragable = false;
            diffX = 0;
            return diffY = 0;
          });
        }
      };

      Modal.prototype.resize = function() {
        var height, left, top, width, windowHeight, windowWidth;
        windowWidth = $(window).width();
        windowHeight = $(window).height();
        width = this.tpl.width();
        height = this.tpl.height();
        console.info(windowHeight, windowWidth, width, height);
        top = (windowHeight - height) / 2;
        left = (windowWidth - width) / 2;
        return this.tpl.css({
          top: top > 0 ? top : 10,
          left: left
        });
      };

      Modal.prototype.modalGroup = [Modal];

      Modal.prototype.next = function(optionConfig) {
        var newModal;
        newModal = new Modal(optionConfig);
        newModal.parentModal = this;
        this.modalGroup.push(newModal);
        this.modalGroup[this.modalGroup.length - 2]._fadeOut();
        return newModal._slideIn();
      };

      Modal.prototype.back = function(optionConfig) {
        var length;
        length = this.modalGroup.length;
        this.modalGroup[length - 2]._fadeIn();
        this.modalGroup[length - 1]._slideOut();
        return window.setTimeout(function() {
          return this.modalGroup[length - 1].close();
        }, 300);
      };

      Modal.prototype._fadeOut = function() {
        console.log("Fading out");
        return this.tpl.addClass("fadeOut");
      };

      Modal.prototype._fadeIn = function() {
        console.log("Fading in");
        return this.tpl.removeClass('fadeOut');
      };

      Modal.prototype._slideIn = function() {
        console.log('Sliding In');
        return this.tpl.addClass('slideIn');
      };

      Modal.prototype._slideOut = function() {
        console.log('Sliding Out');
        return this.tpl.removeClass('slideIn');
      };

      return Modal;

    })();
    return Modal;
  });

}).call(this);
