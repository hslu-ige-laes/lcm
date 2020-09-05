@echo off
SET shinyPath=%~dp0
cd %shinyPath%
%shinyPath%\dist\R-Portable\App\R-Portable\bin\Rscript.exe --no-restore %shinyPath%\lcmDataFetcher.R