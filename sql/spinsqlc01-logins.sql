use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'BUILTIN\Administrators')
CREATE LOGIN [BUILTIN\Administrators] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [BUILTIN\Administrators]
GO
use master
GO
Grant CONNECT SQL TO [BUILTIN\Administrators]  AS [sa]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\jlathero')
CREATE LOGIN [PARADISE\jlathero] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [PARADISE\jlathero]
GO
ALTER SERVER ROLE [securityadmin] ADD MEMBER [PARADISE\jlathero]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [PARADISE\jlathero]
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\jlathero]  AS [sa]
GO
use [RoadrunnerCentral]
GO
CREATE USER [PARADISE\jlathero] FOR LOGIN [PARADISE\jlathero] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [PARADISE\jlathero]
GO
Grant CONNECT TO [PARADISE\jlathero]  AS [dbo]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\kludeman')
CREATE LOGIN [PARADISE\kludeman] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [serveradmin] ADD MEMBER [PARADISE\kludeman]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [PARADISE\kludeman]
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\kludeman]  AS [sa]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\sp_sqladmins')
CREATE LOGIN [PARADISE\sp_sqladmins] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [PARADISE\sp_sqladmins]
GO
ALTER SERVER ROLE [processadmin] ADD MEMBER [PARADISE\sp_sqladmins]
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\sp_sqladmins]  AS [sa]
GO
use [RoadrunnerCentral]
GO
CREATE USER [PARADISE\sp_sqladmins] FOR LOGIN [PARADISE\sp_sqladmins]
GO
Grant CONNECT TO [PARADISE\sp_sqladmins]  AS [dbo]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\svc_spinfarm')
CREATE LOGIN [PARADISE\svc_spinfarm] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\svc_spinfarm]  AS [sa]
GO
use [RoadrunnerCentral]
GO
CREATE USER [PARADISE\svc_spinfarm] FOR LOGIN [PARADISE\svc_spinfarm] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [PARADISE\svc_spinfarm]
GO
Grant CONNECT TO [PARADISE\svc_spinfarm]  AS [dbo]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\svc_spininstall')
CREATE LOGIN [PARADISE\svc_spininstall] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [PARADISE\svc_spininstall]
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'_BackupMaintenancePlan.Subplan_1', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'_syspolicy_purge_history', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'CheckWebSite', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'ClearBOL_Rolling', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'ClearDealsOfTheDay', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'ClearMessages_Rolling', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'ClearTrackingCache_Rolling', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DeleteErrorTraceLog', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DeleteQuickPickupLogs', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DeleteQuickPickupRequestLogs', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DeleteRateQuoteRequestLogs', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DeleteTrackingRequestLog', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use msdb
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DisabledAccountsCleanup', @owner_login_name=N'PARADISE\svc_spininstall'
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\svc_spininstall]  AS [sa]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\svc_spinsql')
CREATE LOGIN [PARADISE\svc_spinsql] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [PARADISE\svc_spinsql]
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\svc_spinsql]  AS [sa]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\svc_spinwebapp')
CREATE LOGIN [PARADISE\svc_spinwebapp] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\svc_spinwebapp]  AS [sa]
GO
use [RoadrunnerCentral]
GO
CREATE USER [PARADISE\svc_spinwebapp] FOR LOGIN [PARADISE\svc_spinwebapp] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [PARADISE\svc_spinwebapp]
GO
Grant CONNECT TO [PARADISE\svc_spinwebapp]  AS [dbo]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\svc_sql')
CREATE LOGIN [PARADISE\svc_sql] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [PARADISE\svc_sql]
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\svc_sql]  AS [sa]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\tdm_sqladmins')
CREATE LOGIN [PARADISE\tdm_sqladmins] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [serveradmin] ADD MEMBER [PARADISE\tdm_sqladmins]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [PARADISE\tdm_sqladmins]
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\tdm_sqladmins]  AS [sa]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'PARADISE\Web Team')
CREATE LOGIN [PARADISE\Web Team] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [PARADISE\Web Team]
GO
ALTER SERVER ROLE [processadmin] ADD MEMBER [PARADISE\Web Team]
GO
ALTER SERVER ROLE [securityadmin] ADD MEMBER [PARADISE\Web Team]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [PARADISE\Web Team]
GO
use master
GO
Grant CONNECT SQL TO [PARADISE\Web Team]  AS [sa]
GO
use [RoadrunnerCentral]
GO
CREATE USER [PARADISE\Web Team] FOR LOGIN [PARADISE\Web Team]
GO
ALTER ROLE [db_owner] ADD MEMBER [PARADISE\Web Team]
GO
Grant CONNECT TO [PARADISE\Web Team]  AS [dbo]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'SQLAccess')
CREATE LOGIN [SQLAccess] WITH PASSWORD = 0x0200245C0CD41AD549300B976C4F9BE05A2D965DF76DC54F50CCCFBDBA1E912D37C5F1A95AD56B0275FA1BD24FC6D74DA1E71C1B76F6F86F273FD60D71AF790FC68FF394FBBA HASHED, SID = 0x46D466A852D4064B85C928CCEFE7F141, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [SQLAccess]
GO
ALTER SERVER ROLE [processadmin] ADD MEMBER [SQLAccess]
GO
ALTER SERVER ROLE [securityadmin] ADD MEMBER [SQLAccess]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLAccess]
GO
use master
GO
Grant CONNECT SQL TO [SQLAccess]  AS [sa]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'SQLAccess2')
CREATE LOGIN [SQLAccess2] WITH PASSWORD = 0x020067ED744699968C1ABB4A0C1AB2EB957C25F87FE46E42B4E9A37E1FAFBA40ADD1360B6A3B1C34D1676B8F98B98094C5FC573C0B063B8AEC86AD974DB9849F24B92A645505 HASHED, SID = 0x2E0791917B19664B8D79DC7AC79F31A9, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = ON, DEFAULT_LANGUAGE = [us_english]
GO
ALTER LOGIN [SQLAccess2] DISABLE
GO
DENY CONNECT SQL TO [SQLAccess2]
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [SQLAccess2]
GO
ALTER SERVER ROLE [processadmin] ADD MEMBER [SQLAccess2]
GO
ALTER SERVER ROLE [serveradmin] ADD MEMBER [SQLAccess2]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLAccess2]
GO
use master
GO
Deny CONNECT SQL TO [SQLAccess2]  AS [sa]
GO
use [RoadrunnerCentral]
GO
CREATE USER [SQLAccess2] FOR LOGIN [SQLAccess2] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [SQLAccess2]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [SQLAccess2]
GO
ALTER ROLE [db_owner] ADD MEMBER [SQLAccess2]
GO
Grant CONNECT TO [SQLAccess2]  AS [dbo]
GO
use master
GO
IF NOT EXISTS (SELECT loginname from master.dbo.syslogins where name = 'svc_linkedserver')
CREATE LOGIN [svc_linkedserver] WITH PASSWORD = 0x0200D97FDA205775C5F7A61AEB9312DB2D791E1ABD4A7BB24606291D26327808CE4E229AE3FBA940E56D7BC1E24D3A5CCBCD615668E30D0394F557BDE38209D9A31B2B8B3FC6 HASHED, SID = 0x7B8FE607346BCA4397317D7907385980, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
use master
GO
Grant CONNECT SQL TO [svc_linkedserver]  AS [sa]
GO
-- use [OFFSQLSTDD01]
GO
CREATE USER [svc_linkedserver] FOR LOGIN [svc_linkedserver] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [svc_linkedserver]
GO
Grant CONNECT TO [svc_linkedserver]  AS [dbo]
