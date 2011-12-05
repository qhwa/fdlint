/**
 * @fileovewview 最新供应
 * 
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Offers = WP.mod.unit.Offers;
	
/**
 * 侧边栏最新供应
 */
WP.ModContext.register('wp-new-supply-offers-sub', function(div) {
	var imgs = $('div.image img', div);
	Offers.resizeImage(imgs, 64);
});


})(jQuery, Platform.winport);
//~
