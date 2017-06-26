USE [LTLTrack_Demo]
GO

/****** Object:  StoredProcedure [dbo].[UpdateProDataWH]    Script Date: 05/04/2017 11:30:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateProDataWH]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[UpdateProDataWH] AS'
END
GO



-- =============================================
-- Author:		Jason Stack
-- Create date: 09MAR2017
-- Description:	Update staging for Pro data tables
--				from Coyote
-- =============================================
ALTER PROCEDURE [dbo].[UpdateProDataWH]
AS

--DROP TABLE #manifests;
--DROP TABLE #tempResults;

BEGIN
    SET NOCOUNT ON;

    SELECT BBPRO
        , BASTDT
        , BASTTM
        , BBFSC
        , CAST (BAMFST AS VARCHAR) BAMFST
        , BATRKR
    INTO #manifests
    FROM [COYOTE].[B10A282B].[RDFSV31DTA].[MFSTHDR] MFSTHDR
        INNER JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[MFSTSTA] MFSTSTA
            ON MFSTHDR.BAMFST = MFSTSTA.ISMFST
                AND ISSTAT IN ('ARV','DSP')
                AND [ISDATE] >= 20170201
        INNER JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[MFSTDTL] MFSTDTL
            ON MFSTDTL.BBMFST  = MFSTHDR.BAMFST
    GROUP BY BBPRO
        , BASTDT
        , BASTTM
        , BBFSC
        , CAST (BAMFST AS VARCHAR)
        , BATRKR;


    --SELECT *
    --FROM #manifests

    DELETE FROM #manifests
    WHERE BAMFST IN
        (
            SELECT CAST (BAMFST AS VARCHAR) BAMFST
            FROM [COYOTE].[B10A282B].[RDFSV31DTA].[MFSTHDR] MFSTHDR
                INNER JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[MFSTSTA] MFSTSTA
                    ON MFSTHDR.BAMFST = MFSTSTA.ISMFST
                        AND ISSTAT IN ('UNL','EMP')
                        AND [ISDATE] >= 20170201
            GROUP BY CAST (BAMFST AS VARCHAR)
        );

    --SELECT *
    --FROM #manifests

    WITH ProFilter_cte AS
    (
        SELECT DISTINCT BBPRO
        FROM #manifests
    )
    , pickups_cte AS
    (
        SELECT PUTRAN.DLPRO
            , PUTRAN.DLPUNO
        FROM ProFilter_cte
            INNER JOIN  [COYOTE].[B10A282B].[RDFSV31DTA].[PUTRAN] PUTRAN
                ON ProFilter_cte.BBPRO = PUTRAN.DLPRO
        GROUP BY PUTRAN.DLPRO
            , PUTRAN.DLPUNO
    )
    , dueStatus_cte AS
    (
        SELECT PROSTA.ALPRO
            , PROSTA.ALDATE AS estDeliveryDate
        FROM ProFilter_cte
            INNER JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[PROSTA]
                ON ProFilter_cte.BBPRO = PROSTA.ALPRO
                    AND PROSTA.ALDATE >= 20170201
                    AND PROSTA.ALSTAT = 'DUD'
        GROUP BY PROSTA.ALPRO
            , PROSTA.ALDATE
    )
    SELECT PROHDR.AJSCD AS CustomerID
        , PROHDR.AJPRO# AS Pro
        , PROHDR.AJSCD AS DispatchCode
        , PROHDR.AJTPCS AS Pieces
        , PROHDR.AJTWGT AS [Weight]
        , PROHDR.AJSNM AS Origin
        , PROHDR.AJSAD1 AS OriginAddress
        , PROHDR.AJSCTY AS OriginCity
        , PROHDR.AJSST AS OriginState
        , PROHDR.AJSZIP AS OriginZIP
        , PROHDR.AJCNM AS Consignee
        , PROHDR.AJCAD1 AS ConsigneeAddress
        , PROHDR.AJCCTY AS ConsigneeCity
        , PROHDR.AJCST AS ConsigneeState
        , PROHDR.AJCZIP AS ConsigneeZIP
        , PROSTA.ALSTAT AS StatusCode
        , PROSTA.ALDATE AS StatusDate
        , PROSTA.ALTIME AS StatusTime
        , PROSTA.ALCMT AS StatusComment
        , PROSTA.ALXREF AS Manifest
        , #manifests.BATRKR AS Tractor
        , PROHDR.AJBLNO AS BOL
        , PROHDR.AJPONO AS PONumber
        , pickups_cte.DLPUNO AS PickupNumber
        , APPT.BSDATE AS ApptDate
        , dueStatus_cte.estDeliveryDate AS EstDeliveryDate
        , APPT.BSDLDT AS DeliveredDate
    INTO #tempResults
    FROM ProFilter_cte
        INNER JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[PROHDR] PROHDR
            ON PROHDR.AJPRO# = ProFilter_cte.BBPRO
        INNER JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[PROSTA] PROSTA
            ON ProFilter_cte.BBPRO = PROSTA.ALPRO
                AND PROSTA.ALDATE >= 20170201
        INNER JOIN [COYOTE].[B10A282B].[RDFSV31DTA].[APPT] APPT
            ON ProFilter_cte.BBPRO = APPT.BSPRO
        INNER JOIN #manifests
                ON LTRIM(RTRIM(PROSTA.ALXREF)) = #manifests.BAMFST
                    AND ProFilter_cte.BBPRO = #manifests.BBPRO
        LEFT JOIN pickups_cte
            ON ProFilter_cte.BBPRO = pickups_cte.DLPRO
        LEFT JOIN dueStatus_cte
            ON ProFilter_cte.BBPRO = dueStatus_cte.ALPRO
    GROUP BY PROHDR.AJSCD
        , PROHDR.AJPRO#
        , PROHDR.AJSCD
        , PROHDR.AJTPCS
        , PROHDR.AJTWGT
        , PROHDR.AJSNM
        , PROHDR.AJSAD1
        , PROHDR.AJSCTY
        , PROHDR.AJSST
        , PROHDR.AJSZIP
        , PROHDR.AJCNM
        , PROHDR.AJCAD1
        , PROHDR.AJCCTY
        , PROHDR.AJCST
        , PROHDR.AJCZIP
        , PROSTA.ALSTAT
        , PROSTA.ALDATE
        , PROSTA.ALTIME
        , PROSTA.ALCMT
        , PROSTA.ALXREF
        , #manifests.BATRKR
        , PROHDR.AJBLNO
        , PROHDR.AJPONO
        , pickups_cte.DLPUNO
        , APPT.BSDATE
        , dueStatus_cte.estDeliveryDate
        , APPT.BSDLDT;

    INSERT INTO ProDataWH
        (
            CustomerID
            , Pro
            , DispatchCode
            , Pieces
            , [Weight]
            , Origin
            , OriginAddress
            , OriginCity
            , OriginState
            , OriginZIP
            , Consignee
            , ConsigneeAddress
            , ConsigneeCity
            , ConsigneeState
            , ConsigneeZIP
            , StatusCode
            , StatusDate
            , StatusTime
            , StatusComment
            , Manifest
            , Tractor
            , BOL
            , PONumber
            , PickupNumber
            , ApptDate
            , EstDeliveryDate
            , DeliveredDate
    )
    SELECT CustomerID
        , Pro
        , DispatchCode
        , Pieces
        , [Weight]
        , Origin
        , OriginAddress
        , OriginCity
        , OriginState
        , OriginZIP
        , Consignee
        , ConsigneeAddress
        , ConsigneeCity
        , ConsigneeState
        , ConsigneeZIP
        , StatusCode
        , CAST(CAST(statusDate AS VARCHAR(10)) AS DATE) AS StatusDate
        , StatusTime
        , StatusComment
        , Manifest
        , Tractor
        , BOL
        , PONumber
        , PickupNumber
        , CAST(CAST(apptDate AS VARCHAR(10)) AS DATE) AS ApptDate
        , CAST(CAST(estDeliveryDate AS VARCHAR(10)) AS DATE) AS EstDeliveryDate
        , CASE WHEN DeliveredDate <> 0
            THEN CAST(CAST(DeliveredDate AS VARCHAR(10)) AS DATE)
            ELSE NULL
        END AS DeliveredDate
    FROM #tempResults
    ORDER BY Pro, StatusDate, StatusTime;
--*/
END



GO

