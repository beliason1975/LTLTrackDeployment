    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET NOCOUNT on;


DECLARE @fromDate as date = dateadd (week , -3 , getdate());

--declare  @searchTerm varchar(9) = '23267824'
--truncate table [LTLTrack_Dev].[dbo].[ProDataWH]
insert into [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH]
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
    LEFT join  [MCLEOD].[lme_1510_ltl].[dbo].[stop]         orig on orig.id = o.shipper_stop_id    and
                                      orig.company_id = o.company_id and
                                      orig.stop_type = 'PU'
    LEFT join  [MCLEOD].[lme_1510_ltl].[dbo].[stop]         con  on con.id = o.consignee_stop_id   and
                                      con.company_id = o.company_id  and
                                      con.stop_type = 'SO'
    LEFT join [MCLEOD].[lme_1510_ltl].[dbo].freight_group  fg   on fg.lme_order_id = o.id         and
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

IF OBJECT_ID('tempdb..#Tractors') IS NOT NULL DROP TABLE #Tractors;

CREATE TABLE #Tractors
(
    [Pro] [int] NOT NULL
   , [Tractor] [varchar](50) not NULL
);

DECLARE @fromDate2 as varchar(10) = convert(varchar(8), dateadd (week , -3, getdate()) ,112)
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
where sta.ALDATE >= ' + @fromDate2 + ' and RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25))) <> ''''''''
group by
        hdr.AJPRO#
            , RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))

 '')'

insert into #Tractors exec(@query2);

IF OBJECT_ID('tempdb..#formatted') IS NOT NULL DROP TABLE #formatted;

--CREATE TABLE #formatted
--(
--    [Pro] [int] NOT NULL,
--    [CustomerID] [int] NULL,
--    [DispatchCode] [int] NULL,
--    [Pieces] [int] NULL,
--    [Weight] [int] NULL,
--    [Origin] [varchar](256) NULL,
--    [OriginAddress] [varchar](256) NULL,
--    [OriginCity] [varchar](50) NULL,
--    [OriginState] [varchar](10) NULL,
--    [OriginZip] [varchar](10) NULL,
--    [Consignee] [varchar](256) NULL,
--    [ConsigneeAddress] [varchar](256) NULL,
--    [ConsigneeCity] [varchar](50) NULL,
--    [ConsigneeState] [varchar](10) NULL,
--    [ConsigneeZip] [varchar](10) NULL,
--    --[Tractor] [varchar](50) NULL,
--    [BOL] [varchar](50) NULL,
--    [PONumber] [varchar](50) NULL,
--    [CoyotePickupNumber] [int] NULL,
--    [ApptDateTime] datetime2(0) NULL,
--    [EstDeliveryDateTime] datetime2(0) NULL,
--    [DeliveredDateTime]   datetime2(0) NULL
--);


--IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results;
CREATE TABLE #formatted
(
    [Pro] [int] NOT NULL,
    [CustomerID] [int] NULL,
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
    [BOL] [varchar](50) NULL,
    [PONumber] [varchar](50) NULL,
    [CoyotePickupNumber] [int] NULL,
    [EstDeliveryDateTime] datetime2(0) NULL,
);

--insert into #formatted
insert into #formatted
select distinct
       cr.Pro
     , cr.CustomerID
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
     , cr.BOL
     , cr.PONumber
     , cr.CoyotePickupNumber
     , cast(substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 1, 4) + '-' +
            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 5, 2) + '-' +
            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 7, 2) + ' ' +
            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 1, 2) + ':' +
            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 3, 2)  + ':' +
            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 5, 2) as datetime2(0)) 
    from #CoyoteResults cr
    inner join
(
	select distinct f.pro,  cast(substring(right(right('00000000' + cast(MIN(f.EstDeliveryDate) as varchar(100)), 8), 8), 1, 4) + '-' +
                                 substring(right(right('00000000' + cast(MIN(f.EstDeliveryDate) as varchar(100)), 8), 8), 5, 2) + '-' +
                                 substring(right(right('00000000' + cast(MIN(f.EstDeliveryDate) as varchar(100)), 8), 8), 7, 2) + ' ' +
                                 substring(right(right('000000'   + cast(MIN(f.EstDeliveryTime) as varchar(100)), 6), 6), 1, 2) + ':' +
                                 substring(right(right('000000'   + cast(MIN(f.EstDeliveryTime) as varchar(100)), 6), 6), 3, 2)  + ':' +
                                 substring(right(right('000000'   + cast(MIN(f.EstDeliveryTime) as varchar(100)), 6), 6), 5, 2) as datetime2(0)) as MinEstDeliveryDate
	from #CoyoteResults f
	group by f.pro
 )T
 on cr.Pro = T.Pro and cast(substring(right(right('00000000' +      cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 1, 4) + '-' +
                                 substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 5, 2) + '-' +
                                 substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 7, 2) + ' ' +
                                 substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 1, 2) + ':' +
                                 substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 3, 2)  + ':' +
                                 substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 5, 2) as datetime2(0))  = T.MinEstDeliveryDate
 order by cr.Pro

 ----select r.pro from #Results r 
 --select * from #Results r 
 --where r.pro = 402171300
 --group by r.pro having count(*) > 1

   -- left join #Tractors T on T.Pro = cr.Pro
--    group by
--      cr.Pro
--     , cr.CustomerID
--     , cr.DispatchCode
--     , cr.Pieces
--     , cr.Weight
--     , cr.Origin
--     , cr.OriginAddress
--     , cr.OriginCity
--     , cr.OriginState
--     , cr.OriginZip
--     , cr.Consignee
--     , cr.ConsigneeAddress
--     , cr.ConsigneeCity
--     , cr.ConsigneeState
--     , cr.ConsigneeZip
----     , T.Tractor
--     , rtrim(cr.BOL)
--     , rtrim(cr.PONumber)
--     , cr.CoyotePickupNumber
--     , cast(substring(right(right('00000000' + cast(cr.ApptDate as varchar(100)), 8), 8), 1, 4) + '-' +
--            substring(right(right('00000000' + cast(cr.ApptDate as varchar(100)), 8), 8), 5, 2) + '-' +
--            substring(right(right('00000000' + cast(cr.ApptDate as varchar(100)), 8), 8), 7, 2) + ' ' +
--            substring(right(right('0000'     + cast(cr.ApptTime as varchar(100)), 4), 4), 1, 2) + ':' +
--            substring(right(right('0000'     + cast(cr.ApptTime as varchar(100)), 4), 4), 3, 2) as datetime2(0))
--     , cast(substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 1, 4) + '-' +
--            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 5, 2) + '-' +
--            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 7, 2) + ' ' +
--            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 1, 2) + ':' +
--            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 3, 2)  + ':' +
--            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 5, 2) as datetime2(0)) 
--     , case
--             when cr.DeliveredDate = 0 then NULL
--             else cast(substring(right(right('00000000' + cast(cr.DeliveredDate as varchar(100)), 8), 8), 1, 4) + '-' +
--                       substring(right(right('00000000' + cast(cr.DeliveredDate as varchar(100)), 8), 8), 5, 2) + '-' +
--                       substring(right(right('00000000' + cast(cr.DeliveredDate as varchar(100)), 8), 8), 7, 2) as datetime2(0)) 
--             end                                                                                   



----select * from #pickup p where p.f_pro in (
--select ff.* from #formatted ff where ff.pro in (
--select f.pro
--from #formatted f
--group by f.Pro
--having count(*) > 1
--)
--order by ff.Pro

--set nocount off;
--IF OBJECT_ID('tempdb..#pickup') IS NOT NULL DROP TABLE #pickup;
--IF OBJECT_ID('tempdb..#pickup2') IS NOT NULL DROP TABLE #pickup2;
--IF OBJECT_ID('tempdb..#pickup3') IS NOT NULL DROP TABLE #pickup3;
--IF OBJECT_ID('tempdb..#pickupTotal') IS NOT NULL DROP TABLE #pickupTotal;

update [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH]
set  w.CoyotePickupNumber    =     f.CoyotePickupNumber
--select f.CoyotePickupNumber, w.CoyotePickupNumber
from (
select *
from #formatted cr
where cr.CoyotePickupNumber is not null)  f
inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro and w.McLeodPickupNumber = f.CoyotePickupNumber and w.CoyotePickupNumber is null



select
     f.Pro                          as f_Pro
   , w.Pro                          as w_Pro
   , f.CoyotePickupNumber           as f_CoyotePickupNumber
   , w.CoyotePickupNumber           as w_CoyotePickupNumber
   , w.McLeodPickupNumber           as w_McLeodPickupNumber
   , f.CustomerID         
   , f.DispatchCode       
   , f.Pieces             
   , f.[Weight]           
   , f.Origin             
   , f.OriginAddress      
   , f.OriginCity         
   , f.OriginState        
   , f.OriginZiP          
   , f.Consignee          
   , f.ConsigneeAddress   
   , f.ConsigneeCity      
   , f.ConsigneeState     
   , f.ConsigneeZip       
   , f.Tractor            
   , f.BOL                
   , f.PONumber           
   , f.ApptDateTime           
   , f.EstDeliveryDateTime    
   , f.DeliveredDateTime     
--into #pickup 
from #formatted f
inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro and w.McLeodPickupNumber = f.CoyotePickupNumber
--where f.CoyotePickupNumber = 23268037
--where w.Pro in (select w_pro from #pickup group by w_pro)
order by f.CoyotePickupNumber

select
     f.Pro                          as f_Pro
   , w.Pro                          as w_Pro
   , f.CoyotePickupNumber           as f_CoyotePickupNumber
   , w.CoyotePickupNumber           as w_CoyotePickupNumber
   , w.McLeodPickupNumber           as w_McLeodPickupNumber
   , f.CustomerID         
   , f.DispatchCode       
   , f.Pieces             
   , f.[Weight]           
   , f.Origin             
   , f.OriginAddress      
   , f.OriginCity         
   , f.OriginState        
   , f.OriginZiP          
   , f.Consignee          
   , f.ConsigneeAddress   
   , f.ConsigneeCity      
   , f.ConsigneeState     
   , f.ConsigneeZip       
   , f.Tractor            
   , f.BOL                
   , f.PONumber           
   , f.ApptDateTime           
   , f.EstDeliveryDateTime    
   , f.DeliveredDateTime
--into #pickup2      
from #formatted f
inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro and w.CoyotePickupNumber = f.CoyotePickupNumber
--where w.McLeodPickupNumber = 23268037
order by f.CoyotePickupNumber

select
     f.Pro                    as f_Pro
   , w.Pro                    as w_Pro
   , f.CoyotePickupNumber     as f_CoyotePickupNumber
   , w.CoyotePickupNumber     as w_CoyotePickupNumber
   , w.McLeodPickupNumber     as w_McLeodPickupNumber
   , f.CustomerID         
   , f.DispatchCode       
   , f.Pieces             
   , f.[Weight]           
   , f.Origin             
   , f.OriginAddress      
   , f.OriginCity         
   , f.OriginState        
   , f.OriginZiP          
   , f.Consignee          
   , f.ConsigneeAddress   
   , f.ConsigneeCity      
   , f.ConsigneeState     
   , f.ConsigneeZip       
   , f.Tractor            
   , f.BOL                
   , f.PONumber           
   , f.ApptDateTime           
   , f.EstDeliveryDateTime    
   , f.DeliveredDateTime   
--into #pickup3   
from #formatted f
inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro and w.CoyotePickupNumber <> f.CoyotePickupNumber
--where w.pro = 397295544
order by f.CoyotePickupNumber

select
     f.Pro                          as f_Pro
   , w.Pro                          as w_Pro
   , f.CoyotePickupNumber           as f_CoyotePickupNumber
   , w.CoyotePickupNumber           as w_CoyotePickupNumber
   , w.McLeodPickupNumber           as w_McLeodPickupNumber
   , f.CustomerID         
   , f.DispatchCode       
   , f.Pieces             
   , f.[Weight]           
   , f.Origin             
   , f.OriginAddress      
   , f.OriginCity         
   , f.OriginState        
   , f.OriginZiP          
   , f.Consignee          
   , f.ConsigneeAddress   
   , f.ConsigneeCity      
   , f.ConsigneeState     
   , f.ConsigneeZip       
   , f.Tractor            
   , f.BOL                
   , f.PONumber           
   , f.ApptDateTime           
   , f.EstDeliveryDateTime    
   , f.DeliveredDateTime
--into #pickupTotal      
from #formatted f
inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro
--where w.McLeodPickupNumber = 23268037
order by f.CoyotePickupNumber


--select count(*) from #pickup;

select * from #pickupTotal pt
left join #pickup p on p.f_Pro = pt.f_Pro and p.w_McLeodPickupNumber = pt.f_CoyotePickupNumber
where p.f_Pro is null

select pt.* from #pickupTotal pt
left join #pickup2 p on p.f_Pro = pt.f_Pro and p.w_CoyotePickupNumber = pt.f_CoyotePickupNumber
where p.f_Pro is null

select pt.* from #pickupTotal pt
left join #pickup3 p on p.f_Pro = pt.f_Pro and p.w_CoyotePickupNumber <> pt.f_CoyotePickupNumber
where p.f_Pro is null




--update [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH]
--set w.Pro                =     T.Pro,
--    w.CustomerID         =     T.CustomerID,
--    w.DispatchCode       =     T.DispatchCode,
--    w.Pieces             =     T.Pieces,
--    w.[Weight]           =     T.Weight,
--    w.Origin             =     T.Origin,
--    w.OriginAddress      =     T.OriginAddress,
--    w.OriginCity         =     T.OriginCity,
--    w.OriginState        =     T.OriginState,
--    w.OriginZiP          =     T.OriginZip,
--    w.Consignee          =     T.Consignee,
--    w.ConsigneeAddress   =     T.ConsigneeAddress,
--    w.ConsigneeCity      =     T.ConsigneeCity,
--    w.ConsigneeState     =     T.ConsigneeState,
--    w.ConsigneeZip       =     T.ConsigneeZip,
--    w.Tractor            =     T.Tractor,
--    w.BOL                =     T.BOL,
--    w.PONumber           =     T.PONumber,
--    --CoyotePickupNumber =     coalesce(T.CoyotePickupNumber, w.CoyotePickupNumber),
--    w.CoyotePickupNumber =     (select case when isnull(T.CoyotePickupNumber, 0) <> 0 then T.CoyotePickupNumber else case when isnull(w.CoyotePickupNumber, 0) <> 0 then w.CoyotePickupNumber else NULL end end),
--    w.ApptDate           =     coalesce(T.ApptDateTime, w.ApptDate),
--    w.EstDeliveryDate       =  coalesce(T.EstDeliveryDateTime, w.EstDeliveryDate),
--    w.DeliveredDate       =    coalesce(T.DeliveredDateTime, w.DeliveredDate)
--from (
--select *
--from #formatted cr)  T
--inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = T.Pro and w.CoyotePickupNumber = T.CoyotePickupNumber;


insert into [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH]
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
--left join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on  w.Pro = f.Pro
--where w.Pro is null;

insert into [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[Pro]
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
[OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w1
inner join
(
	select w2.Pro, MIN(w2.EstDeliveryDate) as MinEstDeliveryDate
	from [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w2
	group by w2.pro

) T
on w1.Pro = T.pro and
   w1.EstDeliveryDate = T.MinEstDeliveryDate
where w1.Pro not in (select p.PK_Pro from [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[Pro] p group by p.PK_Pro)
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



INSERT INTO [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProTruck] (TruckID, FK_Pro)
SELECT ProDataWH.Tractor AS TruckID, ProDataWH.Pro AS FK_Pro
FROM [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] ProDataWH
LEFT JOIN [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProTruck] ProTruck ON  ProDataWH.Pro = ProTruck.FK_Pro
                       AND ltrim(rtrim(ProDataWH.Tractor)) = ProTruck.TruckID
WHERE ProTruck.FK_Pro IS NULL and ltrim(rtrim(ProDataWH.Tractor)) <> ''
GROUP BY ProDataWH.Tractor, ProDataWH.Pro;

set nocount off;
UPDATE [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProTruck]
SET ProTruck.StopTrackingPosition = 1
FROM [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProTruck] ProTruck
    left JOIN [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] ProDataWH ON  ProDataWH.Pro = ProTruck.FK_Pro
          AND ProDataWH.Tractor = ProTruck.TruckID
WHERE ProDataWH.Pro is null;


