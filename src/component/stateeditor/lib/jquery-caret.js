/*
  Implement Github like autocomplete mentions
  http://ichord.github.com/At.js

  Copyright (c) 2013 chord.luo@gmail.com
  Licensed under the MIT license.
*/


/*
本插件操作 textarea 或者 input 内的插入符
只实现了获得插入符在文本框中的位置，我设置
插入符的位置.
*/


(function() {
  (function(factory) {
    if (typeof define === 'function' && define.amd) {
      return define(['jquery'], factory);
    } else {
      return factory(window.jQuery);
    }
  })(function($) {
    "use strict";
    $.browser = $.support;
    var EditableCaret, InputCaret, Mirror, Utils, methods, pluginName;
    pluginName = 'caret';
    EditableCaret = (function() {
      function EditableCaret($inputor) {
        this.$inputor = $inputor;
        this.domInputor = this.$inputor[0];
      }

      EditableCaret.prototype.setPos = function(pos) {
        return this.domInputor;
      };

      EditableCaret.prototype.getIEPosition = function() {
        return $.noop();
      };

      EditableCaret.prototype.getPosition = function() {
        return $.noop();
      };

      EditableCaret.prototype.getOldIEPos = function() {
        var preCaretTextRange, textRange;
        textRange = document.selection.createRange();
        preCaretTextRange = document.body.createTextRange();
        preCaretTextRange.moveToElementText(this.domInputor);
        preCaretTextRange.setEndPoint("EndToEnd", textRange);
        return preCaretTextRange.text.length;
      };

      EditableCaret.prototype.getPos = function() {
        var clonedRange, pos, range;
        if (range = this.range()) {
          clonedRange = range.cloneRange();
          clonedRange.selectNodeContents(this.domInputor);
          clonedRange.setEnd(range.endContainer, range.endOffset);
          pos = clonedRange.toString().length;
          clonedRange.detach();
          return pos;
        } else if (document.selection) {
          return this.getOldIEPos();
        }
      };

      EditableCaret.prototype.getOldIEOffset = function() {
        var range, rect;
        range = document.selection.createRange().duplicate();
        range.moveStart("character", -1);
        rect = range.getBoundingClientRect();
        return {
          height: rect.bottom - rect.top,
          left: rect.left,
          top: rect.top
        };
      };

      EditableCaret.prototype.getOffset = function(pos) {
        var clonedRange, offset, range, rect;
        offset = null;
        if (window.getSelection && (range = this.range())) {
          if (range.endOffset - 1 < 0) {
            return null;
          }
          var leftOffset = range.endOffset;
          if (pos > 0) {
            // leftOffset = 1;
          }
          clonedRange = range.cloneRange();
          clonedRange.setStart(range.endContainer, leftOffset - 1);
          clonedRange.setEnd(range.endContainer, leftOffset);
          rect = clonedRange.getBoundingClientRect();
          offset = {
            height: rect.height,
            left: rect.left + rect.width,
            top: rect.top
          };
          clonedRange.detach();
          offset;
        } else if (document.selection) {
          this.getOldIEOffset();
        }
        if (offset) {
          offset.top += $(window).scrollTop();
          offset.left += $(window).scrollLeft();
        }
        return offset;
      };

      EditableCaret.prototype.range = function() {
        var sel;
        if (!window.getSelection) {
          return;
        }
        sel = window.getSelection();
        if (sel.rangeCount > 0) {
          return sel.getRangeAt(0);
        } else {
          return null;
        }
      };

      return EditableCaret;

    })();
    InputCaret = (function() {
      function InputCaret($inputor) {
        this.$inputor = $inputor;
        this.domInputor = this.$inputor[0];
      }

      InputCaret.prototype.getIEPos = function() {
        var endRange, inputor, len, normalizedValue, pos, range, textInputRange;
        inputor = this.domInputor;
        range = document.selection.createRange();
        pos = 0;
        if (range && range.parentElement() === inputor) {
          normalizedValue = inputor.value.replace(/\r\n/g, "\n");
          len = normalizedValue.length;
          textInputRange = inputor.createTextRange();
          textInputRange.moveToBookmark(range.getBookmark());
          endRange = inputor.createTextRange();
          endRange.collapse(false);
          if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
            pos = len;
          } else {
            pos = -textInputRange.moveStart("character", -len);
          }
        }
        return pos;
      };

      InputCaret.prototype.getPos = function() {
        if (document.selection) {
          return this.getIEPos();
        } else {
          return this.domInputor.selectionStart;
        }
      };

      InputCaret.prototype.setPos = function(pos) {
        var inputor, range;
        inputor = this.domInputor;
        if (document.selection) {
          range = inputor.createTextRange();
          range.move("character", pos);
          range.select();
        } else if (inputor.setSelectionRange) {
          inputor.setSelectionRange(pos, pos);
        }
        return inputor;
      };

      InputCaret.prototype.getIEOffset = function(pos) {
        var h, range, textRange, x, y;
        textRange = this.domInputor.createTextRange();
        if (pos) {
          textRange.move('character', pos);
        } else {
          range = document.selection.createRange();
          textRange.moveToBookmark(range.getBookmark());
        }
        x = textRange.boundingLeft;
        y = textRange.boundingTop;
        h = textRange.boundingHeight;
        return {
          left: x,
          top: y,
          height: h
        };
      };

      InputCaret.prototype.getOffset = function(pos) {
        var $inputor, offset, position;
        $inputor = this.$inputor;
        if (document.selection) {
          offset = this.getIEOffset(pos);
          offset.top += $(window).scrollTop() + $inputor.scrollTop();
          offset.left += $(window).scrollLeft() + $inputor.scrollLeft();
          return offset;
        } else {
          offset = $inputor.offset();
          position = this.getPosition(pos);
          return offset = {
            left: offset.left + position.left - $inputor.scrollLeft(),
            top: offset.top + position.top - $inputor.scrollTop(),
            height: position.height
          };
        }
      };

      InputCaret.prototype.getPosition = function(pos) {
        var $inputor, at_rect, format, html, mirror, start_range;
        $inputor = this.$inputor;
        format = function(value) {
          return value.replace(/</g, '&lt').replace(/>/g, '&gt').replace(/`/g, '&#96').replace(/"/g, '&quot').replace(/\r\n|\r|\n/g, "<br />");
        };
        if (pos === void 0) {
          pos = this.getPos();
        }
        start_range = $inputor.val().slice(0, pos);
        html = "<span>" + format(start_range) + "</span>";
        html += "<span id='caret'>|</span>";
        mirror = new Mirror($inputor);
        return at_rect = mirror.create(html).rect();
      };

      InputCaret.prototype.getIEPosition = function(pos) {
        var h, inputorOffset, offset, x, y;
        offset = this.getIEOffset(pos);
        inputorOffset = this.$inputor.offset();
        x = offset.left - inputorOffset.left;
        y = offset.top - inputorOffset.top;
        h = offset.height;
        return {
          left: x,
          top: y,
          height: h
        };
      };

      return InputCaret;

    })();
    Mirror = (function() {
      Mirror.prototype.css_attr = ["overflowY", "height", "width", "paddingTop", "paddingLeft", "paddingRight", "paddingBottom", "marginTop", "marginLeft", "marginRight", "marginBottom", "fontFamily", "borderStyle", "borderWidth", "wordWrap", "fontSize", "lineHeight", "overflowX", "text-align"];

      function Mirror($inputor) {
        this.$inputor = $inputor;
      }

      Mirror.prototype.mirrorCss = function() {
        var css,
          _this = this;
        css = {
          position: 'absolute',
          left: -9999,
          top: 0,
          zIndex: -20000,
          'white-space': 'pre-wrap'
        };
        $.each(this.css_attr, function(i, p) {
          return css[p] = _this.$inputor.css(p);
        });
        return css;
      };

      Mirror.prototype.create = function(html) {
        this.$mirror = $('<div></div>');
        this.$mirror.css(this.mirrorCss());
        this.$mirror.html(html);
        this.$inputor.after(this.$mirror);
        return this;
      };

      Mirror.prototype.rect = function() {
        var $flag, pos, rect;
        $flag = this.$mirror.find("#caret");
        pos = $flag.position();
        rect = {
          left: pos.left,
          top: pos.top,
          height: $flag.height()
        };
        this.$mirror.remove();
        return rect;
      };

      return Mirror;

    })();
    Utils = {
      adjustOffset: function(offset, $inputor) {
        if (!offset) {
          return;
        }
        offset.top += $(window).scrollTop();
        offset.left += $(window).scrollLeft();
        return offset;
      },
      contentEditable: function($inputor) {
        return !!($inputor[0].contentEditable && $inputor[0].contentEditable === 'true');
      }
    };
    methods = {
      pos: function(pos) {
        if (pos) {
          return this.setPos(pos);
        } else {
          return this.getPos();
        }
      },
      position: function(pos) {
        if (document.selection) {
          return this.getIEPosition(pos);
        } else {
          return this.getPosition(pos);
        }
      },
      offset: function(pos) {
        return this.getOffset(pos);
      }
    };
    $.fn.caret = function(method) {
      var caret;
      caret = Utils.contentEditable(this) ? new EditableCaret(this) : new InputCaret(this);
      if (methods[method]) {
        return methods[method].apply(caret, Array.prototype.slice.call(arguments, 1));
      } else {
        return $.error("Method " + method + " does not exist on jQuery.caret");
      }
    };
    $.fn.caret.EditableCaret = EditableCaret;
    $.fn.caret.InputCaret = InputCaret;
    $.fn.caret.Utils = Utils;
    return $.fn.caret.apis = methods;
  });

}).call(this);


// jQuery List DragSort v0.5.1
// Website: http://dragsort.codeplex.com/
// License: http://dragsort.codeplex.com/license

(function($) {

  $.fn.dragsort = function(options) {
    if (options == "destroy") {
      $(this.selector).trigger("dragsort-uninit");
      return;
    }

    var opts = $.extend({}, $.fn.dragsort.defaults, options);
    var lists = [];
    var list = null, lastPos = null;

    this.each(function(i, cont) {

      //if list container is table, the browser automatically wraps rows in tbody if not specified so change list container to tbody so that children returns rows as user expected
      if ($(cont).is("table") && $(cont).children().size() == 1 && $(cont).children().is("tbody"))
        cont = $(cont).children().get(0);

      var newList = {
        draggedItem: null,
        placeHolderItem: null,
        pos: null,
        offset: null,
        offsetLimit: null,
        scroll: null,
        container: cont,

        init: function() {
          //set options to default values if not set
          var tagName = $(this.container).children().size() == 0 ? "li" : $(this.container).children(":first").get(0).tagName.toLowerCase();
          if (opts.itemSelector == "")
            opts.itemSelector = tagName;
          if (opts.dragSelector == "")
            opts.dragSelector = tagName;
          if (opts.placeHolderTemplate == "")
            opts.placeHolderTemplate = "<" + tagName + ">&nbsp;</" + tagName + ">";

          //listidx allows reference back to correct list variable instance
          $(this.container).attr("data-listidx", i).mousedown(this.grabItem).bind("dragsort-uninit", this.uninit);
          this.styleDragHandlers(true);
        },

        uninit: function() {
          var list = lists[$(this).attr("data-listidx")];
          $(list.container).unbind("mousedown", list.grabItem).unbind("dragsort-uninit");
          list.styleDragHandlers(false);
        },

        getItems: function() {
          return $(this.container).children(opts.itemSelector);
        },

        styleDragHandlers: function(cursor) {
          this.getItems().map(function() { return $(this).is(opts.dragSelector) ? this : $(this).find(opts.dragSelector).get(); }).css("cursor", cursor ? "pointer" : "");
        },

        grabItem: function(e) {
          //if not left click or if clicked on excluded element (e.g. text box) or not a moveable list item return
          if (e.which != 1 || $(e.target).is(opts.dragSelectorExclude) || $(e.target).closest(opts.dragSelectorExclude).size() > 0 || $(e.target).closest(opts.itemSelector).size() == 0)
            return;

          //prevents selection, stops issue on Fx where dragging hyperlink doesn't work and on IE where it triggers mousemove even though mouse hasn't moved,
          //does also stop being able to click text boxes hence dragging on text boxes by default is disabled in dragSelectorExclude
          e.preventDefault();

          //change cursor to move while dragging
          var dragHandle = e.target;
          while (!$(dragHandle).is(opts.dragSelector)) {
            if (dragHandle == this) return;
            dragHandle = dragHandle.parentNode;
          }
          $(dragHandle).attr("data-cursor", $(dragHandle).css("cursor"));
          $(dragHandle).css("cursor", "move");

          //on mousedown wait for movement of mouse before triggering dragsort script (dragStart) to allow clicking of hyperlinks to work
          var list = lists[$(this).attr("data-listidx")];
          var item = this;
          var trigger = function() {
            list.dragStart.call(item, e);
            $(list.container).unbind("mousemove", trigger);
          };
          $(list.container).mousemove(trigger).mouseup(function() { $(list.container).unbind("mousemove", trigger); $(dragHandle).css("cursor", $(dragHandle).attr("data-cursor")); });
        },

        dragStart: function(e) {
          if (list != null && list.draggedItem != null)
            list.dropItem();

          list = lists[$(this).attr("data-listidx")];
          list.draggedItem = $(e.target).closest(opts.itemSelector);

          //record current position so on dragend we know if the dragged item changed position or not
          list.draggedItem.attr("data-origpos", $(this).attr("data-listidx") + "-" + list.getItems().index(list.draggedItem));

          //calculate mouse offset relative to draggedItem
          var mt = parseInt(list.draggedItem.css("marginTop"));
          var ml = parseInt(list.draggedItem.css("marginLeft"));
          list.offset = list.draggedItem.offset();
          list.offset.top = e.pageY - list.offset.top + (isNaN(mt) ? 0 : mt) - 1;
          list.offset.left = e.pageX - list.offset.left + (isNaN(ml) ? 0 : ml) - 1;

          //calculate box the dragged item can't be dragged outside of
          if (!opts.dragBetween) {
            var containerHeight = $(list.container).outerHeight() == 0 ? Math.max(1, Math.round(0.5 + list.getItems().size() * list.draggedItem.outerWidth() / $(list.container).outerWidth())) * list.draggedItem.outerHeight() : $(list.container).outerHeight();
            list.offsetLimit = $(list.container).offset();
            list.offsetLimit.right = list.offsetLimit.left + $(list.container).outerWidth() - list.draggedItem.outerWidth();
            list.offsetLimit.bottom = list.offsetLimit.top + containerHeight - list.draggedItem.outerHeight();
          }

          //create placeholder item
          var h = list.draggedItem.height();
          var w = list.draggedItem.width();
          if (opts.itemSelector == "tr") {
            list.draggedItem.children().each(function() { $(this).width($(this).width()); });
            list.placeHolderItem = list.draggedItem.clone().attr("data-placeholder", true);
            list.draggedItem.after(list.placeHolderItem);
            list.placeHolderItem.children().each(function() { $(this).css({ borderWidth:0, width: $(this).width() + 1, height: $(this).height() + 1 }).html("&nbsp;"); });
          } else {
            list.draggedItem.after(opts.placeHolderTemplate);
            list.placeHolderItem = list.draggedItem.next().css({ height: h, width: w }).attr("data-placeholder", true);
          }

          if (opts.itemSelector == "td") {
            var listTable = list.draggedItem.closest("table").get(0);
            $("<table id='" + listTable.id + "' style='border-width: 0px;' class='dragSortItem " + listTable.className + "'><tr></tr></table>").appendTo("body").children().append(list.draggedItem);
          }

          //style draggedItem while dragging
          var orig = list.draggedItem.attr("style");
          list.draggedItem.attr("data-origstyle", orig ? orig : "");
          list.draggedItem.css({ position: "absolute", opacity: 0.8, "z-index": 999, height: h, width: w });

          //auto-scroll setup
          list.scroll = { moveX: 0, moveY: 0, maxX: $(document).width() - $(window).width(), maxY: $(document).height() - $(window).height() };
          list.scroll.scrollY = window.setInterval(function() {
            if (opts.scrollContainer != window) {
              $(opts.scrollContainer).scrollTop($(opts.scrollContainer).scrollTop() + list.scroll.moveY);
              return;
            }
            var t = $(opts.scrollContainer).scrollTop();
            if (list.scroll.moveY > 0 && t < list.scroll.maxY || list.scroll.moveY < 0 && t > 0) {
              $(opts.scrollContainer).scrollTop(t + list.scroll.moveY);
              list.draggedItem.css("top", list.draggedItem.offset().top + list.scroll.moveY + 1);
            }
          }, 10);
          list.scroll.scrollX = window.setInterval(function() {
            if (opts.scrollContainer != window) {
              $(opts.scrollContainer).scrollLeft($(opts.scrollContainer).scrollLeft() + list.scroll.moveX);
              return;
            }
            var l = $(opts.scrollContainer).scrollLeft();
            if (list.scroll.moveX > 0 && l < list.scroll.maxX || list.scroll.moveX < 0 && l > 0) {
              $(opts.scrollContainer).scrollLeft(l + list.scroll.moveX);
              list.draggedItem.css("left", list.draggedItem.offset().left + list.scroll.moveX + 1);
            }
          }, 10);

          //misc
          $(lists).each(function(i, l) { l.createDropTargets(); l.buildPositionTable(); });
          list.setPos(e.pageX, e.pageY);
          $(document).bind("mousemove", list.swapItems);
          $(document).bind("mouseup", list.dropItem);
          if (opts.scrollContainer != window)
            $(window).bind("DOMMouseScroll mousewheel", list.wheel);
        },

        //set position of draggedItem
        setPos: function(x, y) { 
          //remove mouse offset so mouse cursor remains in same place on draggedItem instead of top left corner
          var top = y - this.offset.top;
          var left = x - this.offset.left;

          //limit top, left to within box draggedItem can't be dragged outside of
          if (!opts.dragBetween) {
            top = Math.min(this.offsetLimit.bottom, Math.max(top, this.offsetLimit.top));
            left = Math.min(this.offsetLimit.right, Math.max(left, this.offsetLimit.left));
          }

          //adjust top, left calculations to parent element instead of window if it's relative or absolute
          this.draggedItem.parents().each(function() {
            if ($(this).css("position") != "static" && (!$.browser.mozilla || $(this).css("display") != "table")) {
              var offset = $(this).offset();
              top -= offset.top;
              left -= offset.left;
              return false;
            }
          });

          //set x or y auto-scroll amount
          if (opts.scrollContainer == window) {
            y -= $(window).scrollTop();
            x -= $(window).scrollLeft();
            y = Math.max(0, y - $(window).height() + 5) + Math.min(0, y - 5);
            x = Math.max(0, x - $(window).width() + 5) + Math.min(0, x - 5);
          } else {
            var cont = $(opts.scrollContainer);
            var offset = cont.offset();
            y = Math.max(0, y - cont.height() - offset.top) + Math.min(0, y - offset.top);
            x = Math.max(0, x - cont.width() - offset.left) + Math.min(0, x - offset.left);
          }
          
          list.scroll.moveX = x == 0 ? 0 : x * opts.scrollSpeed / Math.abs(x);
          list.scroll.moveY = y == 0 ? 0 : y * opts.scrollSpeed / Math.abs(y);

          //move draggedItem to new mouse cursor location
          this.draggedItem.css({ top: top });
        },

        //if scroll container is a div allow mouse wheel to scroll div instead of window when mouse is hovering over
        wheel: function(e) {
          if (($.browser.safari || $.browser.mozilla) && list && opts.scrollContainer != window) {
            var cont = $(opts.scrollContainer);
            var offset = cont.offset();
            if (e.pageX > offset.left && e.pageX < offset.left + cont.width() && e.pageY > offset.top && e.pageY < offset.top + cont.height()) {
              var delta = e.detail ? e.detail * 5 : e.wheelDelta / -2;
              cont.scrollTop(cont.scrollTop() + delta);
              e.preventDefault();
            }
          }
        },

        //build a table recording all the positions of the moveable list items
        buildPositionTable: function() {
          var pos = [];
          this.getItems().not([list.draggedItem[0], list.placeHolderItem[0]]).each(function(i) {
            var loc = $(this).offset();
            loc.right = loc.left + $(this).outerWidth();
            loc.bottom = loc.top + $(this).outerHeight();
            loc.elm = this;
            pos[i] = loc;
          });
          this.pos = pos;
        },

        dropItem: function() {
          if (list.draggedItem == null)
            return;

          //list.draggedItem.attr("style", "") doesn't work on IE8 and jQuery 1.5 or lower
          //list.draggedItem.removeAttr("style") doesn't work on chrome and jQuery 1.6 (works jQuery 1.5 or lower)
          var orig = list.draggedItem.attr("data-origstyle");
          list.draggedItem.attr("style", orig);
          if (orig == "")
            list.draggedItem.removeAttr("style");
          list.draggedItem.removeAttr("data-origstyle");

          list.styleDragHandlers(true);

          list.placeHolderItem.before(list.draggedItem);
          list.placeHolderItem.remove();

          $("[data-droptarget], .dragSortItem").remove();

          window.clearInterval(list.scroll.scrollY);
          window.clearInterval(list.scroll.scrollX);

          //if position changed call dragEnd
          if (list.draggedItem.attr("data-origpos") != $(lists).index(list) + "-" + list.getItems().index(list.draggedItem))
            opts.dragEnd.apply(list.draggedItem);
          list.draggedItem.removeAttr("data-origpos");

          list.draggedItem = null;
          $(document).unbind("mousemove", list.swapItems);
          $(document).unbind("mouseup", list.dropItem);
          if (opts.scrollContainer != window)
            $(window).unbind("DOMMouseScroll mousewheel", list.wheel);
          return false;
        },

        //swap the draggedItem (represented visually by placeholder) with the list item the it has been dragged on top of
        swapItems: function(e) {
          if (list.draggedItem == null)
            return false;

          //move draggedItem to mouse location
          list.setPos(e.pageX, e.pageY);

          //retrieve list and item position mouse cursor is over
          var ei = list.findPos(e.pageX, e.pageY);
          var nlist = list;
          for (var i = 0; ei == -1 && opts.dragBetween && i < lists.length; i++) {
            ei = lists[i].findPos(e.pageX, e.pageY);
            nlist = lists[i];
          }

          //if not over another moveable list item return
          if (ei == -1)
            return false;

          //save fixed items locations
          var children = function() { return $(nlist.container).children().not(nlist.draggedItem); };
          var fixed = children().not(opts.itemSelector).each(function(i) { this.idx = children().index(this); });

          //if moving draggedItem up or left place placeHolder before list item the dragged item is hovering over otherwise place it after
          if (lastPos == null || lastPos.top > list.draggedItem.offset().top || lastPos.left > list.draggedItem.offset().left)
            $(nlist.pos[ei].elm).before(list.placeHolderItem);
          else
            $(nlist.pos[ei].elm).after(list.placeHolderItem);

          //restore fixed items location
          fixed.each(function() {
            var elm = children().eq(this.idx).get(0);
            if (this != elm && children().index(this) < this.idx)
              $(this).insertAfter(elm);
            else if (this != elm)
              $(this).insertBefore(elm);
          });

          //misc
          $(lists).each(function(i, l) { l.createDropTargets(); l.buildPositionTable(); });
          lastPos = list.draggedItem.offset();
          return false;
        },

        //returns the index of the list item the mouse is over
        findPos: function(x, y) {
          for (var i = 0; i < this.pos.length; i++) {
            if (this.pos[i].left < x && this.pos[i].right > x && this.pos[i].top < y && this.pos[i].bottom > y)
              return i;
          }
          return -1;
        },

        //create drop targets which are placeholders at the end of other lists to allow dragging straight to the last position
        createDropTargets: function() {
          if (!opts.dragBetween)
            return;

          $(lists).each(function() {
            var ph = $(this.container).find("[data-placeholder]");
            var dt = $(this.container).find("[data-droptarget]");
            if (ph.size() > 0 && dt.size() > 0)
              dt.remove();
            else if (ph.size() == 0 && dt.size() == 0) {
              if (opts.itemSelector == "td")
                $(opts.placeHolderTemplate).attr("data-droptarget", true).appendTo(this.container);
              else
                //list.placeHolderItem.clone().removeAttr("data-placeholder") crashes in IE7 and jquery 1.5.1 (doesn't in jquery 1.4.2 or IE8)
                $(this.container).append(list.placeHolderItem.removeAttr("data-placeholder").clone().attr("data-droptarget", true));
              
              list.placeHolderItem.attr("data-placeholder", true);
            }
          });
        }
      };

      newList.init();
      lists.push(newList);
    });

    return this;
  };

  $.fn.dragsort.defaults = {
    itemSelector: "",
    dragSelector: "",
    dragSelectorExclude: "input, textarea, .editable-area",
    dragEnd: function() { },
    dragBetween: false,
    placeHolderTemplate: "",
    scrollContainer: window,
    scrollSpeed: 5
  };

})(jQuery);