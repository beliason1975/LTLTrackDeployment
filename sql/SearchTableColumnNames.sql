SELECT *
FROM McLeodData_LTL.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'orders' and COLUMN_NAME like N'%dis%'
