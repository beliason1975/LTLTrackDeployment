DECLARE @fromDate as int = cast(convert(varchar(8), dateadd (day, -1, getdate()) ,112) as int)
DECLARE @toDate as int = cast(convert(varchar(8), dateadd (day, 1, getdate()) ,112) as int)
--select COALESCE(hdr.BADATE, @fromDate) as ApptDate, dtl.*, hdr.*, pro.*
--from MFSTDTL dtl
--left join MFSTPRO pro on pro.BCMFST = dtl.BBMFST and pro.BCCO# = dtl.BBCO#
--left join MFSTHDR hdr on hdr.BAMFST = dtl.BBMFST and hdr.BACO# = dtl.BBCO# --and dtl.BBPRO = pro.BCPRO
--where COALESCE(hdr.BADATE, @fromDate) >= @fromDate and COALESCE(hdr.BADATE, @fromDate) <= @toDate
--order by COALESCE(hdr.BADATE, @fromDate)

--select convert(date, right('000000000000' + cast(BADTTM as varchar(12)), 6), 110) as ba_dttm_date, left(cast(BADTTM as varchar(12)) + '000000000000', 6) as ba_dttm_time, convert(date, right('00000000' + cast(BADATE as varchar(8)), 8), 110) as ba_date--convert(date, cast(right(BADTTM, 6)  as varchar(6)), 108 ) as BA_DATE--, cast(BADTTM as varchar(100)) as bad_ttm--, CONVERT(datetime, left(cast(BADTTM as varchar(100)), 6), 108) as BA_TIME-- right(isnull(sta.ISDTTM, 0), 6) as STA_DATE, left(isnull(sta.ISDTTM, 0), 6) as STA_TIME, convert(date, right(cast(BADATE as varchar(100)), 6), 108 ) as BADATE, CONVERT(time, left(cast(BADTTM as varchar(100)), 6), 108) as BATTM, BAMFST, BATYPE, BAORIG, BADEST, BATRPN, isnull(ltrim(rtrim(cast(BATRKR as varchar(10)))), 'NONE') as Tractor, BASTAT, isnull(cast(ISSTAT as varchar(3)), 'N/A') as ISSTAT, BASTDT, BASTTM, isnull(cast(BADRNO as varchar(10)), 'N/A') as BADRNO, BADRPT, BADRST, isnull([ISDATE], 0), isnull([ISTIME], 0), BATRPN, BATRPS, BASTOPD, BASTOPH, isnull(cast(ISLOC as varchar(3)), 'N/A') as ISLOC, isnull(ISPDTE, 0) as ISPDTE, isnull(ISPTIM, 0) as ISPTIM--*--left(sta.ISDTTM, 6) as left6_isdttm, right(sta.ISDTTM, 6) as right6_isdttm, left(BADTTM, 6) as left6_badttm, right(BADTTM, 6) as right6_badttm, -- 
--select cast(right('000000000000' + cast(BADTTM as varchar(12)), 6) as date) as ba_dttm_date, left(cast(BADTTM as varchar(12)) + '000000000000', 6) as ba_dttm_time--, convert(date, right('00000000' + cast(BADATE as varchar(8)), 8), 110) as ba_date

--EXAMPLE FORMAT--2017-05-26 00:00:00.0000000
select --convert(date, right('000000000000' + cast(BADTTM as varchar(100)), 12), 110), 
	   --hdr.BA date_time,
	   cast(
	   substring(right(right('000000000000' + cast(BADTTM as varchar(100)), 12), 6), 1, 2) + '-' + 
	   substring(right(right('000000000000' + cast(BADTTM as varchar(100)), 12), 6), 3, 2) + '-' + 
	   substring(right(right('000000000000' + cast(BADTTM as varchar(100)), 12), 6), 5, 2) + ' ' +
	   substring(left(right('000000000000' + cast(BADTTM as varchar(100)), 12), 6), 1, 2) + ':' +
	   substring(left(right('000000000000' + cast(BADTTM as varchar(100)), 12), 6), 3, 2) + ':' +
	   substring(left(right('000000000000' + cast(BADTTM as varchar(100)), 12), 6), 5, 2) as datetime) as ba_dttm, hdr.*, sta.*
from MFSTHDR hdr
--left join MFSTDTL dtl on dtl.BBMFST = hdr.BAMFST and dtl.BBCO# = hdr.BACO#
left join offsqlentd01.McLeodData_LTL.dbo.MFSTSTA sta on sta.ISMFST = hdr.BAMFST and sta.[ISDATE] = hdr.BADATE--and sta.ISCONO = hdr.BACO#
--inner join MFSTTRP trp on trp.ITTRPN = hdr.BATRPN
where BADATE >= @fromDate and BADATE <= @toDate and hdr.BACO# = 1
order by ba_dttm desc
--group by BADTTM, BAMFST, BATYPE, BAORIG, BADEST, BATRPN
--order by BADATE, BATTM, BASTDT, BASTTM, [ISDATE], [ISDTTM]--, right6_badttm, left6_isdttm, left6_badttm

--where dtl.BBMFST is null

select * 
from MFSTHDR hdr
left join MFSTDTL dtl on dtl.BBMFST = hdr.BAMFST and dtl.BBCO# = hdr.BACO#
where dtl.BBPRO = 116097825
--where BADATE >= @fromDate and BADATE <= @toDate and hdr.BACO# = 1 and dtl.BBMFST is null

select * 
from MFSTDTL dtl
full outer join MFSTHDR hdr on hdr.BAMFST = dtl.BBMFST and hdr.BACO# = dtl.BBCO#
where hdr.BAMFST is null or dtl.BBMFST is null
--where hdr.BACO# = 1 --and hdr.BAMFST is null
--select top 100 dtl.*
--from MFSTDTL dtl
--left join MFSTHDR hdr on hdr.BAMFST = dtl.BBMFST-- and hdr.BACO# = dtl.BBCO#
--where hdr.BAMFST is null
--order by BBSEQ, BBMFST, BBPRO

--select *
--from MFSTDTL dtl
--where isnull(dtl.BBMFST, 0) = 0 or dtl.BBMFST = 0
--select * from MFSTDTL dtl where dtl.BBPRO
--select * from MFSTHDR hdr where hdr.BAMFST = 18629491
DECLARE @fromDate as int = cast(convert(varchar(8), dateadd (day, -7, getdate()) ,112) as int)
DECLARE @toDate as int = cast(convert(varchar(8), dateadd (day, 7, getdate()) ,112) as int)

select *
from PROHDR hdr
inner join PRODTL dtl on dtl.AKPRO# = hdr.AJPRO# and dtl.AKCO# = hdr.AJCO#
where hdr.AADTTM >= @fromDate and hdr.AADTTM <= @toDate

select *
from MFSTDTL dtl
where dtl.BBPRO = 315517854--dtl.BBMFST = 18629491 or 
order by dtl.BBSEQ
