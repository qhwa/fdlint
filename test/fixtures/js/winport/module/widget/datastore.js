/**
 * @fileoverview 用于减少ajax请求
 * 
 * @author qijun.weiqj
 */
(function($, WP) {


var Util = WP.Util;


var DataStore = {

	request: function(key, url, options) {	
		var opts = $.extend({}, options);

		key = 'data-' + key;
		opts.url = url;
		delete opts['success'];

		$.add(key, opts);
		$.use(key, function() {
			options.success.apply(options, arguments);	
		});

	}

};
//~ Util

WP.widget.DataStore = DataStore;
$.add('wp-datastore');


})(jQuery, Platform.winport);
//~
