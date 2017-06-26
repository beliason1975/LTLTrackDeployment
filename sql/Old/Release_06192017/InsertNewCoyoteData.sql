    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET NOCOUNT on;


DECLARE @fromDate as date = dateadd (week , -1 , getdate());

--declare  @searchTerm varchar(9) = '23267824'
--truncate table [LTLTRACK].[dbo].[ProDataWH]
insert into [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH]
SELECT
     case when fg.pro_nbr is not null and try_cast(fg.pro_nbr as int) is not null
          then cast(fg.pro_nbr as int)
          else NULL
     end                                                as PK_Pro
   , case when customer_id is not null and try_cast(customer_id as int) is not null
          then cast(customer_id as int)
          else NULL
     end                                                as CustomerID
   , NULL                                               as DispatchCode
   , case
         when o.pieces < 0 or isnull(o.pieces, 0) = 0
        then 0
        else o.pieces
     end                                                as Pieces
   , case
         when o.weight < 0 or isnull(o.weight, 0) = 0
         then 0
         else o.[weight]
     end                                                as Weight
   , rtrim(orig.location_name)                          as Origin
   , rtrim(orig.address)                                as OriginAddress
   , rtrim(orig.city_name)                              as OriginCity
   , rtrim(orig.state)                                  as OriginState
   , rtrim(orig.zip_code)                               as OriginZip
   , rtrim(con.location_name)                           as Consignee
   , rtrim(con.address)                                 as ConsigneeAddress
   , rtrim(con.city_name)                               as ConsigneeCity
   , case when rtrim(con.state)    = 'XX'
         then null
         else rtrim(con.state)
     end                                                as ConsigneeState
   , case when rtrim(con.zip_code) = '99999'
         then null
         else rtrim(con.zip_code)
     end                                                as ConsigneeZip
   , NULL                                               as Manifest
   , NULL                                               as Tractor
   , NULL                                               as BOL
   , NULL                                               as PONumber
   , orig.sched_arrive_early                            as ReadyTime
   , orig.sched_arrive_late                             as CloseTime
   , rtrim(o.coyote_pu_no)                              as CoyotePickupNumber
   , rtrim(o.id)                                        as McLeodPickupNumber
   , rtrim(con.sched_arrive_early)                      as ApptDate
   , rtrim(con.sched_arrive_late)                       as EstDeliveryDate
   , rtrim(con.actual_arrival)                          as DeliveredDate
from [MCLEOD].[lme_1510_ltl].[dbo].orders o
    left join  [MCLEOD].[lme_1510_ltl].[dbo].[stop]         orig on orig.id = o.shipper_stop_id    and
                                      orig.company_id = o.company_id and
                                      orig.stop_type = 'PU'
    left join  [MCLEOD].[lme_1510_ltl].[dbo].[stop]         con  on con.id = o.consignee_stop_id   and
                                      con.company_id = o.company_id  and
                                      con.stop_type = 'SO'
    left join [MCLEOD].[lme_1510_ltl].[dbo].freight_group  fg   on fg.lme_order_id = o.id         and
                                      fg.company_id = o.company_id
where o.ordered_date >= @fromDate and isnull(fg.pro_nbr, '') <> '' and try_cast(fg.pro_nbr as int) is not null
group by
     case when fg.pro_nbr is not null and try_cast(fg.pro_nbr as int) is not null
          then cast(fg.pro_nbr as int)
          else NULL
     end
   , case when customer_id is not null and try_cast(customer_id as int) is not null
          then cast(customer_id as int)
          else NULL
     end
   , case
         when o.pieces < 0 or isnull(o.pieces, 0) = 0
         then 0
         else o.pieces
    end
   , case
        when o.weight < 0 or isnull(o.weight, 0) = 0
        then 0
        else o.[weight]
     end
   , rtrim(orig.location_name)
   , rtrim(orig.address)
   , rtrim(orig.city_name)
   , rtrim(orig.state)
   , rtrim(orig.zip_code)
   , rtrim(con.location_name)
   , rtrim(con.address)
   , rtrim(con.city_name)
   , case when rtrim(con.state) = 'XX'
        then null
        else rtrim(con.state)
     end
   , case when rtrim(con.zip_code) = '99999'
        then null
        else rtrim(con.zip_code)
     end
   , orig.sched_arrive_early
  ,  orig.sched_arrive_late

   , rtrim(o.coyote_pu_no)
   , rtrim(o.id)
   , rtrim(con.sched_arrive_early)
   , rtrim(con.sched_arrive_late)
   , rtrim(con.actual_arrival);

------------------------------------------------------------------------------------------------------------
------                                                                                              --------
------                                                                                              --------
------------------------------------------------------------------------------------------------------------

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

--DECLARE @fromDate as int = cast(convert(varchar(8), dateadd (day , -1, getdate()) ,112) as int)
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
where sta.ALDATE >= 20170622
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

IF OBJECT_ID('tempdb..#Tractors') IS NOT NULL DROP TABLE #Tractors;

CREATE TABLE #Tractors
(
    [Pro] [int] NOT NULL
   , [Tractor] [varchar](50) not NULL
);


declare @query2 varchar(max) =
'SELECT * FROM OPENQUERY(COYOTE,
''
select
        hdr.AJPRO#           as Pro
      , RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25))) as Tractor
from RDFSV31DTA.PROHDR hdr
LEFT JOIN RDFSV31DTA.PROSTA sta on sta.ALPRO = hdr.AJPRO# and sta.ALCO = hdr.AJCO# and sta.ALSTAT = ''''DUD''''
LEFT  JOIN RDFSV31DTA.PROSTA sta2 on sta2.ALPRO = hdr.AJPRO# and sta2.ALCO = hdr.AJCO# and sta2.ALFSC <> ''''I'''' and sta2.ALSTAT IN (''''DED'''', ''''DES'''', ''''DEL'''', ''''DEO'''')
LEFT  JOIN RDFSV31DTA.APPT apt on apt.BSPRO = hdr.AJPRO# and apt.BSCONO = hdr.AJCO#
LEFT JOIN  RDFSV31DTA.MFSTDTL dtl on dtl.BBPRO = hdr.AJPRO# and dtl.BBCO# = hdr.AJCO#
LEFT JOIN RDFSV31DTA.MFSTHDR on MFSTHDR.BAMFST = dtl.BBMFST AND MFSTHDR.BACO# = dtl.BBCO#
--LEFT  JOIN RDFSV31DTA.PUTRAN pu on pu.DLPRO = hdr.AJPRO#
--where  hdr.AJPRO# = 352411052
where sta.ALDATE >= 20170622 and RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25))) <> ''''''''
group by
        hdr.AJPRO# 
            , RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))

 '')'

insert into #Tractors exec(@query2);

IF OBJECT_ID('tempdb..#formatted') IS NOT NULL DROP TABLE #formatted;

CREATE TABLE #formatted
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
    [Tractor] [varchar](50) NULL,
    [BOL] [varchar](50) NULL,
    [PONumber] [varchar](50) NULL,
    [CoyotePickupNumber] [int] NULL,
    [ApptDateTime] datetime2(0) NULL,
    [EstDeliveryDateTime] datetime2(0) NULL,
    [DeliveredDate]   datetime2(0) NULL
);

insert into #formatted
select
       cr.Pro
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
     , T.Tractor
     , isnull(ltrim(rtrim(cr.BOL     )), NULL) 
     , isnull(ltrim(rtrim(cr.PONumber)), NULL) 
     , cr.CoyotePickupNumber
     , cast(substring(right(right('00000000' + cast(cr.ApptDate as varchar(100)), 8), 8), 1, 4) + '-' +
            substring(right(right('00000000' + cast(cr.ApptDate as varchar(100)), 8), 8), 5, 2) + '-' +
            substring(right(right('00000000' + cast(cr.ApptDate as varchar(100)), 8), 8), 7, 2) + ' ' +
            substring(right(right('0000'     + cast(cr.ApptTime as varchar(100)), 4), 4), 1, 2) + ':' +
            substring(right(right('0000'     + cast(cr.ApptTime as varchar(100)), 4), 4), 3, 2) as datetime2(0)) 
     , cast(substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 1, 4) + '-' +
            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 5, 2) + '-' +
            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 7, 2) + ' ' +
            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 1, 2) + ':' +
            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 3, 2)  + ':' +
            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 5, 2) as datetime2(0))
     , case
             when cr.DeliveredDate <> 0
             then cast(substring(right(right('00000000' + cast(cr.DeliveredDate as varchar(100)), 8), 8), 1, 4) + '-' +
                       substring(right(right('00000000' + cast(cr.DeliveredDate as varchar(100)), 8), 8), 5, 2) + '-' +
                       substring(right(right('00000000' + cast(cr.DeliveredDate as varchar(100)), 8), 8), 7, 2) as datetime2(0))
             else NULL
         end
    from #CoyoteResults cr
    inner join #Tractors T on T.Pro = cr.Pro;


update [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH]
set Pro                =     T.Pro,
    CustomerID         =     T.CustomerID,
    DispatchCode       =     T.DispatchCode,
    Pieces             =     T.Pieces,
    [Weight]           =     T.Weight,
    Origin             =     T.Origin,
    OriginAddress      =     T.OriginAddress,
    OriginCity         =     T.OriginCity,
    OriginState        =     T.OriginState,
    OriginZiP          =     T.OriginZip,
    Consignee          =     T.Consignee,
    ConsigneeAddress   =     T.ConsigneeAddress,
    ConsigneeCity      =     T.ConsigneeCity,
    ConsigneeState     =     T.ConsigneeState,
    ConsigneeZip       =     T.ConsigneeZip,
    Tractor            =     T.Tractor,
    BOL                =     T.BOL,
    PONumber           =     T.PONumber,
    ApptDate           =     T.ApptDateTime,
    EstDeliveryDate       =  T.EstDeliveryDateTime,
    DeliveredDate       =    T.DeliveredDate
from (
select *
from #formatted cr)  T
inner join [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH] w on w.Pro = T.Pro and w.CoyotePickupNumber = T.CoyotePickupNumber;


insert into [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH]
select     f.Pro
         , f.CustomerID
         , f.DispatchCode
         , f.Pieces
         , f.Weight
         , f.Origin
         , f.OriginAddress
         , f.OriginCity
         , f.OriginState
         , f.OriginZip
         , f.Consignee
         , f.ConsigneeAddress
         , f.ConsigneeCity
         , f.ConsigneeState
         , f.ConsigneeZip
         , NULL as Manifest
         , f.Tractor
         , f.BOL -- BOL
         , f.PONumber --PONumber
         , NULL as ReadyTime
         , NULL as CloseTime
         , f.CoyotePickupNumber --cr.CoyotePickupNumber
         , NULL  AS McLeodPickupNumber
         , f.ApptDateTime
         , f.EstDeliveryDateTime
         , f.DeliveredDate
from #formatted f
left join [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH] w on  w.Pro = f.Pro
where w.Pro is null;

insert into [OFFSQLSTDD01].[LTLTRACK].[dbo].[Pro]
select
  w1.Pro   as PK_Pro
, w1.CustomerID
, w1.DispatchCode
, w1.Pieces
, w1.[Weight]
, w1.Origin
, w1.OriginAddress
, w1.OriginCity
, w1.OriginState
, w1.OriginZip
, w1.Consignee
, w1.ConsigneeAddress
, w1.ConsigneeCity
, w1.ConsigneeState
, w1.ConsigneeZip
, NULL as Manifest
, max(w1.BOL) 
, max(w1.PONumber) 
, max(w1.CoyotePickupNumber)
, max(w1.McLeodPickupNumber)
, min(w1.ApptDate) as AppointmentDate
, min(w1.EstDeliveryDate)
, min(w1.DeliveredDate)
from
[OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH] w1
inner join
(
	select w2.Pro, MIN(w2.EstDeliveryDate) as MinEstDeliveryDate
	from [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH] w2
	group by w2.pro

) T
on w1.Pro = T.pro and
   w1.EstDeliveryDate = T.MinEstDeliveryDate
where w1.Pro not in (select p.PK_Pro from [OFFSQLSTDD01].[LTLTRACK].[dbo].[Pro] p group by p.PK_Pro)
GROUP BY
	  w1.Pro
	, w1.CustomerID
	, w1.DispatchCode
	, w1.Pieces
	, w1.[Weight]
	, w1.Origin
	, w1.OriginAddress
	, w1.OriginCity
	, w1.OriginState
	, w1.OriginZip
	, w1.Consignee
	, w1.ConsigneeAddress
	, w1.ConsigneeCity
	, w1.ConsigneeState
	, w1.ConsigneeZip;


    
INSERT INTO [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProTruck] (TruckID, FK_Pro)
SELECT ProDataWH.Tractor AS TruckID, ProDataWH.Pro AS FK_Pro
FROM [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH] ProDataWH
LEFT JOIN [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProTruck] ProTruck ON  ProDataWH.Pro = ProTruck.FK_Pro
                       AND ltrim(rtrim(ProDataWH.Tractor)) = ProTruck.TruckID
WHERE ProTruck.FK_Pro IS NULL and ltrim(rtrim(ProDataWH.Tractor)) <> ''
GROUP BY ProDataWH.Tractor, ProDataWH.Pro;


UPDATE [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProTruck]
SET ProTruck.StopTrackingPosition = 1
FROM [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProTruck] ProTruck
    left JOIN [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH] ProDataWH ON  ProDataWH.Pro = ProTruck.FK_Pro
          AND ProDataWH.Tractor = ProTruck.TruckID
WHERE ProDataWH.Pro is null;


