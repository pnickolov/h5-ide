define(['backbone', 'i18n!/nls/lang.js'], function(Backbone, lang) {
  var Modal, defaultOptions, modals;
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
  Modal = Backbone.View.extend({
    events: {
      "click .modal-confirm": "confirm",
      "click .btn.modal-close": "cancel",
      "click i.modal-close": "close"
    },
    constructor: function(option) {
      var _base, _base1, _ref;
      $(':focus').blur();
      this.nextOptions = [];
      this.nextCloses = [];
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
      if ((_ref = option.mode) === 'fullscreen' || _ref === 'panel') {
        option.disableDrag = true;
      }
      this.wrap = $("#modal-wrap");
      if (this.wrap.size() === 0) {
        this.wrap = $("<div id='modal-wrap'></div>").appendTo($("body"));
      }
      this.option = $.extend(true, {}, defaultOptions, option);
      (_base = this.option.cancel).text || (_base.text = lang.IDE.POP_LBL_CANCEL);
      (_base1 = this.option.confirm).text || (_base1.text = lang.IDE.LBL_SUBMIT);
      return this.render();
    },
    render: function() {
      var self, _base;
      self = this;
      if (typeof this.option.template === "object") {
        this.option.$template = this.option.template;
        this.option.template = "";
      }
      this.tpl = $(MC.template.modalTemplate(this.option));
      if (this.option.width) {
        this.tpl.find(".modal-wrapper-fix").css("width", this.option.width);
      }
      this.tpl.find(".modal-body").html(this.option.$template);
      this.setElement(this.tpl);
      this.isReady = false;
      if (modals.length && !modals[modals.length - 1].isReady) {
        console.warn("Sorry, But we are moving...");
        if (this.option.force) {
          modals[modals.length - 1].nextOptions.push(this.option);
        }
        return this;
      }
      this.tpl.appendTo(this.wrap);
      this.resize();
      modals.push(this);
      if (modals.length > 1) {
        if (self.option.mode === 'normal') {
          modals[modals.length - 1].resize(1);
          modals[modals.length - 1].animate("slideIn");
        }
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
      _.delay(function() {
        self.resize();
        return self.isReady = true;
      }, 300);
      _.delay(function() {
        return self.nextOptions.forEach(function(option) {
          return new Modal(option);
        });
      }, (this.option.delay || 300) + 10);
      this.bindEvent();
      return this;
    },
    close: function(number) {
      var cb, modal, nextModal, _base;
      modal = modals[modals.length - 1];
      if (modal != null ? modal.pending : void 0) {
        modal.nextCloses.push(this);
        return false;
      }
      if (!number || typeof number !== "number") {
        if (typeof number === "function") {
          cb = number;
        }
        number = 1;
      }
      if (this.isClosed) {
        return false;
      }
      nextModal = modals[modals.length - (1 + number)];
      modal.pending = true;
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
        nextModal.animate("fadeIn");
      } else {
        modal.wrap.removeClass("show");
        modal.tpl.removeClass("bounce");
      }
      _.delay(function() {
        var _ref;
        modal.tpl.remove();
        modal.trigger("closed", this);
        modal.pending = false;
        modal.isClosed = true;
        if (modals.length > 1) {
          modals.length = modals.length - number;
        } else {
          modal.wrap.remove();
          modals = [];
        }
        if ((_ref = modals[modals.length - 1]) != null) {
          _ref.resize();
        }
        return typeof cb === "function" ? cb() : void 0;
      }, modal.option.delay || 300);
      _.delay(function() {
        return modal.nextCloses.forEach(function(modalToClose) {
          return modalToClose.close();
        });
      }, (modal.option.delay || 300) + 10);
      return this;
    },
    confirm: function(evt) {
      var _base;
      if ($(evt.currentTarget).is(":disabled")) {
        return false;
      }
      this.trigger("confirm", this);
      if (typeof (_base = this.option).onConfirm === "function") {
        _base.onConfirm();
      }
      return this;
    },
    cancel: function() {
      var _base;
      this.trigger("cancel", this);
      this.close();
      if (typeof (_base = this.option).onCancel === "function") {
        _base.onCancel(this);
      }
      return this;
    },
    bindEvent: function() {
      var diffX, diffY, disableClose, draggable, modal, self;
      self = this;
      disableClose = false;
      _.each(modals, function(modal) {
        if (modal.option.disableClose) {
          disableClose = true;
        }
      });
      if (!disableClose) {
        this.wrap.off("click");
        this.wrap.on("click", function(e) {
          var modal;
          if (e.target === e.currentTarget) {
            modal = modals[modals.length - 1];
            if (modal.pending) {
              return false;
            }
            return self.close();
          }
        });
      }
      $(window).resize(function() {
        if (!self.isClosed) {
          if (self === modals[modals.length - 1]) {
            return self.resize();
          } else {
            return self.resize(-1);
          }
        }
      });
      $(document).keyup(function(e) {
        if (e.which === 27 && !self.option.disableClose) {
          e.preventDefault();
          return self.close();
        }
      });
      modal = modals[modals.length - 1];
      if (this.option.disableDrag) {
        return false;
      } else if (modal) {
        diffX = 0;
        diffY = 0;
        draggable = false;
        modal.find(".modal-header h3").mousedown(function(e) {
          var originalLayout;
          draggable = true;
          if (e.which) {
            if (e.which === 3) {
              draggable = false;
            }
          } else if (e.button && e.button === 2) {
            draggable = false;
          }
          if (draggable) {
            originalLayout = modal.tpl.offset();
            diffX = originalLayout.left - e.clientX;
            diffY = originalLayout.top - e.clientY;
          }
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
          diffX = diffY = 0;
        });
      }
    },
    resize: function(isSlideIn) {
      var height, left, self, top, width, windowHeight, windowWidth;
      self = this;
      if (!isSlideIn) {
        this.tpl.show();
      }
      if (this.option.mode === "panel" && !isSlideIn) {
        this.trigger("resize", this);
        return false;
      }
      if (this.option.mode === "fullscreen" && !isSlideIn) {
        this.tpl.removeAttr("style");
        return false;
      }
      windowWidth = $(window).width();
      windowHeight = $(window).height();
      width = this.tpl.width();
      height = this.tpl.height();
      top = (windowHeight - height) * 0.4;
      left = (windowWidth - width) / 2;
      if (isSlideIn) {
        this.tpl.removeClass("animate");
      }
      if (top < 0) {
        top = 10;
      }
      if (isSlideIn === 1) {
        left = windowWidth + left;
      }
      if (isSlideIn === -1) {
        left = -windowWidth + left;
      }
      self.tpl.css({
        top: top,
        left: left
      });
      if (isSlideIn) {
        self.tpl.hide();
      }
      this.trigger("resize", {
        top: top,
        left: left
      });
      return this;
    },
    isOpen: function() {
      return !this.isClosed;
    },
    next: function(option) {
      var newModal;
      newModal = new Modal(option);
      this.trigger("next", newModal);
      newModal;
      return this;
    },
    toggleConfirm: function(disabled) {
      this.tpl.find(".modal-confirm").attr("disabled", !!disabled);
      return this;
    },
    toggleFooter: function(visible) {
      this.tpl.find(".modal-footer").toggle(!!visible);
      return this;
    },
    setContent: function(content) {
      var selector;
      if (this.option.maxHeight || this.option.hasScroll) {
        selector = ".scroll-content";
      } else {
        selector = ".modal-body";
      }
      this.tpl.find(selector).html(content);
      this.resize();
      return this;
    },
    compact: function() {
      this.tpl.find(".modal-body").css({
        padding: 0
      });
      return this;
    },
    setWidth: function(width) {
      var body;
      body = this.tpl.find('.modal-body');
      body.parent().css({
        width: width
      });
      this.resize();
      return this;
    },
    animate: function(animate) {
      var delayOption, left, offset, that, windowWidth;
      this.tpl.show();
      that = this;
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
      windowWidth = $(window).width();
      offset = this.tpl.offset();
      left = offset.left + windowWidth;
      delayOption = 300;
      if (animate === "fadeOut" || animate === "fadeIn") {
        delayOption = 100;
        left = +offset.left + windowWidth;
      }
      if (animate === "fadeOut" || animate === "slideIn") {
        left = +offset.left - windowWidth;
      }
      that.isMoving = true;
      this.tpl.animate({
        left: left
      }, delayOption, (function() {
        that.isMoving = false;
        return false;
      }));
      return this;
    },
    find: function(selector) {
      return this.tpl.find(selector);
    },
    $: function(selector) {
      return this.tpl.find(selector);
    },
    setTitle: function(title) {
      this.tpl.find(".modal-header h3").text(title);
      return this;
    },
    abnormal: function() {
      var _ref;
      return (_ref = this.option.mode) === "panel" || _ref === "fullscreen";
    },
    loading: function(revert) {
      if (!revert) {
        this._title = this.find(".modal-header h3").text();
        this.setTitle(lang.PROP.LBL_LOADING);
        this._content = this.find(".modal-body").children();
        this.setContent(MC.template.loadingSpinner());
        return this.toggleFooter(false);
      } else {
        if (!this._title) {
          throw new Error("The modal was not in loading state.");
          return false;
        }
        this.setTitle(this._title);
        this.setContent(this._content);
        return this.toggleFooter(true);
      }
    }
  });
  return Modal;
});
