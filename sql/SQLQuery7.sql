IF OBJECT_ID('tempdb..#CoyoteResults') IS NOT NULL DROP TABLE #CoyoteResults;

CREATE TABLE #CoyoteResults
(
    [Pro] [int] NOT NULL,
    [CustomerID] [int] NULL,
    [DispatchCode] [int] NULL,
    [Pieces] [int] NULL,
    [Weight] [int] NULL,
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
    --[Manifest] [int] NULL,
    --[Tractor] [varchar](50) NULL,
    [BOL] [varchar](50) NULL,
    [PONumber] [varchar](50) NULL,
    --[ReadyTime] [datetime2](7) NULL,
    --[CloseTime] [datetime2](7) NULL,
    [CoyotePickupNumber] [int] NULL,
    --[McLeodPickupNumber] [int] NULL,
    [ApptDate] decimal(8,0) NULL,
    [ApptTime] decimal(8,0) NULL,
    [EstDeliveryDate] decimal(8,0) NULL,
    [EstDeliveryTime] decimal(8,0) NULL,
    [DeliveredDate]   decimal(8,0) NULL
);

DECLARE @fromDate2 as varchar(10) = convert(varchar(8), dateadd (week , -3, getdate()) ,112)
-- all versions

declare @query1 varchar(max) =
'SELECT * FROM OPENQUERY(COYOTE,
''
select
        hdr.AJPRO#           as Pro
      , hdr.AJSCD	         as CustomerID
      , hdr.AJDID	         as DispatchCode
      , hdr.AJTPCS           as Pieces
      , hdr.AJTWGT           as Weight
      , hdr.AJSNM	         as Origin
      , hdr.AJSAD1	         as OriginAddress
      , hdr.AJSCTY	         as OriginCity
      , hdr.AJSST	         as OriginState
      , hdr.AJSZIP	         as OriginZip
      , hdr.AJCNM	         as Consignee
      , hdr.AJCAD1	         as ConsigneeAddress
      , hdr.AJCCTY	         as ConsigneeCity
      , hdr.AJCST	         as ConsigneeState
      , hdr.AJCZIP	         as ConsigneeZip
      , hdr.AJBLNO           as BOL
      , hdr.AJPONO           as PONumber
      , pu.DLPUNO            as CoyotePickupNumber
      , apt.BSDATE           as ApptDate
      , apt.BSTIME           as ApptTime
      , sta.ALDATE           as EstDeliveryDate
      , sta.ALPTIM           as EstDeliveryTime
      , apt.BSDLDT           as DeliveredDate
from RDFSV31DTA.PROHDR hdr
LEFT JOIN RDFSV31DTA.PROSTA sta on sta.ALPRO = hdr.AJPRO# and sta.ALCO = hdr.AJCO# and sta.ALSTAT = ''''DUD''''
LEFT  JOIN RDFSV31DTA.PROSTA sta2 on sta2.ALPRO = hdr.AJPRO# and sta2.ALCO = hdr.AJCO# and sta2.ALFSC <> ''''I'''' and sta2.ALSTAT IN (''''DED'''', ''''DES'''', ''''DEL'''', ''''DEO'''')
LEFT  JOIN RDFSV31DTA.APPT apt on apt.BSPRO = hdr.AJPRO# and apt.BSCONO = hdr.AJCO#
LEFT  JOIN RDFSV31DTA.PUTRAN pu on pu.DLPRO = hdr.AJPRO#
--where  hdr.AJPRO# = 352411052
where sta.ALDATE >= ' + @fromDate2 + '
group by
       hdr.AJPRO#
     , hdr.AJSCD
     , hdr.AJDID
     , hdr.AJTPCS
     , hdr.AJTWGT
     , hdr.AJSNM
     , hdr.AJSAD1
     , hdr.AJSCTY
     , hdr.AJSST
     , hdr.AJSZIP
     , hdr.AJCNM
     , hdr.AJCAD1
     , hdr.AJCCTY
     , hdr.AJCST
     , hdr.AJCZIP
     , hdr.AJBLNO
     , hdr.AJPONO
     , pu.DLPUNO
     , apt.BSDATE
     , apt.BSTIME
     , sta.ALDATE
     , sta.ALPTIM
     , apt.BSDLDT
 '')'

insert into #CoyoteResults exec(@query1);
