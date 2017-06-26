--select * from MFSTDTL where BBPRO = '298545518'
--select BBCO#, MAX(BBMFST), MAX(BBSEQ), BBPRO from MFSTDTL --where BBPRO = '298545518'
--group by BBCO#, BBPRO

IF OBJECT_ID('tempdb..#Manifest') IS NOT NULL DROP TABLE #Manifest;
IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results;
IF OBJECT_ID('tempdb..#UniquePros') IS NOT NULL DROP TABLE #UniquePros;

DECLARE @fromDate as date = dateadd (day , -1 , getdate());

SELECT 
	  PROHDR.AJPRO# AS Pro
	, CAST(CAST(MAX(APPT.BSDATE) AS VARCHAR(10)) AS DATE) AS ApptDate
	, CAST(CAST(MAX(PROSTA.ALDATE) AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
	, CASE WHEN MAX(APPT.BSDLDT) <> 0
		THEN CAST(CAST(MAX(APPT.BSDLDT) AS VARCHAR(10)) AS DATE)
		ELSE NULL
	END AS DeliveredDate
INTO #UniquePros
FROM [PROHDR]  PROHDR
	INNER JOIN [PROSTA] PROSTA on PROSTA.ALPRO	= PROHDR.AJPRO# AND PROSTA.ALCO	= PROHDR.AJCO#
	LEFT JOIN  [APPT]  APPT on APPT.BSPRO		= PROHDR.AJPRO# AND APPT.BSCONO	= PROHDR.AJCO#
where CAST(CAST(PROSTA.ALDATE AS VARCHAR(10)) AS DATE) >= @fromDate
--AND PROHDR.AJPRO# = 410493282
GROUP BY
	PROHDR.AJPRO#

--select Pro
--from #Results
--group by Pro
--having count(*) > 1

--select * from MFSTDTL where BBPRO = '432467538'

select distinct MFSTDTL.BBCO#, MFSTDTL.BBMFST, MFSTDTL.BBPRO
INTO #Manifest
from MFSTDTL
INNER JOIN
		(select distinct MFSTDTL.BBPRO, MAX(MFSTDTL.BBMFST) as MaxManifest
		from MFSTDTL
		join #UniquePros up on up.Pro = MFSTDTL.BBPRO
		--where MFSTDTL.BBPRO = '432467538'
		group by MFSTDTL.BBPRO) groupedMFSTDTL
on MFSTDTL.BBPRO = groupedMFSTDTL.BBPRO
AND MFSTDTL.BBMFST = groupedMFSTDTL.MaxManifest

--select BBPRO 
--from #Manifest
--group by BBPRO
--having count(*) > 1

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
    , m.BBMFST AS Manifest
	, LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))) AS Tractor
	, CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25))))
        ELSE	NULL
      END AS BOL
	, CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25))))
        ELSE	NULL
      END AS PONumber
	, PUTRAN.DLPUNO AS [CoyotePickup#]
	, NULL AS [McLeodPickup#]
	, p.ApptDate
	, p.EstDeliveryDate
	, p.DeliveredDate
INTO #Results
FROM #UniquePros p
	INNER JOIN #Manifest m on m.BBPRO = p.Pro
	INNER JOIN [PROHDR] PROHDR on PROHDR.AJPRO# = m.BBPRO and PROHDR.AJCO# = m.BBCO#
	INNER JOIN [MFSTHDR] MFSTHDR on MFSTHDR.BAMFST = m.BBMFST AND MFSTHDR.BACO#	= m.BBCO#
	--LEFT JOIN [APPT]    APPT on APPT.BSPRO		= PROHDR.AJPRO# AND APPT.BSCONO		= PROHDR.AJCO#
	LEFT JOIN [PUTRAN]  PUTRAN on PUTRAN.DLPRO	= PROHDR.AJPRO#
--where CAST(CAST(PROSTA.ALDATE AS VARCHAR(10)) AS DATE) >= @fromDate
--AND PROHDR.AJPRO# = 410493282
--GROUP BY
--	PROHDR.AJPRO#
--	, PROHDR.AJSCD
--	, PROHDR.AJDID
--	, PROHDR.AJTPCS
--	, PROHDR.AJTWGT
--	, PROHDR.AJSNM
--	, PROHDR.AJSAD1
--	, PROHDR.AJSCTY
--	, PROHDR.AJSST
--	, PROHDR.AJSZIP
--	, PROHDR.AJCNM
--	, PROHDR.AJCAD1
--	, PROHDR.AJCCTY
--	, PROHDR.AJCST
--	, PROHDR.AJCZIP
--	, m.BBMFST
--	, LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25))))
--	, LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25))))
--	, LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25))))
--	, PUTRAN.DLPUNO
select * from #Results where [coyotepickup#] = '23224785'
select * from #Results where [mcleodpickup#] = '23224785'
select * from #Results where [coyotepickup#] = '10475104'
select * from #Results where [mcleodpickup#] = '10475104'
