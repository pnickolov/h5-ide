(function() {
  var defaultOptions, modals,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  modals = [];

  defaultOptions = {
    title: "",
    mode: "normal",
    template: "",
    width: 520,
    maxHeight: null,
    delay: 300,
    compact: false,
    disableClose: false,
    disableFooter: false,
    disableDrag: false,
    hideClose: false,
    hasScroll: false,
    hasHeader: true,
    hasFooter: true,
    cancel: {
      text: "",
      hide: false
    },
    confirm: {
      text: "",
      color: "blue",
      disabled: false,
      hide: false
    },
    onClose: null,
    onConfirm: null,
    onShow: null
  };

  define(['backbone', 'i18n!/nls/lang.js'], function(Backbone, lang) {
    var Modal;
    Modal = (function(_super) {
      __extends(Modal, _super);

      Modal.prototype.events = {
        "click .modal-confirm": "confirm",
        "click .btn.modal-close": "cancel",
        "click i.modal-close": "close"
      };

      function Modal(option) {
        var _base, _base1;
        if (typeof option.cancel === "string") {
          option.cancel = {
            text: option.cancel
          };
        }
        if (typeof option.confirm === "string") {
          option.confirm = {
            text: option.confirm
          };
        }
        if (option.mode === "fullscreen") {
          option.disableClose = true;
          option.disableFooter = true;
        }
        option.hasFooter = !option.disableFooter;
        this.wrap = $("#modal-wrap");
        if (this.wrap.size() === 0) {
          this.wrap = $("<div id='modal-wrap'></div>").appendTo($("body"));
        }
        this.option = $.extend(true, _.clone(defaultOptions), option);
        (_base = this.option.cancel).text || (_base.text = lang.IDE.POP_LBL_CANCEL);
        (_base1 = this.option.confirm).text || (_base1.text = lang.IDE.LBL_SUBMIT);
        this.render();
      }

      Modal.prototype.render = function() {
        var self, _base;
        self = this;
        if (typeof this.option.template === "object") {
          this.option.$template = this.option.template;
          this.option.template = "";
        }
        this.tpl = $(MC.template.modalTemplate(this.option));
        this.tpl.find(".modal-body").html(this.option.$template);
        this.setElement(this.tpl);
        this.tpl.appendTo(this.wrap);
        this.resize();
        modals.push(this);
        if (modals.length > 1) {
          modals[modals.length - 1].resize(1);
          modals[modals.length - 1].animate("slideIn");
          modals[modals.length - 2].animate("fadeOut");
          modals[modals.length - 1].tpl.addClass("bounce");
        } else {
          this.tpl.addClass("animate");
          this.trigger("show", this);
          if (typeof (_base = this.option).onShow === "function") {
            _base.onShow(this);
          }
          _.defer(function() {
            self.wrap.addClass("show");
            return self.tpl.addClass("bounce");
          });
          _.delay(function() {
            return self.trigger("shown", this);
          }, 300);
        }
        this.bindEvent();
        return this;
      };

      Modal.prototype.close = function() {
        var modal, self, _base;
        self = this;
        if (this.pending) {
          return false;
        }
        this.pending = true;
        if (this.isClosed || this.isMoving) {
          return false;
        }
        modal = modals[modals.length - 1];
        modal.trigger("close", this);
        if (typeof (_base = modal.option).onClose === "function") {
          _base.onClose(this);
        }
        if (modals.length > 1) {
          if (modal.option.mode === "panel") {
            modal.tpl.removeClass("bounce");
          } else {
            modal.animate("slideOut");
          }
          modals[modals.length - 2].animate("fadeIn");
        } else {
          modal.wrap.removeClass("show");
          modal.tpl.removeClass("bounce");
        }
        _.delay(function() {
          modal.tpl.remove();
          modal.trigger("closed", this);
          self.pending = false;
          if (modals.length > 1) {
            return modals.pop();
          } else {
            modal.wrap.remove();
            return modals = [];
          }
        }, modal.option.delay || 300);
        modal.isClosed = true;
        return this;
      };

      Modal.prototype.confirm = function(evt) {
        var _base;
        if ($(evt.currentTarget).is(":disabled")) {
          return false;
        }
        this.trigger("confirm", this);
        if (typeof (_base = this.option).onConfirm === "function") {
          _base.onConfirm();
        }
        return this;
      };

      Modal.prototype.cancel = function() {
        var _base;
        this.trigger("cancel", this);
        this.close();
        if (typeof (_base = this.option).onCancel === "function") {
          _base.onCancel(this);
        }
        return this;
      };

      Modal.prototype.bindEvent = function() {
        var diffX, diffY, disableClose, draggable, modal, self;
        self = this;
        disableClose = false;
        _.each(modals, function(modal) {
          if (modal.option.disableClose) {
            return disableClose = true;
          }
        });
        if (!disableClose) {
          this.wrap.off("click");
          this.wrap.on("click", function(e) {
            if (e.target === e.currentTarget) {
              return self.close();
            }
          });
        }
        $(window).resize((function(_this) {
          return function() {
            return modals[modals.length - 1].resize();
          };
        })(this));
        $(document).keyup(function(e) {
          if (e.which === 27 && !this.option.disableClose) {
            e.preventDefault();
            return self.close();
          }
        });
        modal = modals[modals.length - 1];
        if (!this.option.disableDrag || this.option.mode !== "normal" && modal) {
          diffX = 0;
          diffY = 0;
          draggable = false;
          modal.find(".modal-header h3").mousedown(function(e) {
            var originalLayout;
            draggable = true;
            originalLayout = modal.tpl.offset();
            diffX = originalLayout.left - e.clientX;
            return diffY = originalLayout.top - e.clientY;
          });
          $(document).mousemove(function(e) {
            var _base, _base1, _ref;
            if (draggable) {
              modal.tpl.css({
                left: e.clientX + diffX,
                top: e.clientY + diffY
              });
              if (window.getSelection) {
                if (typeof (_base = window.getSelection()).empty === "function") {
                  _base.empty();
                }
                if (typeof (_base1 = window.getSelection()).removeAllRanges === "function") {
                  _base1.removeAllRanges();
                }
                return (_ref = document.selection) != null ? typeof _ref.empty === "function" ? _ref.empty() : void 0 : void 0;
              }
            }
          });
          return $(document).mouseup(function(e) {
            var left, maxHeight, maxRight, top;
            if (draggable) {
              left = e.clientX + diffX;
              top = e.clientY + diffY;
              maxHeight = $(window).height() - modal.tpl.height();
              maxRight = $(window).width() - modal.tpl.width();
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
              modal.tpl.animate({
                top: top,
                left: left
              }, 100);
            }
            draggable = false;
            return diffX = diffX = 0;
          });
        }
      };

      Modal.prototype.resize = function(isSlideIn) {
        var height, left, top, width, windowHeight, windowWidth, _ref, _ref1, _ref2, _ref3;
        if (this.option.mode !== "normal") {
          this.trigger("resize", this);
          return false;
        }
        windowWidth = $(window).width();
        windowHeight = $(window).height();
        width = ((_ref = this.option.width) != null ? (_ref1 = _ref.toString()) != null ? _ref1.toLowerCase().replace('px', '') : void 0 : void 0) || this.tpl.width();
        height = ((_ref2 = this.option.height) != null ? (_ref3 = _ref2.toString()) != null ? _ref3.toLowerCase().replace('px', '') : void 0 : void 0) || this.tpl.height();
        top = (windowHeight - height) * 0.4;
        left = (windowWidth - width) / 2;
        if (top < 0) {
          top = 10;
        }
        if (isSlideIn) {
          left = windowWidth + left;
        }
        this.tpl.css({
          top: top,
          left: left
        });
        this.trigger("resize", {
          top: top,
          left: left
        });
        return this;
      };

      Modal.prototype.isOpen = function() {
        return !this.isClosed;
      };

      Modal.prototype.next = function(option) {
        var newModal;
        newModal = new Modal(option);
        this.trigger("next", newModal);
        newModal;
        return this;
      };

      Modal.prototype.toggleConfirm = function(disabled) {
        this.tpl.find(".modal-confirm").attr("disabled", !!disabled);
        return this;
      };

      Modal.prototype.setContent = function(content) {
        var selector;
        if (this.option.maxHeight || this.option.hasScroll) {
          selector = ".scroll-content";
        } else {
          selector = ".modal-body";
        }
        this.tpl.find(selector).html(content);
        this.resize();
        return this;
      };

      Modal.prototype.compact = function() {
        this.tpl.find(".modal-body").css({
          padding: 0
        });
        return this;
      };

      Modal.prototype.animate = function(animate) {
        var delayOption, symbol, that, windowWidth;
        if (this.option.mode === "fullscreen" && animate === "slideIn") {
          return false;
        }
        if (this.option.mode === "panel") {
          return false;
        }
        if (this.isMoving) {
          console.warn("It's animating.");
          return false;
        }
        symbol = "+=";
        delayOption = 300;
        that = this;
        if (animate === "fadeOut" || animate === "fadeIn") {
          delayOption = 100;
        }
        if (animate === "fadeOut" || animate === "slideIn") {
          symbol = "-=";
        }
        windowWidth = $(window).width();
        that.isMoving = true;
        this.tpl.animate({
          left: symbol + windowWidth
        }, delayOption, function() {
          return that.isMoving = false;
        });
        return this;
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

      Modal.prototype.abnormal = function() {
        var _ref;
        return (_ref = this.option.mode) === "panel" || _ref === "fullscreen";
      };

      return Modal;

    })(Backbone.View);
    window.Modal = Modal;
    return Modal;
  });

}).call(this);
