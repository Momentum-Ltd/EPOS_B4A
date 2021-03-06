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
	' Release...: 12
	' Date......: 20/01/21
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...: based on ShowOrder_v27.
	'
	' Releases
	' 			v2 - 8 see v9, 
	'
	' Date......: 04/11/20
	' Release...: 9
	' Overview..: Changes to support new version of hPlaceOrder class.
	' Amendee...: D Morris.
	' Details...:  Mod: pHandleOrderResponse().
	'
	' Date......: 14/11/20
	' Release...: 10
	' Overview..: Documentation changes.
	' Amendee...: D Morris
	' Details...: Mod: pHandleOrderAcknResponse() description changed.
	'
	' Date......: 26/11/20
	' Release...: 11
	' Overview..: Support for new style UI.
	' Amendee...: D Morris
	' Details...: Mod: ActionBar removed.
	'
	' Date......: 20/01/21
	' Release...: 12
	' Overview..: General maintenance.
	' Amendee...: D Morris
	' Details...: Removed: QueryPaymentAndReturn().
	'			     Mod: Old commented out
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
	Private hc As hPlaceOrder		' This activity's helper class.
End Sub

Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)
End Sub

' Detect back button(bottom of phone).
private Sub Activity_Keypress(KeyCode As Int) As Boolean
	Dim rtnValue As Boolean = False ' Initialised to False, as that will allow the event to continue
	' Prevent 'Back' softbutton, from https://www.b4x.com/android/forum/threads/stopping-the-user-using-back-button.9203/
	If KeyCode = KeyCodes.KEYCODE_BACK Then ' The 'Back' softbutton was pressed,
		rtnValue = True ' Returning true consumes the event, preventing the 'Back' action
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
	hc.ResumeOp
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

' Handles the Order Acknowledgement response from the Server and takes appropriate action.
Public Sub pHandleOrderAcknResponse(orderAcknResponseStr As String)
	hc.HandleOrderAcknResponse(orderAcknResponseStr)
End Sub

' Handles the response from the Server to the Order message.
Public Sub pHandleOrderResponse(orderResponseStr As String)
	hc.HandleOrderResponse(orderResponseStr)
End Sub

'' Query Payment options and makes payment if required - then returns to caller.
'Public Sub QueryPaymentAndReturn(amount As Float)
'	wait for (hc.QueryPayment(amount)) complete(result As Boolean)
'	Activity.Finish		' This makes it return to caller.
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


#End Region  Local Subroutines
