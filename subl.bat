@echo off
REM ===================================================================================================================
REM Command line tool to edit files in the Sublime text editor.
REM Author: Scott MacDonald <scott@smacdo.com>
REM Date:   05/01/2019
REM
REM To use this tool copy it to C:\windows\system32 (or add it to your path) and then invoke it from the command line:
REM subl foobar.txt
REM ===================================================================================================================
start "sublime" "%ProgramW6432%\Sublime Text 3\sublime_text.exe" %*