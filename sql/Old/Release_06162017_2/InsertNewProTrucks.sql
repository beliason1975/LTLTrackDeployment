
INSERT INTO dbo.ProTruck(TruckID, FK_Pro)
SELECT ltrim(rtrim(ProDataWH.Tractor)) AS TruckID, ProDataWH.Pro AS FK_Pro
FROM dbo.ProDataWH
LEFT JOIN dbo.ProTruck ON  ProDataWH.Pro = ProTruck.FK_Pro
                       AND ltrim(rtrim(ProDataWH.Tractor)) = ProTruck.TruckID
WHERE ProTruck.FK_Pro IS NULL and ltrim(rtrim(ProDataWH.Tractor)) <> ''
GROUP BY ltrim(rtrim(ProDataWH.Tractor)), ProDataWH.Pro;

