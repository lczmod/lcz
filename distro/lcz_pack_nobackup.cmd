@echo off
color FD

SET VPROJECT=

pushd %~dp0
"%VPROJECT%\..\bin\bspzip.exe" -addorupdatelist %1 lcz_res.txt %1
popd

pause