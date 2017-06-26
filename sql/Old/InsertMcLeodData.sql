
INSERT INTO [dbo].[ProDataWH]
           ([Pro]
           ,[CustomerID]
           ,[DispatchCode]
           ,[Pieces]
           ,[Weight]
           ,[Origin]
           ,[OriginAddress]
           ,[OriginCity]
           ,[OriginState]
           ,[OriginZip]
           ,[Consignee]
           ,[ConsigneeAddress]
           ,[ConsigneeCity]
           ,[ConsigneeState]
           ,[ConsigneeZip]
           ,[Manifest]
           ,[Tractor]
           ,[BOL]
           ,[PONumber]
           ,[CoyotePickupNumber]
           ,[McLeodPickupNumber]
           ,[ApptDate]
           ,[EstDeliveryDate]
           ,[DeliveredDate])
SELECT * from #track
LEFT JOIN dbo.ProDataWH p on p.Pro = #track.Pro
WHERE p.Pro is null
