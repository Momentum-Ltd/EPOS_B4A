B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
'
' This activity allows a customer to select a item from the menu and add it to the order.
'
#Region  Documentation
	'
	' Name......: aSelectItem
	' Release...: 8
	' Date......: 25/11/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...: based on SelectItem_v12.
	'
	'
	' Date......: 22/12/19
	' Release...: 2
	' Overview..: Centre name displayed in title bar.
	' Amendee...: D Morris
	' Details...:   Mod: frmSelectItem - displays title bar.
	'				Mod: Activity_Create() display name. 
	'
	' Date......: 11/01/20
	' Release...: 3
	' Overview..: Bugfix: pStartSelectItem() is now defined as pubiic.
	' Amendee...: D Morris
	' Details...:  Mod: pStartSelectItem().
		'
	' Date......: 23/01/20
	' Release...: 4
	' Overview..: Bug fix #0283 Display centre name problem.
	' Amendee...: D Morris
	' Details...:    Mod: Bugfix #0283 - Title now displayed in resume. 
	'
	'
	' Date......: 08/02/20
	' Release...: 5
	' Overview..: New UI and Back button added to title bar.
	' Amendee...: D Morris.
	' Details...:  Mod: stdActionBar added and associated code.
	'
	' Date......: 02/04/20
	' Release...: 6
	' Overview..: Issue: #0371 - Notification whilst showing screen.
	' Amendee...: D Morris
	' Details...: Added: ShowMessageNotificationMsgBox() and ShowStatusNotificationMsgBox().
	'
	' Date......: 11/05/20
	' Release...: 7
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
	'
	' Date......: 25/11/20 
	' Release...: 8
	' Overview..: Changes to support new style UI. 
	' Amendee...: D Morris
	' Details...: Mods: References to Tilebar removed.
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
'	Private bar As StdActionBar		' New title bar
	Private hc As hSelectItem		' This activity's helper class.
End Sub

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
	hc.CancelSelectItem
End Sub

Sub Activity_Create(FirstTime As Boolean)
'	modEposApp.InitializeStdActionBar(bar, "bar")
	hc.Initialize(Activity)
End Sub


Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
	If Starter.DisconnectedCloseActivities Then
		Activity.Finish
	End If
End Sub

Sub Activity_Resume
	
'	Activity.Title = modEposApp.FormatSelectedCentre 'TODO could this be moved to the helper?
End Sub
#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines
' Sets up the form to modify the specified item which currently exists in teh order's item list.
Public Sub pEditItem(orderIndex As Int)
	hc.pEditItem(orderIndex)
End Sub


' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	hc.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	hc.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

' Start select item process
public Sub pStartSelectItem
	hc.pStartSelectItem
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines