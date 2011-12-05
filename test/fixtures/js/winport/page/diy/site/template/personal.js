/**
 * 我的模板
 * @author chao.xiuc
 */
(function($, WP) {

var Tabs = WP.widget.Tabs,
	 Msg = WP.diy.Msg,
	 Template = WP.diy.Template;
	
var TemplatePagePersonal = {
	
	init: function(div, config, pageData) {
		this.div = div;
		this.config = config;

		var tabs = $('ul.template-list-tabs>li',this.div),
		    bodies = $('.template-list-body',this.div);
		if (tabs.length && bodies.length) {
			new Tabs(tabs, bodies);
		};
		this.tabs=tabs;
		
		this.bind();
		//根据参数，确定切换到备份tab页
		if(pageData!=null){
			if(pageData.showBackup){
				this.tabs.eq(2).click();
			}
		}

	},
	
	bind: function(){
		var self = this;
		var templateList =$(".template-list",self.div);
		
		//备份
		$(".backup",self.div).bind("click", function(e){
			e.preventDefault();
			
			//调用框架 备份模板
			Template.backup({
				success:function(){
					//从新载入页面，切换到备份tab页
					WP.TemplatePageContext.loadPage(0,{"showBackup":true});
				},
				error:function(message){
					Msg.error('备份模板失败，请刷新后重试。');
				}
			});
		});
		
		//模板应用
		templateList.delegate('a.apply', 'click', function(e) {
			e.preventDefault();
			
			var li = $(this).closest('li'),
				template = li.data('template');
			self.currentTemplate = template;
			//弹出是否应用对话框
			self.applyTemplateDialog();
		});
		
		//修改名称
		templateList.delegate('a.rename', 'click', function(e) {
			e.preventDefault();
			
			var li = $(this).closest('li'),
				template = li.data('template');
				
			self.currentTemplate = template;
			
			var renameDiv = $(".template-rename-panel",self.div);
			
			$("input.name",renameDiv).val(template.name);
			renameDiv.show();
			li.append(renameDiv);
		});
		
		//修改名称，绑定事件,验证字符
		var name = $(".template-rename-panel>.name",self.div);
		var error = $(".template-rename-panel>.error",this.div);
		name.bind('input propertychange', function() {								   
			self.validateName(name.val(),error);
		});
		this.error=error;
		
		//修改名称确认
		$(".confirm",self.div).bind("click", function(e) {
			e.preventDefault();
			//如果存在错误，则不能修改名称
			if(self.error.text()!=""){ 
				return;
			};
			
			$(".template-rename-panel",self.div).hide();
			var li = $(this).closest('li'),
				template = li.data('template');
			self.currentTemplate = template;
			//发送ajax请求
			$.ajax(self.config.renameUrl, {
				type: 'POST',
				data:{
						"id":self.currentTemplate.id,
						"name":self.currentTemplate.name,
						"_csrf_token": $('#doc').data('doc-config')._csrf_token
					},
				dataType: 'json',
				success: function(result){
					if (result.success) {
						//名称修改成功后 刷新新名称
						var renameDiv = $(".template-rename-panel",self.div);
						$(".name",li).text($("input.name",renameDiv).val());
					} else {
						Msg.error('修改模板名称失败，请刷新后重试。');
					}
				},
				error: function(){
					Msg.error('网络繁忙，请刷新后重试。');
				}
			});
			
		
		});
		
		//删除
		templateList.delegate('a.delete', 'click', function(e) {
			e.preventDefault();
			//弹出删除确认框, 确认之后发送删除ajax请求
			self.node = $(this);
			self.delTemplateDialog();
		});
		
	},
	
	delTemplateAction: function(){
		var self = this;
		var li = self.node.closest('li'),
			template = li.data('template');
		self.currentTemplate = template;
		//发送ajax请求
			$.ajax(self.config.delUrl, {
				type: 'POST',
				data:{
						"id":self.currentTemplate.id,
						"_csrf_token": $('#doc').data('doc-config')._csrf_token
					},
				dataType: 'json',
				success: function(result){
					if (result.success) {
						//删除成功后移除元素
						li.remove();
					} else {
						Msg.error('删除模板失败，请刷新后重试。');
					}
				},
				error: function(){
					Msg.error('网络繁忙，请刷新后重试。');
				}
			});
	},
	
	/**
	* 删除模板对话框
	*/
	delTemplateDialog: function(){
		var self = this;
		delDialog = Dialog.open({
		header: '删除模板',
		className: 'del-template-dialog',
		hasClose: true,
		buttons: [{'class': 'd-confirm',value: '删除'},{'class': 'd-cancel',value: '不删除'}],
		draggable : true,
		content : "是否删除该模板",
		confirm : function(dialog){
				self.delTemplateAction();
				delDialog.close();
			}
		});
	},
	
	/**
	 * 应用模板到旺铺的对话框
	 */
	applyTemplateDialog: function(){
		var self = this;
		applyDialog = Dialog.open({
		header: '应用模板',
		className: 'apply-template-dialog',
		hasClose: true,
		buttons: [{'class': 'd-confirm',value: '是'},{'class': 'd-cancel',value: '否'}],
		draggable : true,
		content : "应用旺铺是否自动备份模板",
		confirm : function(dialog){
				//调用备份前，补充旺铺是否到期提示，是否备份 ，调用框架 应用模板
				Template.apply(self.currentTemplate,{
					success:function(){
						//成功后处理
						
					},
					error:function(message){
						Msg.error('应用模板失败，请刷新后重试。');
					}
				});
				applyDialog.close();
			}
		});
	},
	
	validateName: function(nameValue,error) {
		error.text("");
		var value = $.trim(nameValue);
		if(!value) {
			error.text('标题不能为空');
		}
		if (/[~'"@#$?&<>\/\\]/.test(value)) {
			error.text('标题包含特殊字符');
		}
	}

  };
	
	WP.TemplatePageContext.register('template-page-personal', TemplatePagePersonal);
	
})(jQuery, Platform.winport);
