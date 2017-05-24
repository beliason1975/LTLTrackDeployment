 -- DELETE FK

 IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_TruckPosition]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
 ALTER TABLE [dbo].[ProTruckPosition] DROP CONSTRAINT [FK_ProTruckPosition_TruckPosition];

 IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_Pro]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
 ALTER TABLE [dbo].[ProTruckPosition] DROP CONSTRAINT [FK_ProTruckPosition_Pro];

 IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_Pro]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
 ALTER TABLE [dbo].[ProReferenceLink] DROP CONSTRAINT [FK_ProReferenceLink_ProReference];

 truncate table ProDataWH;
 truncate table Pro;
 truncate table ProTruck;
 truncate table ProTruckPosition;
 truncate table TruckPosition;
 truncate table RandMessageIndex;
 insert into RandMessageIndex (PreviousLastMaxIndexReceived, LastMaxIndexReceived ) values (1, 1);


 -- CREATE FK
 IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_Pro]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
 ALTER TABLE [dbo].[ProTruckPosition]  WITH CHECK ADD  CONSTRAINT [FK_ProTruckPosition_Pro] FOREIGN KEY([FK_Pro])
 REFERENCES [dbo].[Pro] ([PK_Pro]);

 IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_Pro]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
 ALTER TABLE [dbo].[ProTruckPosition] CHECK CONSTRAINT [FK_ProTruckPosition_Pro];

 IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_TruckPosition]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
 ALTER TABLE [dbo].[ProTruckPosition]  WITH CHECK ADD  CONSTRAINT [FK_ProTruckPosition_TruckPosition] FOREIGN KEY([FK_TruckPosition])
 REFERENCES [dbo].[TruckPosition] ([PK_TruckPosition]);

 IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ProTruckPosition_TruckPosition]') AND parent_object_id = OBJECT_ID(N'[dbo].[ProTruckPosition]'))
 ALTER TABLE [dbo].[ProTruckPosition] CHECK CONSTRAINT [FK_ProTruckPosition_TruckPosition];
