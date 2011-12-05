/**
 * @fileoverview Offer业务相相关公共JS
 * @author qijun.weiqj
 */
(function($, WP) {

var UI = WP.UI;
	
WP.mod.unit.Offers = {

	resizeImage: function(selector, size) {
		var imageServer = $('#doc').data('doc-config').imageServer,
			noPic = $.util.substitute(
					'/images/app/platform/winport/mod/offers/nopic-{0}.png', [size]);
		return UI.resizeImage(selector, size, imageServer + noPic);
	},
	
	/**
	 * offer列表过滤面板
	 *  标价, 混批, 授权可见, 团批 
	 */
	initFiltersPanel: function(div) {
		var self = this,

			filterConfig = div.data('filter-config'),
		
			filterDiv = $('div.filter', div),
			price = $('input.price-filter', filterDiv),
			mix = $('input.mix-filter', filterDiv),
			privateFilter = $('input.private-filter', filterDiv),
			group = $('input.group-filter', filterDiv),
			
			filter = 'input.price-filter,input.mix-filter,input.private-filter,input.group-filter',
			
			getValue = function(check) {
				return check.prop('checked') ? 'true' : 'false';
			};

		filterDiv.delegate(filter, 'click', function() {
			var url = filterConfig.noneFilterUrl;
			
			url = url.replace(/priceFilter=false/, 'priceFilter=' + getValue(price));
			url = url.replace(/mixFilter=false/, 'mixFilter=' + getValue(mix));
			url = url.replace(/privateFilter=false/, 'privateFilter=' + getValue(privateFilter));
			url = url.replace(/groupFilter=false/, 'groupFilter=' + getValue(group));
			
			window.location.href = url
		});
	}
	
};
//~ Offers

})(jQuery, Platform.winport);
