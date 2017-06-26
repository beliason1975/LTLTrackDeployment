DECLARE @fromDateStr as varchar(8) = convert(varchar(8), dateadd (week , -3, getdate()) ,112) -- all versions
--DECLARE @fromDate as datetime2(7) = dateadd (week , -3, getdate()) -- all versions

declare @query1 varchar(max) =
'SELECT * FROM OPENQUERY(COYOTE,
''
select
        hdr.AJPRO#                                 as Pro
    ,   mfst.BATRKR                                as Tractor
    , sta.ALDATE                                   as EstDeliveryDate
    , sta.ALTIME                                   as EstDeliveryTime
from PROHDR hdr
INNER JOIN PROSTA sta on sta.ALPRO = hdr.AJPRO# and sta.ALCO = hdr.AJCO# and sta.ALSTAT = ''''DUD''''
INNER  JOIN PROSTA sta2 on sta2.ALPRO = hdr.AJPRO# and sta2.ALCO = hdr.AJCO# and sta2.ALFSC <> ''''I'''' and sta2.ALSTAT IN (''''DED'''', ''''DES'''', ''''DEL'''', ''''DEO'''')
INNER JOIN  MFSTDTL dtl on dtl.BBPRO = hdr.AJPRO# and dtl.BBCO# = hdr.AJCO#
INNER JOIN MFSTHDR mfst on mfst.BAMFST = dtl.BBMFST AND mfst.BACO# = dtl.BBCO#
where rtrim(cast(mfst.BATRKR as varchar(100))) <> '''''''' and sta.ALDATE >= ' + @fromDateStr + '
group by hdr.AJPRO#, mfst.BATRKR, sta.ALDATE, sta.ALTIME
--order by EstDeliveryDate desc, Pro
 '')'

 exec(@query1)