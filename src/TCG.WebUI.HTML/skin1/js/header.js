//头部选项卡状态
$(document).ready(function() {
    var o = { onClass: "on" }
    var emus = $(".emu").eq(0).find("li");
    if (typeof (ClassId) != "undefined") {
        try {
            var indexNuN = 0;
            if (ClassId == 3) indexNuN = 1;
            if (ClassId == 5) indexNuN = 2;
            if (ClassId == 6) indexNuN = 3;
            if (ClassId == 7) indexNuN = 4;
            if (ClassId == 4) indexNuN = 5;
            if (ClassId == 9) indexNuN = 6;
            emus.eq(indexNuN).addClass(o.onClass).siblings().removeClass(o.onClass);
        } catch (err) { }
    } else {
        emus.eq(0).addClass(o.onClass).siblings().removeClass(o.onClass);
    }

    setInterval('AutoScroll("#Announcement")', 3000)
	UserLoginInit();
});

/*公告动画*/
function AutoScroll(obj) {
    $(obj).find("ul:first").animate({
        marginTop: "-28px"
    }, 20, function() {
        $(this).css({ marginTop: "8px" }).find("li:first").appendTo(this);
    });
}


function LoginOut(){
	utils.SystemDo("do","正在退出系统，请稍等...",function(){
		$.ajax({
			type: "GET", url: "/interface/userget.aspx?temptime=" + new Date().toString(), data: "action=USER_LOGOUT",
			errror: function(){
				utils.SystemDo("err","退出系统失败!请联系管理员!")
				return false;
			},
			success: function(data) {
				if (data.state) {
					utils.SystemDo("out","成功推出系统!");
					UserLoginInit();
					return false;
				}
				utils.SystemDo("err","退出系统失败!请联系管理员!")
			},
			dataType: "json"
		});
	});
	
}

/*用户登录信息*/
function UserLoginInit(){
	$.ajax({
	    type: "GET", url: "/interface/userget.aspx?temptime=" + new Date().toString(), data: "action=GET_USER_LOGININFO",
	    errror: function(){ 
			return false;
		},
	    success: function(data) {
			utils.user = data.user;
	        if (data.state) {
				var userlogin = $("#userlogin");
				if(data.user.UserClubLevel==-1){
					userlogin.html("您好<span>游客</span>!，欢迎光临TCG CMS。<A href=\"javascript:utils.ConvenientLogin('show');\"><SPAN>登录</SPAN></A> | <A href=\"/Register.aspx\"><SPAN>注册 </SPAN></A>");
				}else{
					userlogin.html("您好<span>"+data.user.Name+"</span>!，欢迎光临TCG CMS。<A href=\"javascript:LoginOut()\"><SPAN>退出</SPAN></A> ");
				}
	        }
	    },
	    dataType: "json"
	});
}



/*-----------登陆开始---------------*/

var UserName  = null;
var UserPassWord = null;
var LoginMsg = null;


/*-----------登陆结束---------------*/

function LoginFormInit(){
	var LoginForm = $("#LoginFrom");
	if(LoginForm.length==0)return;
	LoginForm[0].action = "/interface/userpost.aspx?temptime=" + new Date().toString() + "&action=USER_LOGIN";
	LoginFormDatInit();
    /*添加提交方法*/
    var options = {
        beforeSubmit: LoginFromPost,
        dataType: 'json',
        success: LoginBack
    };
    LoginForm.ajaxForm(options);
}

function LoginBack(data){
	utils.SystemDo("text","正在分析接收数据....");
	if(data.state){
		utils.SystemDo("text","您已经成功登陆本网站！",function(){
			utils.SystemDo("out","正在返回当前页!",function(){
				utils.ConvenientLogin('hide');
				UserLoginInit();
			});
		});
		
	}else{
		utils.SystemDo("err",data.message);
	}
}

/*初始化事件*/
function LoginFormDatInit(){
	UserName = $("#UserName");
	UserPassWord = $("#UserPassWord");
	LoginMsg = $("#LoginMsg");
	
	UserName.blur(CheckUserName);
	UserPassWord.blur(CheckUserPassWord)
}


function CheckUserPassWord(){
	var pt = /^[a-zA-Z0-9]{6,16}$/;
	var PassWordVale = UserPassWord.val();
	if(!utils.IsRegex(PassWordVale,pt)){
		LoginMsg.html("密码格式不正确！");
		LoginMsg.removeClass("ok").addClass("err");
		return false;
	}
	LoginMsg.html("");
	LoginMsg.removeClass("err").addClass("ok");
	return true;
}

function CheckUserName(){
	var pt = /^([a-zA-Z0-9\@\.]{2,50})|[\u4e00-\u9fffa-zA-Z0-9\@\.]{2,25}$/;
	var UserNameValue = UserName.val();
	if(!utils.IsRegex(UserNameValue,pt)){
		LoginMsg.html("请输入正确格式的用户名！");
		LoginMsg.removeClass("ok").addClass("err");
		return false;
	}
	LoginMsg.html("");
	LoginMsg.removeClass("err").addClass("ok");
	return true;
}

function LoginFromPost(){
	if(!(CheckUserName()&&CheckUserPassWord())){
		return false;
	}
	utils.SystemDo("do","正在发送登陆请求,请耐心能等待....");
	return true;
}

/*-----------注册开始---------------*/
var Email = null;
var PassWord = null;
var EmailMsg = null;
var PassWordMsg = null;
var RePassWord=null;
var RePassWordMsg = null;
var ValidateCodeMsg = null;
var ValidateCode = null;

$(document).ready(function() {
	RegFormInit();
});


function RegFormInit(){
	var RegisterForm = $("#Register");
	if(RegisterForm.length==0)return;
	RegisterForm[0].action = "/interface/userpost.aspx?temptime=" + new Date().toString() + "&action=USER_REGISTER";
	RegFromInit();
    /*添加提交方法*/
    var options = {
        beforeSubmit: FromPost,
        dataType: 'json',
        success: RegisterBack
    };
    RegisterForm.ajaxForm(options);
}

/*检测邮箱*/
function CheckEmail(){
	var pt = /^([a-zA-Z0-9\@\.]{2,50})|[\u4e00-\u9fffa-zA-Z0-9\@\.]{2,25}$/;
	var EmailValue = Email.val();
	if(!utils.IsRegex(EmailValue,pt)){
		EmailMsg.html("会员名只能由3到50个英文和数字或2到25个中文组成，不能含空格或特殊符号！");
		EmailMsg.removeClass("ok").addClass("err");
		return false;
	}
	
	$.ajax({
	    type: "GET", url: "/interface/userget.aspx?temptime=" + new Date().toString(), data: "action=CHECK_USER_NAME&name="+EmailValue,
	    errror: function(){ 
			EmailMsg.html("无法检测用户名，请联系系统管理员！");
			EmailMsg.removeClass("ok").addClass("err");
			return false;
		},
	    success: function(data) {
	        if (!data.state) {
				var text = (data.message=='')?"很抱歉，[<span class='blue'>"+EmailValue+"</span>] 已经被其他会员占用，推荐使用您常用的邮箱！":data.message;
				EmailMsg.html(text);
				EmailMsg.removeClass("ok").addClass("err");
				return;
	        }
			
			EmailMsg.html("恭喜您，[<span class='blue'>"+EmailValue+"</span>] 可以使用！");
			EmailMsg.removeClass("err").addClass("ok");
	    },
	    dataType: "json"
	});
	
	EmailMsg.removeClass("err").addClass("ok");
	return true;
}

/*检测密码*/
function CheckPassWord(){
	var pt = /^[a-zA-Z0-9]{6,16}$/;
	var PassWordVale = PassWord.val();
	if(!utils.IsRegex(PassWordVale,pt)){
		PassWordMsg.removeClass("ok").addClass("err");
		return false;
	}
	
	PassWordMsg.removeClass("err").addClass("ok");
	return true;
}


/*检测重复输入密码*/
function CheckRePassWord(){
	
	if(!CheckPassWord()){
		PassWord.focus();
		return false;
	}
	if(PassWord.val()!=RePassWord.val()){
		RePassWordMsg.html('两次输入的密码不一致！');
		RePassWordMsg.removeClass("ok").addClass("err");
		return false;
	}
	RePassWordMsg.html('');
	
	RePassWordMsg.removeClass("err").addClass("ok");
	return true;
}

function RegFromInit(){
	Email = $('#Email');
	EmailMsg = $("#EmailMsg");
	PassWord = $('#PassWord');
	PassWordMsg = $("#PassWordMsg");
	RePassWord = $("#RePassWord");
	RePassWordMsg = $("#RePassWordMsg");
	ValidateCode = $("#Validate_Code");
	ValidateCodeMsg = $("#ValidateCodeMsg");
	
	/*设置邮箱离开事件*/
	Email.blur(CheckEmail);
	PassWord.blur(CheckPassWord);
	RePassWord.blur(CheckRePassWord);
	ValidateCode.blur(CheckValidateCode);
}

function CheckValidateCode(){
	var ValidateCodeValue = ValidateCode.val();
	if(!utils.IsRegex(ValidateCodeValue,/^[a-zA-Z0-9]{4}$/)){
		ValidateCodeMsg.html('请输入4位验证码！');

		ValidateCodeMsg.removeClass("ok").addClass("err");
		return false;
	}
	
	$.ajax({
	    type: "GET", url: "/interface/userget.aspx?temptime=" + new Date().toString(), data: "action=CHECK_USER_VALIDATECODE&code="+ValidateCodeValue,
	    errror: function(){ 
			EmailMsg.html("无法检测验证码，请联系系统管理员！");
			EmailMsg[0].className = "fl info1 err";
			return false;
		},
	    success: function(data) {
	        if (!data.state) {
				ValidateCodeMsg.html('您输入的验证码不正确！');
				ValidateCodeMsg.removeClass("ok").addClass("err");
				return;
	        }else{
				ValidateCodeMsg.html('验证码输入正确！');
				ValidateCodeMsg.removeClass("err").addClass("ok");
			}
	    },
	    dataType: "json"
	});
	
	ValidateCodeMsg.html('');
	return true;
}

/*表单提交的处理方法*/
function FromPost(){
	var pt = /^([a-zA-Z0-9\@\.]{2,50})|[\u4e00-\u9fffa-zA-Z0-9\@\.]{2,25}$/;
	var EmailValue = Email.val();
	if(!utils.IsRegex(EmailValue,pt)){
		EmailMsg.html("会员名只能由3到50个英文和数字或2到25个中文组成，不能含空格或特殊符号！");
		EmailMsg.removeClass("ok").addClass("err");
		return false;
	}
	
	var ValidateCodeValue = ValidateCode.val();
	if(!utils.IsRegex(ValidateCodeValue,/^[a-zA-Z0-9]{4}$/)){
		ValidateCodeMsg.html('请输入4位验证码！');
		ValidateCodeMsg.removeClass("ok").addClass("err");
		return false;
	}
	
	if(!(CheckPassWord()&&CheckRePassWord())){
		return false;
	}
	
	utils.SystemDo("do","正在发送注册请求...");
	return true;
	
}

//注册会送记录
function RegisterBack(data){
	utils.SystemDo("text","正在分析返回数据...");
	
	if(data.state){
		utils.SystemDo("text","您已经成功注册！",function(){
			utils.SystemDo("out","正在返回当前页!",function(){
				utils.ConvenientLogin('hide');
				UserLoginInit();
			});
		});
		
	}else{
		utils.SystemDo("err",data.message);
	}
}
/*-----------注册结束---------------*/