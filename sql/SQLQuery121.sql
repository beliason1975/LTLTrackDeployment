---- select * from [MFSTPRO] MFSTPRO
---- join [PROHDR] PROHDR on PROHDR.AJPRO# = MFSTPRO.BCPRO
---- where MFSTPRO.BCMFST in (27344952, 27940741, 27460611,27706261,28254031,27706261,28254032)


--SET NOCOUNT ON;

--IF OBJECT_ID('tempdb..#results') IS NOT NULL DROP TABLE #results;
--IF OBJECT_ID('tempdb..#uniquepros') IS NOT NULL DROP TABLE #uniquepros;
--IF OBJECT_ID('tempdb..#grouped') IS NOT NULL DROP TABLE #grouped;

----select

----	  Pro
----    , CoyotePickupNumber
----    , McLeodPickupNumber
----	, ApptDate
----	, EstDeliveryDate
----	, DeliveredDate

--from
--(
--    SELECT
--      Pro
--    , CoyotePickupNumber
--    , McLeodPickupNumber
--	, ApptDate
--	, EstDeliveryDate
--	, DeliveredDate
--    from ProDataWH
--) B
--PIVOT
--(
--    count([Status])
--    for [Status] IN
--    ([ARV], [DSP], [UNL], [EMP])
--) as pvt;



select
      Pro
	, [APPT]
	, [ESTD]
    , [DELV]
    --, coalesce(CoyotePickupNumber, McLeodPickupNumber)  as [Pickup#]
    --, coalesce(ApptDate, EstDeliveryDate, DeliveredDate) as [DATE]
from
	(
  select
        Pro
      ,  min(CAST(CAST(ApptDate AS VARCHAR(10)) AS datetime2), CAST(CAST(EstDeliveryDate AS VARCHAR(10)) AS datetime2), CAST(CAST(DeliveredDate AS VARCHAR(10)) AS datetime2))
    , CAST(CAST(apptDate AS VARCHAR(10)) AS DATE) AS APPT
    , CAST(CAST(estDeliveryDate AS VARCHAR(10)) AS datetime2) AS ESTD
    , CASE WHEN DeliveredDate <> 0
       THEN CAST(CAST(DeliveredDate AS VARCHAR(10)) AS DATE)
       ELSE NULL
    END AS DeliveredDate
     from ProDataWH

) B
PIVOT
(
    count([SHIPDATES])
    for [SHIPDATES] IN
    ( [ESTD], [DELV])
) as pvt;

