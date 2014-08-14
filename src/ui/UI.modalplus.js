(function() {
  var modalGroup;

  modalGroup = [];

  define(['backbone'], function(Backbone) {
    var Modal;
    Modal = (function() {
      function Modal(option) {
        var body, isFirst, _ref, _ref1, _ref2, _ref3;
        this.option = option;
        _.extend(this, Backbone.Events);
        isFirst = false;
        if ($('#modal-wrap').size() > 0) {
          isFirst = false;
          this.wrap = $("#modal-wrap");
        } else {
          isFirst = true;
          this.wrap = $("<div id='modal-wrap'>").appendTo($('body'));
        }
        if (isFirst) {
          modalGroup = [];
        }
        this.tpl = $(MC.template.modalTemplate({
          title: this.option.title || "",
          hideClose: this.option.hideClose,
          template: typeof this.option.template === "object" ? "" : this.option.template,
          confirm: {
            text: ((_ref = this.option.confirm) != null ? _ref.text : void 0) || "Submit",
            color: ((_ref1 = this.option.confirm) != null ? _ref1.color : void 0) || "blue",
            disabled: (_ref2 = this.option.confirm) != null ? _ref2.disabled : void 0,
            hide: (_ref3 = this.option.confirm) != null ? _ref3.hide : void 0
          },
          cancel: _.isString(this.option.cancel) ? {
            text: this.option.cancel || "Cancel"
          } : _.isObject(this.option.cancel) ? this.option.cancel : {
            text: "Cancel"
          },
          hasFooter: !this.option.disableFooter,
          hasScroll: !!this.option.maxHeight || this.option.hasScroll,
          compact: this.option.compact,
          mode: this.option.mode || "normal"
        }));
        body = this.tpl.find(".modal-body");
        if (typeof this.option.template === "object") {
          body.html(this.option.template);
        }
        if (this.option.maxHeight) {
          body.css({
            "max-height": this.option.maxHeight
          });
        }
        if (this.option.width) {
          body.parent().css({
            width: this.option.width
          });
        }
        this.tpl.appendTo(this.wrap);
        modalGroup.push(this);
        if (modalGroup.length === 1 || this.option.mode === "panel") {
          this.tpl.addClass('bounce');
          window.setTimeout((function(_this) {
            return function() {
              return _this.tpl.removeClass('bounce');
            };
          })(this), 1);
          this.trigger("show", this);
          this.trigger('shown', this);
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
        if (this.parentModal) {
          return false;
        }
        if (modalGroup.length > 1) {
          this.back();
        } else if (modalGroup.length <= 1) {
          modalGroup = [];
          this.trigger('close', this);
          if (typeof (_base = this.option).onClose === "function") {
            _base.onClose(this);
          }
          this.tpl.addClass('bounce');
          window.setTimeout((function(_this) {
            return function() {
              _this.tpl.remove();
              _this.wrap.remove();
              return _this.trigger('closed', _this);
            };
          })(this), this.option.delay || 300);
          this.wrap.fadeOut(this.option.delay || 300);
        }
        return null;
      };

      Modal.prototype.show = function() {
        var _base;
        this.wrap.removeClass("hide");
        if (modalGroup.length > 1) {
          this.getLast().resize(1);
          this.getLast()._slideIn();
          this.getLastButOne()._fadeOut();
        } else {
          this.resize();
        }
        if (typeof (_base = this.option).onShow === "function") {
          _base.onShow(this);
        }
        return this;
      };

      Modal.prototype.bindEvent = function() {
        var diffX, diffY, dragable;
        this.tpl.find('.modal-confirm').click((function(_this) {
          return function(e) {
            var _base;
            if (typeof (_base = _this.option).onConfirm === "function") {
              _base.onConfirm(_this.tpl, e);
            }
            return _this.trigger('confirm', _this);
          };
        })(this));
        this.tpl.find('.btn.modal-close').click((function(_this) {
          return function(e) {
            var _base, _ref;
            if (typeof (_base = _this.option).onCancel === "function") {
              _base.onCancel(_this.tpl, e);
            }
            _this.trigger('cancel', _this);
            if (!_this.option.preventClose) {
              return (_ref = modalGroup[0]) != null ? _ref.back() : void 0;
            }
          };
        })(this));
        this.tpl.find("i.modal-close").click(function(e) {
          var _ref;
          return (_ref = modalGroup[0]) != null ? _ref.back() : void 0;
        });
        if (!this.option.disableClose) {
          this.getFirst().wrap.off('click');
          this.getFirst().wrap.on('click', (function(_this) {
            return function(e) {
              var _ref;
              if (e.target === e.currentTarget) {
                return (_ref = _this.getFirst()) != null ? _ref.back() : void 0;
              }
            };
          })(this));
        }
        $(window).resize((function(_this) {
          return function() {
            var _ref;
            return _this != null ? (_ref = _this.getLast()) != null ? _ref.resize() : void 0 : void 0;
          };
        })(this));
        $(document).keyup((function(_this) {
          return function(e) {
            var _ref;
            if (e.which === 27 && !_this.option.disableClose) {
              if ((_this != null ? _this.getFirst() : void 0) != null) {
                e.preventDefault();
                return _this != null ? (_ref = _this.getFirst()) != null ? _ref.back() : void 0 : void 0;
              }
            }
          };
        })(this));
        if (!(this.option.disableDrag || (this.option.mode === 'panel'))) {
          diffX = 0;
          diffY = 0;
          dragable = false;
          this.tpl.find(".modal-header h3").mousedown((function(_this) {
            return function(e) {
              var originalLayout;
              dragable = true;
              originalLayout = _this.getLast().tpl.offset();
              diffX = originalLayout.left - e.clientX;
              diffY = originalLayout.top - e.clientY;
              return null;
            };
          })(this));
          $(document).mousemove((function(_this) {
            return function(e) {
              if (dragable && _this.getLast()) {
                _this.getLast().tpl.css({
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
          return $(document).mouseup((function(_this) {
            return function(e) {
              var left, maxHeight, maxRight, top;
              if (dragable) {
                top = e.clientY + diffY;
                left = e.clientX + diffX;
                maxHeight = $(window).height() - _this.getLast().tpl.height();
                maxRight = $(window).width() - _this.getLast().tpl.width();
                if (top < 0) {
                  top = 0;
                }
                if (left < 0) {
                  left = 0;
                }
                if (top > maxHeight) {
                  top = maxHeight;
                }
                if (left > maxRight) {
                  left = maxRight;
                }
                _this.getLast().tpl.css({
                  top: top,
                  left: left
                });
              }
              dragable = false;
              diffX = 0;
              diffY = 0;
              return null;
            };
          })(this));
        }
      };

      Modal.prototype.resize = function(slideIn) {
        var height, left, top, width, windowHeight, windowWidth, _ref, _ref1;
        if (this.option.mode === 'panel') {
          this.trigger('resize', this);
          return false;
        }
        windowWidth = $(window).width();
        windowHeight = $(window).height();
        width = ((_ref = this.option.width) != null ? _ref.toLowerCase().replace('px', '') : void 0) || this.tpl.width();
        height = ((_ref1 = this.option.height) != null ? _ref1.toLowerCase().replace('px', '') : void 0) || this.tpl.height();
        top = (windowHeight - height) * 0.4;
        left = (windowWidth - width) / 2;
        if (slideIn) {
          left = windowWidth + left;
        }
        this.tpl.css({
          top: top > 0 ? top : 10,
          left: left
        });
        return this.trigger('resize', {
          top: top,
          left: left
        });
      };

      Modal.prototype.getFirst = function() {
        return modalGroup != null ? modalGroup[0] : void 0;
      };

      Modal.prototype.getLast = function() {
        return modalGroup[modalGroup.length - 1];
      };

      Modal.prototype.getLastButOne = function() {
        if (this.parentModal) {
          return this.parentModal.getLastButOne();
        } else {
          return modalGroup[modalGroup.length - 2];
        }
      };

      Modal.prototype.isOpen = function() {
        return !this.isClosed;
      };

      Modal.prototype.isCurrent = function() {
        return this === this.getLast();
      };

      Modal.prototype.next = function(optionConfig) {
        var lastModal, newModal, _base, _ref, _ref1;
        if ((modalGroup != null ? modalGroup.length : void 0) >= 1) {
          newModal = new Modal(optionConfig);
          this.trigger("next", this);
          lastModal = this.getLastButOne();
          if ((_ref = this.getFirst()) != null) {
            if (typeof (_base = _ref.option).onNext === "function") {
              _base.onNext();
            }
          }
          newModal.parentModal = lastModal;
          lastModal.childModal = newModal;
          if ((_ref1 = lastModal.parentModal) != null) {
            _ref1.option.disableClose = true;
          }
          this.isMoving = true;
          window.setTimeout((function(_this) {
            return function() {
              _this.isMoving = false;
              newModal.trigger('shown', newModal);
              return null;
            };
          })(this), this.option.delay || 300);
          return newModal;
        } else {
          return false;
        }
      };

      Modal.prototype.back = function() {
        var toRemove, _base;
        if (this.parentModal || this.isMoving) {
          return false;
        }
        if (modalGroup.length === 1) {
          modalGroup.pop();
          this.close();
          this.isClosed = true;
          return false;
        } else {
          this.getLast().trigger("close", this.getLast());
          this.getLastButOne()._fadeIn();
          this.getLast()._slideOut();
          toRemove = modalGroup.pop();
          if (toRemove.option.mode === 'panel') {
            toRemove.tpl.addClass('bounce');
          }
          toRemove.isClosed = true;
          this.getLast().childModal = null;
          if (typeof (_base = toRemove.option).onClose === "function") {
            _base.onClose();
          }
          this.isMoving = true;
          return window.setTimeout((function(_this) {
            return function() {
              _this.isMoving = false;
              toRemove.tpl.remove();
              return toRemove.trigger('closed', toRemove);
            };
          })(this), this.option.delay || 300);
        }
      };

      Modal.prototype.toggleConfirm = function(disabled) {
        this.tpl.find(".modal-confirm").attr('disabled', !!disabled);
        return this;
      };

      Modal.prototype.setContent = function(content) {
        var selector;
        if (this.option.hasScroll || this.option.maxHeight) {
          selector = ".scroll-content";
        } else {
          selector = ".modal-body";
        }
        this.tpl.find(selector).html(content);
        this.resize();
        return this;
      };

      Modal.prototype.setWidth = function(width) {
        var body;
        body = this.tpl.find('.modal-body');
        body.parent().css({
          width: width
        });
        return this;
      };

      Modal.prototype.compact = function() {
        this.tpl.find('.modal-body').css({
          padding: 0
        });
        return this;
      };

      Modal.prototype._fadeOut = function() {
        if (this.option.mode === 'panel') {
          return false;
        }
        return this.tpl.animate({
          left: "-=" + $(window).width()
        }, this.option.delay || 100);
      };

      Modal.prototype._fadeIn = function() {
        if (this.option.mode === 'panel') {
          return false;
        }
        return this.tpl.animate({
          left: "+=" + $(window).width()
        }, this.option.delay || 100);
      };

      Modal.prototype._slideIn = function() {
        if (this.option.mode === 'panel') {
          return false;
        }
        return this.tpl.animate({
          left: "-=" + $(window).width()
        }, this.option.delay || 300);
      };

      Modal.prototype._slideOut = function() {
        if (this.option.mode === 'panel') {
          return false;
        }
        return this.tpl.animate({
          left: "+=" + $(window).width()
        }, this.option.delay || 300);
      };

      Modal.prototype.find = function(selector) {
        return this.tpl.find(selector);
      };

      Modal.prototype.$ = function(selector) {
        return this.tpl.find(selector);
      };

      Modal.prototype.setTitle = function(title) {
        this.tpl.find(".modal-header h3").text(title);
        return this;
      };

      return Modal;

    })();
    return Modal;
  });

}).call(this);
