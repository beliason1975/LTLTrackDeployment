SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#results') IS NOT NULL DROP TABLE #results;
IF OBJECT_ID('tempdb..#uniquepros') IS NOT NULL DROP TABLE #uniquepros;
IF OBJECT_ID('tempdb..#grouped') IS NOT NULL DROP TABLE #grouped;

select
	 Tractor
	, Pro
	, Arrived		= SUM([ARV])
	, Dispatched	= SUM([DSP])
	, Unloaded		= SUM([UNL])
	, Emptied		= SUM([EMT])
into #results
from
	(
    SELECT   ISNULL(LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))), '') AS Tractor
		   , MFSTPRO.BCPRO  AS Pro
           , MFSTSTA.ISSTAT AS [Status]
	FROM [MFSTHDR] MFSTHDR
		inner JOIN [MFSTPRO] MFSTPRO ON MFSTPRO.BCMFST = MFSTHDR.BAMFST
		inner JOIN [MFSTSTA] MFSTSTA ON MFSTSTA.ISMFST = MFSTHDR.BAMFST
	WHERE ISNULL(LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))), '') <> ''
		  AND MFSTSTA.ISSTAT in ('ARV', 'DSP', 'UNL', 'EMT')
		 -- AND
		 -- (BATRKR like '%42097%'   or
		 --BATRKR like '%43475%'   or
		 --BATRKR like '%43742%'   or
		 --BATRKR like '%43751%'   or
		 --BATRKR like '%659044%'  or
		 --BATRKR like '%60031%'   or
		 --BATRKR like '%60078%'   or
		 --BATRKR like '%60085%')
) B
PIVOT
(
    count([Status])
    for [Status] IN
    ([ARV], [DSP], [UNL], [EMT])
) as pvt
group by Tractor, Pro
--having SUM([ARV]) <> SUM([DSP]) OR SUM([ARV]) <> SUM([UNL]) OR SUM([ARV]) <> SUM([EMT])
order by Tractor, Pro;


-- select
-- 	Pro
-- 	, Manifest
-- 	, Tractor
-- 	, sum(Arrived) as Arrived
-- 	, sum(Dispatched) as Dispatched
-- 	, sum(Unloaded) as Unloaded
-- 	, sum(Emptied) as Emptied
-- into #grouped
-- from #results
-- group by
-- 	  Tractor
-- 	, Pro
-- 	, Manifest
-- --having SUM(Arrived) <> SUM(Unloaded) or SUM(Dispatched) > SUM(Arrived)
-- order by Tractor, Pro, Manifest

select Pro
into #uniquepros
from #results
group by Pro
order by Pro


SELECT
	PROHDR.AJPRO#	AS Pro
	, PROHDR.AJSCD	AS CustomerID
	, PROHDR.AJDID	AS DispatchCode
	, PROHDR.AJTPCS	AS Pieces
	, PROHDR.AJTWGT	AS [Weight]
	, PROHDR.AJSNM	AS Origin
	, PROHDR.AJSAD1	AS OriginAddress
	, PROHDR.AJSCTY	AS OriginCity
	, PROHDR.AJSST	AS OriginState
	, PROHDR.AJSZIP	AS OriginZIP
	, PROHDR.AJCNM	AS Consignee
	, PROHDR.AJCAD1	AS ConsigneeAddress
	, PROHDR.AJCCTY	AS ConsigneeCity
	, PROHDR.AJCST	AS ConsigneeState
	, PROHDR.AJCZIP	AS ConsigneeZIP
    , ISNULL(LTRIM(RTRIM(CAST(MFSTHDR.BAMFST AS VARCHAR(25)))), '') AS Manifest
	, ISNULL(LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))), '') AS Tractor
	, CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25)))), '') <> ''
        THEN   	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25)))), '')
        ELSE	NULL
    END AS BOL
	, CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25)))), '') <> ''
        THEN   	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25)))), '')
        ELSE	NULL
    END AS PONumber
	, PUTRAN.DLPUNO AS Pickup#
	, CASE WHEN APPT.BSDATE <> 0
        THEN CAST(CAST(APPT.BSDATE AS VARCHAR(10)) AS DATE)
        ELSE NULL
    END AS ApptDate
, CASE WHEN MAX(PROSTA.ALDATE) <> 0
        THEN CAST(CAST(MAX(PROSTA.ALDATE) AS VARCHAR(10)) AS DATE)
        ELSE NULL
    END AS EstDeliveryDate
	-- , MAX(PROSTA.ALDATE) AS EstDeliveryDate
	, CASE WHEN APPT.BSDLDT <> 0
        THEN CAST(CAST(APPT.BSDLDT AS VARCHAR(10)) AS DATE)
        ELSE NULL
    END AS DeliveredDate
FROM #uniquepros
	INNER JOIN [PROHDR]  PROHDR ON PROHDR.AJPRO# = #uniquepros.Pro
	INNER JOIN  [PROSTA]  PROSTA on PROSTA.ALPRO = PROHDR.AJPRO#
	INNER JOIN [MFSTPRO] MFSTPRO on MFSTPRO.BCPRO = PROHDR.AJPRO#
	INNER JOIN [MFSTHDR] MFSTHDR on MFSTHDR.BAMFST = MFSTPRO.BCMFST
							 --AND PROSTA.ALCO = PROHDR.AJCO#
							 --AND PROSTA.ALSTAT = 'DUD'
	--LEFT JOIN [PROSTA] PROSTAA on PROSTAA.ALPRO = PROHDR.AJPRO#
	--						  --AND PROSTAA.ALCO = PROHDR.AJCO#
	--						  AND PROSTAA.ALFSC <> 'I'
	--						  AND PROSTAA.ALSTAT IN ('DED', 'DES', 'DEL', 'DEO')
	LEFT JOIN [APPT] APPT on APPT.BSPRO = PROHDR.AJPRO#
						 --AND APPT.BSCONO = PROHDR.AJCO#
	LEFT JOIN [PUTRAN] PUTRAN on PUTRAN.DLPRO = PROHDR.AJPRO#
WHERE ISNULL(LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))), '') <> '' AND
	  ISNULL(LTRIM(RTRIM(CAST(MFSTHDR.BAMFST AS VARCHAR(25)))), '') <> ''
	  --AND
	  --APPT.BSDLDT is not null
GROUP BY
	PROHDR.AJPRO#
	, PROHDR.AJSCD
	, PROHDR.AJDID
	, PROHDR.AJTPCS
	, PROHDR.AJTWGT
	, PROHDR.AJSNM
	, PROHDR.AJSAD1
	, PROHDR.AJSCTY
	, PROHDR.AJSST
	, PROHDR.AJSZIP
	, PROHDR.AJCNM
	, PROHDR.AJCAD1
	, PROHDR.AJCCTY
	, PROHDR.AJCST
	, PROHDR.AJCZIP
	, ISNULL(LTRIM(RTRIM(CAST(MFSTHDR.BAMFST AS VARCHAR(25)))), '')
	, ISNULL(LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))), '')
	, CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25)))), '') <> ''
        THEN   	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25)))), '')
        ELSE	NULL
    END
	, CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25)))), '') <> ''
        THEN   	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25)))), '')
        ELSE	NULL
    END
	, PUTRAN.DLPUNO
	, CASE WHEN APPT.BSDATE <> 0
        THEN CAST(CAST(APPT.BSDATE AS VARCHAR(10)) AS DATE)
        ELSE NULL
    END
	, PROSTA.ALDATE
	, CASE WHEN APPT.BSDLDT <> 0
        THEN CAST(CAST(APPT.BSDLDT AS VARCHAR(10)) AS DATE)
        ELSE NULL
    END
-- order by Tractor, Pro, Manifest
