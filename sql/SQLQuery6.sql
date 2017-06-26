DECLARE @fromDate as varchar(8) = convert(varchar(8), dateadd (day , -1, getdate()) ,112) -- all versions


select top 10
        hdr.AJPRO#                                 as Pro
    ,   rtrim(cast(mfst.BATRKR as varchar(100)))   as Tractor
    , sta.ALDATE
    , sta.ALTIME
    , cast( concat(substring(right( right(concat('00000000', cast(sta.ALDATE as varchar(100))), 8), 8), 1, 4), '-',
                   substring(right(right(concat('00000000',  cast(sta.ALDATE as varchar(100))),  8), 8), 5, 2), '-',
                   substring(right(right(concat('00000000',  cast(sta.ALDATE as varchar(100))),  8), 8), 7, 2), ' ',
                   substring(right(right(concat('000000'  ,  cast(sta.ALTIME as varchar(100))),  6), 6), 1, 2), ':',
                   substring(right(right(concat('000000'  ,  cast(sta.ALTIME as varchar(100))),  6), 6), 3, 2), ':',
                   substring(right(right(concat('000000'  , cast(sta.ALTIME as varchar(100))), 6), 6),  5, 2)) as datetime) 
from PROHDR hdr
inner JOIN PROSTA sta on sta.ALPRO = hdr.AJPRO# and sta.ALCO = hdr.AJCO# and sta.ALSTAT = 'DUD'
inner  JOIN PROSTA sta2 on sta2.ALPRO = hdr.AJPRO# and sta2.ALCO = hdr.AJCO# and sta2.ALFSC <> 'I' and sta2.ALSTAT IN ('DED', 'DES', 'DEL', 'DEO')
inner JOIN  MFSTDTL dtl on dtl.BBPRO = hdr.AJPRO# and dtl.BBCO# = hdr.AJCO#
inner JOIN MFSTHDR mfst on mfst.BAMFST = dtl.BBMFST AND mfst.BACO# = dtl.BBCO#
where rtrim(cast(mfst.BATRKR as varchar(100))) <> '' and sta.ALDATE >= cast(@fromDate as int)
order by sta.ALDATE desc
 