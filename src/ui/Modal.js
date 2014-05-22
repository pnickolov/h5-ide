(function() {
  define([], function() {
    var Modal;
    Modal = (function() {
      function Modal(option) {
        this.option = option;
        _.extend(this, Backbone.Events);
        console.log(option);
        this.wrap = $('#modal-wrap').size() > 0 ? $("#modal-wrap") : $("<div id='modal-wrap'>").appendTo($('body'));
        this.tpl = $(MC.template.modalTemplate({
          title: this.option.title || "",
          closeAble: !this.option.disableClose,
          template: this.option.template || "",
          confirm: this.option.confirm || "Submit",
          cancel: this.option.cancel || "Cancel",
          hasFooter: !this.option.disableFooter
        }));
        this.tpl.find(".modal-body").parent().css({
          width: this.option.width || "520px"
        });
        this.tpl.appendTo(this.wrap);
        this.modalGroup.push(this);
        if (this.modalGroup.length === 1) {
          this.trigger("show", this);
        }
        this.show();
        this.bindEvent();
        this;
      }

      Modal.prototype.close = function() {
        var _base;
        if (this.isMoving) {
          return false;
        }
        console.log(this.option.onClose);
        if (this.parentModal) {
          return false;
        }
        if (this.modalGroup.length > 1) {
          this.back();
        } else if (this.modalGroup.length === 1) {
          this.trigger('close', this);
          this.getLast().tpl.remove();
          if (typeof (_base = this.option).onClose === "function") {
            _base.onClose(this);
          }
          this.modalGroup = null;
          this.wrap.remove();
        }
        return null;
      };

      Modal.prototype.show = function() {
        var _base;
        this.wrap.removeClass("hide");
        if (this.modalGroup.length > 1) {
          this.getLast().resize(1);
          this.getLast()._slideIn();
          this.getLastButOne()._fadeOut();
        } else {
          this.resize();
        }
        console.log(this.option.onShow);
        return typeof (_base = this.option).onShow === "function" ? _base.onShow(this) : void 0;
      };

      Modal.prototype.bindEvent = function() {
        var diffX, diffY, dragable;
        this.tpl.find('#button-confirm').click((function(_this) {
          return function(e) {
            var _base;
            if (typeof (_base = _this.option).onConfirm === "function") {
              _base.onConfirm(_this.tpl, e);
            }
            console.log(_this.modalGroup);
            return _this.modalGroup[0].back();
          };
        })(this));
        this.tpl.find('#button-cancel').click((function(_this) {
          return function(e) {
            var _base;
            if (typeof (_base = _this.option).onCancel === "function") {
              _base.onCancel(_this.tpl, e);
            }
            return _this.modalGroup[0].back();
          };
        })(this));
        this.tpl.find("i.modal-close").click((function(_this) {
          return function(e) {
            return _this.modalGroup[0].back();
          };
        })(this));
        if (!this.option.disableClose) {
          this.wrap.on('click', (function(_this) {
            return function(e) {
              if (e.target === e.currentTarget) {
                return _this.back();
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

      Modal.prototype.resize = function(slideIn) {
        var height, left, top, width, windowHeight, windowWidth;
        windowWidth = $(window).width();
        windowHeight = $(window).height();
        width = this.tpl.width();
        height = this.tpl.height();
        console.info(windowHeight, windowWidth, width, height);
        top = (windowHeight - height) / 2;
        left = (windowWidth - width) / 2;
        if (slideIn) {
          left = windowWidth + left;
        }
        return this.tpl.css({
          top: top > 0 ? top : 10,
          left: left
        });
      };

      Modal.prototype.modalGroup = [];

      Modal.prototype.getFirst = function() {
        var _ref;
        return (_ref = this.modalGroup) != null ? _ref[0] : void 0;
      };

      Modal.prototype.getLast = function() {
        return this.modalGroup[this.modalGroup.length - 1];
      };

      Modal.prototype.getLastButOne = function() {
        return this.modalGroup[this.modalGroup.length - 2];
      };

      Modal.prototype.next = function(optionConfig) {
        var lastModal, newModal, _base, _ref, _ref1, _ref2;
        if (!(((_ref = this.modalGroup) != null ? _ref.length : void 0) < 1)) {
          newModal = new Modal(optionConfig);
          this.trigger("next", this);
          lastModal = this.getLastButOne();
          if ((_ref1 = this.getFirst()) != null) {
            if (typeof (_base = _ref1.option).onNext === "function") {
              _base.onNext();
            }
          }
          newModal.parentModal = lastModal;
          lastModal.childModal = newModal;
          if ((_ref2 = lastModal.parentModal) != null) {
            _ref2.option.disableClose = true;
          }
          this.isMoving = true;
          return window.setTimeout((function(_this) {
            return function() {
              return _this.isMoving = false;
            };
          })(this), 300);
        } else {
          return false;
        }
      };

      Modal.prototype.back = function() {
        var toRemove, _base;
        if (this.parentModal || this.isMoving) {
          return false;
        }
        if (this.modalGroup.length === 1) {
          this.close();
          return false;
        } else {
          this.trigger("back", this);
          console.log(this.getLastButOne(), this.modalGroup, "-=-=-=-=-=-=-=-=-");
          this.getLastButOne()._fadeIn();
          this.getLast()._slideOut();
          toRemove = this.modalGroup.pop();
          this.getLast().childModal = null;
          if (typeof (_base = toRemove.option).onClose === "function") {
            _base.onClose();
          }
          this.isMoving = true;
          return window.setTimeout((function(_this) {
            return function() {
              toRemove.tpl.remove();
              return _this.isMoving = false;
            };
          })(this), 300);
        }
      };

      Modal.prototype._fadeOut = function() {
        console.log("Fading out");
        return this.tpl.animate({
          left: "-=" + $(window).width()
        }, 300);
      };

      Modal.prototype._fadeIn = function() {
        console.log("Fading in");
        return this.tpl.animate({
          left: "+=" + $(window).width()
        }, 300);
      };

      Modal.prototype._slideIn = function() {
        console.log('Sliding In');
        return this.tpl.animate({
          left: "-=" + $(window).width()
        }, 300);
      };

      Modal.prototype._slideOut = function() {
        console.log('Sliding Out');
        return this.tpl.animate({
          left: "+=" + $(window).width()
        }, 300);
      };

      return Modal;

    })();
    return Modal;
  });

}).call(this);
