/**
 * @fileoverview ±à¼­°å¿é
 * @author long.fanl
 */
(function($,WP){
	
var ModBox = WP.diy.ModBox;
	
		
var BoxEditHandler = {
	
	operation: 'edit',

	operate: function(box) {
		return ModBox.edit(box);
	}
	
}


WP.diy.BoxOperateHandler.edit = BoxEditHandler;

	
})(jQuery,Platform.winport);

