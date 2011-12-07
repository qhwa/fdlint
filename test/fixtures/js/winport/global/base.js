/**
 * @fileoverview 旺铺名字空间申明
 * 
 * 所有旺铺中使用的公共类都需要定义在名字空间Platform.winport下,
 * 也可以基于以下结构进行编写
 * 
 * 不允许使用全局名字空间
 * 
 * <code>
 *  (function($, WP) {
 *  	...
 *  })(jQuery, Platform.winport);
 * </code>
 * 
 * @author qijun.weiqj
 */
jQuery.namespace(
	'Platform.winport', 
	'Platform.winport.widget',		// 业务无关组件
	'Platform.winport.mod', 		// 板块
	'Platform.winport.mod.unit',	// 板块相关公共代码
	'Platform.winport.unit'			// TODO 后续去掉mod.unit名字空间 
);
//~

jQuery.DEBUG = false;	// 调试开关, 打开后将输出日志
