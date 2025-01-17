
CREATE TABLE [dbo].[UserContact](
	[UserId] [varchar](36) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[UserRealName] [nvarchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[Province] [int] NULL,
	[City] [int] NULL,
	[District] [int] NULL,
	[Fulladdress] [nvarchar](200) COLLATE Chinese_PRC_CI_AS NULL,
	[Postcode] [char](10) COLLATE Chinese_PRC_CI_AS NULL,
	[Telephone] [nvarchar](20) COLLATE Chinese_PRC_CI_AS NULL,
	[Mobile] [nvarchar](20) COLLATE Chinese_PRC_CI_AS NULL,
	[Email] [nvarchar](50) COLLATE Chinese_PRC_CI_AS NULL,
 CONSTRAINT [PK_UserContact] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF