# DriverRookie

a simple powershell script to check your system specs and installed custom drivers. it filters out the microsoft generic ones so you only see what matters.

it also drops a report on your desktop with google search links to download the drivers if they're outdated, plus direct links for nvidia, amd and intel.

## how to use

just open powershell as admin and run this:

`irm https://raw.githubusercontent.com/AybarsBarut/DriverRookie/main/DriverUpdater.ps1 | iex`

## english version

if you want the english output, set the lang variable before running:

`$Lang='en'; irm https://raw.githubusercontent.com/AybarsBarut/DriverRookie/main/DriverUpdater.ps1 | iex`

## local testing

there's a starter.bat file if you download the repo and want to test it locally without execution policy crying about it.
