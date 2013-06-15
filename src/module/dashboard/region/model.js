(function() {
  define(['backbone', 'jquery', 'underscore', 'aws_model', 'vpc_model', 'constant'], function(Backbone, $, _, aws_model, vpc_model, constant) {
    var RegionModel, current_region, model, resource_source, unmanaged_list, update_timestamp, vpc_attrs_value;
    current_region = null;
    resource_source = null;
    vpc_attrs_value = null;
    unmanaged_list = null;
    update_timestamp = 0;
    RegionModel = Backbone.Model.extend({
      defaults: {
        'resourse_list': null,
        'vpc_attrs': null,
        'unmanaged_list': null
      },
      initialize: function() {
        var me;
        me = this;
        aws_model.on('AWS_RESOURCE_RETURN', function(result) {
          console.log('AWS_RESOURCE_RETURN');
          resource_source = result.resolved_data[current_region];
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
        var me, time_stamp;
        me = this;
        time_stamp = new Date().getTime() / 1000;
        unmanaged_list = {};
        unmanaged_list.time_stamp = time_stamp;
        console.log('unmanaged_list');
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
      describeAWSResourcesService: function(region) {
        var me, resources;
        me = this;
        current_region = region;
        resources = [constant.AWS_RESOURCE.INSTANCE, constant.AWS_RESOURCE.EIP, constant.AWS_RESOURCE.VOLUME, constant.AWS_RESOURCE.VPC, constant.AWS_RESOURCE.VPN, constant.AWS_RESOURCE.ELB];
        aws_model.resource({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), region, resources);
        return me.updateUnmanagedList();
      }
    });
    model = new RegionModel();
    return model;
  });

}).call(this);
