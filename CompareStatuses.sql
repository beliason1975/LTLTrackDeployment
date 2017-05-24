IF OBJECT_ID('tempdb..#mfststatus') IS NOT NULL DROP TABLE #mfststatus;
CREATE TABLE #mfststatus([MFSTSTA_PRO] varchar(3))
IF OBJECT_ID('tempdb..#prostatus') IS NOT NULL DROP TABLE #prostatus;
CREATE TABLE #prostatus([PROSTA_PRO] varchar(3))

select


ACC
ARQ
ARV
BRK
BTD
CLO
CRA
CUD
DEL
DLY
DSP
EMT
ENL
ENR
ETA
HOL
INT
LDG
MAR
MFI
MPU
MSG
OFD
SCD
SPT
STL
TDC
TST
UNI
UNL
UNO
WTR
XTA
