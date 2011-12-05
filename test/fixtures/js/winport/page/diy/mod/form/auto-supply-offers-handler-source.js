/**
 * @fileoverview 供应产品自动 
 * 
 * @author long.fanl
 */
(function($, WP){
	
	var SimpleHandler = WP.diy.form.SimpleHandler,
		InstantValidator = WP.widget.InstantValidator,
		previewUrl = ""; // 预览offerlist url
	
	WP.diy.form.AutoSupplyOffersHandler = $.extendIf({
		init: function(){
			SimpleHandler.init.apply(this, arguments);

			var form = this.form;

			previewUrl = $("a.auto-offer-preview-a", form)[0].href;
			
			togglePriceScope(form);
			initPriceInput();
			initPreviewFilter(form);
		}
	}, SimpleHandler);
	
	// 隐藏/显示 价格筛选框
	function togglePriceScope(form){
		var priceFilter = $("#price-filter"),
		priceStart = $("input.price-start"),
		priceEnd = $("input.price-end"),
		priceScopeWrap = $("div.price-scope-wrap",form);
		
		//如果默认选中，则显示价格区域
		if(priceFilter[0].checked){
			priceScopeWrap.css("visibility","visible");
		}
		
		priceFilter.click(function(){
			if(this.checked){
				priceScopeWrap.css("visibility","visible");
			}else{
				priceScopeWrap.css("visibility","hidden");
				priceStart.val("");
				priceEnd.val("");
			}
		});
	}
	
	// 限制价格输入框
	function initPriceInput() {
		InstantValidator.validate("input.price-start,input.price-end","price");
	}
	
	// 预览筛选结果
	function initPreviewFilter(form){
		$("a.auto-offer-preview-a",form).bind("click",function(){
			var params = {};
			params.userDefined = true;
			// 关键字
			var keywords = $("input.keywords",form).val();
			if($.trim(keywords) !== ""){
				params.keywords = keywords;
			}
			// 产品分类
			params.catId = $("select[name=catId]",form).val();
			// 信息类型
			if(!$("#all-type-offers-radio")[0].checked){
				params.groupFilter = $("#group-offers-radio")[0].checked;
				params.privateFilter = $("#private-offers-radio")[0].checked;
				params.mixFilter = $("#mix-offers-radio")[0].checked;
			}
			// 价格范围
			params.priceFilter = $("#price-filter")[0].checked;
			if(params.priceFilter){
				params.priceStart = $("input.price-start",form).val();
				params.priceEnd = $("input.price-end",form).val();
			}
			this.href = WP.Util.formatUrl(previewUrl,$.paramSpecial(params)+"#search-bar-in-column");
		});
	}
    
})(jQuery, Platform.winport);
//~
