


DELETE FROM dbo.ProTruck WHERE Manifest NOT IN (SELECT DISTINCT Manifest FROM dbo.ProDataWH);
