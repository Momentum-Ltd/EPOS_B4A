B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
'
' This is a help class for SyncDatabase
'

#Region  Documentation
	'
	' Name......: hSyncDatabase
	' Release...: 9
	' Date......: 04/07/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on code from SyncDatabase_v9.
		'
	' Date......: 25/11/19
	' Release...: 2
	' Overview..: Confusing operation when switching centres/accounts.
	' Amendee...: D Morris
	' Details...: Mod: InvokeDatabaseSync() now uses myData.centre.centreId.
	'
	' Date......: 21/03/20
	' Release...: 3
	' Overview..: #315 Issue removed B4A compiler warnings. 
	' Amendee...: D Morris
	' Details...:  Mod: PROGRESS_DIALOG_TIMEOUT commented out.
	'			    Mod: Declaration menuRevision and ID commented out.
	'			    Mod: GetMenuFromWebServer()  menuRevision and ID commented out.	
		'
	' Date......: 25/05/20
	' Release...: 4
	' Overview..: Bugfix: 0259 - Menu revision not checked.
	' Amendee...: D Morris.
	' Details...:  Mod: GetMenuFromWebServer() updated the Database with ID and menuRevision values.
	'			   Mod: GetMenuFromWebServer() uses modEposWeb for URL.
	'			   Bugfix: Sync Database running twice at startup - InitializeLocal() code removed.
		'
	' Date......: 06/04/20
	' Release...: 5
	' Overview..: Issue: #0329 Retry buttons removed. 
	' Amendee...: D Morris
	' Details...:   Mod: retry and create account buttons removed from forms.
	'		      Added: progressbox_Timeout() with Msgbox gives user a choice to retry or abort.
		'
	' Date......: 26/04/20
	' Release...: 6
	' Overview..: Bugfix: Integer to string conversion if numbers too big.
	' Amendee...: D Morris
	' Details...:  Mod: InvokeDatabaseSync(), GetMenuFromWebServer().
	'
	' Date......: 11/05/20
	' Release...: 7
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Added: OnClose().
	'
	' Date......: 07/06/20
	' Release...: 8
	' Overview..: Mod: Support for second Server.
	' Amendee...: D Morris.
	' Details...:  Mod: GetMenuFromWebServer().
	'
	' Date......: 04/07/20
	' Release...: 9
	' Overview..: Bufix: #0439 - Download menu timeout problem. 
	' Amendee...: D Morris.
	' Details...:  Mod: progressbox_Timeout().
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Mandatory Subroutines & Data

Sub Class_Globals
	
	' Constants
'	Private Const PROGRESS_DIALOG_TIMEOUT As Int = 30000 ' Number of milliseconds before progress dialogs are hidden (due to failed operation).
	
	' X-platform related.
	Private xui As XUI									'ignore (to remove warning) -  Required for X platform operation.
	
'	Private tmrProgressTimeout As Timer 				' The timer used to control the progress dialog's timeout.	
	Private tmrMinimumDisplayPeriod As Timer			' Controls the minimum time this activity is displayed.

	Private minDisplayElapsed As Boolean				' When set indicates the minimum display period has elapased.
	Private exitToTaskSelect As Boolean					' Indicates exit to Task Select  activity.
	
	Private const DFT_MIN_DISPLAY_TIME As Int = 5000 	' Minimum time the Sign is displayed for (in msecs).
	
'	Private btnSync As B4XView							'ignore (leave otherwise problems with 	parent.LoadLayout("frmSyncDataBase") instruction.
	Private lblCaption As B4XView
	Private DEFAULT_TIME_STAMP As Int = 1
'	Private ID As Int
'	Private menuRevision As Int
	Private menuItems As String
	
	' misc object
	Private progressbox As clsProgressDialog

End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmSyncDataBase")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

'' Handles the Click event of the Sync button.
'Private Sub btnSync_Click()
'	InvokeDatabaseSync
'End Sub

' Ensures the display shows for a minimum time.
Sub tmrMinimumDisplayPeriod_Tick
	minDisplayElapsed = True
	tmrMinimumDisplayPeriod.Enabled = False
	If exitToTaskSelect Then
		ProgressHide
		ShowTaskSelectPage
	End If
End Sub

' Progress dialog has timed out
Sub progressbox_Timeout()
	'TODO need some code to deail with this problem!
	xui.Msgbox2Async("No response to request menu!, what would you like to do?", "Timeout Error", "Retry", "Try another Centre", "", Null)
	Wait for msgbox_result (Result As Int)
	If Result = xui.DialogResponse_Positive  Then
		InvokeDatabaseSync
	Else	' Select Play Centre.
#if B4A
	#if CENTRE_LOGOS
		StartActivity(aSelectPlayCentre2)
	#else ' Just list centres
		StartActivity(xSelectPlayCentre)	
	#End If
#else ' B4i
	#if CENTRE_LOGOS
		frmXSelectPlayCentre2.Show
	#else ' Just list centres.
		frmXSelectPlayCentre.Show	
	#End If
#End If
	End If
End Sub
#End Region  Event Handlers

#Region  Public Subroutines

' Handles the response from the Server to the Sync Database command.
Public Sub HandleSyncDbReponse(syncDbResponseStr As String)
#if B4A
	Dim xmlStr As String = syncDbResponseStr.SubString(modEposApp.EPOS_SYNC_DATA.Length) ' TODO - Need to detect if the XML string is valid
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(syncDbResponseStr) ' TODO - Need to detect if the XML string is valid
#end if
	Dim responseObj As clsDataBaseTables
	responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr) ' TODO - need to determine if the deserialisation was successful
	Starter.DataBase = responseObj
	DelayedTaskSelect
End Sub

' Sends the Sync Database command to the Server.
Public Sub InvokeDatabaseSync
	tmrMinimumDisplayPeriod.Enabled = True
	ProgressShow("Getting menu information, please wait...")
	If Starter.settings.webOnlyComms Then
		GetMenuFromWebServer(Starter.myData.centre.centreID)
	Else ' Get menu via WIFI
		Dim msg As String = modEposApp.EPOS_SYNC_DATA & "," & modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
								"," & DEFAULT_TIME_STAMP
#if B4A	
		CallSub2(Starter, "pSendMessage", msg)
#else ' B4I
		Main.SendMessage(msg)
#end if	
	End If
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	tmrMinimumDisplayPeriod.Enabled = False
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Initialize the locals etc.
private Sub InitializeLocals
	tmrMinimumDisplayPeriod.Initialize("tmrMinimumDisplayPeriod", DFT_MIN_DISPLAY_TIME)

	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)

'	tmrProgressTimeout.Enabled = False
	
	' Line removed. 
	' InvokeDatabaseSync
End Sub

' Ensures the activity does not exit before DFT_MIN_DISPLAY_TIME has elapsed.
private Sub DelayedTaskSelect
	If minDisplayElapsed Then
		ProgressHide
		ShowTaskSelectPage
	Else
		exitToTaskSelect = True
	End If
End Sub

' Gets the centre menu from the Web Server
private Sub GetMenuFromWebServer(centreId As Int)
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	
'	job.Download("https://www.superord.co.uk/api/centremenu/" & centreId)
'	job.Download(modEposWeb.URL_CENTREMENU_API & "/" & modEposWeb.ConvertToString(centreId))
	job.Download(Starter.server.URL_CENTREMENU_API & "/" & modEposWeb.ConvertToString(centreId))
	Wait For (job) JobDone(job As HttpJob)
	Dim jsonMenuStrg As String
	If job.Success And job.Response.StatusCode = 200 Then
		jsonMenuStrg = job.GetString
	End If
	Dim jParser As JSONParser
	jParser.Initialize(jsonMenuStrg)
	Dim root As Map = jParser.NextObject
	Starter.menuRevision = root.Get("menuRevision")
	menuItems  = root.Get("menuItems")
	
	job.Release ' Must always be called after the job is complete, to free its resources
#if B4A
	CallSubDelayed2(Starter, "pProcessInputStrg", menuItems)
#else ' B4I
	Main.ProcessInputStrg(menuItems)
#end if

End Sub

' Hide the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Show The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

' Show Task Select page.
private Sub ShowTaskSelectPage
#if B4A
	StartActivity(aTaskSelect)
#else
	xTaskSelect.Show
#End If
End Sub

#End Region  Local Subroutines