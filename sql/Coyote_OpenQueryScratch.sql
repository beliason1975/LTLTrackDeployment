

declare @query1 varchar(max) =
'SELECT * FROM OPENQUERY(COYOTE, ''
    SELECT A.*, D.ALFSC AS D_ALFSC, D.ALCO AS D_ALCO, D.ALPRO AS D_ALPRO, D.ALSTAT AS D_ALSTAT, D.ALDATE AS D_ALDATE, D.ALTIME AS D_ALTIME, D.ALCMT AS D_ALCMT, D.ALLOC AS D_ALLOC, D.ALPDTE AS D_ALPDTE, D.ALPTIM AS D_ALPTIM, D.ALXRPT AS D_ALXRPT, D.ALEDRE AS D_ALEDRE, D.ALXREF AS D_ALXREF, D.ALDTTM AS D_ALDTTM, D.ALUSER AS D_ALUSER, D.ALSTDT AS D_ALSTDT, D.ALSTUR AS D_ALSTUR
    FROM       RDFSV31DTA.PROSTA A 
    LEFT JOIN RDFSV31DTA.PROSTA D ON D.ALCO = A.ALCO AND D.ALPRO = A.ALPRO 
                                                      --AND D.ALFSC <> ''''I''''
                                                      --AND D.ALSTAT IN (''''DED'''', ''''DES'''', ''''DEL'''', ''''DEO'''')
WHERE A.ALCO = 01 and A.ALSTAT = ''''DUD'''' 
                  and A.ALPRO  = ''''424526747''''
                  AND D.ALFSC <> ''''I''''
                  AND D.ALSTAT IN (''''DED'''', ''''DES'''', ''''DEL'''', ''''DEO'''')
'')'

exec(@query1)


declare @query1 varchar(max) =
'SELECT * FROM OPENQUERY(COYOTE, ''
    SELECT *
    FROM   RDFSV31DTA.PROSTA A 
    WHERE  A.ALCO = 01 and A.ALPRO  = ''''424526747''''
'')'

exec(@query1)


declare @query1 varchar(max) =
'SELECT * FROM OPENQUERY(COYOTE, ''
    SELECT *
    FROM   RDFSV31DTA.PROSTA A 
    WHERE  A.ALCO = 01 and rtrim(A.ALFSC) <> '''''''' and rtrim(A.ALFSC) <> ''''I''''
'')'

exec(@query1)
