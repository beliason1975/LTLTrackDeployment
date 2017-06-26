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
    [EstDeliveryDate] decimal(8,0)  NULL,
    [EstDeliveryDateTime] decimal(8,0)  NULL,
    [DeliveredDate] decimal(8,0) NULL);

DECLARE @fromDate as int = cast(convert(varchar(8), dateadd (day , -1, getdate()) ,112) as int) -- all versions

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
      , sta.ALPTIM           as EstDeliveryTIME
      , apt.BSDLDT           as DeliveredDate
from RDFSV31DTA.PROHDR hdr
INNER JOIN RDFSV31DTA.PROSTA sta on sta.ALPRO = hdr.AJPRO# and sta.ALCO = hdr.AJCO# and sta.ALSTAT = ''''DUD''''
INNER  JOIN RDFSV31DTA.PROSTA sta2 on sta2.ALPRO = hdr.AJPRO# and sta2.ALCO = hdr.AJCO# and sta2.ALFSC <> ''''I'''' and sta2.ALSTAT IN (''''DED'''', ''''DES'''', ''''DEL'''', ''''DEO'''')
LEFT  JOIN RDFSV31DTA.APPT apt on apt.BSPRO = hdr.AJPRO# and apt.BSCONO = hdr.AJCO#
LEFT  JOIN RDFSV31DTA.PUTRAN pu on pu.DLPRO = hdr.AJPRO#
--where  hdr.AJPRO# = 352411052
where sta.ALDATE >= 20170620
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
     , OriginZIP as OriginZip
     , Consignee
     , ConsigneeAddress
     , ConsigneeCity
     , ConsigneeState
     , ConsigneeZIP as ConsigneeZip
     , isnull(ltrim(rtrim(BOL     )), NULL) as BOL
     , isnull(ltrim(rtrim(PONumber)), NULL) as PONumber
     , CoyotePickupNumber
     , cast(substring(right(right('00000000' + cast(ApptDate as varchar(100)), 8), 8), 1, 4) + '-' + 
            substring(right(right('00000000' + cast(ApptDate as varchar(100)), 8), 8), 5, 2) + '-' + 
            substring(right(right('00000000' + cast(ApptDate as varchar(100)), 8), 8), 7, 2) + ' ' +
            substring(right(right('0000'     + cast(ApptTime as varchar(100)), 4), 4), 1, 2) + ':' +
            substring(right(right('0000'     + cast(ApptTime as varchar(100)), 4), 4), 3, 2) as datetime2(0)) as ApptDateTime
     , cast(substring(right(right('00000000' + cast(EstDeliveryDate as varchar(100)), 8), 8), 1, 4) + '-' + 
            substring(right(right('00000000' + cast(EstDeliveryDate as varchar(100)), 8), 8), 5, 2) + '-' + 
            substring(right(right('00000000' + cast(EstDeliveryDate as varchar(100)), 8), 8), 7, 2) + ' ' +
            substring(right(right('000000'   + cast(EstDeliveryDateTime as varchar(100)), 6), 6), 1, 2) + ':' +
            substring(right(right('000000'   + cast(EstDeliveryDateTime as varchar(100)), 6), 6), 3, 2)  + ':' +
            substring(right(right('000000'   + cast(EstDeliveryDateTime as varchar(100)), 6), 6), 5, 2) as datetime2(0)) as StatusDateTime
     , case 
             when DeliveredDate <> 0 
             then cast(substring(right(right('00000000' + cast(DeliveredDate as varchar(100)), 8), 8), 1, 4) + '-' + 
                       substring(right(right('00000000' + cast(DeliveredDate as varchar(100)), 8), 8), 5, 2) + '-' + 
                       substring(right(right('00000000' + cast(DeliveredDate as varchar(100)), 8), 8), 7, 2) as date) 
             else NULL 
         end as DeliveredDate
--into coyote_tmp
from #CoyoteResults                           

--select * from coyote_tmp  order by pro;--where pro = 399435809






--select top 1 *,
--cast(
--	   substring(right(right('00000000' + cast(appt.BSDLDT as varchar(100)), 8), 8), 1, 4) + '-' + 
--	   substring(right(right('00000000' + cast(appt.BSDLDT as varchar(100)), 8), 8), 5, 2) + '-' + 
--	   substring(right(right('00000000' + cast(appt.BSDLDT as varchar(100)), 8), 8), 7, 2) as date) as DeliveredDate ,
--cast(
--	   substring(right(right('00000000' + cast(appt.BSDATE as varchar(100)), 8), 8), 1, 4) + '-' + 
--	   substring(right(right('00000000' + cast(appt.BSDATE as varchar(100)), 8), 8), 5, 2) + '-' + 
--	   substring(right(right('00000000' + cast(appt.BSDATE as varchar(100)), 8), 8), 7, 2) + ' ' +
--	   substring(right(right('0000' + cast(appt.BSTIME as varchar(100)), 4), 4), 1, 2) + ':' +
--	   substring(right(right('0000' + cast(appt.BSTIME as varchar(100)), 4), 4), 3, 2) as datetime2(0)) as ApptDateTime
--from COYOTE.B10A282B.RDFSV31DTA.APPT appt








