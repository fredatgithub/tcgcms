
CREATE TABLE [dbo].[UserPay](
	[UserId] [varchar](36) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[FreeMoney] [money] NOT NULL CONSTRAINT [DF_UserPay_FreeMoney]  DEFAULT ((0)),
	[FrezzMoney] [money] NOT NULL CONSTRAINT [DF_UserPay_FrezzMoney]  DEFAULT ((0)),
	[SumMoney] [money] NOT NULL CONSTRAINT [DF_UserPay_SumMoney]  DEFAULT ((0)),
	[Points] [money] NOT NULL CONSTRAINT [DF_UserPay_Points]  DEFAULT ((0)),
	[PayPassWord] [nvarchar](200) COLLATE Chinese_PRC_CI_AS NOT NULL,
 CONSTRAINT [PK_UserPay] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF