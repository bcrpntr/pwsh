##PS
##Scripted steps for Endpoint/Defender Updates from https://docs.microsoft.com/en-us/mem/configmgr/protect/deploy-use/troubleshoot-endpoint-client

##Reset IE Settings
RunDll32.exe InetCpl.cpl,ResetIEtoDefaults

##Set time to pool.ntp.org
w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"

##Rename Software Distribution folder
net stop wuauserv
##Below may need to be changed if you changed the default windir, %windir% fails in PS
cd C:\Windows
ren SoftwareDistribution SDTemp
net start wuauserv

##Reset AV engine
cd \

# cd "C:\Program Files\Windows Defender"
##For servers, comment out the above, uncomment the below
cd "C:\Program Files\Microsoft Security Client"
MpCmdRun -RemoveDefinitions -all

##If all of the above fail, manually download definitions at https://www.microsoft.com/en-us/wdsi/defenderupdates

exit
