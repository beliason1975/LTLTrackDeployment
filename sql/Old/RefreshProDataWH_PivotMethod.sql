SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results;
CREATE TABLE #Results
(
    BAMFST int,
    BASTDT int,
    BASTTM int,
    BATRKR varchar(20),
    [Date] decimal,
    Arrived int,
    Dispatched int,
    Unloaded int,
    Emptied int
);

IF OBJECT_ID('tempdb..#GroupedResults') IS NOT NULL DROP TABLE #GroupedResults;
CREATE TABLE #GroupedResults
(
    BATRKR varchar(20),
    BAMFST int,
    BASTDT int,
    BASTTM int,
    Arrived int,
    Dispatched int,
    Unloaded int,
    Emptied int
);

IF OBJECT_ID('tempdb..#manifests') IS NOT NULL DROP TABLE #manifests;
CREATE TABLE #manifests
(
    BATRKR varchar(20),
    BAMFST int,
    BASTDT int,
    BASTTM int,
    BBPRO int,
    BBFSC int
);

IF OBJECT_ID('tempdb..#uniquePros') IS NOT NULL DROP TABLE #uniquePros;
CREATE TABLE #uniquePros
(
    BBPRO int
);

IF OBJECT_ID('tempdb..#pickups') IS NOT NULL DROP TABLE #pickups;
CREATE TABLE #pickups
(
    DLPRO int,
    DLPUNO int
);

IF OBJECT_ID('tempdb..#est') IS NOT NULL DROP TABLE #est;
CREATE TABLE #est
(
    ALPRO int,
    estDeliveryDate int
);

IF OBJECT_ID('tempdb..#tempResults') IS NOT NULL DROP TABLE #tempResults;

declare @fromTime as int = 20170401;

insert into #Results
select BBPRO, BASTDT, BASTTM, BBFSC, BAMFST, BATRKR, [Date], [ARV] as Arrived, [DSP] as Dispatched, [UNL] as Unloaded, [EMP] as Emptied
from
(
    SELECT BBPRO
            , BASTDT
            , BASTTM
            , BBFSC
            , CAST(BAMFST AS VARCHAR) BAMFST
            , CAST(BATRKR AS VARCHAR) BATRKR
            , MFSTSTA.ISSTAT as [Status]
    FROM[MFSTHDR] MFSTHDR
        INNER JOIN [MFSTSTA] MFSTSTA
        ON MFSTHDR.BAMFST = MFSTSTA.ISMFST
            AND BASTTM <> 0
            AND BBPRO <> 0
            AND ISNULL(RTRIM(LTRIM(BATRKR)), '') <> ''
) B
PIVOT
(
    count([Status])
    for [Status] IN
    ([ARV], [DSP], [UNL], [EMP])
) as pvt;

select BBPRO
    , BASTDT
    , BASTTM
    , BBFSC
    , BAMFST
    , BATRKR
    , sum(Arrived) as Arrived
    , sum(Dispatched) as Dispatched
    , sum(Unloaded) as Unloaded
    , sum(Emptied) as Emptied
into #manifests
from #Results
group by  BBPRO
        , BASTDT
        , BASTTM
        , BBFSC
        , BAMFST
        , BATRKR
having SUM(Arrived) <> SUM(Unloaded) or SUM(Dispatched) > SUM(Arrived);


-- insert into #manifests
-- select BATRKR, BAMFST, BASTDT, BASTTM, MFSTDTL.BBPRO, MFSTDTL.BBFSC
-- from #GroupedResults
--     INNER JOIN [MFSTDTL] MFSTDTL ON BAMFST = MFSTDTL.BBMFST
-- group by BATRKR, BAMFST, BASTDT, BASTTM, MFSTDTL.BBPRO, MFSTDTL.BBFSC;

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
select BATRKR, BBPRO
from #manifests
group by BATRKR, BBPRO

insert into #proManifests
select bamfst, bbpro
from #manifests
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
        , #pickups.DLPUNO as PickupNumber
        , APPT.BSDATE AS ApptDate
        , #est.estDeliveryDate as estDeliveryDate
        , APPT.BSDLDT AS DeliveredDate
INTO #tempResults
FROM #uniquePros
    INNER JOIN [PROHDR] PROHDR on PROHDR.AJPRO# = #uniquePros.BBPRO
    INNER JOIN [APPT] APPT on APPT.BSPRO = PROHDR.AJPRO#
    INNER JOIN #tractors on #tractors.BBPRO = PROHDR.AJPRO#
    INNER JOIN #proManifests on #proManifests.BBPRO = PROHDR.AJPRO#
    LEFT JOIN #pickups on #pickups.DLPRO = PROHDR.AJPRO#
    LEFT JOIN #est on #est.ALPRO = PROHDR.AJPRO#
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
--			, PickupNumber
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
        , PickupNumber
        , CAST(CAST(apptDate AS VARCHAR(10)) AS DATE) AS ApptDate
        , CAST(CAST(estDeliveryDate AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
        , CASE WHEN DeliveredDate <> 0
            THEN CAST(CAST(DeliveredDate AS VARCHAR(10)) AS DATE)
            ELSE NULL
        END AS DeliveredDate
FROM #tempResults
ORDER BY Pro;

