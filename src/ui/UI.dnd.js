(function() {
  define(["jquery"], function($) {
    var cancelDnd, cloneElement, defaultOptions, detectDrag, emptyFunction, onMouseMove, onMouseUp, startDrag;
    cloneElement = function(data) {
      return $("<div id='DndItem'></div>").appendTo(document.body).html(data.source.html()).attr("class", data.source.attr("class").replace("bubble", "").replace("tooltip", ""));
    };
    emptyFunction = function() {};
    defaultOptions = {
      clone: cloneElement,
      grid: 0,
      eventPrefix: "",
      minDistance: 4,
      lockToCenter: true,
      onDragStart: emptyFunction,
      onDrag: emptyFunction,
      onDragEnd: emptyFunction
    };
    $.fn.dnd = function(mouseDownEvent, options) {
      console.assert(options.dropTargets);
      console.assert(options.dataTransfer);
      options = $.extend({
        source: this,
        startX: mouseDownEvent.pageX,
        startY: mouseDownEvent.pageY
      }, defaultOptions, options);
      $(document).on({
        "mousemove.uidnd": detectDrag,
        "mousedown.uidnd": cancelDnd
      }, options);
      return this;
    };
    cancelDnd = function(evt) {
      $(document).off(".uidnd");
      if (evt.data.hoverZone) {
        evt.data.hoverZone.removeClass("dragOver");
      }
      if (evt.data.shadow) {
        evt.data.shadow.remove();
      }
    };
    detectDrag = function(evt) {
      var data;
      data = evt.data;
      if (Math.pow(evt.pageX - data.startX, 2) + Math.pow(evt.pageY - data.startY, 2) >= 4) {
        $(document).off("mousemove.uidnd").on({
          "mousemove.uidnd": onMouseMove,
          "mouseup.uidnd": onMouseUp
        }, data);
        startDrag(data, evt);
      }
      return false;
    };
    startDrag = function(data, evt) {
      var offset, shadow;
      data.onDragStart(data);
      data.shadow = shadow = data.clone(data);
      if (data.lockToCenter) {
        data.offset = {
          x: shadow.outerWidth() / 2,
          y: shadow.outerHeight() / 2
        };
      } else {
        offset = data.source.offset();
        data.offset = {
          x: data.startX - offset.left,
          y: data.startY - offset.top
        };
      }
      shadow.css({
        left: evt.pageX - data.offset.x,
        top: evt.pageY - data.offset.y
      });
      data.dropZones = _.map(data.dropTargets, function(tgt) {
        var $tgt;
        $tgt = $(tgt);
        offset = $tgt.offset();
        return {
          x1: offset.left,
          y1: offset.top,
          x2: offset.left + $tgt.outerWidth(),
          y2: offset.top + $tgt.outerHeight()
        };
      });
    };
    onMouseMove = function(evt) {
      var data, dz, hoverZone, idx, newZone, _i, _len, _ref, _ref1, _ref2;
      data = evt.data;
      _ref = data.dropZones;
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        dz = _ref[idx];
        if ((dz.x1 <= (_ref1 = evt.pageX) && _ref1 <= dz.x2) && (dz.y1 <= (_ref2 = evt.pageY) && _ref2 <= dz.y2)) {
          newZone = data.dropTargets.eq(idx);
          break;
        }
      }
      hoverZone = data.hoverZone;
      if (hoverZone && newZone && newZone[0] === hoverZone[0]) {
        newZone.triggerHandler("" + data.eventPrefix + "dragover", data);
      } else {
        if (hoverZone) {
          hoverZone.removeClass("dragOver").triggerHandler("" + data.eventPrefix + "dragleave", data);
        }
        if (newZone) {
          newZone.addClass("dragOver").triggerHandler("" + data.eventPrefix + "dragenter", data);
        }
        data.shadow.toggleClass("dragOver", !!newZone);
        data.hoverZone = newZone;
      }
      data.shadow.css({
        left: evt.pageX - data.offset.x,
        top: evt.pageY - data.offset.y
      });
      data.onDrag(evt);
      return false;
    };
    return onMouseUp = function(evt) {
      var data;
      data = evt.data;
      cancelDnd(evt);
      data.onDragEnd();
      if (data.hoverZone) {
        data.hoverZone.triggerHandler("" + data.eventPrefix + "drop", data);
      }
    };
  });

}).call(this);
