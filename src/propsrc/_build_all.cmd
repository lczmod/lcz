@ECHO OFF
SET COMPILE_CMD=N:\het\blender\export\compile.cmd

FOR /F "tokens=1,2 delims=." %%Q IN ('DIR /B') DO (CALL :QCCOMPILE %%Q %%R)
GOTO :END

:QCCOMPILE
	IF /I "%2" == "qc" ( "O:/L/Steam/steamapps/common/Counter-Strike Global Offensive/bin/studiomdl.exe" -game "O:/L/Steam/steamapps/common/Counter-Strike Global Offensive/csgo/" -nop4 "%1.%2")
GOTO :EOF

:END
pause