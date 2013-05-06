var https = require('https');
var fs = require('fs');

module.exports.proxyMiddleware = function(req, res, next){
	
	if(req.method != 'POST'){
		return next();
	}

	var reqPath = req.originalUrl;

	var requestStr = JSON.stringify(req.body);

	var options = {
		hostname: 'api.madeiracloud.com',
		path: reqPath,
		method: 'POST',
		headers: {
			'Content-Length': requestStr.length
		}
	};

	var proxyReq = https.request(options, function(proxyRes) {
		var result = '';
		proxyRes.on('data', function(data) {
			result += data;
		});
		proxyRes.on('end', function(){
			console.log(result);
			res.end(result);
		});
	});

	proxyReq.end(requestStr);

	proxyReq.on('error', function(err) {
		console.error(err);
	});

	//next();
};