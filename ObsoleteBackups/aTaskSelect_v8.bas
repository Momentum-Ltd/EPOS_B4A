B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
'
' This Activity acts as a main menu, allowing the operator to choose which task to perform next.
'
#Region  Documentation
	'
	' Name......: aTaskSelect
	' Release...: 8
	' Date......: 16/05/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on TaskSelect_v34
	'
	' Date......: 22/12/19
	' Release...: 2
	' Overview..: Centre name displayed in title bar.
	' Amendee...: D Morris
	' Details...:   Mod: frmTaskSelect - displays title bar.
	'				Mod: Activity_Create() display name -
		'
	' Date......: 23/01/20
	' Release...: 3
	' Overview..: Bug fix #0283 Display centre name problem.
	' Amendee...: D Morris
	' Details...:    Mod: Bugfix #0283 - Title now displayed in resume. 
	'
	' Date......: 02/04/20
	' Release...: 4
	' Overview..: Issue: #0371 - Notification whilst showing screen.
	' Amendee...: D Morris
	' Details...: Mod: Rename pShowMessageNotificationMsgBox() and pShowStatusNotificationMsgBox().
	'
	' Date......: 05/05/20
	' Release...: 5
	' Overview..: Added: Show order status list now supports payment.
	' Amendee...: D Morris.
	' Details...:  Added: Public QueryPayment(). 
	'
	' Date......: 09/05/20
	' Release...: 6
	' Overview..: Bugfix: 0401 - No progress dialog order between order ackn message and displaying payment options. 
	' Amendee...: D Morris.
	' Details...:  Removed: HandleOrderAcknResponse() and QueryPayment() moved to aPlaceOrder.
	'
	' Date......: 11/05/20
	' Release...: 7
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 16/05/20
	' Release...: 8
	' Overview..: Mod: Task Select now settings option is in title bar.
	' Amendee...: D Morris
	' Details...:    Mod: Settings option in title bar
	'			   Added: mnuChangeSettings_Click().
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Activity Attributes
	#FullScreen: False
'	#IncludeTitle: False
#End Region  Activity Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	' Currently none
End Sub

Sub Globals
	Private hc As hTaskSelect ' This activity's helper class.
End Sub

Sub Activity_Create(FirstTime As Boolean)
'	Activity.Title = modEposApp.FormatSelectedCentre	
	hc.Initialize(Activity)
	Activity.AddMenuItem("Settings", "mnuChangeSettings")
End Sub

Sub Activity_Resume
	Activity.Title = modEposApp.FormatSelectedCentre 'TODO could this be moved to the helper?
	hc.ResumeOp
End Sub

Sub Activity_Pause(UserClosed As Boolean)
	hc.OnClose
	If Starter.DisconnectedCloseActivities Then 
		Activity.Finish
	End If
End Sub

Sub Activity_Keypress(KeyCode As Int) As Boolean
	' Prevent 'Back' softbutton, from https://www.b4x.com/android/forum/threads/stopping-the-user-using-back-button.9203/
	If KeyCode = KeyCodes.KEYCODE_BACK Then ' The 'Back' softbutton was pressed
		Return True ' Returning true consumes the event, preventing the 'Back' action
	Else ' It wasn't the 'Back' softbutton that was pressed
		Return False ' Returning false allows the event to continue
	End If
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

'' Handles the Order Acknowledgement response from the Server by displaying a messagebox with relevant text.
'Public Sub pHandleOrderAcknResponse(orderAcknResponseStr As String)
'	hc.HandleOrderAcknResponse(orderAcknResponseStr)
'End Sub

' Handles the Order Start repsonse from the Server by displaying a relevant messagebox and then starting the Show Order activity.
Public Sub pHandleOrderStart(orderStartStr As String)
	hc.HandleOrderStart(orderStartStr)
End Sub

'' Query Payment options and makes payment if required.
'Public Sub QueryPayment(amount As Float)
'	hc.QueryPayment(amount)
'End Sub

' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	hc.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	hc.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Handles menu option Settings
Private Sub mnuChangeSettings_Click
	hc.ChangeDeviceSettings
End Sub

#End Region  Local Subroutines
