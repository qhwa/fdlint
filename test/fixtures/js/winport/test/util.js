/**
 * 测试工具方法
 * @author qijun.weiqj
 */
(function() {

var cache = {};
window.require = function(path, base) {
	var prefix = 'http://style.china.alibaba.com/js/';
	base = base || window.APP_BASE || '';
	path = base.replace(/^\//, '').replace(/\/$/, '') + '/' + path.replace(/^\//, '').replace(/\.js$/, '');
	if (cache[path]) {
		return;
	}
	cache[path] = true;
	document.write('<script type="text/javascript" src="' + prefix + path + '.js"></scr'+'ipt>');
}

	
})();

