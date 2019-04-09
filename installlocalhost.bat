@echo off
call del "*.ospx"

for /f %%i in ('"oscript -version"') do set result=%%i

if %result%==1.0.19.105 (
    call opm build . -mf ./packagedef -out .
) else (
    call opm build -m ./packagedef -o .
)

call opm install -f *.ospx
