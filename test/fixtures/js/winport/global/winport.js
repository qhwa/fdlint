/**
 * @fileoverview 旺铺基础类 NodeContext
 * 
 * @author qijun.weiqj
 */
(function($, WP) {

/**
 * ModeContext负责处理所有mod的初始化
 * 每个mod通过 ModContext.register(modId, config) 的方式注册到context中, 有两种调用方式
 * 	例：
 *  - ModContext.register('wp-supplier-info', { init: function()... });    // singleton 方式 
 *  - ModContext.register('wp-rec-advertisement', function(...);   // prototype方式
 * 
 * 默认情况下mod的config信息以JSON格式存于节点的 data-mod-config 属性上
 */
WP.ModContext = new WP.NodeContext('ModContext', { configField: 'modConfig' });


/**
 * 可使用PageContext代替原来的DomReady方法, 以进行统一管理
 */
WP.PageContext = new WP.NodeContext('PageContext');


})(jQuery, Platform.winport);
//~



