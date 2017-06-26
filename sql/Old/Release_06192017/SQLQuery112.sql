select * from  prodatawh p
order by p.CoyotePickupNumber


select * from ProDataWH p
group by p.pro
having count(*) > 1
