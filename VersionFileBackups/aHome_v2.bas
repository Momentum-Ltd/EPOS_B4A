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
	' Release...: 2
	' Date......: 28/09/20
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
	hc.OnClose	' Calling this ensures the timer in progress timeout is stopped.
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
Public Sub pHandleOrderInfo(orderInfoStr As String)
	hc.pHandleOrderInfo(orderInfoStr)
End Sub

' Handles the Order Start repsonse from the Server by displaying a relevant messagebox and then starting the Show Order activity.
Public Sub pHandleOrderStart(orderStartStr As String)
	hc.HandleOrderStart(orderStartStr)
End Sub

' Sends to the Server the message which requests the customer's order status list.
Public Sub pSendRequestForOrderStatusList
	hc.pSendRequestForOrderStatusList
End Sub

' Populates the listview with each of the orders and their statuses in the specified XML string.
Public Sub pHandleOrderStatusList(orderStatusStr As String)
	hc.pHandleOrderStatusList(orderStatusStr)
End Sub

' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	'Log("aShowOrderStatusList.ShowMessageNotificationMsgBox")
	hc.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	'Log("aShowOrderStatusList.ShowStatusNotificationMsgBox")
	hc.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

' Causes the listview to be repopulated so that the specified order's information is updated.
Public Sub pUpdateOrderStatus(statusObj As clsEposOrderStatus)
	'Log("aShowOrderStatusList.pUpdateOrderStatus")
	hc.pUpdateOrderStatus(statusObj)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines

