:: Script that lists environment variables from `envs.txt`.

@ECHO off
SETLOCAL EnableDelayedExpansion
SET /A COUNT=1

IF NOT EXIST .env (
    ECHO No environment variables specified.
    GOTO :eof
)

IF "%1"=="keys" (
    @REM ECHO -----
    @REM ECHO Here are the current keys for your environment variables:
    @REM ECHO -----
    FOR /F "tokens=1,2 delims==" %%a in (.env) DO (
        ECHO !COUNT!: %%a
        SET /A COUNT+=1
    )
    GOTO :eof
)

IF "%1"=="all" (
    @REM ECHO -----
    @REM ECHO Here are all environment variables (key=value) from the file:
    @REM ECHO -----
    FOR /F "tokens=1,2 delims==" %%a in (.env) DO (
        ECHO !COUNT!: %%a=%%b
        SET /A COUNT+=1
    )
    GOTO :eof
)
