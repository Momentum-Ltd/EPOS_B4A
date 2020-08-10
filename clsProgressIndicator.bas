B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
'
' This is a class to handle the progress dialog (x platform version).
' Event handlen see https://www.b4x.com/android/forum/threads/raising-events.82701/#post-523613
'

#Region  Documentation
	'
	' Name......: clsProgressIndicator
	' Release...: 1
	' Date......: 22/07/20
	'
	' History
	' Date......: 22/07/20
	' Release...: 1
	' Created by: D Morris (started 20/7/20 )
	' Details...: Based on clsProgressDialog_v4.
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Mandatory Subroutines & Data
' event generated when the progress dialog is not hidden by the caller within the timeout period.
#Event: Timeout 

Sub Class_Globals
	Private xui As XUI
	Private tmrProgressTimeout As Timer			' Progress dialog timeout
	Private mIndicator As B4XLoadingIndicator	' Caller's progress indicator

	' Required for event handling
	Private mCallback As Object
	Private mEvent As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
' indicator is the callers indicator.
Public Sub Initialize(callback As Object, eventName As String, timeOutMsecs As Int, indicator As B4XLoadingIndicator)
	mCallback = callback
	mEvent = eventName
	mIndicator = indicator
	tmrProgressTimeout.Initialize("tmrProgressTimeout", timeOutMsecs)
End Sub
#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Timeout trips - hide the progress indicator and raise a Timeout event.
Sub tmrProgressTimeout_Tick()
	Log("Timeout tripped")
	' See post https://www.b4x.com/android/forum/threads/callbacks-with-ios.108501/
	If xui.SubExists(mCallback, mEvent & "_Timeout", 0) Then
		CallSub(mCallback, mEvent & "_Timeout")
	End If
End Sub
#End Region  Event Handlers

#Region  Public Subroutines
' Shows the process indicator
public Sub Show
	' Just in case the timer is already running - needs to be stopped the restarted.
	' See https://www.b4x.com/android/forum/threads/call-timer_tick-and-reset-timer.30105/
	tmrProgressTimeout.Enabled = False ' This is necessary, see above.
	tmrProgressTimeout.Enabled = True
	mIndicator.Show
End Sub

' Hides the process dialog
public Sub Hide
	tmrProgressTimeout.Enabled = False
	mIndicator.Hide
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines
