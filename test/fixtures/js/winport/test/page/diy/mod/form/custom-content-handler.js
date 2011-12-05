/**
 * 自定义内容FormHandler单元测试
 * @author qijun.weiqj
 */
(function($, WP) {

module('diy.form.CustomContentHandler');

WP.diy.form.SimpleHandler = WP.diy.form.SimpleHandler || {};

require('page/diy/mod/form/custom-content-handler-source');


test('fitlerValue-过滤标签中的id和class属性', function() {
	var html = 
'<div id="header" class="mod" style="width: 100px; height: 100px;">\
	<div id="helloabc" class="myclass">\
		这个是自定义内容\
	</div>\
</div>',
		expect =
'<div   style="width: 100px; height: 100px;">\
	<div  >\
		这个是自定义内容\
	</div>\
</div>',
	Handler = WP.diy.form.CustomContentHandler;

	equal(Handler.filterValue(html), expect);
});

	
})(jQuery, Platform.winport);


