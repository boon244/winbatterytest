$logpath = $($env:public) + "\" + $($MyInvocation.MyCommand.Name) + ".log"

start-transcript $logpath

#disable standby
&powercfg.exe -x -monitor-timeout-ac 0
&powercfg.exe -x -monitor-timeout-dc 0
&powercfg.exe -x -disk-timeout-ac 0
&powercfg.exe -x -disk-timeout-dc 0
&powercfg.exe -x -standby-timeout-ac 0
&powercfg.exe -x -standby-timeout-dc 0
&powercfg.exe -x -hibernate-timeout-ac 0
&powercfg.exe -x -hibernate-timeout-dc 0

#enable praesentation 
Start-Process cmd -ArgumentList "/c PresentationSettings /start" -NoNewWindow

$batteryInt = (Get-WmiObject win32_battery | Select-Object -ExpandProperty EstimatedChargeRemaining)
write-host Battery : $($batteryInt)
#run edge
function run-edge {
	$defaultEdgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

	if (test-path $defaultEdgePath) {
		$edgePath = $defaultEdgePath 
	}
	else {
		write-host "looking for msedge.exe..."
		$msedge = Get-ChildItem -Include "msedge.exe" -Path "C:\" -Recurse -ErrorAction SilentlyContinue
		try {$edgePath = $msedge[0].Fullname}
		catch {
			write-host "edge not found"
			exit 1
			}
		}

	try { $edgeProcess = Start-Process $edgePath "maps.google.com" -PassThru }
		

	catch {
		write-host "Edge not start"
		exit 1
		}
}
	
	while ($batteryInt -ge 5) {
		run-edge
		Start-Sleep -Seconds 20
		$batteryInt = (Get-WmiObject win32_battery | Select-Object -ExpandProperty EstimatedChargeRemaining)
		write-host "Time $(Get-Date -Format "dd/MM/yyyy HH:mm") | Battery: $(Get-WmiObject win32_battery | Select-Object -ExpandProperty EstimatedChargeRemaining)"
		Get-Process "msedge" | Stop-Process
		}

end-transcript

