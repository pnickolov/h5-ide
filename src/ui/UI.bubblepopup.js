(function() {
  define(['jquery'], function() {
    var bubblePopup;
    $(document).on('click', function(event) {
      if (!$(event.target).hasClass('bubble-popuped')) {
        $('#bubble-box').remove();
        return $('.bubble-popuped').removeClass('bubble-popuped');
      }
    });
    bubblePopup = function(target, content, handleMap) {
      var $content, bubble_box, coordinate, height, target_height, target_offset, target_width, width;
      target = $(target);
      bubble_box = $('#bubble-box');
      coordinate = {};
      if ($.trim(content) !== '') {
        if (!bubble_box[0]) {
          $(document.body).append('<div id="bubble-box" class="bubble-popup"><div class="arrow"></div><div id="bubble-content"></div></div>');
          bubble_box = $('#bubble-box');
        }
        $content = $('#bubble-content').html(content);
        $content.find('.cancel').on('click', function() {
          $('#bubble-box').remove();
          return $('.bubble-popuped').removeClass('bubble-popuped');
        });
        _.each(handleMap, function(handle, selector) {
          return $content.find(selector).on('click', handle);
        });
        target_offset = target.offset();
        target_width = target.innerWidth();
        target_height = target.innerHeight();
        width = bubble_box.width();
        height = bubble_box.height();
        if (target_offset.top + target_height + height - document.documentElement.scrollTop > window.innerHeight) {
          coordinate.top = target_offset.top - height - 15;
          bubble_box.addClass('bubble-top');
        } else {
          coordinate.top = target_offset.top + target_height + 15;
          bubble_box.addClass('bubble-bottom');
        }
        coordinate.left = target_offset.left - ((width - target_width) / 2);
        bubble_box.css(coordinate).show();
        return target.addClass('bubble-popuped');
      }
    };
    return bubblePopup;
  });

}).call(this);
