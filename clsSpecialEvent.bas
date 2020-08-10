B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.01
@EndOfDesignText@
#Event: DmDoEvent
' Code taken from
' 	https://www.b4x.com/android/forum/threads/raising-events.82701/#post-523613
Sub Class_Globals
	Private mCallback As Object
	Private mEvent As String
	
	Private tmr As Timer	
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(callback As Object, eventName As String)
	mCallback = callback
	mEvent = eventName
	tmr.Initialize("tmr", 10000)
	tmr.Enabled = True 
	
	Log("Timer started")
End Sub

Sub DmRaiseEvent()
	If SubExists(mCallback, mEvent & "_DmDoEvent") Then
		CallSub(mCallback, mEvent & "_DmDoEvent") 	' <--- This bit of code never gets called!
	End If
End Sub

Sub tmr_Tick()
	Log("Timer tripped")
	If SubExists(mCallback, mEvent & "_DmDoEvent") Then
		CallSub(mCallback, mEvent & "_DmDoEvent") 	' <--- This bit of code never gets called!
	End If
End Sub