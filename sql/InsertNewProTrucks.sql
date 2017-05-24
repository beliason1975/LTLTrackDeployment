SET NOCOUNT ON;

INSERT INTO dbo.ProTruck(TruckID, FK_Pro)
SELECT ProDataWH.Tractor AS TruckID, ProDataWH.Pro AS FK_Pro
FROM dbo.ProDataWH
LEFT JOIN dbo.ProTruck ON  ProDataWH.Pro = ProTruck.FK_Pro
					   AND ProDataWH.Tractor = ProTruck.TruckID
WHERE ProTruck.FK_Pro IS NULL
GROUP BY ProDataWH.Tractor, ProDataWH.Pro;

-- select Pro, Tractor from ProDataWH
-- left join ProTruck  on  ProTruck.FK_Pro = ProDataWH.Pro
-- 					and ProTruck.TruckID = ProDataWH.Tractor
-- where FK_Pro is null
-- group by Pro, Tractor, FK_Pro
