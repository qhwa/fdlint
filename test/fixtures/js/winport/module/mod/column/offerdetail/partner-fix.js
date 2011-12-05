/**
	 * 老版旺铺判断是否有会员体系，依赖了旧的结构
	 * 这里加块狗皮膏药，根据新的结构判断是否发partner的请求（依赖 供应商信息板块的一个节点）
	 * 参见offerprototype.js
	 */
(function(){
	FYE.onDOMReady(function() {
		if (!isDiscountMember()) {
            return;
        }
        
        var notice = FYS('.dis-notice', 'mod-detail', true),
            span = FYS('span.member-discount', notice, true),
            url = '';
            
        if (span && (url = FYD.getAttribute(span, 'data-request-url'))) {
            FD.common.request('jsonp', url, { onCallback: onCallback });
        }
        
        function isDiscountMember() {
            return !!FYS('dl.member-service a.discount',null,true);  // 旺铺侧栏折扣节点
        }
        
        function onCallback(o) {
            span && (span.innerHTML = o.discount || '');
            FYD.setStyle(notice, 'display', 'block');
        }
    });
})();