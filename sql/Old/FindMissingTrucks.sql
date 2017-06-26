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
    SELECT MFSTPRO.BCPRO PRO
            , MFSTHDR.BAMFST Manifest
			, MFSTHDR.BATRKR AS Tractor
            , MFSTSTA.ISSTAT [Status]
	FROM [MFSTHDR] MFSTHDR
		INNER JOIN [MFSTPRO] MFSTPRO ON MFSTPRO.BCMFST = MFSTHDR.BAMFST
		INNER JOIN [MFSTSTA] MFSTSTA ON MFSTSTA.ISMFST = MFSTHDR.BAMFST
	WHERE MFSTHDR.BATRKR like '%42097%'   or
	MFSTHDR.BATRKR like '%43475%'   or
	MFSTHDR.BATRKR like '%43742%'   or
	MFSTHDR.BATRKR like '%43751%'   or
	MFSTHDR.BATRKR like '%659044%'  or
	MFSTHDR.BATRKR like '%60031%'   or
	MFSTHDR.BATRKR like '%60078%'   or
	MFSTHDR.BATRKR like '%60085%'
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
