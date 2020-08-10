B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
'
' Sync Database activity
'
#Region  Documentation
	'
	' Name......: aSyncDatabase
	' Release...: 4
	' Date......: 11/05/20   
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...:  Replaces SyncDatabase_v9.
	'
	' Date......: 22/12/19
	' Release...: 2
	' Overview..: Centre name displayed in title bar.
	' Amendee...: D Morris
	' Details...:   Mod: frmSyncDataBase - displays title bar.
	'				Mod: Activity_Create() display name - 
	'
	' Date......: 23/01/20
	' Release...: 3
	' Overview..: Bug fix #0283 Display centre name problem.
	' Amendee...: D Morris
	' Details...:    Mod: Bugfix #0283 - Title now displayed in resume. 
	'
	' Date......: 11/05/20
	' Release...: 4
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
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
'	#IncludeTitle: true
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private hc As hSyncDatabase ' This activity's helper class.
End Sub

Sub Activity_Create(FirstTime As Boolean)
'	Activity.Title = modEposApp.FormatSelectedCentre
	hc.Initialize(Activity)
End Sub

Sub Activity_Resume
	Activity.Title = modEposApp.FormatSelectedCentre 'TODO could this be moved to the helper?
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
	If Starter.DisconnectedCloseActivities Then 
		Activity.Finish
	End If
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers


#End Region  Event Handlers

#Region  Public Subroutines

' Starts the database synchronisation procedure.
Public Sub pSyncDataBase()
	hc.InvokeDatabaseSync
End Sub

' Handles the response from the Server to the Sync Database command.
Public Sub pHandleSyncDbReponse(syncDbResponseStr As String)
	hc.HandleSyncDbReponse(syncDbResponseStr)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines


#End Region  Local Subroutines
