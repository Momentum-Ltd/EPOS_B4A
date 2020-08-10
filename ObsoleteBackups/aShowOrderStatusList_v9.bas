B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
'
' This X-platform activity platform.
'
#Region  Documentation
	'
	' Name......: aShowOrderStatusList
	' Release...: 9
	' Date......: 22/05/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...: based on ShowOrderStatusList_v13.
		'
	' Date......: 22/12/19
	' Release...: 2
	' Overview..: Centre name displayed in title bar.
	' Amendee...: D Morris
	' Details...:   Mod: frmShowOrderStatusList - displays name in title bar.
	'				Mod: Activity_Create() display name. 
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
	'			   Mod: Close button removed and click on item text revised.
	'
	' Date......: 02/04/20
	' Release...: 6
	' Overview..: Issue: #0371 - Notification whilst showing screen.
	' Amendee...: D Morris
	' Details...: Added: ShowMessageNotificationMsgBox() and ShowStatusNotificationMsgBox().
	'
	' Date......: 09/05/20
	' Release...: 7
	' Overview..: Bugfix: 0401 - No progress dialog order between order ackn message and displaying payment options. 
	' Amendee...: D Morris.
	' Details...:  Mod: Activity_Resume() refreshes the list.
	'			   Mod: Activity_Pause() 
	'
	' Date......: 09/05/20
	' Release...: 8
	' Overview..: Problems with operation after pay for order by cash. 
	' Amendee...: D Morris
	' Details...: Removed: RecreateActivity().
		'
	' Date......: 22/05/20
	' Release...: 9
	' Overview..: Bugfix: Sending request order list (EPOS_ORDERSTATUSLIST) twice. 
	' Amendee...: D Morris.
	' Details...: Mod: Activity_Resume() remove call to hc.Resume().
	'			   Mod: Obsolete methods commented out.
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
	Private bar As StdActionBar				' New title bar
	Private hc As hShowOrderStatusList		' This activity's helper class.
End Sub

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
	hc.CloseOrderStatusList
End Sub

Sub Activity_Create(FirstTime As Boolean)
'	Activity.Title = modEposApp.FormatSelectedCentre
	hc.Initialize(Activity)
End Sub

Sub Activity_Resume
	Activity.Title = modEposApp.FormatSelectedCentre 'TODO could this be moved to the helper?
	modEposApp.InitializeStdActionBar(bar, "bar")
'	hc.RefreshList 'If we leave this in EPOS_ORDERSTATUSLIST get called twice. 
End Sub

Sub Activity_Pause (UserClosed As Boolean)
'	Log("aShowOrderStatusList - Activity_Pause")
	hc.OnClose	' Calling this ensures the timer in progress timeout is stopped.
	If Starter.DisconnectedCloseActivities Then
		Activity.Finish
	End If
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

' Displays the details of the specified order using a message box.
Public Sub pHandleOrderInfo(orderInfoStr As String)
'	Log("aShowOrderStatusList.pHandleOrderInfo")
	hc.pHandleOrderInfo(orderInfoStr)
End Sub

' Sends to the Server the message which requests the customer's order status list.
Public Sub pSendRequestForOrderStatusList
'	Log("aShowOrderStatusList.pSendRequestForOrderStatusList")
'	If hc.IsInitialized = False Then
'		hc.Initialize(Activity)
'	End If
	hc.pSendRequestForOrderStatusList
End Sub

' Populates the listview with each of the orders and their statuses in the specified XML string.
Public Sub pHandleOrderStatusList(orderStatusStr As String)
'	Log("aShowOrderStatusList.pHandleOrderStatusList")
'	If hc.IsInitialized = False Then
'		hc.Initialize(Activity)
'	End If
	hc.pHandleOrderStatusList(orderStatusStr)
End Sub

'' Refresh the bill list
'Public Sub RefreshList
''	Log("aShowOrderStatusList.RefreshList")
'	hc.RefreshList
'End Sub

' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	Log("aShowOrderStatusList.ShowMessageNotificationMsgBox")
	hc.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	Log("aShowOrderStatusList.ShowStatusNotificationMsgBox")
	hc.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

' Causes the listview to be repopulated so that the specified order's information is updated.
Public Sub pUpdateOrderStatus(statusObj As clsEposOrderStatus)
	Log("aShowOrderStatusList.pUpdateOrderStatus")
	hc.pUpdateOrderStatus(statusObj)
End Sub

' New restart see https://www.b4x.com/android/forum/threads/restarting-an-activity.106576/
'Public Sub RestartMe
'	Activity.Finish
'	Log("aShowOrderStatusList.RestartMe")
'	Starter.RestartShowOrderStatusList
'End Sub

'' Recreates (restart) this activity.
'' Code taken from https://www.b4x.com/android/forum/threads/start-activity-from-the-same-activity.52347/#post-327832
'Public Sub RecreateActivity
'	Log("RecreateActivity called")
'	Dim JavaObject1 As JavaObject
'	JavaObject1.InitializeContext
'	JavaObject1.RunMethod("NativeRecreateActivity", Null)
'End Sub
'
'#If JAVA
'public void NativeRecreateActivity(){
'    this.recreate();
'}
'#End If
#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines
