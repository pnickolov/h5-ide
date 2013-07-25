(function() {
  define(['jquery', 'MC'], function($, MC) {
    return {
      addVPN: function(vgwUID, cgwUID) {
        var component_data, vpn_uid;
        vpn_uid = MC.guid();
        component_data = $.extend(true, {}, MC.canvas.VPN_JSON.data);
        component_data.uid = vpn_uid;
        component_data.resource.VpnGatewayId = '@' + vgwUID + '.resource.VpnGatewayId';
        component_data.resource.CustomerGatewayId = '@' + cgwUID + '.resource.CustomerGatewayId';
        MC.canvas_data.component[vpn_uid] = component_data;
        return null;
      },
      delVPN: function(vgwUID, cgwUID) {
        var cgw_ref, item, vgw_ref, _i, _len, _ref, _results;
        vgw_ref = '@' + vgwUID + '.resource.VpnGatewayId';
        cgw_ref = '@' + cgwUID + '.resource.CustomerGatewayId';
        _ref = MC.canvas_data.component;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (item.type === 'AWS.VPC.VPNConnection' && item.resource.VpnGatewayId === vgw_ref && item.resource.CustomerGatewayId === cgw_ref) {
            delete MC.canvas_data.component[item.uid];
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };
  });

}).call(this);
