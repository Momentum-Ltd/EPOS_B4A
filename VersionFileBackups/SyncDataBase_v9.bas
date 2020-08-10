B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=7.3
@EndOfDesignText@
'
' This activity synchronises the phone's local database with the server.
'

#Region  Documentation
	'
	' Name......: SyncDataBase
	' Release...: 9
	' Date......: 14/08/19  
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 17/02/18
	' Release...: 2
	' Amendee...: D Morris
	' Details...: Mod: pSyncDataBase() allows the database to be synchronise by an external call. 
	'
	' Date......: 10/09/18
	' Release...: 3
	' Amendee...: D Hathway
	' Details...: Mod: Changed #IncludeTitle setting in Activity Attributes to false, to hide the title bar
	'
	' Date......: 20/09/18
	' Release...: 4
	' Overview..: Improved comms handling by always showing progress dialog.
	' Amendee...: D Hathway
	' Details...: Mod: Moved duplicate code in btnSync_Click() and pSyncDataBase() into new local method lInvokeDatabaseSync()
	'			  Mod: Changes to pHandleSyncDbReponse() and lInvokeDatabaseSync() to show and hide progress dialog during comms
	'
	' Date......: 22/10/18
	' Release...: 5
	' Overview..: Changes to activity layout.
	' Amendee...: D Hathway
	' Details...: Mod: Changes to the layout file to make the form more user-friendly
	'
	' Date......: 04/06/19
	' Release...: 6
	' Overview..: Can now get menu from Web Server.
	' Amendee...: D Morris
	' Details...: Added: lGetMenuFromWebServer() to get menu from Web server.
	'			    Mod: lInvokeDatabaseSync() Now get menu from API. 
		'
	' Date......: 11/06/19
	' Release...: 7
	' Overview..: Bugfix to sync by Wifi or Web.
	' Amendee...: D Morris
	' Details...:  Bugfix: lInvokeDatabaseSync() now selects according to setting.webOnlyComms.
	'
	' Date......: 07/08/19
	' Release...: 8
	' Overview..: Support for myData
	' Amendee...: D Morris 
	' Details...: Mods: Support for myData lInvokeDatabaseSync().
		'
	' Date......: 14/08/19
	' Release...: 9
	' Overview..: Changes to improve operation and display progress for a minimum time.
	' Amendee...: D Morris
	' Details...: Mod: tmrMinimumDisplayPeriod timer supported.
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
	Private tmrMinimumDisplayPeriod As Timer			' Controls the minimum time this activity is displayed.

	Private minDisplayElapsed As Boolean				' When set indicates the minimum display period has elapased.
	Private exitToTaskSelect As Boolean					' Indicates exit to Task Select  activity.
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	
	Private const DFT_MIN_DISPLAY_TIME As Int = 5000 	' Minimum time the Sign is displayed for (in msecs).
	
	Private btnSync As Button	' Sync database 
	Private DEFAULT_TIME_STAMP As Int = 1
	
	Private ID As Int
	Private menuRevision As Int
	Private menuItems As String
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmSyncDataBase")
	tmrMinimumDisplayPeriod.Initialize("tmrMinimumDisplayPeriod", DFT_MIN_DISPLAY_TIME) 
End Sub

Sub Activity_Resume
	' Currently nothing
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If Starter.DisconnectedCloseActivities Then Activity.Finish
End Sub

Sub tmrMinimumDisplayPeriod_Tick
	minDisplayElapsed = True
	tmrMinimumDisplayPeriod.Enabled = False
	If exitToTaskSelect Then
		ProgressDialogHide
		ShowTaskSelectPage
	End If
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Sync button.
Private Sub btnSync_Click()
	lInvokeDatabaseSync
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Starts the database synchronisation procedure.
Public Sub pSyncDataBase()
	lInvokeDatabaseSync
End Sub

' Handles the response from the Server to the Sync Database command.
Public Sub pHandleSyncDbReponse(syncDbResponseStr As String)
	Dim xmlStr As String = syncDbResponseStr.SubString(modEposApp.EPOS_SYNC_DATA.Length) ' TODO - Need to detect if the XML string is valid
	Dim responseObj As clsDataBaseTables
	responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr) ' TODO - need to determine if the deserialisation was successful
	Starter.DataBase = responseObj
	'ProgressDialogHide
	' StartActivity("TaskSelect")
	DelayedTaskSelect
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Ensures this Task Select not invoked before DFT_MIN_DISPLAY_TIME has elapsed.
private Sub DelayedTaskSelect
	If minDisplayElapsed Then
		ProgressDialogHide
		ShowTaskSelectPage
	Else
		exitToTaskSelect = True
	End If
End Sub
' Sends the Sync Database command to the Server.
Private Sub lInvokeDatabaseSync
	tmrMinimumDisplayPeriod.Enabled = True
	ProgressDialogShow("Getting menu information, please wait...")	
	If Starter.settings.webOnlyComms Then
		lGetMenuFromWebServer(Starter.centreID)			
	Else ' Get menu via WIFI
		Dim msg As String = modEposApp.EPOS_SYNC_DATA & "," & Starter.myData.customer.customerIdStr & "," & DEFAULT_TIME_STAMP
		CallSub2(Starter, "pSendMessage", msg)
	End If
End Sub

' Gets the centre menu from the Web Server
private Sub lGetMenuFromWebServer(centreId As Int)
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)

	'job.Download("http://www.superord.co.uk/api/centremenu/1")
	job.Download("http://www.superord.co.uk/api/centremenu/" & centreId)
	Wait For (job) JobDone(job As HttpJob)
	Dim jsonMenuStrg As String
	If job.Success And job.Response.StatusCode = 200 Then
		jsonMenuStrg = job.GetString
	End If
	Dim jParser As JSONParser
	jParser.Initialize(jsonMenuStrg)
	Dim root As Map = jParser.NextObject
	ID = root.Get("ID")
	menuRevision = root.Get("menuRevision")
	menuItems  = root.Get("menuItems")
	
	job.Release ' Must always be called after the job is complete, to free its resources
	
	CallSubDelayed2(Starter, "pProcessInputStrg", menuItems)
End Sub

' Show Task Select page.
private Sub ShowTaskSelectPage
#if B4A
	StartActivity(TaskSelect)
#else
	frmTaskSelect.Show
#End If
End Sub

#End Region  Local Subroutines
