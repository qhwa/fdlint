/**
 * @fileoverview 二级栏目页 联系方式
 * 
 * @author qijun.weiqj
 */
(function($, WP) {

var WPAlitalk = WP.mod.unit.WPAlitalk,
	TraceLog = WP.widget.TraceLog;

var ContactInfo = new WP.Class({
    init: function(div, config) {
      this.div = div;
      this.config = config;
      this.initMap();
	  this.feedBackTraceLog();
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

		$.add('vas-zqx', { js: ['http://style.china.alibaba.com/js/vas/hub/zqx.js'] });
		$.use('vas-zqx', function() {
			window.ZQX &&
			ZQX.init({
				prodid: '200',
				container: container[0],
				width: 718,
                height: 328,
                memberIds: WP.Component.getDocConfig().uid,
                service: 'map'
            });
		});
	},

	feedBackTraceLog: function(){
		var docCfg = $('#doc').data('docConfig'),
			params = {
				toid: WP.Component.getDocConfig().uid,
				fromid: FE.util.lastLoginId || 'notmember',
				sourcetype: this.config.contactFrom || 'athena',
				domainType: docCfg.isTopDomain ? 'www' : '',
				time: $.now()
			},
			cosite = $.util.cookie('cosite');

		if (cosite) {
			params.fromsite = cosite;
		}

		new TraceLog(this.div, {
			when: 'exposure', 
			url: 'http://page.china.alibaba.com/shtml/static/forfeedbacklog.html',
			param: params 
		})
	}
    
});

WP.ModContext.register('wp-contact-info-column', ContactInfo);


})(jQuery, Platform.winport);
