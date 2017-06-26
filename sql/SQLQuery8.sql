DECLARE @fromTime as varchar(10) = convert(varchar(8), dateadd (week , -5, getdate()) ,112)
declare @proNumber as int = 418599577;


SELECT BBPRO as ProNumber
     , rtrim(cast(BATRKR as varchar(100))) as Tractor
     , cast(concat(substring(right(right(concat('00000000',  cast(BASTDT as varchar(100))),  8), 8), 1, 4), '-',
                   substring(right(right(concat('00000000',  cast(BASTDT as varchar(100))),  8), 8), 5, 2), '-',
                   substring(right(right(concat('00000000',  cast(BASTDT as varchar(100))),  8), 8), 7, 2), ' ',
                   substring(right(right(concat('000000'  ,  cast(BASTTM as varchar(100))),  6), 6), 1, 2), ':',
                   substring(right(right(concat('000000'  ,  cast(BASTTM as varchar(100))),  6), 6), 3, 2), ':',
                   substring(right(right(concat('000000'  ,  cast(BASTTM as varchar(100))),  6), 6),  5, 2)) as datetime2(7)) as MFSTDateTime
    -- , BASTDT
    --, BASTTM as MFSTTime 
    -- , ISSTAT as MFSTStatus
FROM [MFSTHDR] MFSTHDR
    INNER JOIN [MFSTSTA] MFSTSTA
        ON MFSTHDR.BAMFST = MFSTSTA.ISMFST
            AND ISSTAT IN ('ARV','DSP')
    INNER JOIN [MFSTDTL] MFSTDTL
        ON MFSTDTL.BBMFST  = MFSTHDR.BAMFST
where 	coalesce(BBPRO,0) <> 0
        and coalesce(RTRIM(BATRKR), '') <> '' --and BBPRO = @proNumber
        and BASTDT >= @fromTime
GROUP BY BBPRO
       , BASTDT
       , BASTTM
       , BATRKR
       --, ISSTAT
order by Tractor, ProNumber--MFSTDateTime desc