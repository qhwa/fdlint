/**
 * @fileoverview 联系方式
 * 
 * @author qijun.weiqj
 */
(function($, WP) {

var WPAlitalk = WP.mod.unit.WPAlitalk;

var ContactInfo = new WP.Class({
    init: function(div, config) {
      this.div = div;
      this.config = config;
      this.initMap();
      this.initAlitalk();
    },
    
    initAlitalk: function() {
      	var alitalk = $('a[data-alitalk]', this.div);
	      WPAlitalk.init(alitalk);
    },

	initMap: function() {
		var container = $('div.map-container', this.div),
			uid = null;

		if (!container.length) {
			return;
		}

		uid = $('#doc').data('docConfig').uid;

		$.add('vas-zqx', { js: ['http://style.china.alibaba.com/js/vas/hub/zqx.js'] });
		$.use('vas-zqx', function() {
			window.ZQX &&
			ZQX.init({
				prodid: '201',
				container: container[0],
				width: 174,
                height: 203,
                memberIds: uid,
                service: 'map'
            });
		});
	}

});
    
WP.ModContext.register('wp-contact-info-main', ContactInfo);	
WP.ModContext.register('wp-contact-info-sub', ContactInfo);	

})(jQuery, Platform.winport);

