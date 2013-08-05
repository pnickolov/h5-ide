define(['jquery', 'event'], function($, ide_event){
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
		jsonViewFrame = $('#json_view_frame');
		jsonViewFrame.width(650)
			.height(document.body.clientHeight - 20);
		compObj = MC.canvas_data.component[comp_uid];
		if(compObj) {
			jsonViewFrame[0].contentWindow.postMessage(JSON.stringify(compObj), '*');
		}else{
			jsonViewFrame[0].contentWindow.postMessage('{"none": "none"}', '*');
			//jsonViewFrame.hide();
		}
	});
	
});