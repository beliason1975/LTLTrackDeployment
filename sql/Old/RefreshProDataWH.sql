SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#manifests') IS NOT NULL DROP TABLE #manifests;
IF OBJECT_ID('tempdb..#tempResults') IS NOT NULL DROP TABLE #tempResults;

IF OBJECT_ID('tempdb..#uniquePros') IS NOT NULL DROP TABLE #uniquePros;
CREATE TABLE #uniquePros  (BBPRO int);

IF OBJECT_ID('tempdb..#pickups') IS NOT NULL DROP TABLE #pickups;
CREATE TABLE #pickups  (DLPRO int, DLPUNO int);

IF OBJECT_ID('tempdb..#est') IS NOT NULL DROP TABLE #est;
CREATE TABLE #est  (ALPRO int, estDeliveryDate int);

IF OBJECT_ID('tempdb..#tractors') IS NOT NULL DROP TABLE #tractors;
CREATE TABLE #tractors  (BATRKR varchar(25), BBPRO int);

IF OBJECT_ID('tempdb..#proManifests') IS NOT NULL DROP TABLE #proManifests;
CREATE TABLE #proManifests  (BAMFST varchar(25), BBPRO int);

declare @fromTime as int = 20170401;

SELECT BBPRO
    , BASTDT
    , BASTTM
    , BBFSC
    , CAST (BAMFST AS VARCHAR) BAMFST
    , BATRKR
INTO #manifests
FROM [MFSTHDR] MFSTHDR
    INNER JOIN [MFSTSTA] MFSTSTA
        ON MFSTHDR.BAMFST = MFSTSTA.ISMFST
            AND ISSTAT IN ('ARV','DSP')
            AND [ISDATE] >= @fromTime
    INNER JOIN [MFSTDTL] MFSTDTL
        ON MFSTDTL.BBMFST  = MFSTHDR.BAMFST
where 	ISNULL(RTRIM(LTRIM(BATRKR)), '') <> ''
        AND BBPRO <> 0
        AND BASTDT <> 0
GROUP BY BBPRO
    , BASTDT
    , BASTTM
    , BBFSC
    , CAST (BAMFST AS VARCHAR)
    , BATRKR;


--SELECT *
--FROM #manifests

--DELETE FROM #manifests
--WHERE BAMFST IN
--	(
--		SELECT CAST (BAMFST AS VARCHAR) BAMFST
--		FROM [MFSTHDR] MFSTHDR
--			INNER JOIN [MFSTSTA] MFSTSTA
--				ON MFSTHDR.BAMFST = MFSTSTA.ISMFST
--					AND ISSTAT IN ('UNL','EMP')
--					AND [ISDATE] >= 20170201
--		GROUP BY CAST (BAMFST AS VARCHAR)
--	);

--SELECT *
--FROM #manifests
--where BBPRO = 398396994


insert into #uniquePros
select BBPRO
from #manifests
where BBPRO <> 0
group by BBPRO;

insert into #pickups
select PUTRAN.DLPRO, PUTRAN.DLPUNO
from #uniquePros
join [PUTRAN] PUTRAN on PUTRAN.DLPRO = #uniquePros.BBPRO
--group by PUTRAN.DLPRO, PUTRAN.DLPUNO;

insert into #est
select PROSTA.ALPRO, MAX(PROSTA.ALDATE) AS estDeliveryDate
from #uniquePros
    join [PROSTA] PROSTA on PROSTA.ALPRO = #uniquePros.BBPRO
    and PROSTA.ALSTAT = 'DUD'
    and PROSTA.ALDATE >= @fromTime and PROSTA.ALDATE is not null
group by PROSTA.ALPRO;

insert into #tractors
select BATRKR, BBPRO from #manifests group by BATRKR, BBPRO

insert into #proManifests
select bamfst, bbpro from #manifests
group by BAMFST, BBPRO

SELECT PROHDR.AJSCD AS CustomerID
    , PROHDR.AJPRO# AS Pro
    , PROHDR.AJSCD AS DispatchCode
    , PROHDR.AJTPCS AS Pieces
    , PROHDR.AJTWGT AS [Weight]
    , PROHDR.AJSNM AS Origin
    , PROHDR.AJSAD1 AS OriginAddress
    , PROHDR.AJSCTY AS OriginCity
    , PROHDR.AJSST AS OriginState
    , PROHDR.AJSZIP AS OriginZIP
    , PROHDR.AJCNM AS Consignee
    , PROHDR.AJCAD1 AS ConsigneeAddress
    , PROHDR.AJCCTY AS ConsigneeCity
    , PROHDR.AJCST AS ConsigneeState
    , PROHDR.AJCZIP AS ConsigneeZIP
    , #proManifests.BAMFST as Manifest
    , #tractors.BATRKR as Tractor
    , PROHDR.AJBLNO AS BOL
    , PROHDR.AJPONO AS PONumber
    , #pickups.DLPUNO as Pickup#
    , APPT.BSDATE AS ApptDate
    , #est.estDeliveryDate as estDeliveryDate
    , APPT.BSDLDT AS DeliveredDate
INTO #tempResults
FROM #uniquePros
    INNER JOIN [PROHDR] PROHDR on PROHDR.AJPRO# = #uniquePros.BBPRO
    INNER JOIN [APPT] APPT on APPT.BSPRO = PROHDR.AJPRO#
    INNER JOIN #tractors on #tractors.BBPRO = PROHDR.AJPRO#
    INNER JOIN #proManifests on #proManifests.BBPRO = PROHDR.AJPRO#
    LEFT JOIN  #pickups on #pickups.DLPRO = PROHDR.AJPRO#
    LEFT JOIN  #est on #est.ALPRO = PROHDR.AJPRO#
GROUP BY PROHDR.AJSCD
    , PROHDR.AJPRO#
    , PROHDR.AJSCD
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
    , #proManifests.BAMFST
    , #tractors.BATRKR
    , PROHDR.AJBLNO
    , PROHDR.AJPONO
    , #pickups.DLPUNO
    , APPT.BSDATE
    , #est.estDeliveryDate
    , APPT.BSDLDT;

--INSERT INTO ProDataWH
--		(
--			CustomerID
--			, Pro
--			, DispatchCode
--			, Pieces
--			, [Weight]
--			, Origin
--			, OriginAddress
--			, OriginCity
--			, OriginState
--			, OriginZIP
--			, Consignee
--			, ConsigneeAddress
--			, ConsigneeCity
--			, ConsigneeState
--			, ConsigneeZIP
--			, Manifest
--			, Tractor
--			, BOL
--			, PONumber
--			, Pickup#
--			, ApptDate
--			, EstDeliveryDate
--			, DeliveredDate
--	)
SELECT CustomerID
    , Pro
    , DispatchCode
    , Pieces
    , [Weight]
    , Origin
    , OriginAddress
    , OriginCity
    , OriginState
    , OriginZIP
    , Consignee
    , ConsigneeAddress
    , ConsigneeCity
    , ConsigneeState
    , ConsigneeZIP
    , Manifest
    , Tractor
    , BOL
    , PONumber
    , Pickup#
    , CAST(CAST(apptDate AS VARCHAR(10)) AS DATE) AS ApptDate
    , CAST(CAST(estDeliveryDate AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
    , CASE WHEN DeliveredDate <> 0
        THEN CAST(CAST(DeliveredDate AS VARCHAR(10)) AS DATE)
        ELSE NULL
    END AS DeliveredDate
FROM #tempResults
ORDER BY Pro;

