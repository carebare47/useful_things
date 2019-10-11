#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

^!u::RestartUnifiedRemote() 

RestartUnifiedRemote()
{

Process, Close, RemoteServerWin.exe
Sleep, 5000 
run "C:\Program Files (x86)\Unified Remote 3\RemoteServerWin.exe"
Return		
}	

