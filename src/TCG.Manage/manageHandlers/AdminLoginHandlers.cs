/* 
  * Copyright (C) 2009-2009 tcgcms.com <http://www.tcgcms.cn/> 
  *  
  *    本代码以公共的方式开发下载，任何个人和组织可以下载， 
  * 修改，进行第二次开发使用，但请保留作者版权信息。 
  *  
  *    任何个人或组织在使用本软件过程中造成的直接或间接损失， 
  * 需要自行承担后果与本软件开发者(三云鬼)无关。 
  *  
  *    本软件解决中小型商家产品网络化销售方案。 
  *     
  *    使用中的问题，咨询作者QQ邮箱 sanyungui@vip.qq.com 
  */

using System;
using System.Web;
using System.Web.SessionState;
using System.Data;
using System.Collections.Generic;
using System.Text;

using TCG.Utils;
using TCG.Data;
using TCG.Entity;

using TCG.Handlers;

namespace TCG.Handlers
{
    /// <summary>
    /// 后台管理登陆状态的操作方法
    /// </summary>
    public class AdminLoginHandlers : ManageObjectHandlersBase
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="conn">数据库连接</param>
        /// <param name="configservice">基本配置信息</param>
        /// <param name="handlersevice">所有操作方法句柄</param>
        /// <param name="adminhandlers">管理员操作方法</param>
        public AdminLoginHandlers(Connection conn, ConfigService configservice,HandlerService handlersevice, AdminHandlers adminhandlers)
        {
            base.conn = conn;
          
            base.handlerService = handlersevice;
            this._adminh = adminhandlers;
            this.Initialization();
        }

        private void Initialization()
        {
            if (this._admincookie == null)
            {
                this._admincookie = Cookie.Get(ConfigServiceEx.baseConfig["AdminCookieName"]);
                if (this._admincookie != null)
                {
                    if (this._admincookie.Values.Count != 1) return;
                    this._name = objectHandlers.UrlDecode(this._admincookie.Values["AdminName"].ToString());
                }
            }
            this._currenturl = this.RemoveA(objectHandlers.CurrentUrl);
        }

        private void AdminInit()
        {
            if (this._admin != null) return;
            object TempAdmin = null;
            if (string.IsNullOrEmpty(this._name))
            {
                TempAdmin = SessionState.Get(ConfigServiceEx.baseConfig["AdminSessionName"]);
                if (TempAdmin != null) SessionState.Remove(ConfigServiceEx.baseConfig["AdminSessionName"]);
                this._admin = null;
                return;
            }
            TempAdmin = SessionState.Get(ConfigServiceEx.baseConfig["AdminSessionName"]);
            if (TempAdmin == null)
            {
                this._admin = this._adminh.GetAdminEntityByAdminName(this._name);

                if (this._admin != null && this._admin.cIsOnline == "Y" && this._admin.vcLastLoginIp == objectHandlers.UserIp && this._admin.cIsDel != "Y")
                {
                    SessionState.Set(ConfigServiceEx.baseConfig["AdminSessionName"], this._admin);
                }
                else
                {
                    SessionState.Remove(ConfigServiceEx.baseConfig["AdminSessionName"]);
                }
            }
        }

        /// <summary>
        /// 检测权限操作项目
        /// </summary>
        /// <param name="pid">操作项编号</param>
        public void CheckAdminPop(int pid)
        {
            if (!(this._admin != null && this._admin.vcPopedom != null && this._admin.vcPopedom.Count != 0 && this._admin.vcPopedom.ContainsKey(pid)))
            {
                new Terminator().Throw("您无权限访问改页面!", "", "," + ConfigServiceEx.baseConfig["WebSite"]
                         + ConfigServiceEx.baseConfig["ManagePath"]
                         + "login.aspx", ConfigServiceEx.baseConfig["WebSite"] +
                         ConfigServiceEx.baseConfig["ManagePath"] + "login.aspx", false);
                return;
            }
        }

        /// <summary>
        /// 检测管理员登录
        /// </summary>
        public void CheckAdminLogin()
        {
            this.AdminInit();

            if (this._admin == null)
            {
                new Terminator().Throw("您还未登录后台!", "登录后台", "返回首页," + ConfigServiceEx.baseConfig["WebSite"]
                         + ConfigServiceEx.baseConfig["ManagePath"]
                         + "login.aspx", ConfigServiceEx.baseConfig["WebSite"] +
                         ConfigServiceEx.baseConfig["ManagePath"] + "login.aspx", false);
                return;
            }
        }
    
       
        private string RemoveA(string str)
        {
            if (str.IndexOf("?") > 0)
            {
                str = str.Substring(0, str.IndexOf("?"));
            }
            return str;
        }

        public void Logout()
        {
            this.AdminInit();
            this._adminh.AdminLoginOut(this._name);
            if (this._admincookie != null)
            {
                Cookie.Remove(this._admincookie);
            }
            if (this._admin != null)
            {
                SessionState.Remove(ConfigServiceEx.baseConfig["AdminSessionName"]);
            }
        }

       
        public Admin adminInfo 
        {
            get 
            {
                this.AdminInit();
                if (this._admin == null) return new Admin();
                return this._admin; 
            }
        }

        
        private HttpCookie _admincookie = null;
        private string _name = string.Empty;
        private Admin _admin = null;
        private AdminHandlers _adminh = null;
        private string _currenturl = string.Empty;
    }
}