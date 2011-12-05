/**
 * @fileoverview 推荐相册板块
 * 
 * @author long.fanl
 */
(function($, WP) {

var UI = WP.UI,
	PagingSwitcher = WP.widget.PagingSwitcher;

/**
 * 主区域推荐相册
 */
WP.ModContext.register('wp-recommend-albums-main', function(div) {
	var uls = $('div.group', div),
		navs = $('div.paging a', div);
	new PagingSwitcher(navs, uls);
});


/**
 * 侧边栏推荐相册
 */
WP.ModContext.register('wp-recommend-albums-sub', function(div) {
	var imgs = $('div.image img', div),
		uls = $('ul', div),
		navs = $('div.paging a', div);

	UI.resizeImage(imgs, 64);
	new PagingSwitcher(navs, uls);
});


})(jQuery, Platform.winport);
//~
