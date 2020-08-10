B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
'
' This X-platform activity for Place Order.
'
#Region  Documentation
	'
	' Name......: aPlaceOrder
	' Release...: 8
	' Date......: 31/05/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...: based on ShowOrder_v27.
	'
	' Date......: 22/12/19
	' Release...: 2
	' Overview..: Centre name displayed in title bar.
	' Amendee...: D Morris
	' Details...:   Mod: frmPlaceOrder - displays title bar.
	'				Mod: Activity_Create() display name - 
	'
	' Date......: 23/01/20
	' Release...: 3
	' Overview..: Back button operation improved and bug fix.
	' Amendee...: D Morris
	' Details...:   Added: Activity_Keypress() back button goes to Task Select screen.
	'				  Mod: Bugfix #0283 - Title now displayed in resume.
	'
	' Date......: 08/02/20
	' Release...: 4
	' Overview..: New UI and Back button added to title bar.
	' Amendee...: D Morris.
	' Details...:  Mod: stdActionBar added and associated code.
	'
	' Date......: 02/04/20
	' Release...: 5
	' Overview..: Issue: #0371 - Notification whilst showing screen.
	' Amendee...: D Morris
	' Details...: Added: ShowMessageNotificationMsgBox() and ShowStatusNotificationMsgBox().
	'
	' Date......: 6
	' Release...: 09/05/20
	' Overview..: Bugfix: 0401 - No progress dialog order between order ackn message and displaying payment options. 
	' Amendee...: D Morris.
	' Details...:  Added: HandleOrderAcknResponse() and QueryPayment() moved from aTaskSelect.
	'			   Added: QueryPaymentAndReturn().
	'
	' Date......: 11/05/20
	' Release...: 7
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 31/05/20
	' Release...: 8
	' Overview..: Bugfix: #0421 - Placing new orders when previous orders cancelled.
	' Amendee...: D Morris
	' Details...:  Remove: Public QueryPayment() not used
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
	Private bar As StdActionBar		' New title bar	
	Private hc As hPlaceOrder		' This activity's helper class.
End Sub

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
	hc.CancelOrder
End Sub

Sub Activity_Create(FirstTime As Boolean)
'	Activity.Title = modEposApp.FormatSelectedCentre
'	InitializeStdActionBar
	modEposApp.InitializeStdActionBar(bar, "bar")
	hc.Initialize(Activity)
End Sub

' Detect back button(bottom of phone).
private Sub Activity_Keypress(KeyCode As Int) As Boolean
	Dim rtnValue As Boolean = False ' Initialised to False, as that will allow the event to continue
	
	' Prevent 'Back' softbutton, from https://www.b4x.com/android/forum/threads/stopping-the-user-using-back-button.9203/
	If KeyCode = KeyCodes.KEYCODE_BACK Then ' The 'Back' softbutton was pressed,
		rtnValue = True ' Returning true consumes the event, preventing the 'Back' action
'#if B4A
'		StartActivity(aTaskSelect) ' Will return to the Task Select activity
'#else ' B4I
'		mClosingForm = True 	' Will return to the Task Select activity
'		xTaskSelect.show
'#End If
		hc.CancelOrder
	End If
	Return rtnValue
End Sub


Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
	If Starter.DisconnectedCloseActivities Then
		Activity.Finish
	End If
End Sub

Sub Activity_Resume
	Activity.Title = modEposApp.FormatSelectedCentre 'TODO could this be moved to the helper?
	hc.ResumeOp
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

' Handles the Order Acknowledgement response from the Server by displaying a messagebox with relevant text.
Public Sub pHandleOrderAcknResponse(orderAcknResponseStr As String)
	hc.HandleOrderAcknResponse(orderAcknResponseStr)
End Sub

' Handles the response from the Server to the Order message.
Public Sub pHandleOrderResponse(orderResponseStr As String)
	hc.pHandleOrderResponse(orderResponseStr)
End Sub
'
'' Query Payment options and makes payment if required.
'Public Sub QueryPayment(amount As Float)
'	wait for (hc.QueryPayment(amount)) complete(result As Boolean)
'End Sub

' Query Payment options and makes payment if required - then returns to caller.
Public Sub QueryPaymentAndReturn(amount As Float)
	wait for (hc.QueryPayment(amount)) complete(result As Boolean)
	Activity.Finish		' This makes it return to caller.
End Sub

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
'' Intialize the std action bar
'Private Sub InitializeStdActionBar()
'	bar.Initialize("bar")
'	bar.NavigationMode = bar.NAVIGATION_MODE_STANDARD
'	' bar.subtitle = "This is the subtitle if required."
'	bar.ShowUpIndicator = True
'End Sub

#End Region  Local Subroutines
