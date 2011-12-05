/*
* 旺铺新版装修向导
* @param DATA 用于展示的数据 增加（在需要增加的位置插入一条标准数据即可） 删除（删除DATA中的指定数据即可，DATA中的数据不能小于3条）
* @param 0 标题
* @param 1 内容
* @param 2 大背景图片地址
* @param 3 数组 高亮显示图片参数 对应 0 图片地址 1 左边界距离 2 顶部距离 
* @param 4 dialog 三角tip样式 1,2,3为上（1,2,3位置不同）  4为下  5为左 为空表示没有tip
* @param 5 数组 dialog定位 0 左边界距离 1 顶部距离
* @author deming.wei
*/
(function(window,undefined){
var DATA =[
   ["模板更多样","根据版本不同，提供最多80套的模板可供选择，主题设置、布局风格、页面管理更轻松；","http://img.china.alibaba.com/cms/upload/detail/11011015/images/Guide_02.jpg",["http://img.china.alibaba.com/cms/upload/detail/11011015/images/Highlight01.jpg","25","37"],"1",["200","359"]],
   ["招牌更炫丽","招牌高度由原来90像素增加到200像素，企业形象更突出，给买家留下深刻印象；","http://img.china.alibaba.com/cms/upload/detail/11011015/images/Guide_01.jpg",["http://img.china.alibaba.com/cms/upload/detail/11011015/images/Highlight02.png","25","45"],"2",["445","425"]],
   ["操作更简单","像傻瓜照相机般简单的操作设计，双击进行板块设置，拖动移动板块位置，操作方式更简单易用；","http://img.china.alibaba.com/cms/upload/detail/11011015/images/Guide_03.jpg",["http://img.china.alibaba.com/cms/upload/detail/11011015/images/Highlight03.png","0","0"],"5",["400","498"]],
   ["版块更丰富","更丰富的板块内容，更直观的板块选择，板块容器让您添加板块更快捷；","http://img.china.alibaba.com/cms/upload/detail/11011015/images/Guide_01.jpg",["http://img.china.alibaba.com/cms/upload/detail/11011015/images/Highlight04.png","0","0"],"3",["45","420"]],
   ["自定义分类","自定义设置产品所属类别，二级分类、图片展示，使产品分类更专业；","http://img.china.alibaba.com/cms/upload/detail/11011015/images/Guide_06.jpg",["http://img.china.alibaba.com/cms/upload/detail/11011015/images/Highlight05.png","0","0"],"4",["235","359"]],
   ["自定义板块","自定义板块随心设计，随意添加图片内容，自主写入设计代码，展示样式更绚丽；","http://img.china.alibaba.com/cms/upload/detail/11011015/images/Guide_07.jpg",["http://img.china.alibaba.com/cms/upload/detail/11011015/images/Highlight06.png","0","0"],"5",["500","87"]],
   ["现在立即装修你的旺铺吧","&nbsp;","http://img.china.alibaba.com/cms/upload/detail/11011015/images/Guide_01.jpg","","",["307","400"]]
  ];
var Guide = function(DATA){
	this.init.apply(this,arguments);
}
	
Guide.prototype={
	init:function(){
		this.DATA = DATA;
		this.TITLE = jQuery('h2','.dialog_main');
		this.CONTENT = jQuery('p','.dialog_main');
		this.DIALOGMAIN = jQuery('div.dialog_main');
		this.HIGHLIGHT = jQuery('div.dialog_main2');
		this.TIPBAR = jQuery('div.tipbar');
		this.BOTTON = jQuery('.botton','.dialog_main');
		this.TOPCLOSE = jQuery('.topclose');
		this.DIALOG_CLOSE = jQuery('span.dialog_close');
		this.DIALOG = jQuery('.dialog');
		this.LISTNUM =jQuery('span.listnum');
		this.ELM = jQuery('span.btn1');
		this.NUM = DATA.length;
		this.BGIMG = jQuery('img','.container');
		this.STEP = 0;
		this.bind();
		this.tipbar();
	},
	bind:function(){
		var self = this;
			jQuery(self.ELM).bind('click',function(e){
				e.preventDefault();
				if(self.STEP>self.NUM-1){
					window.close();
					return false;
				}
				self.HIGHLIGHT.fadeOut(0);
				self.render(self.STEP)
				self.STEP = self.STEP+1;
			});
			jQuery(self.DIALOG_CLOSE).bind('click',function(e){
				e.preventDefault();
				window.close();
			})
	},
	bindPrev:function(){
		var self = this;
			jQuery('span.prev').bind('click',function(e){
				e.preventDefault();
				self.HIGHLIGHT.fadeOut(0);
				if(self.STEP<2){
					return false;
				}else if(self.STEP===2){
					jQuery('span').remove('.prev');
				}
				self.render(self.STEP-2);
				self.STEP = self.STEP-1;
			})
	},
	render:function(i){
		var self = this;
		this.DIALOG.addClass('dialogclass')
		this.BGIMG.attr('src',DATA[i][2]);
		this.TITLE.html(DATA[i][0]);
		this.HIGHLIGHT.css({"left":""+DATA[i][3][1]+"px","top":""+DATA[i][3][2]+"px"});
		this.HIGHLIGHT.html('<img src="'+DATA[i][3][0]+'" />');
		this.DIALOGMAIN.animate({"left":""+DATA[i][5][0]+"px","top":""+DATA[i][5][1]+"px"},500);
		this.CONTENT.html(DATA[i][1]);
		jQuery(self.ELM).html('下一步');
		this.tipbar(DATA[i][4]);
		switch(i){
			case 1: 
			jQuery('span').remove('.prev');
			self.BOTTON.prepend('<span class="prev">上一步</span>');
			self.bindPrev();
			break;
			case self.NUM-1:
			jQuery('span').remove('.prev');
			jQuery('span').remove('.listnum');
			self.DIALOG.removeClass('dialogclass');
			this.HIGHLIGHT.html('');
			jQuery(self.ELM).html('开始');

		}
		if(self.LISTNUM){
			jQuery(self.LISTNUM).html(""+(i+1)+"/"+(self.NUM-1)+"");
		}
		self.HIGHLIGHT.fadeIn(1000);
	},
	tipbar:function(i){
		switch(i-0){
			case 1:
			this.TIPBAR.css({
							"display":"block",
							"left":"25px",
							"top":"-30px",
							"background-position":"0 0"
							});
			break;
			case 2:
			this.TIPBAR.css({
							"display":"block",
							"left":"20px",
							"top":"-30px",
							"background-position":"0 -40px"
							});
			break;
			case 3:
			this.TIPBAR.css({
							"display":"block",
							"left":"340px",
							"top":"-30px",
							"background-position":"0 0"
							});
			break;
			case 4:
			this.TIPBAR.css({
							"display":"block",
							"left":"-30px",
							"top":"75px",
							"background-position":"0 -120px"
							});
			break;
			case 5:
			this.TIPBAR.css({
							"display":"block",
							"left":"312px",
							"top":"200px",
							"background-position":"0 -80px"
							});
			break;
			default:
			this.TIPBAR.css({"display":"none"});

		}
	}
}
window.Guide  = Guide;
})(window)
jQuery(function(){
	new Guide();
	jQuery.use('ui-dialog', function(){
			var dialog1 = jQuery('div.dialogbg');
			dialog1.dialog({
				draggable: false,
				bgiframe: true
			});
	});
})

