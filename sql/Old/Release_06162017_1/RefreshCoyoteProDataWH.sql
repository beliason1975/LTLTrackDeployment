IF OBJECT_ID('tempdb..#CoyoteResults') IS NOT NULL DROP TABLE #CoyoteResults;
CREATE TABLE #CoyoteResults(
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
    [Manifest] [int] NULL,
    [Tractor] [varchar](50) NULL,
    [BOL] [varchar](50) NULL,
    [PONumber] [varchar](50) NULL,
    [ReadyTime] [datetime2](7) NULL,
    [CloseTime] [datetime2](7) NULL,
    [CoyotePickupNumber] [int] NULL,
    [McLeodPickupNumber] [int] NULL,
    [ApptDate] decimal(8,0) NULL,
    [EstDeliveryDate] decimal(8,0)  NULL,
    [DeliveredDate] decimal(8,0) NULL);

DECLARE @fromDate as varchar(8) = convert(varchar(8), dateadd (day , 0, getdate()) ,112) -- all versions

declare @query1 varchar(max) =
'SELECT * FROM OPENQUERY(COYOTE,
''
select     hdr.AJPRO#    as Pro             ,
           hdr.AJSCD	AS CustomerID      ,
           hdr.AJDID	AS DispatchCode	   ,
           hdr.AJTPCS   AS Pieces		   ,
           hdr.AJTWGT   AS Weight	       ,
           hdr.AJSNM	AS Origin		   ,
           hdr.AJSAD1	AS OriginAddress   ,
           hdr.AJSCTY	AS OriginCity	   ,
           hdr.AJSST	AS OriginState	   ,
           hdr.AJSZIP	AS OriginZip	   ,
           hdr.AJCNM	AS Consignee	   ,
           hdr.AJCAD1	AS ConsigneeAddress,
           hdr.AJCCTY	AS ConsigneeCity   ,
           hdr.AJCST	AS ConsigneeState  ,
           hdr.AJCZIP	AS ConsigneeZip	   ,
           MFSTHDR.BAMFST as Manifest,
           MFSTHDR.BATRKR as Tractor,
           hdr.AJBLNO as BOL,
           hdr.AJPONO AS PONumber,
           '''' '''' as ReadyTime,
           '''' '''' as StopTime,
       MAX(pu.DLPUNO) as CoyotePickupNumber,
       '''' '''' as McLeodPickupNumber,
       MAX(apt.BSDATE) AS ApptDate,
       MAX(sta.ALDATE) AS EstDeliveryDate,
       MAX(apt.BSDLDT) AS DeliveredDate
from RDFSV31DTA.PROHDR hdr
INNER JOIN RDFSV31DTA.PROSTA sta on sta.ALPRO = hdr.AJPRO# and sta.ALCO = hdr.AJCO#
LEFT JOIN  RDFSV31DTA.MFSTDTL dtl on dtl.BBPRO = hdr.AJPRO# and dtl.BBCO# = hdr.AJCO#
INNER JOIN RDFSV31DTA.MFSTHDR on MFSTHDR.BAMFST = dtl.BBMFST AND MFSTHDR.BACO#	= dtl.BBCO#
LEFT JOIN  RDFSV31DTA.APPT apt on apt.BSPRO = hdr.AJPRO# and apt.BSCONO = hdr.AJCO#
LEFT JOIN  RDFSV31DTA.PUTRAN pu on pu.DLPRO = hdr.AJPRO#
where sta.ALDATE >= ' + @fromDate + ' and hdr.AJCO# = 1
group by hdr.AJPRO#,
     hdr.AJSCD ,
     hdr.AJDID	,
     hdr.AJTPCS,
     hdr.AJTWGT,
     hdr.AJSNM ,
     hdr.AJSAD1,
     hdr.AJSCTY,
     hdr.AJSST ,
     hdr.AJSZIP,
     hdr.AJCNM ,
     hdr.AJCAD1,
     hdr.AJCCTY,
     hdr.AJCST ,
     hdr.AJCZIP,
	 MFSTHDR.BAMFST,
     MFSTHDR.BATRKR ,
     hdr.AJBLNO ,
     hdr.AJPONO
'')'

insert into #CoyoteResults exec(@query1);


 update ProDataWH
set Pro = T.Pro,
    CustomerID 		=	 T.CustomerID         ,
    DispatchCode		=	 T.DispatchCode		  ,
    Pieces             =     T.Pieces			  ,
    Weight             =     T.Weight			  ,
    Origin             =     T.Origin			  ,
    OriginAddress      =     T.OriginAddress	  ,
    OriginCity         =     T.OriginCity		  ,
    OriginState        =     T.OriginState		  ,
    OriginZIP          =     T.OriginZIP		  ,
    Consignee          =     T.Consignee		  ,
    ConsigneeAddress   =     T.ConsigneeAddress  ,
    ConsigneeCity      =     T.ConsigneeCity	  ,
    ConsigneeState     =     T.ConsigneeState	  ,
    ConsigneeZIP       =     T.ConsigneeZIP	  ,
    Manifest           =     T.Manifest		  ,
    Tractor            =     T.Tractor			  ,
   BOL                 =     T.BOL				  ,
   PONumber            =     T.PONumber		  ,
    CoyotePickupNumber =     T.CoyotePickupNumber,
   ApptDate            =     CAST(CAST(T.ApptDate AS VARCHAR(10)) AS DATE)		  ,
   EstDeliveryDate     =     CAST(CAST(T.EstDeliveryDate AS VARCHAR(10)) AS DATE)	  ,
   DeliveredDate       =     CASE WHEN T.DeliveredDate <> 0
         THEN CAST(CAST(T.DeliveredDate AS VARCHAR(10)) AS DATE)
          ELSE NULL
         END
from (
select *
from #CoyoteResults cr)  T
inner join ProDataWH w on w.Pro = t.Pro
and w.CoyotePickupNumber = T.CoyotePickupNumber


insert into ProDataWH
select     cr.Pro
         , cr.CustomerID
         , cr.DispatchCode
         , cr.Pieces
         , cr.Weight
         , cr.Origin
         , cr.OriginAddress
         , cr.OriginCity
         , cr.OriginState
         , cr.OriginZip
         , cr.Consignee
         , cr.ConsigneeAddress
         , cr.ConsigneeCity
         , cr.ConsigneeState
         , cr.ConsigneeZip
         , cr.Manifest
         , CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(cr.Tractor AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(cr.Tractor AS VARCHAR(25))))
        ELSE	NULL
      END

    , CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(cr.BOL AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(cr.BOL AS VARCHAR(25))))
        ELSE	NULL
      END AS BOL
    , CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(cr.PONumber AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(cr.PONumber AS VARCHAR(25))))
        ELSE	NULL
      END AS PONumber
         ,cr.ReadyTime
         ,cr.CloseTime
         , cr.CoyotePickupNumber
         , NULL AS McLeodPickupNumber
         , CAST(CAST(cr.ApptDate AS VARCHAR(10)) AS DATE) AS ApptDate
         , CAST(CAST(cr.EstDeliveryDate AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
         , CASE WHEN cr.DeliveredDate <> 0
         THEN CAST(CAST(cr.DeliveredDate AS VARCHAR(10)) AS DATE)
          ELSE NULL
         END AS DeliveredDate
from #CoyoteResults cr
left join ProDataWH on cr.Pro = ProDataWH.pro
where ProDataWH.pro is null

