﻿/* 
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
using System.Collections.Generic;
using System.Text;


namespace TCG.Entity
{
    /// <summary>
    /// 后台管理权限项操作
    /// </summary>
    public enum PopedomKey
    {
        /// <summary>
        /// 系统管理 总操作项
        /// </summary>
        SystemManage = 1,
        /// <summary>
        /// 系统管理 帐号管理
        /// </summary>
        SystemManageAccManage = 2,
        /// <summary>
        /// 系统管理 帐号管理 个人帐号维护
        /// </summary>
        SystemManageAccManageMyAcc = 3,
    }
}
