
UPDATE ProTruck
SET ProTruck.StopTrackingPosition = 1
FROM ProTruck
	left JOIN dbo.ProDataWH ON  ProDataWH.Pro = ProTruck.FK_Pro
						    AND ProDataWH.Tractor = ProTruck.TruckID
WHERE ProDataWH.Pro is null;


