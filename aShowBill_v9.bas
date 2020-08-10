B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
'
' This activity is used to display the customer's current bill.
'
#Region  Documentation
	'
	' Name......: aShowBill
	' Release...: 9
	' Date......: 11/06/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...: based on ShowBill_v19.
	'
	' Date......: 22/12/19
	' Release...: 2
	' Overview..: Centre name displayed in title bar.
	' Amendee...: D Morris
	' Details...:   Mod: frmShowBill - displays title bar.
	'				Mod: Activity_Create() display name - 
	'
	' Date......: 30/12/19
	' Release...: 3 
	' Overview..: Support for refresh
	' Amendee...: D Morris
	' Details...:   Added: RefreshList().
	'
	' Date......: 23/01/20
	' Release...: 4
	' Overview..: Bug fix #0283 Display centre name problem.
	' Amendee...: D Morris
	' Details...:    Mod: Bugfix #0283 - Title now displayed in resume. 
	'
	' Date......: 08/02/20
	' Release...: 5
	' Overview..: New UI and Back button added to title bar.
	' Amendee...: D Morris.
	' Details...:  Mod: stdActionBar added and associated code.
	'			   Mod: Close and refresh buttons removed.
	'
	' Date......: 02/04/20
	' Release...: 6
	' Overview..: Issue: #0371 - Notification whilst showing screen.
	' Amendee...: D Morris
	' Details...: Added: ShowMessageNotificationMsgBox() and ShowStatusNotificationMsgBox().
	'
	' Date......: 05/05/20
	' Release...: 7
	' Overview..: Bugfix: #0392 No progress dialog when new card information entered.
	' Amendee...: D Morris
	' Details...:   Mod: Remove ReportPaymentStatus() and SendPayment().
	'
	' Date......: 11/05/20
	' Release...: 8
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 11/06/20
	' Release...: 9
	' Overview..: bugfix: #420 Order status update problem.
	' Amendee...: D Morris.
	' Details...:  Removed: RefreshList().
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
	Private bar As StdActionBar	' New title bar
	Private hc As hShowBill		' This activity's helper class.
End Sub

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
	hc.CloseShowBill
End Sub

Sub Activity_Create(FirstTime As Boolean)
'	Activity.Title = modEposApp.FormatSelectedCentre 
	hc.Initialize(Activity)
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
	If Starter.DisconnectedCloseActivities Then 
		Activity.Finish
	End If
End Sub

Sub Activity_Resume
	Activity.Title = modEposApp.FormatSelectedCentre 'TODO could this be moved to the helper?
	modEposApp.InitializeStdActionBar(bar, "bar")
	hc.ResumeOp
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

' Close the form.
Public Sub Close
	Activity.Finish
End Sub

' Handles the response received from the Server to the request for an itemised bill.
Public Sub pHandleGetBillByItemResponse(customerBillByItemStr As String)
	hc.pHandleGetBillByItemResponse(customerBillByItemStr)
End Sub

'' Handles the response received from the Server to the request for an order-based bill.
'' Note: The EPOS_BILL command is now considered obsolete; this handler for it is retained for backwards-compatibility.
'Public Sub pHandleGetBillResponse(customerBillStr As String)
'	hc.pHandleGetBillResponse(customerBillStr)
'End Sub

'' Refresh the bill list
'Public Sub RefreshList
'	hc.RefreshList
'End Sub
'
'' Reports the result of a card transaction.
'Public Sub ReportPaymentStatus(paymentInfo As clsEposCustomerPayment)
'	hc.ReportPaymentStatus(paymentInfo)
'End Sub

'
'' Sends a payment message
'public Sub SendPayment(amount As Float)
'	hc.SendPayment(amount)
'End Sub

' Sends to the Server the message which requests the customer's bill information.
Public Sub pSendRequestForBill
	hc.pSendRequestForBill
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

#End Region  Local Subroutines
