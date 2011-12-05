/**
 * @fileoverview JS翻页组件
 * 
 * @author denis
 */
(function($, WP) {

	var InstantValidator = WP.widget.InstantValidator;
	
	/**
	 * JS翻页
	 * 回调: pageClick, onRender
	 * @param {Object} context
	 * @param {Object} config
	 */
	var Paging = function(context, config){
		this.context = context;
	    this.config = config || new Object();
	};
	
	Paging.Content = 
		'<div class="<%=className%>">\
			<ul>\
			    <li class="pagination"></li>\
			    <li>共<em class="page-count"> </em>页/<em class="item-count"></em><%=itemUnit%> 到<input class="pnum" maxlength="4" autocomplete="off" type="text">页</li>\
			    <li><a class="goto-page" href="#"><span class="btn-l"><em>确 定</em></span><span class="btn-r"></span></a></li>\
			</ul>\
		</div>';

	Paging.DefaultClass = {
		"className":"common-paging",
		"itemUnit" : "个"
	};
	
	Paging.prototype = {
	    init: function(cur, pageSize,itemCount){
			this.pageSize = pageSize;
			this.create();
			this.pageSubmit();
			this.pageNumInit();
	        this.render(cur, Math.ceil(itemCount/pageSize),itemCount);
	    },
		
		// 创建并插入（目前只有append）分页节点
		create : function(){
			var cssConfig = $.extend({},Paging.DefaultClass,this.config.css),
				paging = $(FE.util.sweet(Paging.Content).applyData(cssConfig));
				
			this.context.append(paging);
			
		    this.pagination = $('li.pagination', paging);
		    this.pageCount = $('em.page-count', paging);
			this.itemCount = $('em.item-count',paging);
		    this.pageNum = $('input.pnum', paging);
			this.gotoPage = $('a.goto-page',paging);
		},
		
		// 为翻页确定按钮添加事件 
		pageSubmit : function(){
			this.gotoPage.bind("click",this,function(e){
				var scope = e.data,
				pnum = scope.pageNum.val()*1,
				pageCount = scope.pageCount.html()*1,
				itemCount = scope.itemCount.html()*1,
				curr = $("a.current",scope).html()*1;
				if(pnum === 0 || pnum === curr){
					return false;
				}
				pnum = (pnum > pageCount) ? pageCount : 
							  (pnum > 1) ? pnum : 1;
				if(scope.config.pageSubmit){
					scope.config.pageSubmit.call(scope,pnum);
				}
				scope.render(pnum, pageCount,itemCount);
				return false;
			});
		},
		
		// 页数输入框事件初始化
		pageNumInit : function(){
			
	        this.pageNum.bind('focus',function(){
	            this.select();
	        });
	        this.pageNum.bind('keydown', this,function(e){
	            if (e.keyCode && e.keyCode == 13) {
	                e.data.gotoPage.click();
	                this.select();
	            }
	        });
			
			InstantValidator.validate(this.pageNum,"pagenum");
		},
		
	    /*
	     *   creat page info
	     *   @param  cur         index of page from 1
	     *   @param  total       total page number from 1
	     *   @param  pagination   dom that render paging
	     */
	    render: function(cur, total,itemCount){
	        if (cur < 1) 
	            cur = 1;
	        if (total < 1) 
	            total = 1;
	        if (cur > total) 
	            cur = total;
	        var html = [], pre, next;
	        //total page
	        this.pageCount.html(total);
			this.itemCount.html(itemCount);
	        this.pageNum.data("max",total);
	        
	        if (cur == 1) {
	            html.push('<a class="pre-disabled" href="javascript:;"> </a>');
	            html.push('<a class="current" href="javascript:;">1</a>');
	        }
	        else {
	            html.push('<a class="pre" href="javascript:;" data-page="' + (cur - 1) + '"> </a>');
	            html.push('<a href="javascript:;" data-page="1">1</a>');
	        }
	        if (total > 1) {
	            if (cur > 4 && total > 7) 
	                html.push('<a class="omit" href="javascript:;">...</a>');
	            //cur==1?
	            if (cur < 3) {
	                pre = 0;
	                next = cur == 1 ? 5 : 4;
	                if (cur + next > total) 
	                    next = total - cur;
	            }else if (cur == 3) {
	                pre = 1;
	                next = 3;
	                if (cur + next > total) 
	                    next = total - cur;
	            }else {
	                pre = 2;
	                next = 2;
	                if (cur + next > total) 
	                    next = total - cur;
	                pre = 4 - next;
	                if (cur + 3 > total) 
	                    pre++;
	                if (cur - pre < 2) 
	                    pre = cur - 2;
	            }
	            
	            for (var i = pre; 0 < i; i--) 
	                html.push('<a href="javascript:;" data-page="' + (cur - i) + '">' + (cur - i) + '</a>');
	            if (cur > 1) 
	                html.push('<a class="current" href="javascript:;">' + cur + '</a>');
	            for (var i = 1; i < next + 1; i++) 
	                html.push('<a href="javascript:;" data-page="' + (cur + i) + '">' + (cur + i) + '</a>');
	            
	            if (cur + next < total - 1) {
	                html.push('<a class="omit" href="javascript:;">...</a>');
	                html.push('<a href="javascript:;" data-page="' + total + '">' + total + '</a>');
	            }
	            if (cur + next == total - 1) 
	                html.push('<a href="javascript:;" data-page="' + total + '">' + total + '</a>');
	        }
	        if (cur == total){
	            html.push('<a class="next-disabled" href="javascript:;">下一页</a>');
			}else{
	            html.push('<a class="next" href="javascript:;" data-page="' + (cur + 1) + '">下一页</a>');
	        }
	        this.pagination.html(html.join(''));
	        //trigger onRender
	        if (this.config.onRender) 
	            this.config.onRender.call(this);
	        //set nomarl
	        if (this.pageNum.val() && this.pageNum.val() * 1 > total) 
	            this.pageNum.val(cur);
	        $('a[data-page]', this.pagination).bind('click',this, function(e){
				var scope = e.data,
	            page = $(this).data('page') * 1;
	            scope.render(page, total);
				if(scope.config.pageClick){
					scope.config.pageClick.call(scope,page);
				}
				return false;
	        });
	    }
	};

	WP.widget.Paging = Paging;
	$.add('wp-paging');

})(jQuery, Platform.winport);
//~
