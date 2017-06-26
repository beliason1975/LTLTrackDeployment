IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results;
IF OBJECT_ID('tempdb..#Results2') IS NOT NULL DROP TABLE #Results2;

DECLARE @fromDate as date = dateadd (week , -1 , getdate());

SELECT DISTINCT
    o.id as [McLeodPickupNumber],
    o.coyote_pu_no as [CoyotePickupNumber],
    fg.pro_nbr as Pro,
	o.operational_status,
    RTRIM(ship.location_name) as Origin,
	CASE WHEN ISNULL(RTRIM(ship.address2), '') <> ''
	THEN RTRIM(ship.[address]) + RTRIM(ship.address2)
	ELSE RTRIM(ship.[address])
	END AS OriginAddress,
    RTRIM(ship.city_name) as OriginCity,
    RTRIM(ship.state) as OriginState,
    ship.zip_code as OriginZip,
    RTRIM(con.location_name) as Consignee,
	CASE WHEN ISNULL(RTRIM(con.address2), '') <> ''
	THEN RTRIM(con.[address]) + RTRIM(con.address2)
	ELSE RTRIM(con.[address])
	END AS ConsigneeAddress,
    RTRIM(con.city_name) as ConsigneeCity,
    CASE WHEN RTRIM(con.[state]) = 'XX' THEN NULL ELSE RTRIM(con.[state]) END as ConsigneeState,
    CASE WHEN RTRIM(con.zip_code) = '99999' THEN NULL ELSE RTRIM(con.zip_code) END as ConsigneeZip,
    ship.sched_arrive_early as SchedArriveEarly,
    ship.sched_arrive_late as SchedArriveLate,
    CASE WHEN o.operational_status = 'PICK' THEN ship.actual_departure ELSE NULL END as ActualDeparture,
    ship.projected_arrival  as ProjectedArrival,
    o.[weight],
    o.Pieces,
    o.[status],
    ship.operational_status as PUStopOpStatus,
    ship.actual_arrival as PUStopActualArrival,
    o.ordered_date as OrderDate
INTO #Results
FROM dbo.orders o with(nolock)
    LEFT  JOIN dbo.stop ship with(nolock) ON --Shipper Info
            o.shipper_stop_id = ship.id AND
            o.company_id = ship.company_id AND
            ship.stop_type = 'PU'
    LEFT JOIN dbo.stop con with(nolock) ON  --Consignee Info
            o.consignee_stop_id = con.id AND
            o.company_id = con.company_id AND
            con.stop_type = 'SO'
    LEFT  JOIN dbo.freight_group fg WITH(NOLOCK) ON
            o.id = fg.lme_order_id AND
            o.company_id = fg.company_id AND
            ISNULL(RTRIM(fg.pro_nbr), '') <> ''
WHERE o.ordered_date >= @fromDate --AND o.operational_status <> 'PICK'


SELECT DISTINCT
    o.id as [McLeodPickupNumber],
    o.coyote_pu_no as [CoyotePickupNumber],
    fg.pro_nbr as Pro,
	o.operational_status,
    RTRIM(ship.location_name) as Origin,
	CASE WHEN ISNULL(RTRIM(ship.address2), '') <> ''
	THEN RTRIM(ship.[address]) + RTRIM(ship.address2)
	ELSE RTRIM(ship.[address])
	END AS OriginAddress,
    RTRIM(ship.city_name) as OriginCity,
    RTRIM(ship.state) as OriginState,
    ship.zip_code as OriginZip,
    RTRIM(con.location_name) as Consignee,
	CASE WHEN ISNULL(RTRIM(con.address2), '') <> ''
	THEN RTRIM(con.[address]) + RTRIM(con.address2)
	ELSE RTRIM(con.[address])
	END AS ConsigneeAddress,
    RTRIM(con.city_name) as ConsigneeCity,
    CASE WHEN RTRIM(con.[state]) = 'XX' THEN NULL ELSE RTRIM(con.[state]) END as ConsigneeState,
    CASE WHEN RTRIM(con.zip_code) = '99999' THEN NULL ELSE RTRIM(con.zip_code) END as ConsigneeZip,
    ship.sched_arrive_early as SchedArriveEarly,
    ship.sched_arrive_late as SchedArriveLate,
    CASE WHEN o.operational_status = 'PICK' THEN ship.actual_departure ELSE NULL END as ActualDeparture,
    ship.projected_arrival  as ProjectedArrival,
    o.[weight],
    o.Pieces,
    o.[status],
    ship.operational_status as PUStopOpStatus,
    ship.actual_arrival as PUStopActualArrival,
    o.ordered_date as OrderDate
INTO #Results2
FROM dbo.orders o with(nolock)
    INNER JOIN dbo.stop ship with(nolock) ON --Shipper Info
			o.shipper_stop_id = ship.id AND
			o.company_id = ship.company_id AND
			ship.stop_type = 'PU'
    LEFT JOIN dbo.stop con with(nolock) ON  --Consignee Info
            o.consignee_stop_id = con.id AND
			o.company_id = con.company_id AND
			con.stop_type = 'SO'
    INNER JOIN dbo.freight_group fg with(nolock) ON
            o.id = fg.lme_order_id AND
			o.company_id = fg.company_id AND
            ISNULL(RTRIM(fg.pro_nbr), '') <> ''
WHERE o.ordered_date >= @fromDate and o.operational_status = 'PICK'


--select * from #Results2 where operational_status <> 'PICK'
select count(*) from #Results
select count(*) from #Results2
select *
from #Results r1
inner join #Results2 r2 on r2.[McLeodPickupNumber] = r1.[McLeodPickupNumber] and r2.Pro = r1.Pro
where r1.[McLeodPickupNumber] = '23248625'

