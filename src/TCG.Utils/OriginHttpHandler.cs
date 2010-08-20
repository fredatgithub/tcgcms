﻿using System;
using System.Collections.Generic;
using System.Text;
using System.Web;

using TCG.Data;
using TCG.Entity;

namespace TCG.Utils
{
    public class OriginHttpHandler : IHttpHandler
    {
        public virtual void ProcessRequest(HttpContext context)
        {

        }

        public bool IsReusable
        {
            get { return false; }
        }

        /// <summary>
        /// 获得配置信息支持
        /// </summary>
        public ConfigService configService
        {
            get
            {
                if (this._configservice == null)
                {
                    this._configservice = new ConfigService();
                }
                return this._configservice;
            }
        }
        private ConfigService _configservice = null;

        /// <summary>
        /// 设置数据库链接
        /// </summary>
        public Connection conn
        {
            get
            {
                if (this._conn == null)
                {
                    this._conn = new Connection();
                }
                return this._conn;
            }
        }
        private Connection _conn = null;

        protected void AjaxErch(string str)
        {
            this._httpcontext.Response.Write(str);
            this._httpcontext.Response.End();
        }

        /// <summary>
        /// 判断数据库执行参数
        /// </summary>
        /// <param name="rtn"></param>
        /// <param name="okmessage"></param>
        protected void AjaxErch(int rtn, string okmessage)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("{state:");
            if (rtn < 0)
            {
                sb.Append("false,message:\"" + errHandlers.GetErrTextByErrCode(rtn, this.configService.baseConfig["ManagePath"]) + "\"");
            }
            else
            {
                sb.Append("true,message:'" + okmessage + "'");
            }
            sb.Append("}");
            this._httpcontext.Response.ContentType = "application/x-javascript";
            this._httpcontext.Response.Write(sb.ToString());
            this._httpcontext.Response.End();
        }

        protected void AjaxErch(int rtn, string okmessage, string callback)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("{state:");
            if (rtn < 0)
            {
                sb.Append("false,message:\"" + errHandlers.GetErrTextByErrCode(rtn, this.configService.baseConfig["ManagePath"]) + "\"");
            }
            else
            {
                sb.Append("true,message:\"" + okmessage + "\",callback:\"" + callback + "\"");
            }
            sb.Append("}");
            this._httpcontext.Response.Write(sb.ToString());
            this._httpcontext.Response.End();
        }

        /// <summary>
        /// AJAX输出字符串
        /// </summary>
        public string ajaxdata
        {
            get
            {
                return this._ajaxdata;
            }
            set
            {
                this._ajaxdata = value;
            }
        }


        protected void Finish()
        {
            if ((this._conn != null) && this._conn.Connected) { this._conn.Close(); }
        }

        private string _ajaxdata = string.Empty;
        protected HttpContext httpContext
        {
            set
            {
                this._httpcontext = value;
            }
        }
        private HttpContext _httpcontext;
    }
}