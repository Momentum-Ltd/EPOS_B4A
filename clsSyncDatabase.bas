B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'
' This is a class for Synchronizing the Database
'
#Region  Documentation
	'
	' Name......: clsSyncDatabase
	' Release...: 1
	' Date......: 28/11/20
	'
	' History
	' Date......: 28/11/20
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on code from hSyncDatabase_v11.
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
#End Region  Documentation

#Region  Mandatory Subroutines & Data

' Event raised when the database is synchronization is complete or has timeout.
#Event: SyncComplete	

Sub Class_Globals
	
	
	' X-platform related.
	Private xui As XUI									'ignore (to remove warning) -  Required for X platform operation.

	' Constants
	Private DEFAULT_TIME_STAMP As Int = 1
	Private const DFT_MIN_DISPLAY_TIME As Int = 2000 	' Minimum time to show progress box.

	' flags
	Private minDisplayElapsed As Boolean				' When set indicates the mininum show progress box time has elapased.
	Private taskCompleted As Boolean					' Indicates the sync task is complete (it can exit when the minimum time has elapsed).
	Private syncCompleteEventRaised As Boolean			' Indicates the sync complete event has been raised (required to prevent race timer hazards)
	
	' Variables
	Private menuItems As String							' Storage for the Centre menu item list.

	' misc objects
	Private progressbox As clsProgressDialog			' Sync in-progress dialog.
	Private tmrMinimumDisplayPeriod As Timer			' Controls the minimum time this progress dialog is displayed.
	
	' Required for event handling
	Private mCallback As Object
	Private mEvent As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
' Public Sub Initialize (parent As B4XView)
'	parent.LoadLayout("frmSyncDataBase")
Public Sub Initialize(callback As Object, eventName As String)
	mCallback = callback
	mEvent = eventName
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Ensures the progress dialog is displayed for a minimum time.
Private Sub tmrMinimumDisplayPeriod_Tick
	minDisplayElapsed = True
	tmrMinimumDisplayPeriod.Enabled = False
	If taskCompleted Then
		ProgressHide
		RaiseSyncCompleteEvent(True) ' Raise Sync Complete event (Success)
	End If
End Sub

' Progress dialog has timed out
Private Sub progressbox_Timeout()
	RaiseSyncCompleteEvent(False) 'Raise Sync Complete event (error)
End Sub
#End Region  Event Handlers

#Region  Public Subroutines

' Asynchronous version of Sync Database - returns when process complete.
Public Sub AsyncSyncDatabase() As ResumableSub
	InvokeDatabaseSync
	Wait for Local_SyncComplete(success As Boolean)
'	Dim complete As Boolean = True
'	Return complete
	Return success
End Sub

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
	DelayRaiseSyncCompleteEvent
End Sub

' Sends the Sync Database command to the Server.
Public Sub InvokeDatabaseSync
	tmrMinimumDisplayPeriod.Enabled = False ' Just in case the timer was previously running.
	minDisplayElapsed = False				' Also re-initialize the flags.
	taskCompleted = False
	syncCompleteEventRaised = False
	tmrMinimumDisplayPeriod.Enabled = True
	ProgressShow("Getting menu information, please wait...")
	If Starter.settings.webOnlyComms Then
		GetMenuFromWebServer(Starter.myData.centre.centreID)
	Else ' Get menu via WIFI
		Dim msg As String = modEposApp.EPOS_SYNC_DATA & "," &  _
								modEposWeb.ConvertToString(Starter.myData.customer.customerId) & "," & DEFAULT_TIME_STAMP
#if B4A	
		CallSub2(Starter, "pSendMessage", msg)
#else ' B4I
		Main.SendMessage(msg)
#end if	
	End If
End Sub

' Will perform any cleanup operation when the user has Finished with this class.
'  NOTE: IF restarted, it will perform a completely new Sync database operation.
public Sub Finished
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
End Sub

' Ensures the Sync Complete event is NOT raised before the DFT_MIN_DISPLAY_TIME has elapsed.
private Sub DelayRaiseSyncCompleteEvent
	If minDisplayElapsed Then
		ProgressHide
		RaiseSyncCompleteEvent(True) ' Raise Sync Complete event (Success)
	Else
		taskCompleted = True
	End If
End Sub

' Gets the centre menu from the Web Server
private Sub GetMenuFromWebServer(centreId As Int)
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	
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

' Raise the Sync Complete event
'  Success = true of Synchronization was successful otherwise false.
' Note: OK to call this sub multiple times. However, it will only Raise the event once.
Private Sub RaiseSyncCompleteEvent(success As Boolean)
	If Not( syncCompleteEventRaised) Then ' Only raise Sync complete event once.
		If xui.SubExists(mCallback, mEvent & "_SyncComplete", 0) Then ' Raise Sync Complete event
			CallSub2(mCallback, mEvent & "_SyncComplete", success)
			syncCompleteEventRaised = True
		End If
		CallSubDelayed2(Me, "Local_SyncComplete", success) ' Raises a local event indicating Sync is complete (used by AsyncSyncDatabase).
	End If
End Sub

#End Region  Local Subroutines