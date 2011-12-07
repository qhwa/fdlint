/**
 * @fileoverview Offerdetail页面
 * 
 * @author long.fanl
 */
(function($,WP){
	
	var LayoutFolder = WP.LayoutFolder;
	
	var Offerdetail = {
		init : function(){
			this.initFolder(); // 初始化页面 收缩/展开功能
		},
		
		initFolder : function(){
			var detailFolder = new LayoutFolder();
		}
	}
	
	WP.ModContext.register('wp-offerdetail', Offerdetail);
	
})(jQuery,Platform.winport);
