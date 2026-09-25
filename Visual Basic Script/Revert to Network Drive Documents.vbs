Set WshShell = CreateObject ( "Wscript.Shell" )

WshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\Personal", "\\server\Users\username\Documents", "REG_EXPAND_SZ"
WshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Personal", "\\server\Users\username\Documents", "REG_SZ"

