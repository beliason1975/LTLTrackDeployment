--IF OBJECT_ID('tempdb..#results') IS NOT NULL DROP TABLE #results;

DECLARE @fromDate as varchar(8) = convert(varchar(8), dateadd (day, 0, getdate()) ,112);
DECLARE @toDate   as varchar(8) = convert(varchar(8), dateadd (day, 0, getdate()) ,112);
declare @padding varchar(100) = '000000000000';
declare @dash varchar(2) = '-';
declare @colon varchar(2) = ':';
declare @space varchar(2) = ' ';

--EXAMPLE 2017-05-26 00:00:00.0000000

declare @query1 varchar(max) =
'select top 100 * from openquery(COYOTE,
''
select
concat
(
	substring(
		right( right( concat(''000000000000'', cast(hdr.BADTTM as varchar(20))) , 12) , 6) , 1, 2) ,''-'',
    substring(
		right( right( concat(''000000000000'', cast(hdr.BADTTM as varchar(20))) , 12) , 6) , 3, 2) ,''-'',
	substring(
		right( right( concat(''000000000000'', cast(hdr.BADTTM as varchar(20))) , 12) , 6) , 5, 2) ,''-'',
    substring(
		left( right( concat(''000000000000'', cast(hdr.BADTTM as varchar(20))) , 12) , 6) , 1, 2) , '':'',
	substring(
		left( right( concat(''000000000000'', cast(hdr.BADTTM as varchar(20))) , 12) , 6) , 3, 2) , '':'',
	substring(
		left( right( concat(''000000000000'', cast(hdr.BADTTM as varchar(20))) , 12) , 6) , 5, 2)
)
from RDFSV31DTA.PROSTA sta

'')'

declare @sql as varchar(max) =
'select top 100 * from openquery(COYOTE, '+ @query1+')'

exec @sql
