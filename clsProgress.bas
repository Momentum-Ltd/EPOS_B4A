B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
'
' This is a class to handle the progress dialog and indicator (x platform version).
' Event handlen see https://www.b4x.com/android/forum/threads/raising-events.82701/#post-523613
'
#Region  Documentation
	'
	' Name......: clsProgress
	' Release...: 1-
	' Date......: 07/11/20
	'
	' History
	' Date......: 06/08/20
	' Release...: 1
	' Created by: D Morris 
	' Details...: Based on clsProgressDialog_v4 and clsProgressIndicator_v1.
	'
	' Date......: 
	' Release...: 
	' Overview..: Documentation changes.
	' Amendee...: D Morris
	' Details...: Mod: Documentation on about message improved.
	'			  Added: IsShown.
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
#if B4I
	Private mHudObj As HUD 						' The HUD object used to display progress dialogs.
#End If
	' Required for event handling
	Private mCallback As Object
	Private mEvent As String

	Private mDialogMessage As String			' Storage for the message shown when the progree dialog is displayed.	
	Private mShowDialog As Boolean				' When set indicates dialog is shown.
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

' Hides the process dialog
public Sub Hide
	tmrProgressTimeout.Enabled = False
#if B4A
	ProgressDialogHide
#else
	mHudObj.ProgressDialogHide
#End If
	mIndicator.Hide
	mShowDialog = False	
End Sub

' Is the Progress circles been shown
Public Sub IsShown As Boolean
	Return mIndicator.mBase.Visible	
End Sub

' Shows the process dialog
' The dialogMessage is the message shown in progress dialog is invoked.
public Sub Show(dialogMessage As String)
	' Just in case the timer is already running - needs to be stopped the restarted.
	' See https://www.b4x.com/android/forum/threads/call-timer_tick-and-reset-timer.30105/
	tmrProgressTimeout.Enabled = False ' This is necessary, see above.
	tmrProgressTimeout.Enabled = True
	mIndicator.Show
	mDialogMessage = dialogMessage
	mShowDialog = False
End Sub

' Show the dialog box
Public Sub ShowDialog
	If tmrProgressTimeout.Enabled = True And mShowDialog = False Then
		mShowDialog = True
#if B4A
		ProgressDialogShow2(mDialogMessage, False)
#else
		mHudObj.ProgressDialogShow(mDialogMessage)
#End If		
	End If
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines
