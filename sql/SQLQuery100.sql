-----------------------------------------------------------
--Candidate for GetCoyoteData.sql
-----------------------------------------------------------
IF OBJECT_ID('tempdb..#CoyoteResults') IS NOT NULL DROP TABLE #CoyoteResults;

CREATE TABLE #CoyoteResults(
	[Pro] [int] NOT NULL,
	[CustomerID] [int] NULL,
	[DispatchCode] [int] NULL,
	[Pieces] [int] NOT NULL,
	[Weight] [int] NOT NULL,
	[Origin] [varchar](256) NULL,
	[OriginAddress] [varchar](256) NULL,
	[OriginCity] [varchar](50) NULL,
	[OriginState] [varchar](10) NULL,
	[OriginZip] [varchar](10) NULL,
	[Consignee] [varchar](256) NULL,
	[ConsigneeAddress] [varchar](256) NULL,
	[ConsigneeCity] [varchar](50) NULL,
	[ConsigneeState] [varchar](10) NULL,
	[ConsigneeZip] [varchar](10) NULL,
	[Manifest] [int] NULL,
	[Tractor] [varchar](50) NULL,
	[BOL] [varchar](50) NULL,
	[PONumber] [varchar](50) NULL,
	[CoyotePickupNumber] [int] NULL,
	[ApptDate] [datetime2](7) NULL,
	[EstDeliveryDate] [datetime2](7) NULL,
	[DeliveredDate] [datetime2](7) NULL);

DECLARE @fromDate as varchar(8) = convert(varchar, dateadd (week , -1 , getdate()), 112);

declare @query1 varchar(max) = NULL;

SELECT * FROM 
OPENQUERY(COYOTE,
'
select
  PROHDR.AJPRO# AS Pro
, PROHDR.AJSCD AS CustomerID
, PROHDR.AJDID AS DispatchCode
, PROHDR.AJTPCS AS Pieces
, PROHDR.AJTWGT AS Weight
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
, LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))) AS Tractor
, LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25)))) AS BOL
, LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25)))) AS PONumber
, PUTRAN.DLPUNO AS PickupNumber
, CAST(CAST(APPT.BSDATE AS VARCHAR(10)) AS DATE) AS ApptDate
, CAST(CAST(PROSTA.ALDATE AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
, CASE WHEN APPT.BSDLDT <> 0
,   THEN CAST(CAST(APPT.BSDLDT AS VARCHAR(10)) AS DATE)
,   ELSE NULL
, END AS DeliveredDate
FROM [PROHDR] PROHDR
left  join [PROSTA]  PROSTA  on PROSTA.ALPRO = PROHDR.AJPRO#    and PROSTA.ALCO = PROHDR.AJCO#
left  join [MFSTDTL] MFSTDTL on MFSTDTL.BBPRO = PROHDR.AJPRO#   and MFSTDTL.BBCO# = PROHDR.AJCO#
left  join [MFSTHDR] MFSTHDR on MFSTHDR.BAMFST = MFSTDTL.BBMFST and MFSTHDR.BACO# = MFSTDTL.BBCO#
left  join [APPT]    APPT    on APPT.BSPRO = PROHDR.AJPRO#      and APPT.BSCONO = PROHDR.AJCO#
left  join [PUTRAN]  PUTRAN  on PUTRAN.DLPRO = PROHDR.AJPRO#
WHERE ISNULL(PROSTA.ALDATE, '' +@fromDate+') >= '+@fromDate+'
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
, PUTRAN.DLPUNO
, LTRIM(RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25))))
, LTRIM(RTRIM(CAST(PROHDR.AJBLNO AS VARCHAR(25))))
, LTRIM(RTRIM(CAST(PROHDR.AJPONO AS VARCHAR(25))))
'')';

insert into #CoyoteResults exec(@query1);

update ProDataWH
set Pro                =     T.Pro,
    CustomerID         =     T.CustomerID,
    DispatchCode       =     T.DispatchCode,
    Pieces             =     T.Pieces,
    [Weight]           =     T.Weight,
    Origin             =     T.Origin,
    OriginAddress      =     T.OriginAddress,
    OriginCity         =     T.OriginCity,
    OriginState        =     T.OriginState,
    OriginZIP          =     T.OriginZIP,
    Consignee          =     T.Consignee,
    ConsigneeAddress   =     T.ConsigneeAddress,
    ConsigneeCity      =     T.ConsigneeCity,
    ConsigneeState     =     T.ConsigneeState,
    ConsigneeZIP       =     T.ConsigneeZIP,
    Manifest           =     T.Manifest,
    Tractor            =     T.Tractor,
    BOL                =     T.BOL,
    PONumber           =     T.PONumber,
    CoyotePickupNumber =     ISNULL(T.CoyotePickupNumber, CoyotePickupNumber),
    ApptDate           =     ISNULL(T.ApptDate, ApptDate),
    DeliveryDate       =     ISNULL(T.EstDeliveryDate, EstDeliveryDate),
    DeliveredDate      =     ISNULL(T.DeliveredDate, DeliveredDate)
from (
select *
from #CoyoteResults cr) T
where Pro = T.Pro;

insert into ProDataWH
select *
from #CoyoteResults cr
where cr.Pro not in (select wh.Pro from ProDataWH wh group by wh.Pro);



--SELECT
--      Pro
--    , CustomerID
--    , DispatchCode
--    , Pieces
--    , Weight
--    , Origin
--    , OriginAddress
--    , OriginCity
--    , OriginState
--    , OriginZIP
--    , Consignee
--    , ConsigneeAddress
--    , ConsigneeCity
--    , ConsigneeState
--    , ConsigneeZIP
--    , Tractor
--    , BOL
--    , PONumber
--    , PickupNumber
--    , ApptDate
--    , EstDeliveryDate
--    , DeliveredDate
--FROM #CoyoteResults
