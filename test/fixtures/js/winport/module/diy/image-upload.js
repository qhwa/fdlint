/**
 * @fileoverview DIY后台图片上传类
 * 
 * @author qijun.weiqj
 */
(function($, WP) {


var Util = WP.Util;


var ImageUpload = Util.mkclass({
	
	init: function(panel, config){
		this.panel = panel;
		this.config = config;
		
		var preview = (this.preview = $('div.preview', panel));
		this.img = $('img', preview);
		this.remove = $('a.remove', preview);
		this.pathInput = $('input.path', preview);
		this.message = $('div.message', panel);
		
		this.initPreview();
		this.handleUpload();
		this.handleRemove();
	},
	
	/**
	 * 初始化预览图
	 */
	initPreview: function(){
		if (!this.img.length) {
			this.img = $('<img />').prependTo(this.preview);
		}
		
		var src = this.img.attr('src'),
			path = this.pathInput.val();
		if (!src && path) {
			this.img.attr('src', path);
			src = path;
		}
		src && this.preview.show();
	},
	
	/**
	 * 处理上传
	 */
	handleUpload: function(){
		var self = this, 
			config = this.config, 
			url = config.imageUploadUrl, 
			upload = $('div.upload', this.panel), 
			loading = $('div.loading', this.panel);
		
		$.use('ui-flash-uploader', function(){
			upload.flash({
				module: 'uploader'
			});
			
			upload.bind('fileSelect.flash', function(e, data) {
				$(this).flash('uploadAll', url, {
					_csrf_token: config._csrf_token,
					name: 'file1',
					memberId: config.uid,
					source: 'winport_diy',
					drawFootTxt: false,
					noScale: config.noScale
				});
			});
			
			upload.bind('uploadStart.flash compressStart.flash', function(e) {
				$.log('ImageUpload: ' + e.type);
				
				self.showMessage(false);
				loading.show();
			});
			
			upload.bind('uploadCompleteData.flash', function(e, o) {
				$.log('ImageUpload: uploadComplete');
				
				loading.hide();

				var data = o.data || {};
				if(typeof data === 'string') {
					data = $.parseJSON(data);
				}
				
				if (data.result === 'success') {
					self.uploadSuccess(data.imgUrls);
					return;
				}
				
				var errMsg = data.errMsg || '',
					errCode = typeof errMsg === 'string' ? 
						errMsg.split(',')[0] : errMsg[0];
						
				self.uploadError(errCode);
			});
		});
	},
	//~ handleUpload
	
	/**
	 * 处理上传失败
	 */
	uploadError: function(errCode) {
		var msg = this.getErrorMessage(errCode);
		this.showMessage('error', msg);
	},
	
	/**
	 * 出错提示信息
	 */
	getErrorMessage: function(errCode) {
		var map = {
			TYPEERR: '抱歉，图片格式不正确！请上传jpg、jpeg、gif、png、bmp格式的图片',
			IMGTYPEERR: '抱歉，图片格式不正确！请上传jpg、jpeg、gif、png、bmp格式的图片',
			IMGSIZEERR: '抱歉，图片大小超出最大限制！请上传1MB以内的图片',
			IMGREQUIRED: '抱歉，图片大小超出最大限制！请上传1MB以内的图片'
		};
		errCode = (errCode || '').toUpperCase();
		return map[errCode] || '网络繁忙，图片上传失败，请重试';
	},
	
	/**
	 * 上传成功, 更新预览图, 触发回调
	 */
	uploadSuccess: function(imgUrl){
		this.pathInput.val(imgUrl);
		this.img.attr('src', imgUrl);
		this.preview.show();
		this.showMessage('success', '图片已上传成功');
		
		this.config.onUpload && this.config.onUpload(imgUrl);
	},
	
	/**
	 * 处理移除图片事件
	 */
	handleRemove: function(){
		var self = this;
		this.remove.click(function(){
			self.pathInput.val('');
			self.preview.hide();
			
			self.config.onRemove && self.config.onRemove();
			return false;
		});
	},
	
	/**
	 * 显示提示信息
	 * @param {string} type 信息类型 'success' | 'error'
	 * @param {string} message
	 */
	showMessage: function(type, message){
		var elm = this.message;
		elm.removeClass('error success').stop(true);
		if (type === false) {
			elm.hide();
		} else {
			elm.addClass(type).text(message).show();
		}
	}
});


WP.diy.ImageUpload = ImageUpload;	

	
})(jQuery, Platform.winport);
