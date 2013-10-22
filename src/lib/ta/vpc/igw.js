(function() {
  define(['MC', 'constant'], function(MC, constant) {
    var addIGWToCanvas;
    addIGWToCanvas = function() {
      var component_size, coordinate, node_option, resource_type, vpc_coor, vpc_data, vpc_id;
      resource_type = constant.AWS_RESOURCE_TYPE;
      vpc_id = $('.AWS-VPC-VPC').attr('id');
      vpc_data = MC.canvas.data.get("layout.component.group." + vpc_id);
      vpc_coor = vpc_data.coordinate;
      component_size = MC.canvas.COMPONENT_SIZE[resource_type.AWS_VPC_InternetGateway];
      node_option = {
        groupUId: vpc_id,
        name: "IGW"
      };
      coordinate = {
        x: vpc_coor[0] - component_size[1] / 2,
        y: vpc_coor[1] + (vpc_data.size[1] - component_size[1]) / 2
      };
      return MC.canvas.add(resource_type.AWS_VPC_InternetGateway, node_option, coordinate);
    };
    return {
      addIGWToCanvas: addIGWToCanvas
    };
  });

}).call(this);
