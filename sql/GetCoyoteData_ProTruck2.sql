-- select * from [MFSTPRO] MFSTPRO
-- join [PROHDR] PROHDR on PROHDR.AJPRO# = MFSTPRO.BCPRO
-- where MFSTPRO.BCMFST in (27344952, 27940741, 27460611,27706261,28254031,27706261,28254032)


SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#results') IS NOT NULL DROP TABLE #results;
IF OBJECT_ID('tempdb..#uniquepros') IS NOT NULL DROP TABLE #uniquepros;
IF OBJECT_ID('tempdb..#grouped') IS NOT NULL DROP TABLE #grouped;

select
	Pro
	, Manifest
	, Tractor
	, [ARV] as Arrived
	, [DSP] as Dispatched
	, [UNL] as Unloaded
	, [EMP] as Emptied
into #results
from
	(
    SELECT    BCPRO PRO
            , BAMFST Manifest
			, BATRKR AS Tractor
            , ISSTAT [Status]
	FROM COYOTE.B10A282B.RDFSV31DTA.[MFSTHDR] MFSTHDR
		LEFT JOIN COYOTE.B10A282B.RDFSV31DTA.[MFSTPRO] MFSTPRO ON MFSTPRO.BCMFST = MFSTHDR.BAMFST
		LEFT JOIN COYOTE.B10A282B.RDFSV31DTA.[MFSTSTA] MFSTSTA ON MFSTSTA.ISMFST = MFSTHDR.BAMFST
	WHERE rtrim(BATRKR) <> '' and (
          MFSTHDR.BATRKR like '%60045%'  or
	      MFSTHDR.BATRKR like '%43787%'  or
	      MFSTHDR.BATRKR like '%43784%'  or
	      MFSTHDR.BATRKR like '%60090%'  or
	      MFSTHDR.BATRKR like '%43827%'  or
	      MFSTHDR.BATRKR like '%60010A%' or
	      MFSTHDR.BATRKR like '%60000%'  or
	      MFSTHDR.BATRKR like '%60072%'  or
          MFSTHDR.BATRKR like '%43788%'  or
          MFSTHDR.BATRKR like '%43573%'  or
          MFSTHDR.BATRKR like '%43812%'  or
          MFSTHDR.BATRKR like '%40170%'  or
          MFSTHDR.BATRKR like '%43809%'  or
          MFSTHDR.BATRKR like '%42412%'  or
          MFSTHDR.BATRKR like '%43525%'  or
          MFSTHDR.BATRKR like '%43818%'  or
          MFSTHDR.BATRKR like '%42837%'  or
          MFSTHDR.BATRKR like '%43684%'  or
          MFSTHDR.BATRKR like '%80013%'  or
          MFSTHDR.BATRKR like '%60051A%' or
          MFSTHDR.BATRKR like '%43659%' 
          )











) B
PIVOT
(
    count([Status])
    for [Status] IN
    ([ARV], [DSP], [UNL], [EMP])
) as pvt;

select
	Pro
	, Manifest
	, Tractor
	, sum(Arrived) as Arrived
	, sum(Dispatched) as Dispatched
	, sum(Unloaded) as Unloaded
	, sum(Emptied) as Emptied
into #grouped
from #results
group by
	  Tractor
	, Pro
	, Manifest
--having SUM(Arrived) <> SUM(Unloaded) or SUM(Dispatched) > SUM(Arrived)
order by Tractor, Pro, Manifest

select * from #grouped