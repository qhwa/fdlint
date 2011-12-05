/**
 * @fileoverview 旺铺布局相关公共方法
 * 
 * @author long.fanl
 */
(function($,WP){
	
var Component = $.extendIf({
	
	/**
	 * 获取页面布局结构, page -> segment-> layout-> region-> widget
	 * 每个组件只需要cid和可选的sid数据
	 */
	getPageLayout: function() {
		var self = this,
			page = $('#content'),
			pageLayout = this._getData(page, 'contentConfig', pageVisit);
			
		return JSON.stringify(pageLayout[0]);
		
		
		function pageVisit(page, data) {
			var segments = $('div.segment', page);
			data.segments = self._getData(segments, 'segmentConfig', segmentVisit);
		}
		
		function segmentVisit(segment, data) {
			var layouts = $('div.layout-box', segment);
			data.layouts = self._getData(layouts, 'boxConfig', layoutVisit);
		}
		
		function layoutVisit(layout, data) {
			var regions = $('div.region', layout);
			data.regions = self._getData(regions, 'regionConfig', regionVisit);
		}
		
		function regionVisit(region, data) {
			var mods = $("div.mod-box:not(.ui-portlets-placeholder)", region);
			data.widgets = self._getData(mods, 'boxConfig');
		}
	},

	_getData: function(components, configField, visit) {
		var result = [];
		components.each(function() {
			var elm = $(this),
				config = elm.data(configField),
				data = {};
				
			config.cid !== undefined && (data.cid = config.cid);
			config.sid !== undefined && (data.sid = config.sid);
			
			visit && visit(elm, data);
			
			result.push(data);
		});
		return result;
	},

	/**
	 * region相关的post请求，需要提交以下参数
	 */
	getRegionPostData: function(region) {
		var contentCfg = this.getContentConfig(),
			layoutCfg = region.closest('div.layout-box').data('boxConfig');
		
		return {
			pageCid: contentCfg.cid,
			pageSid: contentCfg.sid,
			segment: region.closest('div.segment').data('segmentConfig').cid,
			layoutCid: layoutCfg.cid,
			layoutSid: layoutCfg.sid,
			region: region.data('regionConfig').cid,
			_csrf_token: this.getDocConfig()._csrf_token
		};
	}

}, WP.Component);

WP.diy.Component = Component;

})(jQuery,Platform.winport);
