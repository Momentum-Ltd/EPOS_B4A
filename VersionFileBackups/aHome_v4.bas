B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=10
@EndOfDesignText@
'
' Activity for Centre Home page.
'
#Region  Documentation
	'
	' Name......: aHome
	' Release...: 4
	' Date......: 24/01/21
	'
	' History
	' Date......: 08/08/20
	' Release...: 1
	' Created by: D Morris
	' Details...: based on ShowOrderStatusList_v13 and aTaskSelect_v28.
	'		
	' Date......: 28/09/20
	' Release...: 2
	' Overview..: Bugfix: #0498 - Not displaying correct centre after switching (Second attempt to fix).
	' Amendee...: D Morris
	' Details...: Mod: Activity_Resume() - calls RefreshPage().
	'		
	' Date......: 28/11/20
	' Release...: 3
	' Overview..: Issue: #0567 Download/sync menu now handled by the Home activity.
	' Amendee...: D Morris
	' Details...: Added: Public HandleSyncDbReponse(). 
	'		
	' Date......: 24/01/21
	' Release...: 4
	' Overview..: Bugfix: #0562 - Payment with Saved card shows Enter card as background fixed. 
	' Amendee...: D Morris
	' Details...:  Added: ReportPaymentStatus(). 
	'			     Mod: All 'p' and 'l' Prefixes dropped.
	'		     Removed: pSendRequestForOrderStatusList().
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
	#IncludeTitle: False
#End Region  Activity Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	' Currently none
End Sub

Sub Globals
	Private hc As hHome		' This activity's helper class.
End Sub

Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)
End Sub

' Detect back button(bottom of phone).
private Sub Activity_Keypress(KeyCode As Int) As Boolean
	Dim rtnValue As Boolean = False ' Initialised to False, as that will allow the event to continue
	If KeyCode = KeyCodes.KEYCODE_BACK Then ' The 'Back' softbutton was pressed,
		rtnValue = True ' Returning true consumes the event, preventing the 'Back' action
		hc.LeaveCentre
	End If
	Return rtnValue
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose	' Calling this ensures the timer to progress timeout is stopped.
	If Starter.DisconnectedCloseActivities Then
		Activity.Finish
	End If
End Sub

Sub Activity_Resume
	hc.RefreshPage 	' Ensures the Centre pictures are correct.
End Sub
#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

' Displays the details of the specified order using a message box.
Public Sub HandleOrderInfo(orderInfoStr As String)
	hc.HandleOrderInfo(orderInfoStr)
End Sub

' Handles the Order Start repsonse from the Server by displaying a relevant messagebox and then starting the Show Order activity.
Public Sub HandleOrderStart(orderStartStr As String)
	hc.HandleOrderStart(orderStartStr)
End Sub

'' Sends to the Server the message which requests the customer's order status list.
'Public Sub pSendRequestForOrderStatusList
'	hc.SendRequestForOrderStatusList
'End Sub

' Displays a list of orders statuses.
Public Sub HandleOrderStatusList(orderStatusStr As String)
	hc.HandleOrderStatusList(orderStatusStr)
End Sub

' Handles the response from the Server to the Sync Database command.
Public Sub HandleSyncDbResponse(syncDbResponseStr As String)
	hc.HandleSyncDbReponse(syncDbResponseStr)
End Sub

' Reports the result of a card transaction.
Public Sub ReportPaymentStatus(paymentInfo As clsEposCustomerPayment)
	hc.ReportPaymentStatus(paymentInfo)
End Sub

' Displays a messagebox the latest Message To Customer text.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	hc.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the latest Order Status text.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	hc.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

' Update an order in the displayed order list. 
Public Sub UpdateOrderStatus(statusObj As clsEposOrderStatus)
	hc.UpdateOrderStatus(statusObj)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines

