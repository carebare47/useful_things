#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

^!t::StartTerminator() 

StartTerminator()
{

SetTitleMatchMode, 2
Process, Exist, Xming.exe
if %ErrorLevel% != 0
	MsgBox, 48, Checking Xming, Checking Xming... Exists! PID: %ErrorLevel%, 1.5
else
{
	Run C:\Program Files (x86)\Xming\Xming.exe :0 -clipboard -multiwindow,,, NewPID
	MsgBox, 48, Starting Xming, Starting Xming... Xming.exe PID: %NewPID%, 1.5
}
Process, Wait, Xming.exe, 4
NewerPID := ErrorLevel  ; Save the value immediately since ErrorLevel is often changed.
if %NewerPID% == 0
{
    MsgBox Something went wrong starting XMing.exe
    MsgBox Process did not appear within 5.5 seconds
    MsgBox Error
    return
}
MsgBox, 48, Starting Terminator, Starting Terminator..., 1.5
Run bash -c "DISPLAY=:0 terminator"
return
}


