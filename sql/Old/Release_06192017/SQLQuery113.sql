SELECT    p.pk_pro, t.TruckID, t.PingTimeStamp
FROM  ProTruckPosition ptp
INNER JOIN TruckPosition t ON t.PK_TruckPosition = ptp.FK_TruckPosition
INNER JOIN Pro p ON t.PK_TruckPosition = ptp.FK_TruckPosition
where t.TruckID = '60097' and p.PK_Pro = 412727802
group by p.pk_pro, t.TruckID, t.PingTimeStamp
order by t.PingTimeStamp desc

select * from ProDataWH where pro = 412727802