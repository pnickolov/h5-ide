(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['jquery', 'MC', 'constant'], function($, MC, constant) {
    var getLCLine;
    getLCLine = function(line_id) {
      var line_target, ports, return_line_id;
      line_target = MC.canvas_data.layout.connection[line_id];
      ports = [];
      return_line_id = null;
      $.each(line_target.target, function(comp_uid, port_type) {
        var original_group_uid;
        if (!MC.canvas_data.component[comp_uid]) {
          original_group_uid = MC.canvas_data.layout.component.group[comp_uid].originalId;
          return $.each(MC.canvas_data.layout.component.node, function(c_uid, node_data) {
            if (node_data.type === "AWS.AutoScaling.LaunchConfiguration" && node_data.groupUId === original_group_uid) {
              return ports.push(c_uid);
            }
          });
        } else {
          return ports.push(comp_uid);
        }
      });
      $.each(MC.canvas_data.layout.connection, function(line_uid, line) {
        var flag;
        flag = 0;
        return $.each(line.target, function(port_uid, port_type) {
          if (__indexOf.call(ports, port_uid) >= 0) {
            flag += 1;
          }
          if (flag === 2) {
            return return_line_id = line_uid;
          }
        });
      });
      return return_line_id;
    };
    return {
      getLCLine: getLCLine
    };
  });

}).call(this);
