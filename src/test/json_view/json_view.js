define(['jquery', 'event', 'underscore'], function($, ide_event, _){

	if(!$('#json_view_frame').length) {
		$('body').append('<iframe src="test/json_view/json_view.html" ' +
			'style="border:0;position:absolute;z-index:9999999;display:none;top:20px;bottom:0;left:20px;"' +
			' id="json_view_frame"></iframe>');
	}
	if(!$('#json_view_toggle').length) {
		$('body').append('<div id="json_view_toggle" style="width:20px;height:20px;background-color:#fff;position: absolute;"></div>');
		$('#json_view_toggle').click(function(){
			$('#json_view_frame').toggle();
		});
	}

	ide_event.onLongListen(ide_event.OPEN_PROPERTY, function(type, comp_uid){
		var comp_data = MC.canvas_data.component,
			comp_layout = MC.canvas_data.layout.component,
			span_radio = $("#span_radio",document.getElementById("json_view_frame").contentWindow.document);

		jsonViewFrame = $('#json_view_frame');
		jsonViewFrame.width(650)
			.height(document.body.clientHeight - 20);

		compObj = comp_layout.group[comp_uid] ? comp_layout.group[comp_uid] : comp_layout.node[comp_uid] ;

		if(compObj) {

			span_radio.hide();

			//visible component
			var visibleComp = {
				layout: comp_layout.group[comp_uid] ? comp_layout.group[comp_uid] : comp_layout.node[comp_uid],
				data: compObj.originalId ? comp_data[compObj.originalId] : comp_data[comp_uid]
			};
			jsonViewFrame[0].contentWindow.postMessage(JSON.stringify(visibleComp), '*');

		}else{

			span_radio.show();

			var show_stack = $("input[name='radio_type']:checked",document.getElementById("json_view_frame").contentWindow.document);

			if (show_stack.val()==="stack")
			{//show whole stack json
				jsonViewFrame[0].contentWindow.postMessage(JSON.stringify(MC.canvas_data), '*');
			}
			else
			{
				//show all invisible component json
				invisibleCompAry = [];
				_.each(MC.canvas_data.component, function(compObj){
					if(compObj.type == 'AWS.EC2.KeyPair' || compObj.type == 'AWS.EC2.SecurityGroup' || compObj.type == 'AWS.EC2.EIP' || compObj.type == 'AWS.VPC.NetworkInterface' ||
						compObj.type == 'AWS.VPC.DhcpOptions' || compObj.type == 'AWS.VPC.NetworkAcl' || compObj.type == 'AWS.IAM.ServerCertificate'){
						invisibleCompAry.push(compObj);
					}
				});
				jsonViewFrame[0].contentWindow.postMessage(JSON.stringify(invisibleCompAry), '*');
			}

			//jsonViewFrame.hide();
		}
	});

});