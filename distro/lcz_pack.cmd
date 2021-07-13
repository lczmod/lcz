@echo off
color FD

SET VPROJECT=

copy %1 %~dp0%~n1%~x1.bak
pushd %~dp0
"%VPROJECT%\..\bin\bspzip.exe" -addorupdatelist %~n1%~x1.bak lcz_res.txt %~n1%~x1
popd
copy %~dp0%~n1%~x1 %1
pause