    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET NOCOUNT on;


DECLARE @fromDate as date = dateadd (week , -1 , getdate());

--declare  @searchTerm varchar(9) = '23267824'
truncate table [LTLTRACK].[dbo].[ProDataWH]
insert into [OFFSQLSTDD01].[LTLTRACK].[ProDataWH]
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
insert into #CoyoteResults
exec(@query1);

--select T.Pro
--from (
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
    --[Manifest] [int] NULL,
    --[Tractor] [varchar](50) NULL,
    [BOL] [varchar](50) NULL,
    [PONumber] [varchar](50) NULL,
    --[ReadyTime] [datetime2](7) NULL,
    --[CloseTime] [datetime2](7) NULL,
    [CoyotePickupNumber] [int] NULL,
    --[McLeodPickupNumber] [int] NULL,
    [ApptDateTime] datetime2(7) NULL,
    [EstDeliveryDateTime] datetime2(7) NULL,
    [DeliveredDate]   datetime2(7) NULL
);

insert into #formatted
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
            substring(right(right('000000'   + cast(EstDeliveryTime as varchar(100)), 6), 6), 1, 2) + ':' +
            substring(right(right('000000'   + cast(EstDeliveryTime as varchar(100)), 6), 6), 3, 2)  + ':' +
            substring(right(right('000000'   + cast(EstDeliveryTime as varchar(100)), 6), 6), 5, 2) as datetime2(0)) as EstDeliveryDateTime
     , case
             when DeliveredDate <> 0
             then cast(substring(right(right('00000000' + cast(DeliveredDate as varchar(100)), 8), 8), 1, 4) + '-' +
                       substring(right(right('00000000' + cast(DeliveredDate as varchar(100)), 8), 8), 5, 2) + '-' +
                       substring(right(right('00000000' + cast(DeliveredDate as varchar(100)), 8), 8), 7, 2) as date)
             else NULL
         end as DeliveredDate
    from #CoyoteResults
    --where Pro in ( 399481712
    --              ,256907478
    --              ,269490504
    --              ,274266295
    --              ,280525791
    --              ,299811877
    --              ,332328368
    --              ,341828176
    --              ,351005772
    --              ,357332733
    --              ,372611236
    --              ,373472778
    --              ,382101467
    --              ,389480161
    --              ,398527952
    --              ,398595652
    --              ,398602334
    --              ,398648824
    --              ,398778142
    --              ,399338649
    --              ,399481712
    --              ,405832932
    --              ,406949735
    --              ,409919743
    --              ,410354088
    --              ,410493456
    --              ,414245456
    --              ,415119650
    --              ,419718622
    --              ,421780958
    --              ,422002840
    --              ,422303917
    --              ,426346243
    --              ,426346250)


--order by Pro

--) T
--group by T.Pro
--having count(*) > 1
--order by T.Pro
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
    BOL                =     T.BOL,
    PONumber           =     T.PONumber,
    ApptDate           =     T.ApptDateTime,
    EstDeliveryDate       =  T.EstDeliveryDateTime,
    DeliveredDate       =    T.DeliveredDate
from (
select *
from #formatted cr)  T
inner join [OFFSQLSTDD01].[LTLTRACK].[dbo].[ProDataWH] w on w.Pro = T.Pro and w.CoyotePickupNumber = T.CoyotePickupNumber





