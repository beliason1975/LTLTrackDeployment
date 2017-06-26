SET NOCOUNT on;


DECLARE @fromTime as varchar(10) = convert(varchar(8), dateadd (week , -3, getdate()) ,112)

IF OBJECT_ID('tempdb..#CoyoteResults') IS NOT NULL DROP TABLE #CoyoteResults;

CREATE TABLE #CoyoteResults
(
     [ProNumber] [int] NOT NULL
   , [Tractor] [varchar](50) NULL
   , [ManifestDate] decimal(8,0) NULL
   , [ManifestTime] decimal(8,0) NULL
   --, [DeliveredDate]   decimal(8,0) NULL
   --, [DeliveredTime] decimal(8,0) NULL
);

-- all versions
--declare @proNumber as int = 418599577;

declare @query1 varchar(max) =
'SELECT * FROM OPENQUERY(COYOTE, ''
SELECT BBPRO                       as ProNumber
     , BATRKR                      as Tractor
     , BASTDT                      as ManifestDate
     , BASTTM                      as ManifestTime

FROM  RDFSV31DTA.MFSTHDR
INNER JOIN RDFSV31DTA.MFSTSTA
          ON  ISMFST  =  BAMFST
          AND ISCONO  =  BACO#
          AND ISSTAT  IN (''''ARV'''',''''DSP'''')
INNER JOIN RDFSV31DTA.MFSTDTL
          ON  BBMFST  =  BAMFST
          AND BBCO#   =  BACO#
where     BATRKR = ''''40170''''
          --BATRKR like ''''%60045%''''  or
	      --BATRKR like ''''%43787%''''  or
	      --BATRKR like ''''%43784%''''  or
	      --BATRKR like ''''%60090%''''  or
	      --BATRKR like ''''%43827%''''  or
	      --BATRKR like ''''%60010A%'''' or
	      --BATRKR like ''''%60000%''''  or
	      --BATRKR like ''''%60072%''''  or
       --   BATRKR like ''''%43788%''''  or
       --   BATRKR like ''''%43573%''''  or
       --   BATRKR like ''''%43812%''''  or
       --   BATRKR like ''''%40170%''''  or
       --   BATRKR like ''''%43809%''''  or
       --   BATRKR like ''''%42412%''''  or
       --   BATRKR like ''''%43525%''''  or
       --   BATRKR like ''''%43818%''''  or
       --   BATRKR like ''''%42837%''''  or
       --   BATRKR like ''''%43684%''''  or
       --   BATRKR like ''''%80013%''''  or
       --   BATRKR like ''''%60051A%'''' or
       --   BATRKR like ''''%43659%''''
GROUP BY BBPRO
       , BATRKR
       , BASTDT 
       , BASTTM 
'')'

insert into #CoyoteResults exec(@query1);

select *
from #CoyoteResults
--where ProNumber = 319793501
--group by Tractor, ProNumber
order by ManifestDate, ManifestTime
-- select * from #CoyoteResults where rtrim(Tractor) <> '' order by StatusDateTime desc, ProNumber

--declare @query1 varchar(max) =
--'SELECT * FROM OPENQUERY(COYOTE, ''
--select * from RDFSV31DTA.PROSTA where ALPRO = 319793501
--'')'
--exec(@query1)
--IF OBJECT_ID('tempdb..#Tractors') IS NOT NULL DROP TABLE #Tractors;

--CREATE TABLE #Tractors
--(
--    [Pro] [int] NOT NULL
--   , [Tractor] [varchar](50) not NULL
--);

--declare @query2 varchar(max) =
--'SELECT * FROM OPENQUERY(COYOTE,
--''
--select
--        hdr.AJPRO#           as Pro
--      , RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25))) as Tractor
--from RDFSV31DTA.PROHDR hdr
--LEFT JOIN RDFSV31DTA.PROSTA sta on sta.ALPRO = hdr.AJPRO# and sta.ALCO = hdr.AJCO# and sta.ALSTAT = 'DUD'
--LEFT  JOIN RDFSV31DTA.PROSTA sta2 on sta2.ALPRO = hdr.AJPRO# and sta2.ALCO = hdr.AJCO# and sta2.ALFSC <> 'I' and sta2.ALSTAT IN ('DED', 'DES', 'DEL', 'DEO')
--LEFT  JOIN RDFSV31DTA.APPT apt on apt.BSPRO = hdr.AJPRO# and apt.BSCONO = hdr.AJCO#
--LEFT JOIN  RDFSV31DTA.MFSTDTL dtl on dtl.BBPRO = hdr.AJPRO# and dtl.BBCO# = hdr.AJCO#
--LEFT JOIN RDFSV31DTA.MFSTHDR on MFSTHDR.BAMFST = dtl.BBMFST AND MFSTHDR.BACO# = dtl.BBCO#
----LEFT  JOIN RDFSV31DTA.PUTRAN pu on pu.DLPRO = hdr.AJPRO#
----where  hdr.AJPRO# = 352411052
--where sta.ALDATE >= ' + @fromDate + ' and RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25))) <> ''
--group by
--        hdr.AJPRO#
--            , RTRIM(CAST(MFSTHDR.BATRKR AS VARCHAR(25)))

-- '')'

--insert into #Tractors exec(@query2);

--IF OBJECT_ID('tempdb..#formatted') IS NOT NULL DROP TABLE #formatted;

----CREATE TABLE #formatted
----(
----    [Pro] [int] NOT NULL,
----    [CustomerID] [int] NULL,
----    [DispatchCode] [int] NULL,
----    [Pieces] [int] NULL,
----    [Weight] [int] NULL,
----    [Origin] [varchar](256) NULL,
----    [OriginAddress] [varchar](256) NULL,
----    [OriginCity] [varchar](50) NULL,
----    [OriginState] [varchar](10) NULL,
----    [OriginZip] [varchar](10) NULL,
----    [Consignee] [varchar](256) NULL,
----    [ConsigneeAddress] [varchar](256) NULL,
----    [ConsigneeCity] [varchar](50) NULL,
----    [ConsigneeState] [varchar](10) NULL,
----    [ConsigneeZip] [varchar](10) NULL,
----    --[Tractor] [varchar](50) NULL,
----    [BOL] [varchar](50) NULL,
----    [PONumber] [varchar](50) NULL,
----    [CoyotePickupNumber] [int] NULL,
----    [ApptDateTime] datetime2(0) NULL,
----    [EstDeliveryDateTime] datetime2(0) NULL,
----    [DeliveredDateTime]   datetime2(0) NULL
----);


----IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results;
--CREATE TABLE #formatted
--(
--    [Pro] [int] NOT NULL,
--    [CustomerID] [int] NULL,
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
--    [BOL] [varchar](50) NULL,
--    [PONumber] [varchar](50) NULL,
--    [CoyotePickupNumber] [int] NULL,
--    [EstDeliveryDateTime] datetime2(0) NULL,
--);

----insert into #formatted
--insert into #formatted
--select distinct
--       cr.Pro
--     , cr.CustomerID
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
--     , cr.BOL
--     , cr.PONumber
--     , cr.CoyotePickupNumber
--     , cast(substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 1, 4) + '-' +
--            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 5, 2) + '-' +
--            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 7, 2) + ' ' +
--            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 1, 2) + ':' +
--            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 3, 2)  + ':' +
--            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 5, 2) as datetime2(0))
--    from #CoyoteResults cr
--    inner join
--(
--    select distinct f.pro,  cast(substring(right(right('00000000' + cast(MIN(f.EstDeliveryDate) as varchar(100)), 8), 8), 1, 4) + '-' +
--                                 substring(right(right('00000000' + cast(MIN(f.EstDeliveryDate) as varchar(100)), 8), 8), 5, 2) + '-' +
--                                 substring(right(right('00000000' + cast(MIN(f.EstDeliveryDate) as varchar(100)), 8), 8), 7, 2) + ' ' +
--                                 substring(right(right('000000'   + cast(MIN(f.EstDeliveryTime) as varchar(100)), 6), 6), 1, 2) + ':' +
--                                 substring(right(right('000000'   + cast(MIN(f.EstDeliveryTime) as varchar(100)), 6), 6), 3, 2)  + ':' +
--                                 substring(right(right('000000'   + cast(MIN(f.EstDeliveryTime) as varchar(100)), 6), 6), 5, 2) as datetime2(0)) as MinEstDeliveryDate
--    from #CoyoteResults f
--    group by f.pro
-- )T
-- on cr.Pro = T.Pro and cast(substring(right(right('00000000' +      cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 1, 4) + '-' +
--                                 substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 5, 2) + '-' +
--                                 substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 7, 2) + ' ' +
--                                 substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 1, 2) + ':' +
--                                 substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 3, 2)  + ':' +
--                                 substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 5, 2) as datetime2(0))  = T.MinEstDeliveryDate
-- order by cr.Pro

-- ----select r.pro from #Results r
-- --select * from #Results r
-- --where r.pro = 402171300
-- --group by r.pro having count(*) > 1

--   -- left join #Tractors T on T.Pro = cr.Pro
----    group by
----      cr.Pro
----     , cr.CustomerID
----     , cr.DispatchCode
----     , cr.Pieces
----     , cr.Weight
----     , cr.Origin
----     , cr.OriginAddress
----     , cr.OriginCity
----     , cr.OriginState
----     , cr.OriginZip
----     , cr.Consignee
----     , cr.ConsigneeAddress
----     , cr.ConsigneeCity
----     , cr.ConsigneeState
----     , cr.ConsigneeZip
------     , T.Tractor
----     , rtrim(cr.BOL)
----     , rtrim(cr.PONumber)
----     , cr.CoyotePickupNumber
----     , cast(substring(right(right('00000000' + cast(cr.ApptDate as varchar(100)), 8), 8), 1, 4) + '-' +
----            substring(right(right('00000000' + cast(cr.ApptDate as varchar(100)), 8), 8), 5, 2) + '-' +
----            substring(right(right('00000000' + cast(cr.ApptDate as varchar(100)), 8), 8), 7, 2) + ' ' +
----            substring(right(right('0000'     + cast(cr.ApptTime as varchar(100)), 4), 4), 1, 2) + ':' +
----            substring(right(right('0000'     + cast(cr.ApptTime as varchar(100)), 4), 4), 3, 2) as datetime2(0))
----     , cast(substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 1, 4) + '-' +
----            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 5, 2) + '-' +
----            substring(right(right('00000000' + cast(cr.EstDeliveryDate as varchar(100)), 8), 8), 7, 2) + ' ' +
----            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 1, 2) + ':' +
----            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 3, 2)  + ':' +
----            substring(right(right('000000'   + cast(cr.EstDeliveryTime as varchar(100)), 6), 6), 5, 2) as datetime2(0))
----     , case
----             when cr.DeliveredDate = 0 then NULL
----             else cast(substring(right(right('00000000' + cast(cr.DeliveredDate as varchar(100)), 8), 8), 1, 4) + '-' +
----                       substring(right(right('00000000' + cast(cr.DeliveredDate as varchar(100)), 8), 8), 5, 2) + '-' +
----                       substring(right(right('00000000' + cast(cr.DeliveredDate as varchar(100)), 8), 8), 7, 2) as datetime2(0))
----             end



------select * from #pickup p where p.f_pro in (
----select ff.* from #formatted ff where ff.pro in (
----select f.pro
----from #formatted f
----group by f.Pro
----having count(*) > 1
----)
----order by ff.Pro

----set nocount off;
----IF OBJECT_ID('tempdb..#pickup') IS NOT NULL DROP TABLE #pickup;
----IF OBJECT_ID('tempdb..#pickup2') IS NOT NULL DROP TABLE #pickup2;
----IF OBJECT_ID('tempdb..#pickup3') IS NOT NULL DROP TABLE #pickup3;
----IF OBJECT_ID('tempdb..#pickupTotal') IS NOT NULL DROP TABLE #pickupTotal;

--update [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH]
--set  w.CoyotePickupNumber    =     f.CoyotePickupNumber
----select f.CoyotePickupNumber, w.CoyotePickupNumber
--from (
--select *
--from #formatted cr
--where cr.CoyotePickupNumber is not null)  f
--inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro and w.McLeodPickupNumber = f.CoyotePickupNumber and w.CoyotePickupNumber is null



--select
--     f.Pro                          as f_Pro
--   , w.Pro                          as w_Pro
--   , f.CoyotePickupNumber           as f_CoyotePickupNumber
--   , w.CoyotePickupNumber           as w_CoyotePickupNumber
--   , w.McLeodPickupNumber           as w_McLeodPickupNumber
--   , f.CustomerID
--   , f.DispatchCode
--   , f.Pieces
--   , f.[Weight]
--   , f.Origin
--   , f.OriginAddress
--   , f.OriginCity
--   , f.OriginState
--   , f.OriginZiP
--   , f.Consignee
--   , f.ConsigneeAddress
--   , f.ConsigneeCity
--   , f.ConsigneeState
--   , f.ConsigneeZip
--   , f.Tractor
--   , f.BOL
--   , f.PONumber
--   , f.ApptDateTime
--   , f.EstDeliveryDateTime
--   , f.DeliveredDateTime
----into #pickup
--from #formatted f
--inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro and w.McLeodPickupNumber = f.CoyotePickupNumber
----where f.CoyotePickupNumber = 23268037
----where w.Pro in (select w_pro from #pickup group by w_pro)
--order by f.CoyotePickupNumber

--select
--     f.Pro                          as f_Pro
--   , w.Pro                          as w_Pro
--   , f.CoyotePickupNumber           as f_CoyotePickupNumber
--   , w.CoyotePickupNumber           as w_CoyotePickupNumber
--   , w.McLeodPickupNumber           as w_McLeodPickupNumber
--   , f.CustomerID
--   , f.DispatchCode
--   , f.Pieces
--   , f.[Weight]
--   , f.Origin
--   , f.OriginAddress
--   , f.OriginCity
--   , f.OriginState
--   , f.OriginZiP
--   , f.Consignee
--   , f.ConsigneeAddress
--   , f.ConsigneeCity
--   , f.ConsigneeState
--   , f.ConsigneeZip
--   , f.Tractor
--   , f.BOL
--   , f.PONumber
--   , f.ApptDateTime
--   , f.EstDeliveryDateTime
--   , f.DeliveredDateTime
----into #pickup2
--from #formatted f
--inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro and w.CoyotePickupNumber = f.CoyotePickupNumber
----where w.McLeodPickupNumber = 23268037
--order by f.CoyotePickupNumber

--select
--     f.Pro                    as f_Pro
--   , w.Pro                    as w_Pro
--   , f.CoyotePickupNumber     as f_CoyotePickupNumber
--   , w.CoyotePickupNumber     as w_CoyotePickupNumber
--   , w.McLeodPickupNumber     as w_McLeodPickupNumber
--   , f.CustomerID
--   , f.DispatchCode
--   , f.Pieces
--   , f.[Weight]
--   , f.Origin
--   , f.OriginAddress
--   , f.OriginCity
--   , f.OriginState
--   , f.OriginZiP
--   , f.Consignee
--   , f.ConsigneeAddress
--   , f.ConsigneeCity
--   , f.ConsigneeState
--   , f.ConsigneeZip
--   , f.Tractor
--   , f.BOL
--   , f.PONumber
--   , f.ApptDateTime
--   , f.EstDeliveryDateTime
--   , f.DeliveredDateTime
----into #pickup3
--from #formatted f
--inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro and w.CoyotePickupNumber <> f.CoyotePickupNumber
----where w.pro = 397295544
--order by f.CoyotePickupNumber

--select
--     f.Pro                          as f_Pro
--   , w.Pro                          as w_Pro
--   , f.CoyotePickupNumber           as f_CoyotePickupNumber
--   , w.CoyotePickupNumber           as w_CoyotePickupNumber
--   , w.McLeodPickupNumber           as w_McLeodPickupNumber
--   , f.CustomerID
--   , f.DispatchCode
--   , f.Pieces
--   , f.[Weight]
--   , f.Origin
--   , f.OriginAddress
--   , f.OriginCity
--   , f.OriginState
--   , f.OriginZiP
--   , f.Consignee
--   , f.ConsigneeAddress
--   , f.ConsigneeCity
--   , f.ConsigneeState
--   , f.ConsigneeZip
--   , f.Tractor
--   , f.BOL
--   , f.PONumber
--   , f.ApptDateTime
--   , f.EstDeliveryDateTime
--   , f.DeliveredDateTime
----into #pickupTotal
--from #formatted f
--inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = f.Pro
----where w.McLeodPickupNumber = 23268037
--order by f.CoyotePickupNumber


----select count(*) from #pickup;

--select * from #pickupTotal pt
--left join #pickup p on p.f_Pro = pt.f_Pro and p.w_McLeodPickupNumber = pt.f_CoyotePickupNumber
--where p.f_Pro is null

--select pt.* from #pickupTotal pt
--left join #pickup2 p on p.f_Pro = pt.f_Pro and p.w_CoyotePickupNumber = pt.f_CoyotePickupNumber
--where p.f_Pro is null

--select pt.* from #pickupTotal pt
--left join #pickup3 p on p.f_Pro = pt.f_Pro and p.w_CoyotePickupNumber <> pt.f_CoyotePickupNumber
--where p.f_Pro is null




----update [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH]
----set w.Pro                =     T.Pro,
----    w.CustomerID         =     T.CustomerID,
----    w.DispatchCode       =     T.DispatchCode,
----    w.Pieces             =     T.Pieces,
----    w.[Weight]           =     T.Weight,
----    w.Origin             =     T.Origin,
----    w.OriginAddress      =     T.OriginAddress,
----    w.OriginCity         =     T.OriginCity,
----    w.OriginState        =     T.OriginState,
----    w.OriginZiP          =     T.OriginZip,
----    w.Consignee          =     T.Consignee,
----    w.ConsigneeAddress   =     T.ConsigneeAddress,
----    w.ConsigneeCity      =     T.ConsigneeCity,
----    w.ConsigneeState     =     T.ConsigneeState,
----    w.ConsigneeZip       =     T.ConsigneeZip,
----    w.Tractor            =     T.Tractor,
----    w.BOL                =     T.BOL,
----    w.PONumber           =     T.PONumber,
----    --CoyotePickupNumber =     coalesce(T.CoyotePickupNumber, w.CoyotePickupNumber),
----    w.CoyotePickupNumber =     (select case when isnull(T.CoyotePickupNumber, 0) <> 0 then T.CoyotePickupNumber else case when isnull(w.CoyotePickupNumber, 0) <> 0 then w.CoyotePickupNumber else NULL end end),
----    w.ApptDate           =     coalesce(T.ApptDateTime, w.ApptDate),
----    w.EstDeliveryDate       =  coalesce(T.EstDeliveryDateTime, w.EstDeliveryDate),
----    w.DeliveredDate       =    coalesce(T.DeliveredDateTime, w.DeliveredDate)
----from (
----select *
----from #formatted cr)  T
----inner join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on w.Pro = T.Pro and w.CoyotePickupNumber = T.CoyotePickupNumber;


--insert into [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH]
--select     f.Pro
--         , f.CustomerID
--         , f.DispatchCode
--         , f.Pieces
--         , f.Weight
--         , f.Origin
--         , f.OriginAddress
--         , f.OriginCity
--         , f.OriginState
--         , f.OriginZip
--         , f.Consignee
--         , f.ConsigneeAddress
--         , f.ConsigneeCity
--         , f.ConsigneeState
--         , f.ConsigneeZip
--         , NULL as Manifest
--         , f.Tractor
--         , f.BOL -- BOL
--         , f.PONumber --PONumber
--         , NULL as ReadyTime
--         , NULL as CloseTime
--         , f.CoyotePickupNumber --cr.CoyotePickupNumber
--         , NULL  AS McLeodPickupNumber
--         , f.ApptDateTime
--         , f.EstDeliveryDateTime
--         , f.DeliveredDate
--from #formatted f
----left join [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w on  w.Pro = f.Pro
----where w.Pro is null;

--insert into [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[Pro]
--select
--  w1.Pro   as PK_Pro
--, w1.CustomerID
--, w1.DispatchCode
--, w1.Pieces
--, w1.[Weight]
--, w1.Origin
--, w1.OriginAddress
--, w1.OriginCity
--, w1.OriginState
--, w1.OriginZip
--, w1.Consignee
--, w1.ConsigneeAddress
--, w1.ConsigneeCity
--, w1.ConsigneeState
--, w1.ConsigneeZip
--, NULL as Manifest
--, max(w1.BOL)
--, max(w1.PONumber)
--, max(w1.CoyotePickupNumber)
--, max(w1.McLeodPickupNumber)
--, min(w1.ApptDate) as AppointmentDate
--, min(w1.EstDeliveryDate)
--, min(w1.DeliveredDate)
--from
--[OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w1
--inner join
--(
--    select w2.Pro, MIN(w2.EstDeliveryDate) as MinEstDeliveryDate
--    from [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] w2
--    group by w2.pro

--) T
--on w1.Pro = T.pro and
--   w1.EstDeliveryDate = T.MinEstDeliveryDate
--where w1.Pro not in (select p.PK_Pro from [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[Pro] p group by p.PK_Pro)
--GROUP BY
--      w1.Pro
--    , w1.CustomerID
--    , w1.DispatchCode
--    , w1.Pieces
--    , w1.[Weight]
--    , w1.Origin
--    , w1.OriginAddress
--    , w1.OriginCity
--    , w1.OriginState
--    , w1.OriginZip
--    , w1.Consignee
--    , w1.ConsigneeAddress
--    , w1.ConsigneeCity
--    , w1.ConsigneeState
--    , w1.ConsigneeZip;



--INSERT INTO [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProTruck] (TruckID, FK_Pro)
--SELECT ProDataWH.Tractor AS TruckID, ProDataWH.Pro AS FK_Pro
--FROM [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] ProDataWH
--LEFT JOIN [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProTruck] ProTruck ON  ProDataWH.Pro = ProTruck.FK_Pro
--                       AND ltrim(rtrim(ProDataWH.Tractor)) = ProTruck.TruckID
--WHERE ProTruck.FK_Pro IS NULL and ltrim(rtrim(ProDataWH.Tractor)) <> ''
--GROUP BY ProDataWH.Tractor, ProDataWH.Pro;

--set nocount off;
--UPDATE [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProTruck]
--SET ProTruck.StopTrackingPosition = 1
--FROM [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProTruck] ProTruck
--    left JOIN [OFFSQLSTDD01].[LTLTrack_Dev].[dbo].[ProDataWH] ProDataWH ON  ProDataWH.Pro = ProTruck.FK_Pro
--          AND ProDataWH.Tractor = ProTruck.TruckID
--WHERE ProDataWH.Pro is null;


