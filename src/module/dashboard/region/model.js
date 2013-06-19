(function() {
  define(['backbone', 'jquery', 'underscore', 'aws_model', 'vpc_model', 'constant'], function(Backbone, $, _, aws_model, vpc_model, constant) {
    var RegionModel, current_region, model, popup_key_set, resource_source, status_list, unmanaged_list, update_timestamp, vpc_attrs_value;
    current_region = null;
    resource_source = null;
    vpc_attrs_value = null;
    unmanaged_list = null;
    status_list = null;
    update_timestamp = 0;
    popup_key_set = {
      "unmanaged_bubble": {
        "DescribeVolumes": {
          "status": ["status"],
          "title": "volumeId",
          "sub_info": [
            {
              "key": ["createTime"],
              "show_key": "Create Time"
            }, {
              "key": ["availabilityZone"],
              "show_key": "Availability Zone"
            }, {
              "key": ["attachmentSet", "item", "status"],
              "show_key": "Attachment Status"
            }
          ]
        },
        "DescribeInstances": {
          "status": ["instanceState", "name"],
          "title": "instanceId",
          "sub_info": [
            {
              "key": ["launchTime"],
              "show_key": "Launch Time"
            }, {
              "key": ["placement", "availabilityZone"],
              "show_key": "Availability Zone"
            }
          ]
        },
        "DescribeVpnConnections": {
          "status": ["state"],
          "title": "vpnConnectionId",
          "sub_info": [
            {
              "key": ["vpnConnectionId"],
              "show_key": "VPC"
            }, {
              "key": ["type"],
              "show_key": "Type"
            }, {
              "key": ["routes", "item", "source"],
              "show_key": "Routing"
            }
          ]
        },
        "DescribeVpcs": {
          "status": ["state"],
          "title": "vpcId",
          "sub_info": [
            {
              "key": ["cidrBlock"],
              "show_key": "CIDR"
            }, {
              "key": ["isDefault"],
              "show_key": "Default VPC:"
            }, {
              "key": ["instanceTenancy"],
              "show_key": "Tenacy"
            }
          ]
        }
      },
      "detail": {
        "DescribeVolumes": {
          "title": "volumeId",
          "sub_info": [
            {
              "key": ["volumeId"],
              "show_key": "Volume ID"
            }, {
              "key": ["attachmentSet", "item", "device"],
              "show_key": "Device Name"
            }, {
              "key": ["snapshotId"],
              "show_key": "Snapshot ID"
            }, {
              "key": ["createTime"],
              "show_key": "Create Time"
            }, {
              "key": ["attachmentSet", "item", "attachTime"],
              "show_key": "Attach Name"
            }, {
              "key": ["attachmentSet", "item", "deleteOnTermination"],
              "show_key": "Delete On Termination"
            }, {
              "key": ["attachmentSet", "item", "instanceId"],
              "show_key": "Instance ID"
            }, {
              "key": ["status"],
              "show_key": "status"
            }, {
              "key": ["attachmentSet", "item", "status"],
              "show_key": "Attachment Status"
            }, {
              "key": ["availabilityZone"],
              "show_key": "Availability Zone"
            }, {
              "key": ["volumeType"],
              "show_key": "Volume Type"
            }, {
              "key": ["Iops"],
              "show_key": "Iops"
            }
          ]
        },
        "DescribeInstances": {
          "title": "instanceId",
          "sub_info": [
            {
              "key": ["instanceState", "name"],
              "show_key": "Status"
            }, {
              "key": ["keyName"],
              "show_key": "Key Pair Name"
            }, {
              "key": ["monitoring", "state"],
              "show_key": "Monitoring"
            }, {
              "key": ["ipAddress"],
              "show_key": "Primary Public IP"
            }, {
              "key": ["dnsName"],
              "show_key": "Public DNS"
            }, {
              "key": ["privateIpAddress"],
              "show_key": "Primary Private IP"
            }, {
              "key": ["privateDnsName"],
              "show_key": "Private DNS"
            }, {
              "key": ["launchTime"],
              "show_key": "Launch Time"
            }, {
              "key": ["placement", "availabilityZone"],
              "show_key": "Zone"
            }, {
              "key": ["amiLaunchIndex"],
              "show_key": "AMI Launch Index"
            }, {
              "key": ["blockDeviceMapping", "item", "deleteOnTermination"],
              "show_key": "Termination Protection"
            }, {
              "key": ["blockDeviceMapping", "item", "status"],
              "show_key": "Shutdown Behavior"
            }, {
              "key": ["instanceType"],
              "show_key": "Instance Type"
            }, {
              "key": ["ebsOptimized"],
              "show_key": "EBS Optimized"
            }, {
              "key": ["rootDeviceType"],
              "show_key": "Root Device Type"
            }, {
              "key": ["placement", "tenancy"],
              "show_key": "Tenancy"
            }, {
              "key": ["networkInterfaceSet"],
              "show_key": "Network Interface"
            }, {
              "key": ["blockDeviceMapping", "item", "deviceName"],
              "show_key": "Block Devices"
            }, {
              "key": ["groupSet", "item", "groupName"],
              "show_key": "Security Groups"
            }
          ]
        },
        "DescribeVpnConnections": {
          "title": "vpnConnectionId",
          "sub_info": [
            {
              "key": ["state"],
              "show_key": "State"
            }, {
              "key": ["vpnGatewayId"],
              "show_key": "Virtual Private Gateway"
            }, {
              "key": ["customerGatewayId"],
              "show_key": "Customer Gateway"
            }, {
              "key": ["type"],
              "show_key": "Type"
            }, {
              "key": ["routes", "item", "source"],
              "show_key": "Routing"
            }
          ],
          "btns": [
            {
              "type": "download_configuration",
              "name": "Download Configuration"
            }
          ],
          "detail_table": [
            {
              "key": ["vgwTelemetry", "item"],
              "show_key": "VPN Tunnel",
              "count_name": "tunnel"
            }, {
              "key": ["outsideIpAddress"],
              "show_key": "IP Address"
            }, {
              "key": ["status"],
              "show_key": "Status"
            }, {
              "key": ["lastStatusChange"],
              "show_key": "Last Changed"
            }, {
              "key": ["statusMessage"],
              "show_key": "Detail"
            }
          ]
        },
        "DescribeVpcs": {
          "title": "vpcId",
          "sub_info": [
            {
              "key": ["state"],
              "show_key": "SvpcId"
            }, {
              "key": ["cidrBlock"],
              "show_key": "CIDR"
            }, {
              "key": ["instanceTenancy"],
              "show_key": "Tenancy"
            }
          ]
        }
      }
    };
    RegionModel = Backbone.Model.extend({
      defaults: {
        'resourse_list': null,
        'vpc_attrs': null,
        'unmanaged_list': null,
        'status_list': null
      },
      initialize: function() {
        var me;
        me = this;
        aws_model.on('AWS_RESOURCE_RETURN', function(result) {
          console.log('AWS_RESOURCE_RETURN');
          resource_source = result.resolved_data[current_region];
          me.setResource(resource_source);
          me.updateUnmanagedList();
          return null;
        });
        return null;
      },
      temp: function() {
        var me;
        me = this;
        return null;
      },
      updateUnmanagedList: function() {
        var me, resources_keys, time_stamp;
        me = this;
        time_stamp = new Date().getTime() / 1000;
        unmanaged_list = {};
        unmanaged_list.time_stamp = time_stamp;
        unmanaged_list.items = [];
        resources_keys = ['DescribeVolumes', 'DescribeLoadBalancers', 'DescribeInstances', 'DescribeVpnConnections', 'DescribeVpcs', 'DescribeAddresses'];
        console.log(resource_source);
        _.map(resources_keys, function(value) {
          var cur_attr, cur_tag;
          cur_attr = resource_source[value];
          cur_tag = value;
          _.map(cur_attr, function(value) {
            var name;
            if (me.hasnotTagId(value.tagSet)) {
              name = value.tagSet ? value.tagSet.name : null;
              switch (cur_tag) {
                case "DescribeVolumes":
                  if (!name) {
                    if (value.attachmentSet) {
                      if (value.attachmentSet.item) {
                        name = value.attachmentSet.item.device;
                      }
                    }
                  }
                  unmanaged_list.items.push({
                    'type': "Volume",
                    'name': (name ? name : value.volumeId),
                    'status': value.status,
                    'cost': 0.00,
                    'data-bubble-data': me.parseSourceValue(cur_tag, value, "unmanaged_bubble", name),
                    'data-modal-data': me.parseSourceValue(cur_tag, value, "detail", name)
                  });
                  break;
                case "DescribeInstances":
                  unmanaged_list.items.push({
                    'type': "Instance",
                    'name': (name ? name : value.instanceId),
                    'status': value.instanceState.name,
                    'cost': 0.00,
                    'data-bubble-data': me.parseSourceValue(cur_tag, value, "unmanaged_bubble", name),
                    'data-modal-data': me.parseSourceValue(cur_tag, value, "detail", name)
                  });
                  break;
                case "DescribeVpnConnections":
                  unmanaged_list.items.push({
                    'type': "VPN",
                    'name': (name ? name : value.vpnConnectionId),
                    'status': value.state,
                    'cost': 0.00,
                    'data-bubble-data': me.parseSourceValue(cur_tag, value, "unmanaged_bubble", name),
                    'data-modal-data': me.parseSourceValue(cur_tag, value, "detail", name)
                  });
                  break;
                case "DescribeVpcs":
                  unmanaged_list.items.push({
                    'type': "VPC",
                    'name': (name ? name : value.vpcId),
                    'status': value.state,
                    'cost': 0.00,
                    'data-bubble-data': me.parseSourceValue(cur_tag, value, "unmanaged_bubble", name),
                    'data-modal-data': me.parseSourceValue(cur_tag, value, "detail", name)
                  });
                  break;
              }
            }
            return null;
          });
          return null;
        });
        me.set('unmanaged_list', unmanaged_list);
        return null;
      },
      describeRegionAccountAttributesService: function(region) {
        var me;
        me = this;
        current_region = region;
        vpc_model.DescribeAccountAttributes({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), current_region, ["supported-platforms"]);
        vpc_model.on('VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', function(result) {
          var regionAttrSet;
          console.log('region_VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN');
          regionAttrSet = result.resolved_data.accountAttributeSet.item.attributeValueSet.item;
          if ($.type(regionAttrSet) === "array") {
            vpc_attrs_value = {
              'classic': 'Classic',
              'vpc': 'VPC'
            };
          } else {
            vpc_attrs_value = {
              'vpc': 'VPC'
            };
          }
          me.set('vpc_attrs', vpc_attrs_value);
          return null;
        });
        return null;
      },
      hasnotTagId: function(tagset) {
        if (tagset) {
          _.map(tagset, function(value) {
            if (value.key === "app-id" && value.value) {
              return false;
            }
          });
        }
        return true;
      },
      parseSourceValue: function(type, value, keys, name) {
        var cur_state, keys_to_parse, keys_type, me, parse_btns, parse_result, parse_sub_info, parse_table, state_key, status_keys, value_to_parse;
        me = this;
        keys_to_parse = null;
        value_to_parse = value;
        parse_result = '';
        parse_sub_info = '';
        parse_table = '';
        parse_btns = '';
        keys_type = keys;
        if (popup_key_set[keys]) {
          keys_to_parse = popup_key_set[keys_type][type];
        } else {
          keys_type = 'unmanaged_bubble';
          keys_to_parse = popup_key_set[keys_type][type];
        }
        status_keys = keys_to_parse.status;
        if (status_keys) {
          state_key = status_keys[0];
          cur_state = value_to_parse[state_key];
          _.map(status_keys, function(value, key) {
            if (cur_state) {
              if (key > 0) {
                cur_state = cur_state[value];
                return null;
              }
            }
          });
          if (cur_state) {
            parse_result += '"status":"' + cur_state + '", ';
          }
        }
        if (keys_to_parse.title) {
          if (keys === 'unmanaged_bubble' || 'bubble') {
            if (name) {
              parse_result += '"title":"' + name;
              if (value_to_parse[keys_to_parse.title]) {
                parse_result += '-' + value_to_parse[keys_to_parse.title];
                parse_result += '", ';
              }
            } else {
              if (value_to_parse[keys_to_parse.title]) {
                parse_result += '"title":"';
                parse_result += value_to_parse[keys_to_parse.title];
                parse_result += '", ';
              }
            }
          } else if (keys === 'detail') {
            if (name) {
              parse_result += '"title":"' + name;
              if (value_to_parse[keys_to_parse.title]) {
                parse_result += '(' + value_to_parse[keys_to_parse.title];
                parse_result += ')", ';
              }
            } else {
              if (value_to_parse[keys_to_parse.title]) {
                parse_result += '"title":"';
                parse_result += value_to_parse[keys_to_parse.title];
                parse_result += '", ';
              }
            }
          }
        }
        _.map(keys_to_parse.sub_info, function(value) {
          var cur_key, cur_value, key_array, show_key;
          key_array = value.key;
          show_key = value.show_key;
          cur_key = key_array[0];
          cur_value = value_to_parse[cur_key];
          _.map(key_array, function(value, key) {
            if (cur_value) {
              if (key > 0) {
                cur_value = cur_value[value];
                return cur_value;
              }
            }
          });
          if (cur_value) {
            parse_sub_info += '"<dt>' + show_key + ': </dt><dd>' + cur_value + '</dd>", ';
          }
          return null;
        });
        if (parse_sub_info) {
          parse_sub_info = '"sub_info":[' + parse_sub_info;
          parse_sub_info = parse_sub_info.substring(0, parse_sub_info.length - 2);
          parse_sub_info += ']';
        }
        if (keys_to_parse.detail_table) {
          parse_table = me.parseTableValue(keys_to_parse.detail, value_to_parse);
          if (parse_table) {
            parse_table = '"detail_table":' + parse_table;
            if (parse_sub_info) {
              parse_sub_info = parse_sub_info + ', ' + parse_table;
            } else {
              parse_sub_info = parse_table;
            }
          }
        }
        if (keys_to_parse.btns) {
          parse_btns = me.parseBtnValue(keys_to_parse.btns, value_to_parse);
          if (parse_btns) {
            parse_btns = '"btns":' + parse_btns;
            if (parse_sub_info) {
              parse_sub_info = parse_sub_info + ', ' + parse_btns;
            } else {
              parse_sub_info = parse_btns;
            }
          }
        }
        if (parse_result) {
          parse_result = '{' + parse_result;
          if (parse_sub_info) {
            parse_result += parse_sub_info;
          } else {
            parse_result = parse_result.substring(0, parse_result.length - 2);
          }
          parse_result += '}';
        }
        console.log(parse_result);
        return parse_result;
      },
      parseTableValue: function(keyes_set, value_set) {
        return null;
      },
      parseBtnValue: function(keyes_set, value_set) {
        var btn_date, parse_btns_result;
        parse_btns_result = '';
        btn_date = '';
        _.map(keyes_set, function(value) {
          var dc_date, dc_filename, dc_parse;
          btn_date = '';
          if (value.type === "download_configuration") {
            dc_date = {};
            dc_date.vpnConnectionId = value_set.vpnConnectionId ? value_set.vpnConnectionId : '';
            dc_date = MC.template.configurationDownload(dc_date);
            dc_filename = dc_date.vpnConnectionId ? dc_date.vpnConnectionId : 'download_configuration';
            dc_parse = '{filecontent: "';
            dc_parse += dc_date;
            dc_parse += '", filename: "';
            dc_parse += dc_filename;
            dc_parse += '",btnname:"';
            dc_parse += value.name;
            dc_parse += '"},';
            btn_date += dc_parse;
          }
          if (btn_date) {
            btn_date = btn_date.substring(0, btn_date.length - 1);
            parse_btns_result += '[';
            parse_btns_result += btn_date;
            return parse_btns_result += ']';
          }
        });
        return parse_btns_result;
      },
      setResource: function(resources) {
        var elb, lists;
        lists = {};
        elb = resources.DescribeLoadBalancers.LoadBalancerDescriptions;
        if ($.isEmptyObject(elb)) {
          lists.ELB = 0;
        } else if (elb.member.constructor === Array) {
          lists.ELB = elb.member.length;
        } else {
          lists.ELB = 1;
        }
        return console.error(lists);
      },
      describeAWSResourcesService: function(region) {
        var me, resources;
        me = this;
        current_region = region;
        resources = [constant.AWS_RESOURCE.INSTANCE, constant.AWS_RESOURCE.EIP, constant.AWS_RESOURCE.VOLUME, constant.AWS_RESOURCE.VPC, constant.AWS_RESOURCE.VPN, constant.AWS_RESOURCE.ELB];
        return aws_model.resource({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), region, resources);
      },
      describeAWSStatusService: function(region) {
        var me;
        me = this;
        current_region = region;
        aws_model.status({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), null, null);
        return aws_model.on('AWS_STATUS_RETURN', function(result) {
          var result_list, service_list;
          console.log('AWS_STATUS_RETURN');
          status_list = {
            red: 0,
            yellow: 0,
            info: 0
          };
          service_list = constant.SERVICE_REGION[current_region];
          result_list = result.resolved_data.current;
          _.map(result_list, function(value) {
            var cur_service, service_set, should_show_service;
            service_set = value;
            cur_service = service_set.service;
            should_show_service = false;
            _.map(service_list, function(value) {
              if (cur_service === value) {
                should_show_service = true;
              }
              return null;
            });
            if (should_show_service) {
              switch (service_set.status) {
                case '1':
                  status_list.red += 1;
                  return null;
                case '2':
                  status_list.yellow += 1;
                  return null;
                case '3':
                  status_list.info += 1;
                  return null;
                default:
                  return null;
              }
            }
          });
          me.set('status_list', status_list);
          return null;
        });
      }
    });
    model = new RegionModel();
    return model;
  });

}).call(this);
