IF OBJECT_ID('tempdb..#results') IS NOT NULL DROP TABLE #results;
IF OBJECT_ID('tempdb..#grouped') IS NOT NULL DROP TABLE #grouped;

CREATE TABLE #results(
    [PK_Pro] [int] NOT NULL,
    [CustomerID] [int] NULL,
    [DispatchCode] [int] NULL,
    [Pieces] [int] NOT NULL,
    [Weight] [int] NOT NULL,
    [Origin] [varchar](256) NOT NULL,
    [OriginAddress] [varchar](256) NOT NULL,
    [OriginCity] [varchar](50) NOT NULL,
    [OriginState] [varchar](10) NOT NULL,
    [OriginZip] [varchar](10) NOT NULL,
    [Consignee] [varchar](256) NOT NULL,
    [ConsigneeAddress] [varchar](256) NOT NULL,
    [ConsigneeCity] [varchar](50) NOT NULL,
    [ConsigneeState] [varchar](10) NOT NULL,
    [ConsigneeZip] [varchar](10) NOT NULL,
    [Tractor] [varchar](50) NULL,
    [BOL] [varchar](50) NULL,
    [PONumber] [varchar](50) NULL,
    --[ReadyTime] [datetime2](7) NULL,
    --[CloseTime] [datetime2](7) NULL,
    [CoyotePickupNumber] [int] NULL,
    [McLeodPickupNumber] [int] NULL,
    [ApptDate] [decimal](8,0) NULL,
    [EstDeliveryDate] [decimal](8,0) NOT NULL,
    [DeliveredDate]   [decimal](8,0) NULL);

DECLARE @fromDate as varchar(8) = convert(varchar(8), dateadd (day , -1, getdate()) ,112) -- all versions

declare @query1 varchar(max) =
'SELECT * FROM OPENQUERY(COYOTE,
''
select    hdr.AJPRO#            as Pro
        , hdr.AJSCD	            as CustomerID
        , hdr.AJDID	            as DispatchCode
        , hdr.AJTPCS            as Pieces
        , hdr.AJTWGT            as Weight
        , hdr.AJSNM	            as Origin
        , hdr.AJSAD1	        as OriginAddress
        , hdr.AJSCTY	        as OriginCity
        , hdr.AJSST	            as OriginState
        , hdr.AJSZIP	        as OriginZIP
        , hdr.AJCNM	            as Consignee
        , hdr.AJCAD1	        as ConsigneeAddress
        , hdr.AJCCTY	        as ConsigneeCity
        , hdr.AJCST	            as ConsigneeState
        , hdr.AJCZIP	        as ConsigneeZIP
        , coalesce(rtrim(MFSTHDR.BATRKR ), ''''NA'''') as Tractor
        , coalesce(rtrim(hdr.AJBLNO     ), ''''NA'''')      as BOL
        , coalesce(rtrim(hdr.AJPONO     ), ''''NA'''')      as PONumber
        , coalesce(pu.DLPUNO, ''''00000000'''')              as CoyotePickupNumber
		, ''''00000000'''' as McLeodPickupNumber
        , coalesce(apt.BSDATE, sta.ALDATE, apt.BSDLDT, ' + @fromDate + ') as ApptDate
        , coalesce(sta.ALDATE, apt.BSDLDT, apt.BSDATE, ' + @fromDate + ') as EstDeliveryDate
        , coalesce(apt.BSDLDT, sta.ALDATE, apt.BSDATE, ' + @fromDate + ') as DeliveredDate
from RDFSV31DTA.PROHDR hdr
LEFT  JOIN RDFSV31DTA.PROSTA sta on sta.ALPRO = hdr.AJPRO# and sta.ALCO = hdr.AJCO#
LEFT  JOIN RDFSV31DTA.MFSTDTL dtl on dtl.BBPRO = hdr.AJPRO# and dtl.BBCO# = hdr.AJCO#
LEFT  JOIN RDFSV31DTA.MFSTHDR on MFSTHDR.BAMFST = dtl.BBMFST AND MFSTHDR.BACO#	= hdr.AJCO#
LEFT  JOIN RDFSV31DTA.APPT apt on apt.BSPRO = hdr.AJPRO# and apt.BSCONO = hdr.AJCO#
LEFT  JOIN RDFSV31DTA.PUTRAN pu on pu.DLPRO = hdr.AJPRO#
where coalesce(sta.ALDATE, apt.BSDLDT, apt.BSDATE, ' + @fromDate + ') >= ' + @fromDate + ' and hdr.AJCO# = 1
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
    , coalesce(rtrim(MFSTHDR.BATRKR ), ''''NA'''')
    , coalesce(rtrim(hdr.AJBLNO     ), ''''NA'''')
    , coalesce(rtrim(hdr.AJPONO     ), ''''NA'''')
    , coalesce(pu.DLPUNO, ''''00000000'''')
	, ''''00000000''''
    , coalesce(apt.BSDATE, sta.ALDATE, apt.BSDLDT, ' + @fromDate + ')
    , coalesce(sta.ALDATE, apt.BSDLDT, apt.BSDATE, ' + @fromDate + ')
    , coalesce(apt.BSDLDT, sta.ALDATE, apt.BSDATE, ' + @fromDate + ')
'')'
insert into #results exec(@query1);

IF OBJECT_ID('tempdb..#tractorgrouped') IS NOT NULL DROP TABLE #tractorgrouped;

select *
from #results r
inner join
(
select r1.pro, r1.tractor, MIN(EstDeliveryDate) as MinEstDeliveryDate
from #results r1
group by r1.pro, r1.tractor
having isnull(r1.tractor, '') <> ''
)t
on r.Pro = t.Pro and
   r.Tractor = t.Tractor and
   r.EstDeliveryDate = MinEstDeliveryDate

update ProDataWH
set Pro = T.Pro,
    CustomerID 		   =	 T.CustomerID         ,
    DispatchCode	   =	 T.DispatchCode		  ,
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
    Tractor            =     T.Tractor			  ,
    BOL                 =     T.BOL				  ,
    PONumber            =     T.PONumber		  ,
    CoyotePickupNumber =     T.CoyotePickupNumber,
    ApptDate            =     CAST(CAST(T.ApptDate AS VARCHAR(10)) AS DATE)		  ,
    EstDeliveryDate     =     CAST(CAST(T.EstDeliveryDate AS VARCHAR(10)) AS DATE)	  ,
    DeliveredDate       =     CASE WHEN T.DeliveredDate <> 0 THEN CAST(CAST(T.DeliveredDate AS VARCHAR(10)) AS DATE) ELSE NULL END
from
(
	select pro, tractor, MIN(EstDeliveryDate) as MinEstDeliveryDate
	from coyote
	--where pro = 277771531
	group by pro, tractor
	having isnull(tractor, '') <> ''

)
--from (
--select *
--from #results cr)  T
--inner join ProDataWH w on w.Pro = t.Pro
--and w.CoyotePickupNumber = T.CoyotePickupNumber

insert into coyote
select     cr.Pro
         , cr.CustomerID
         , cr.DispatchCode
         , cr.Pieces
         , cr.Weight
         , cr.Origin
         , cr.OriginAddress
         , cr.OriginCity
         , cr.OriginState
         , cr.OriginZIP
         , cr.Consignee
         , cr.ConsigneeAddress
         , cr.ConsigneeCity
         , cr.ConsigneeState
         , cr.ConsigneeZIP
         --, cr.Manifest
         , CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(cr.Tractor AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(cr.Tractor AS VARCHAR(25))))
        ELSE	NULL
      END as Tractor

    , CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(cr.BOL AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(cr.BOL AS VARCHAR(25))))
        ELSE	NULL
      END AS BOL
    , CASE WHEN	ISNULL(LTRIM(RTRIM(CAST(cr.PONumber AS VARCHAR(25)))), '') <> ''
        THEN   	LTRIM(RTRIM(CAST(cr.PONumber AS VARCHAR(25))))
        ELSE	NULL
      END AS PONumber
         --,cr.ReadyTime
         --,cr.CloseTime
         , cr.CoyotePickupNumber
         , NULL AS McLeodPickupNumber
         , CAST(CAST(cr.ApptDate AS VARCHAR(10)) AS DATE) AS ApptDate
         , CAST(CAST(cr.EstDeliveryDate AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
         , CASE WHEN cr.DeliveredDate <> 0
         THEN CAST(CAST(cr.DeliveredDate AS VARCHAR(10)) AS DATE)
          ELSE NULL
         END AS DeliveredDate
from #results cr
order by pro

select
      Pro
    , CustomerID
    , DispatchCode
    , Pieces
    , Weight
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
    , Tractor
    , BOL
    , PONumber
    , CoyotePickupNumber
    , McLeodPickupNumber
    , ApptDate
    , min(EstDeliveryDate) as MinEstDeliveryDate
    , DeliveredDate
from  coyote
group by
      Pro
    , CustomerID
    , DispatchCode
    , Pieces
    , Weight
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
    , Tractor
    , BOL
    , PONumber
    , CoyotePickupNumber
    , McLeodPickupNumber
    , ApptDate
    , DeliveredDate
order by pro
