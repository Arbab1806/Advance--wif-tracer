Set shell = CreateObject("Wscript.Shell")
shell.Run "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File wifi_info.ps1", 0, False
