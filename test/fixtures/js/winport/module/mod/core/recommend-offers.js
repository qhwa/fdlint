/**
 * @fileoverview 精品offer推荐
 * 
 * @author qijun.weiqj
 */
(function($, WP) {

var Offers = WP.mod.unit.Offers,
	PagingSwitcher = WP.widget.PagingSwitcher;


/**
 * 主区域精品推荐
 */
WP.ModContext.register('wp-recommend-offers-main', function(div) {
	var uls = $('div.group', div),
		navs = $('div.paging a', div);
	new PagingSwitcher(navs, uls);
});


/**
 * 侧边栏精品推荐
 */
WP.ModContext.register('wp-recommend-offers-sub', function(div) {
	var imgs = $('div.image img', div),
		uls = $('ul', div),
		navs = $('div.paging a', div);

	Offers.resizeImage(imgs, 64);
	new PagingSwitcher(navs, uls);
});


})(jQuery, Platform.winport);
//~
