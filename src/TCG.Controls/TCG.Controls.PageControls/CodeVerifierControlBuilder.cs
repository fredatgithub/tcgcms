
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

namespace TCG.Controls.PageControls
{
    using System;
    using System.Collections;
    using System.Web.UI;

    public class CodeVerifierControlBuilder : ControlBuilder
    {
        public override Type GetChildControlType(string tagName, IDictionary attributes)
        {
            if (tagName.ToLower() == "textboxattribute")
            {
                return typeof(VerifierTextBoxAttribute);
            }
            if (tagName.ToLower() == "codeimageattribute")
            {
                return typeof(VerifierCodeImageAttribute);
            }
            return null;
        }

    }
}

