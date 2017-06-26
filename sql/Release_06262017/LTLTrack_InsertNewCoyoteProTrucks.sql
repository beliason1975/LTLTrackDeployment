USE [LTLTrack_Dev]
GO

/****** Object:  StoredProcedure [dbo].[LTLTrack_InsertNewCoyoteProTrucks]    Script Date: 06/26/2017 6:47:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LTLTrack_InsertNewCoyoteProTrucks]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LTLTrack_InsertNewCoyoteProTrucks] AS'
END
GO



ALTER PROCEDURE [dbo].[LTLTrack_InsertNewCoyoteProTrucks]
AS
BEGIN
    set nocount off;

    DECLARE @fromTime AS VARCHAR(10) = CONVERT(VARCHAR(8), DATEADD (day , -3, GETDATE()) ,112)

    IF OBJECT_ID('tempdb..#CoyoteResults') IS NOT NULL DROP TABLE #CoyoteResults;

    CREATE TABLE #CoyoteResults
    (
         [ProNumber] [int] NOT NULL
       , [Tractor] [varchar](50) NULL
    );

    DECLARE @query1 VARCHAR(MAX) =
    'SELECT * FROM OPENQUERY(COYOTE, ''
    SELECT BBPRO            as ProNumber
         , BATRKR           as Tractor
    FROM  RDFSV31DTA.MFSTDTL
    INNER JOIN RDFSV31DTA.MFSTHDR
              ON  BAMFST          = BBMFST
              AND BACO#           = BBCO#
              AND RTRIM(BATRKR) <> ''''''''
    where BASTDT >= ' + @fromTime + ' and RTRIM(BATRKR) <> '''''''' and BBCO# = 1
    GROUP BY  BBPRO
            , BATRKR
    '')'

    insert into #CoyoteResults exec(@query1);

    -- First insert any new Pro, TruckID entries
    insert into ProTruck
    select cr.ProNumber, cr.Tractor, 0
    from #CoyoteResults cr
    left join ProTruck pt on pt.FK_Pro = cr.ProNumber
                         and pt.TruckID = cr.Tractor
    where pt.FK_Pro is null

    -- Then update any entries that do not exist in the current data set from #CoyoteResults
    UPDATE ProTruck
    SET StopTrackingPosition = 1
    from ProTruck pt
    left join #CoyoteResults cr on cr.ProNumber = pt.FK_Pro
                               and cr.Tractor = pt.TruckID
    where cr.ProNumber is null and pt.FK_Pro is not null

END


GO


