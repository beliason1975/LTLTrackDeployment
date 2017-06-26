-- BY PICKUP#

IF OBJECT_ID('tempdb..#McLeodResults') IS NOT NULL DROP TABLE #McLeodResults;

CREATE TABLE #McLeodResults(
	[Pro] [int] NULL,
	[CustomerID] [int] NULL,
	[DispatchCode] [int] NULL,
	[Pieces] [int] NOT NULL,
	[Weight] [int] NOT NULL,
	[Origin] [varchar](256) NOT NULL,
	[OriginAddress] [varchar](256) NOT NULL,
	[OriginCity] [varchar](50) NOT NULL,
	[OriginState] [varchar](10) NOT NULL,
	[OriginZip] [varchar](10) NOT NULL,
	[Consignee] [varchar](256) NULL,
	[ConsigneeAddress] [varchar](256) NULL,
	[ConsigneeCity] [varchar](50) NULL,
	[ConsigneeState] [varchar](10) NULL,
	[ConsigneeZip] [varchar](10) NULL,
	[Manifest] [int] NULL,
	[Tractor] [varchar](50) NULL,
	[BOL] [varchar](50) NULL,
	[PONumber] [varchar](50) NULL,
	[ReadyTime] [datetime2](7) NULL,
	[CloseTime] [datetime2](7) NULL,
	[CoyotePickup#] [int] NULL,
	[McLeodPickup#] [int] NULL,
	[ApptDate] [datetime2](7) NULL,
	[EstDeliveryDate] [datetime2](7) NULL,
	[DeliveredDate] [datetime2](7) NULL);


DECLARE @baseDate as date = dateadd (week , -1 , getdate());
INSERT INTO #McLeodResults
SELECT DISTINCT
    fg.pro_nbr as Pro,
	NULL as CustomerID,
	NULL as DispatchCode,
    CASE WHEN o.pieces is NULL THEN 0 ELSE o.pieces END  as Pieces,
    CASE WHEN o.[weight] is NULL THEN 0 ELSE o.[weight] END  as [Weight],
    RTRIM(ship.location_name) as Origin,
	CASE WHEN ISNULL(RTRIM(ship.address2), '') <> ''
	THEN RTRIM(ship.[address]) + RTRIM(ship.address2)
	ELSE RTRIM(ship.[address])
	END AS OriginAddress,
    RTRIM(ship.city_name) as OriginCity,
    RTRIM(ship.state) as OriginState,
    ship.zip_code as OriginZip,
    RTRIM(con.location_name) as Consignee,
	CASE WHEN ISNULL(RTRIM(con.address2), '') <> ''
	THEN RTRIM(con.[address]) + RTRIM(con.address2)
	ELSE RTRIM(con.[address])
	END AS ConsigneeAddress,
    RTRIM(con.city_name) as ConsigneeCity,
    CASE WHEN RTRIM(con.[state]) = 'XX' THEN NULL ELSE RTRIM(con.[state]) END as ConsigneeState,
    CASE WHEN RTRIM(con.zip_code) = '99999' THEN NULL ELSE RTRIM(con.zip_code) END as ConsigneeZip,
	NULL as Manifest,
	NULL as Tractor,
	NULL as BOL,
	NULL as PONumber,
    ship.sched_arrive_early as ReadyTime,
    ship.sched_arrive_late as CloseTime,
    cast(o.coyote_pu_no as int) as [CoyotePickup#],
    cast(o.id as int) as [McLeodPickup#],
	NULL as ApptDate,
	NULL as EstDeliveryDate,
	NULL as DeliveredDate
--INTO #McLeodResults
FROM dbo.orders o --with(nolock)
    LEFT  JOIN dbo.stop ship --with(nolock) ON --Shipper Info
           ON o.shipper_stop_id = ship.id AND
            o.company_id = ship.company_id AND
            ship.stop_type = 'PU'
    LEFT JOIN dbo.stop con --with(nolock) ON  --Consignee Info
           ON o.consignee_stop_id = con.id AND
            o.company_id = con.company_id AND
            con.stop_type = 'SO'
    LEFT  JOIN dbo.freight_group fg --WITH(NOLOCK) ON
           ON o.id = fg.lme_order_id AND
            o.company_id = fg.company_id AND
            ISNULL(RTRIM(fg.pro_nbr), '') <> '' AND	ISNUMERIC(fg.pro_nbr) = 1
WHERE o.ordered_date >= @baseDate --AND fg.pro_nbr = '298-71504' --AND o.operational_status <> 'PICK' --AND fg.lme_order_id is null



--COYOTE
DECLARE @fromDate as int = cast(convert(varchar(8), dateadd (week , -1 , getdate()) ,112) as int) -- all versions
IF OBJECT_ID('tempdb..#UniquePros') IS NOT NULL DROP TABLE #UniquePros;
SELECT
	  PROHDR.AJPRO# AS Pro
	, MAX(APPT.BSDATE) AS ApptDate
	, MAX(PROSTA.ALDATE) AS EstDeliveryDate
	, MAX(APPT.BSDLDT) AS DeliveredDate
INTO #UniquePros
FROM CoyoteDataWarehouse.dbo.[PROHDR]  PROHDR
	INNER JOIN CoyoteDataWarehouse.dbo.[PROSTA] PROSTA on PROSTA.ALPRO	= PROHDR.AJPRO# AND PROSTA.ALCO	= PROHDR.AJCO#
	LEFT JOIN  CoyoteDataWarehouse.dbo.[APPT]  APPT on APPT.BSPRO		= PROHDR.AJPRO# AND APPT.BSCONO	= PROHDR.AJCO#
where PROSTA.ALDATE >= @fromDate and APPT.BSDLDT <> 0 and PROHDR.AJCO# = 1
GROUP BY
	PROHDR.AJPRO#

---- Check for duplicate pros
--select Pro
--from #Results
--group by Pro
--having count(*) > 1

IF OBJECT_ID('tempdb..#Manifest') IS NOT NULL DROP TABLE #Manifest;
select distinct MFSTDTL.BBCO#, MFSTDTL.BBMFST, MFSTDTL.BBPRO
INTO #Manifest
from CoyoteDataWarehouse.dbo.[MFSTDTL] MFSTDTL
INNER JOIN #UniquePros p on p.Pro = MFSTDTL.BBPRO and MFSTDTL.BBCO# = 1
INNER JOIN
		(select distinct MFSTDTL.BBPRO, MAX(MFSTDTL.BBMFST) as MaxManifest
		from CoyoteDataWarehouse.dbo.[MFSTDTL] MFSTDTL
		join #UniquePros up on up.Pro = MFSTDTL.BBPRO and MFSTDTL.BBCO# = 1
		--where MFSTDTL.BBPRO = '432467538'
		group by MFSTDTL.BBPRO) groupedMFSTDTL
on MFSTDTL.BBPRO = groupedMFSTDTL.BBPRO
AND MFSTDTL.BBMFST = groupedMFSTDTL.MaxManifest
AND MFSTDTL.BBCO# = 1

---- Check for duplicate pros
--select BBPRO
--from #Manifest
--group by BBPRO
--having count(*) > 1
IF OBJECT_ID('tempdb..#CoyoteResults') IS NOT NULL DROP TABLE #CoyoteResults;
CREATE TABLE #CoyoteResults(
	[Pro] [int] NULL,
	[CustomerID] [int] NULL,
	[DispatchCode] [int] NULL,
	[Pieces] [int] NOT NULL,
	[Weight] [int] NOT NULL,
	[Origin] [varchar](256) NOT NULL,
	[OriginAddress] [varchar](256) NOT NULL,
	[OriginCity] [varchar](50) NOT NULL,
	[OriginState] [varchar](10) NOT NULL,
	[OriginZip] [varchar](10) NOT NULL,
	[Consignee] [varchar](256) NULL,
	[ConsigneeAddress] [varchar](256) NULL,
	[ConsigneeCity] [varchar](50) NULL,
	[ConsigneeState] [varchar](10) NULL,
	[ConsigneeZip] [varchar](10) NULL,
	[Manifest] [int] NULL,
	[Tractor] [varchar](50) NULL,
	[BOL] [varchar](50) NULL,
	[PONumber] [varchar](50) NULL,
	[ReadyTime] [datetime2](7) NULL,
	[CloseTime] [datetime2](7) NULL,
	[CoyotePickup#] [int] NULL,
	[McLeodPickup#] [int] NULL,
	[ApptDate] [datetime2](7) NULL,
	[EstDeliveryDate] [datetime2](7) NULL,
	[DeliveredDate] [datetime2](7) NULL);

INSERT INTO #CoyoteResults
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
    , m.BBMFST      AS Manifest
	, LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))) AS Tractor
	, CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25))))
        ELSE	NULL
      END AS BOL
	, CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25))))
        ELSE	NULL
      END AS PONumber
	, NULL as ReadyTime
    , NULL as CloseTime
	, PUTRAN.DLPUNO AS [CoyotePickup#]
	, NULL AS [McLeodPickup#]
	, CAST(CAST(p.ApptDate AS VARCHAR(10)) AS DATE) AS ApptDate
	, CAST(CAST(p.EstDeliveryDate AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
	, CAST(CAST(p.DeliveredDate AS VARCHAR(10)) AS DATE) AS DeliveredDate
--INTO #CoyoteResults
FROM #UniquePros p
	INNER JOIN #Manifest m on m.BBPRO = p.Pro
	INNER JOIN CoyoteDataWarehouse.dbo.[PROHDR]  PROHDR  on PROHDR.AJPRO#  = m.BBPRO  AND PROHDR.AJCO#  = m.BBCO#
	INNER JOIN CoyoteDataWarehouse.dbo.[MFSTHDR] MFSTHDR on MFSTHDR.BAMFST = m.BBMFST AND MFSTHDR.BACO#	= m.BBCO#
	LEFT  JOIN CoyoteDataWarehouse.dbo.[PUTRAN]  PUTRAN  on PUTRAN.DLPRO   = PROHDR.AJPRO#

----
--select mr.*
--from #CoyoteResults cr
--inner join #McLeodResults mr on mr.[McLeodPickup#] = cr.[CoyotePickup#]
--order by cr.[CoyotePickup#]

----UPDATE1---------
update #CoyoteResults
set #CoyoteResults.[McLeodPickup#] = mr.[McLeodPickup#]
from #CoyoteResults cr
inner join #McLeodResults mr on mr.[McLeodPickup#] = cr.[CoyotePickup#]

--select cr.*
--from #CoyoteResults cr
--left join #McLeodResults mr on mr.[CoyotePickup#] = cr.[CoyotePickup#]

----UPDATE2---------
update #CoyoteResults
set #CoyoteResults.[McLeodPickup#] = mr.[McLeodPickup#]
from #CoyoteResults cr
inner join #McLeodResults mr on mr.[CoyotePickup#] = cr.[CoyotePickup#]


------VerifyQuery---------
--select [CoyotePickup#], [McLeodPickup#] from #CoyoteResults where [CoyotePickup#] is not null and [McLeodPickup#] is not null
--order by [CoyotePickup#], [McLeodPickup#]
------ Result verification ------------ update1.rowCount + update2.rowCount = VerifyQuery.rowCount

-- INSERT McLeod results that don't exist in Coyote
--insert into #CoyoteResults

select md.[McLeodPickup#], cd.[McLeodPickup#]
from #McLeodResults md
left join #CoyoteResults cd on md.[McLeodPickup#] = cd.[McLeodPickup#]
where cd.[McLeodPickup#] is null

select md.*
from #McLeodResults md
where md.[McLeodPickup#] not in (select c.[McLeodPickup#] from #CoyoteResults c where c.[CoyotePickup#] is not null and c.[McLeodPickup#] is not null)

select * from #CoyoteResults where [CoyotePickup#] = 10475326 or [McLeodPickup#] = 10475326
select * from #CoyoteResults where [CoyotePickup#] = 23225145 or [McLeodPickup#] = 23225145

--select * from #CoyoteResults order by [CoyotePickup#], [McLeodPickup#]
--select * from #McLeodResults order by [CoyotePickup#], [McLeodPickup#]
--select *
--from #CoyoteResults cr
--where [McLeodPickup#] = 23242397 or [CoyotePickup#] = 23242397
--order by cr.[CoyotePickup#]


--where mr.[McLeodPickup#] = 23242397 or mr.[CoyotePickup#] = 23242397
---- Result verification
--select cr.*
--from #CoyoteResults cr
--where cr.[CoyotePickup#] is not null and cr.[McLeodPickup#] is not null --and mr.Pro is null --and (mr.[McLeodPickup#] = 23245909 or mr.[McLeodPickup#] = 23264071)
--order by cr.[CoyotePickup#]
---- Verify columns match
--select top 1 * from #McLeodResults
--select top 1 * from #CombinedResults

--IF OBJECT_ID('tempdb..#CombinedResults') IS NOT NULL DROP TABLE #CombinedResults;
