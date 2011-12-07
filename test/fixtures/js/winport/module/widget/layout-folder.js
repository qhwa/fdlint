/**
 * @fileoverview 旺铺页面 展开/收缩 功能
 * 
 * @author long.fanl
 */
(function($,WP){
	
	var defaultOpt = {
		container : "#winport-content",
		folderClass : "wp-layout-folder",
		folderInClass : "folder-in", // folder收缩时的样式
		folderOutClass : "folder-out", // folder展开时的样式
		containerFoldOutClass : "wp-content-fold-out", // 展开时container的样式
		foldOutDir : ".main-wrap", // 展开的对象
		foldInDir : ".grid-sub" // 收缩的对象（现在只用css控制，用不到，若做其他交互效果，可以放开）
	};
	
	var LayoutFolder = function(opt){
		this.options = $.extend(defaultOpt, opt);
		this.init();
		return this.folder;
	}
	
	LayoutFolder.prototype = {
		init : function(){
			var opt = this.options;
			this.container = $(opt.container);
			if(this.container.length === 0){
				return;
			}
			this.createFolder();
			WP.UI.positionFixed(this.folder);
			this.initFolderEvent();
		},
		
		createFolder : function(){
			var self = this, opt = self.options, folder = $('<a href="#"></a>');
			folder.addClass(opt.folderClass).addClass(opt.folderInClass);
			folder.appendTo($(opt.foldOutDir,opt.container));
			this.folder = folder;
		},
		
		initFolderEvent : function(){
			var self = this, folder = this.folder,opt = self.options,
			container = this.container;
			
			folder.click(function(ev){
				if(folder.hasClass(opt.folderInClass)){
					folder.removeClass(opt.folderInClass).addClass(opt.folderOutClass);
					container.addClass(opt.containerFoldOutClass);
				}else{
					folder.removeClass(opt.folderOutClass).addClass(opt.folderInClass);
					container.removeClass(opt.containerFoldOutClass);
				}
				return false;
			});
		}
	}
	
	$.add("wp-switch-bar");
	WP.LayoutFolder = LayoutFolder;
	
})(jQuery, Platform.winport);