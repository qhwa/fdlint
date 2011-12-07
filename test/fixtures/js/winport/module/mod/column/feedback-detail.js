/**
 * @fileoverview 二级栏目页-留言板
 *
 * @author qijun.weiqj
 */
(function($, WP){


var Util = WP.Util,
	Paging = WP.mod.unit.Paging,
	FormUtil = WP.widget.FormUtil;


var FeekbackDetail = {
    init: function(div, config){
		this.div = div;
		
		this.formPanel = $('div.feedback-form', div);
		this.form = $('form', this.formPanel);
		this.successPanel = $('dl.feedback-success', div);
		
		this.isLogin = $('#doc').data('doc-config').isLogin;
		
		this.initNotice();
		this.initPaging();
		this.form && this.initForm();
    },
	
	/**
	 * 1. 设置登录按扭链接targetUrl, 因为登录后需要跳回当前页面
	 * 2. 设置注册按扭链接leadUrl, 因为注册后需要返回
	 */
	initNotice: function() {
		var div = $('div.feedback-notice', this.div),
			login = $('a.login', div),
			register = $('a.register', div),
			loginUrl = null,
			registerUrl = null;
		
		if (login.length) {
			loginUrl = Util.formatUrl(login.attr('href'), {
				targetUrl: window.location.href
			})
			login.attr('href', loginUrl);
		}
		if (register.length) {
			registerUrl = Util.formatUrl(register.attr('href'), {
				leadUrl: loginUrl
			})
			register.attr('href', registerUrl);
		}
	},
	
	initPaging: function() {
		var paging = $('div.wp-paging-unit', this.div);
		new Paging(paging);
	},
	
	/**
	 * 初始化表单
	 */
	initForm: function() {
		this.feedbackText = $('dl.feedback-content textarea:first', this.form);
		this.checkCodeText = $('dl.check-code input.input-text:first', this.form);
		this.submitBtn = $('div.form-footer a.submit:first', this.form);
		this.checkCodeImg = $('a.refresh-img img', this.form);
		this.checkCodeUrl = this.checkCodeImg.attr('src');
		
		this.initFloagLogin();
		this.handleValidate();
		this.handleSubmit();
		this.handleSuccessPanel();
		this.handleCheckCode();
	},
	
	/**
	 * 初始化浮层登录
	 * 当鼠标focus到输入域或提交按扭时会出现浮层登录
	 */
	initFloagLogin: function() {
		var self = this,
			elms = [this.feedbackText[0], this.checkCodeText[0], this.submitBtn[0]];
		
		$(elms).click(function(e) {
			if (self.isLogin) {
				return;
			}
			FD.Member.LR.show({
				onLoginSuccess: function () {
					window.location.reload();
				},
				onRegistSuccess: function () {
					window.location.reload();
				}
			});
			return false;
		}); 
	},
	
	/**
	 * 处理表单验证事件
	 */
	handleValidate: function() {
		var self = this,
			elms = [this.feedbackText, this.checkCodeText],
			vs = ['validateFeedback', 'validateCheckCode'];
			
		$.each(elms, function(index) {
			var elm = this,
				v = vs[index];
			elm.blur(function() {
				self[v]();
			});
			elm.focus(function() {
				self.showError(elm, false);
			});
		});
	},
	
	/**
	 * 验证留言内容
	 */
	validateFeedback: function() {
		var elm = this.feedbackText,
			value = $.trim(elm.val());
		
		this.showError(elm, false);
		
		if (!value) {
			this.showError(elm, '请输入您的留言内容');
			elm.val('');
			return false;
		}
		
		if (value.length < 10 || value.length > 1500) {
			this.showError(elm, '留言内容请控制在10-1500个字符');
			return false;
		}
		
		return true;
	},
	
	/**
	 * 验证验证码
	 */
	validateCheckCode: function() {
		var elm  = this.checkCodeText,
			value = $.trim(elm.val());
			
		this.showError(elm, false);
		
		if (!value) {
			this.showError(elm, '请输入校验码');
			elm.val('');
			return false;
		}
		
		return true;
	},
	
	/**
	 * 处理表单提交事件
	 */
	handleSubmit: function() {
		var self = this,
		handler = function(e) {
			e.preventDefault();
			if (!self.isLogin|| self.running) {
				return;
			}
			self.validate() && self.submit();
		};
		
		this.form.submit(handler);
		this.submitBtn.click(handler);
	},
	
	/**
	 * 表单前端验证
	 */
	validate: function() {
		this.showError(this.submitBtn, false);
		return this.validateFeedback() &&
				this.validateCheckCode();
	},
	
	/**
	 * 提示出错信息
	 */
	showError: function(elm, message) {
		FormUtil.showMessage(elm, message, 'error');
	},
	
	/**
	 * 提交表单
	 */
	submit: function() {
		var self = this,
			url = this.form.attr('action'),
			data = this.form.serialize();
		
		this.running = true;
		$('span', this.submitBtn).html('正在发送...');
		this.submitBtn.addClass('sending');
		
		$.ajax(Util.formatUrl(url, '_input_charset=UTF-8'), {
			type: 'POST',
			dateType: 'json',
			data: data,
			success: $.proxy(this, 'submitSuccess'),
			complete: $.proxy(this, 'submitComplete')
		});
	},
	
	/**
	 * 提交留言成功
	 */
	submitSuccess: function(ret) {
		if (ret.success) {
			this.form[0].reset();
			this.formPanel.hide();
			this.successPanel.show();
		} else {
			this.showErrorMessage(ret.data || []);
		}
	},
	
	/**
	 * 提交留言完成(成功或失败)
	 */
	submitComplete: function() {
		this.running = false;
		$('span', this.submitBtn).html('发送留言');
		this.submitBtn.removeClass('sending');
		this.refreshCheckCode();
	},
	
	/**
	 * 提交表单失败，提示出错信息
	 */
	showErrorMessage: function(data) {
		data = data[0] || {};
		
        var fields = {
			checkCodeFailure: this.checkCodeText,
			content: this.feedbackText
		},
		
		msgs = {
            checkCodeFailure: '校验码不正确，请重新输入'
        },
		
		message = data.message || msgs[data.errorCode] || '留言发送失败，请刷新后重试',
		field = fields[data.errorCode] || fields[data.fieldName] || this.submitBtn;
		
		this.showError(field, message);
	},
	
	/**
	 * 初始化留言成功面板
	 */
	handleSuccessPanel: function() {
		var self = this,
			link = $('a.continue', this.successPanel);
		link.click(function() {
			self.formPanel.show();
			self.successPanel.hide();
			return false;
		});
	},
	
	/**
	 * 初始化验证码刷新逻辑
	 */
	handleCheckCode: function() {
		var self = this,
			links = $('a.refresh-img,a.refresh-link', this.form);
		links.click(function() {
			self.refreshCheckCode();
			return false;
		});
	},
	
	/**
	 * 刷新验证码
	 */
	refreshCheckCode: function() {
		var url = Util.formatUrl(this.checkCodeUrl, { _: $.now() });
		this.checkCodeImg.attr('src', url);
		this.checkCodeText.val('');
	}
};


WP.ModContext.register('wp-feedback-detail', FeekbackDetail);

    
})(jQuery, Platform.winport);
