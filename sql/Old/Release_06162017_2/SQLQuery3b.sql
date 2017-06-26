        --Get top level shipment info...
        SELECT
            o.id as [McLeodOrderNbr],
            ISNULL(o.coyote_pu_no, o.id) as [PickupRequestNbr], --2
            fg.pro_nbr as [ProNbr],
            o.operational_status as [OperationalStatus], --4
            RTRIM(ship.location_name) as [ShipperName],
            RTRIM(ship.[address]) as [ShipperAddress], --6
            RTRIM(ship.address2) as [ShipperAddress2],
            RTRIM(ship.city_name) as [ShipperCity], --8
            RTRIM(ship.state) as [ShipperState],
            ship.zip_code as [ShipperZip], --10
            RTRIM(con.location_name) as [ConsigneeName],
            RTRIM(con.[address]) as [ConsigneeAddress], --12
            RTRIM(con.address2) as [ConsigneeAddress2],
            RTRIM(con.city_name) as [ConsigneeCity], --14
            CASE WHEN RTRIM(con.[state]) = 'XX' THEN NULL ELSE RTRIM(con.[state]) END as [ConsigneeState],
            CASE WHEN RTRIM(con.zip_code) = '99999' THEN NULL ELSE RTRIM(con.zip_code) END as [ConsigneeZip], --16
            ship.sched_arrive_early as [SchedArriveEarly],
            ship.sched_arrive_late as [SchedArriveLate], --18
            CASE WHEN o.operational_status = 'PICK' THEN ship.actual_departure ELSE NULL END as [ActualDeparture],
            ship.projected_arrival  as [ProjectedArrival], --20
            RTRIM(ship.id) as [StopID],
            o.shipper_stop_id, --22
            o.consignee_stop_id,
            o.[weight], --24
            o.Pieces,
            fg.ship_ref_nbr, --26
            fg.cons_ref_nbr,
            o.[status], --28
            RTRIM(l.LocationCode) as [LocationCode],
            RTRIM(l.LocationName) as [LocationName], --30
            RTRIM(l.Phone) as [Phone],
            ship.operational_status as [PUStopOpStatus], --32
            ship.actual_arrival as [PUStopActualArrival],
            o.ordered_date as [OrderDate]
        --34
        FROM OFFSQLENTD01.McLeodData_LTL.dbo.orders o with(nolock)
            INNER JOIN OFFSQLENTD01.McLeodData_LTL.dbo.stop ship with(nolock) ON --Shipper Info
                                        o.shipper_stop_id = ship.id AND
                o.company_id = ship.company_id AND
                ship.stop_type = 'PU'
            LEFT JOIN OFFSQLENTD01.McLeodData_LTL.dbo.stop con with(nolock) ON  --Consignee Info
                                        o.consignee_stop_id = con.id AND
                o.company_id = con.company_id AND
                con.stop_type = 'SO'
            INNER JOIN OFFSQLENTD01.McLeodData_LTL.dbo.freight_group fg with(nolock) ON
                                        o.id = fg.lme_order_id AND
                o.company_id = fg.company_id
            LEFT JOIN (SELECT
                RTRIM(LocationCode) AS [LocationCode],
                RTRIM(LocationName) AS [LocationName],
                RTRIM(lcm.Value) AS [Phone]
                  FROM [SPINSQLC01\INTERNET].[RoadrunnerCentral].[dbo].[Location] l
                LEFT JOIN [SPINSQLC01\INTERNET].[RoadrunnerCentral].[dbo].LocationContactMethodValue lcm
                ON l.LocationID = lcm.LocationID
                INNER JOIN [SPINSQLC01\INTERNET].[RoadrunnerCentral].[dbo].ContactMethod cm
                ON lcm.ContactMethodID = cm.ContactMethodID
            WHERE cm.ContactMethodID = 21) l ON
                                        RTRIM(ship.zone_id) = RTRIM(l.LocationCode)
        WHERE o.operational_status = 'PICK' AND
             ------------------------------------------------------------------------------
    --IF ISNULL(@StopID,'') <> ''
    --BEGIN
    --    --Get Reference #(s) detail
    --    SELECT
    --        rn.stop_id,
    --        rn.reference_qual as [ReferenceQual],
    --        rn.reference_number as [ReferenceNbr]
    --    FROM OFFSQLENTD01.McLeodData_LTL.dbo.reference_number rn
    --    WHERE rn.stop_id = @StopID
    --        and rn.reference_qual NOT LIKE '%SI%'
    --END

