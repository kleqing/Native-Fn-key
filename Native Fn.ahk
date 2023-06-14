#NoEnv
#persistent
;SetWorkingDir %C:\Program Files (x86)\Fn Key%
#SingleInstance force
 
Menu, Tray, NoStandard
Menu, Tray, Add , Suspend, Sus
Menu, Tray, Add , Reload, Rel
Menu, Tray, Add , Exit, Exi
Menu, Tray, Default, Exit
;Menu, Tray, Icon , normal.ico,, 1
Return

^!l::
suspend
GoTO refreshICON

Sus:
Suspend, Toggle      
refreshICON:
if (A_IsSuspended){
	TrayTip, Fn Key, The Function key  has disabed, 20, 17
	;Menu, Tray, Icon , suspend.ico
}
else{
	TrayTip, Fn Key, Now you can use the Function key, 20, 17
	;Menu, Tray, Icon , normal.ico
}
return
Exi:
ExitApp
Return
Rel:
Reload
Return

F1::
    AdjustScreenBrightness(-10)
    return
  
F2::
    AdjustScreenBrightness(10)
    return

F3::
    Send, {LWin down}{Tab}{LWin up}
    return

F4::
    Send, {PrintScreen}
    return

F7::
    VolumeOSD()
    Send, {Media_Prev}
    return

F8::
    VolumeOSD()
    Send, {Media_Play_Pause}
    return

F9::
    VolumeOSD()
    Send, {Media_Next}
    return

F10::
    VolumeOSD()
    Send, {Volume_Mute}
    return

F11::
    VolumeOSD()
    SoundSet, -6
    return

F12::
    VolumeOSD()
    SoundSet, +6
    return

VolumeOSD(){
try if ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
	try if ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
		 DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0)
		,ObjRelease(flyoutDisp)
	}
ObjRelease(shellProvider)
}
}

AdjustScreenBrightness(step) {
	static service := "winmgmts:{impersonationLevel=impersonate}!\\.\root\WMI"
	monitors := ComObjGet(service).ExecQuery("SELECT * FROM WmiMonitorBrightness WHERE Active=TRUE")
	monMethods := ComObjGet(service).ExecQuery("SELECT * FROM wmiMonitorBrightNessMethods WHERE Active=TRUE")
	for i in monitors {
		curr := i.CurrentBrightness
		break
	}
	toSet := curr + step
	if (toSet < 0)
		toSet := 0
	if (toSet > 100)
		toSet := 100
	for i in monMethods {
		i.WmiSetBrightness(1, toSet)
		break
	}
	BrightnessOSD()
}
BrightnessOSD() {
	static PostMessagePtr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "PostMessageW" : "PostMessageA", "Ptr")
	 ,WM_SHELLHOOK := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
	static FindWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "FindWindowW" : "FindWindowA", "Ptr")
	HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	IF !(HWND) {
		try IF ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
			try IF ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
				DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0)
				 ,ObjRelease(flyoutDisp)
			}
			ObjRelease(shellProvider)
		}
		HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	}
	DllCall(PostMessagePtr, "Ptr", HWND, "UInt", WM_SHELLHOOK, "Ptr", 0x37, "Ptr", 0)
}
