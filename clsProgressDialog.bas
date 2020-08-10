B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' This is a class to handle the progress dialog (x platform version).
' Event handlen see https://www.b4x.com/android/forum/threads/raising-events.82701/#post-523613
'

#Region  Documentation
	'
	' Name......: clsProgressDialog
	' Release...: 4
	' Date......: 05/05/20
	'
	' History
	' Date......: 08/08/19
	' Release...: 1
	' Created by: D Morris (started 8/8/19)
	' Details...: First release to support version tracking
	'
	' Date......: 22/10/19
	' Release...: 2
	' Overview..: Parameter to set the timeout value on initialisation.
	' Amendee...: D Morris
	' Details...: Mod: Initialize() changed.
	'
	' Date......: 29/12/19
	' Release...: 3
	' Overview..: Bugfix #0236 - Able to hide the progress dialog.
	' Amendee...: D Morris.
	' Details...:  Mod: Show() now calls ProgressDialogShow2().
	'
	' Date......: 05/05/20
	' Release...: 4
	' Overview..: Bugfix to deal with restart whilst running.
	' Amendee...: D Morris.
	' Details...:  Mod: Show().
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
'	Private const PROGRESS_DIALOG_TIMEOUT As Int = 20000 ' Timeout in msecs.
	
	Private tmrProgressTimeout As Timer			' Progress dialog timeout
#if B4I
	Private mHudObj As HUD 						' The HUD object used to display progress dialogs.
#End If
	' Required for event handling
	Private mCallback As Object
	Private mEvent As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(callback As Object, eventName As String, timeOutMsecs As Int)
	mCallback = callback
	mEvent = eventName
	tmrProgressTimeout.Initialize("tmrProgressTimeout", timeOutMsecs)
End Sub
#End Region  Mandatory Subroutines & Data

#Region  Event Handlers
' Timeout trips - hide the progress dialog and raise a Timeout event.
Sub tmrProgressTimeout_Tick()
	Log("Timeout tripped")
	Hide 
	' See post https://www.b4x.com/android/forum/threads/callbacks-with-ios.108501/
	If xui.SubExists(mCallback, mEvent & "_Timeout", 0) Then
		CallSub(mCallback, mEvent & "_Timeout")
	End If
End Sub
#End Region  Event Handlers

#Region  Public Subroutines
' Shows the process dialog
public Sub Show(message As String)
	' Just in case the timer is already running - needs to be stopped the restarted.
	' See https://www.b4x.com/android/forum/threads/call-timer_tick-and-reset-timer.30105/
	tmrProgressTimeout.Enabled = False ' This is necessary, see above. 
	tmrProgressTimeout.Enabled = True
#if B4A
	'ProgressDialogShow(message)
	ProgressDialogShow2(message, False)
#else
	mHudObj.ProgressDialogShow(message)
#End If	
End Sub

' Hides the process dialog
public Sub Hide
	tmrProgressTimeout.Enabled = False
#if B4A
	ProgressDialogHide
#else
	mHudObj.ProgressDialogHide
#End If	
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines
