module.exports = {

    /*modify by xjimmy*/

    unittest: {
        url : 'http://localhost:<%= connect.options.port %>/test/index.html'
    },
    develop: {
        url: 'http://localhost:<%= connect.options.port %>/demo.html'
    },
    publish: {
        url: 'http://localhost:<%= connect.options.port %>/login.html'
    }

};