/**
 * @fileoverview ·ÖÒ³
 * @author qijun.weiqj
 */
(function($, WP) {

var Util = WP.Util,
	InstantValidator = WP.widget.InstantValidator;


WP.mod.unit.Paging = Util.mkclass({

	init: function(div) {
		if (!div.length) {
			return;
		}
		
		this.div = div;
		this.pageUrl = div.data('paging-config').gotoPageUrl;
		this.currentPage = parseInt($('a.current', div).html(), 10);
		this.pageCount = parseInt($('em.page-count', div).html(), 10);
		this.pnumInput = $('input.pnum', div);
		
		this.handlePageNum();
		this.handleGotoPage();
	},
	
	handlePageNum: function() {
		var self = this;
		
		InstantValidator.validate(this.pnumInput, 'pagenum');
		
		this.pnumInput.keydown(function(e){
			if(e.keyCode === 13){
				self.gotoPage();
				return false;
			}
		});
	},
	
	handleGotoPage: function() {
		var self = this;
		$('a.goto-page', this.div).click(function(e){
			e.preventDefault();
			self.goToPage();
		});
	},
	
	goToPage: function() {
		var pageCount = this.pageCount,
			pnum = parseInt(this.pnumInput.val(), 10);
		
		if (!pnum || pnum === this.currentPage) {
			return;
		}
		
		pnum = pnum > pageCount ? pageCount :
				pnum < 1 ? 1 : pnum;
				
		FE.util.goTo(this.pageUrl.replace('(PAGE_NUM_PLACEHOLDER)', pnum));
	}
	
});
//~ Paging

})(jQuery, Platform.winport);
