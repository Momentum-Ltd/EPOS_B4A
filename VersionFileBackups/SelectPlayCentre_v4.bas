B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Web Start Select Play Centre
'

#Region  Documentation
	'
	' Name......: SelectPlayCentre
	' Release...: 4
	' Date......: 28/07/19   
	'
	' History
	' Date......: 22/06/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking (based on SelectCentre by D Hathway)
		'
	' Date......: 01/07/19
	' Release...: 2
	' Overview..: New options added to menu.
	' Amendee...: D Morris
	' Details...: Added: Refresh button (removed later).
	'				Mod: Handling of Activity_Resume() changed.
	'			    Mod: New menu options "New account" and "About" added.    
	'
	' Date......: 21/07/19
	' Release...: 3
	' Overview..: When location not available - now lists all centres (previously just gave an error report).
	' Amendee...: D Morris
	' Details...: Mod: GetAllCentres() - now calls the Get All Centres API.
		'
	' Date......: 28/07/19
	' Release...: 4
	' Overview..: CustomerDetails now updated with centre ID
	' Amendee...: D Morris
	' Details...:	Mods: lvwCentres_ItemClick() updates Starter.CustomerDetails.centreId
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

##Region  Activity Attributes
	#FullScreen: False
	'#IncludeTitle: False
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	
	' Local variables
	Private mClosingActivity As Boolean 		' Whether the activity should be closed the next time it is paused.
	Private mLocator As FusedLocationProvider 	' Object used to get the phone's location.
	
	' View declarations
	Private btnFresh As Button					' Refresh centre information.
	Private lvwCentres As ListView 				' Listview used to show the list of centres available as options.

End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmSelectPlayCentre")
	
	Activity.AddMenuItem("Change your information", "mnuChangeAccountInfo")
	Activity.AddMenuItem("Settings", "mnuChangeSettings")
	Activity.AddMenuItem("New account", "mnuNewAccount")
	Activity.AddMenuItem("About", "mnuAbout")
	
	mLocator.Initialize("mLocator")		'
	
	' Ensure the listview always displays its text properly
	lvwCentres.SingleLineLayout.Label.Width = 999999dip ' See below (one-line layout is currently unused - but just in case)
	lvwCentres.TwoLinesLayout.Label.Width = 999999dip ' Set this to be absurdly wide, as a HACK to prevent text wraparound
	lvwCentres.TwoLinesLayout.SecondLabel.Width = 999999dip ' Set this to be absurdly wide, as a HACK to prevent text wraparound
	lvwCentres.SingleLineLayout.Label.TextColor = Colors.Black ' One-line layout isn't currently used on this form - but just in case
	lvwCentres.TwoLinesLayout.Label.TextColor = Colors.Black
	lvwCentres.TwoLinesLayout.SecondLabel.TextColor = Colors.Black
End Sub

' Inhibit back button.
Sub Activity_Keypress(KeyCode As Int) As Boolean
	Dim rtnValue As Boolean = False ' Initialised to False, as that will allow the event to continue
	
	' Prevent 'Back' softbutton, from https://www.b4x.com/android/forum/threads/stopping-the-user-using-back-button.9203/
	If KeyCode = KeyCodes.KEYCODE_BACK And Not(Starter.TestMode) Then ' The 'Back' softbutton was pressed, and not test mode
		rtnValue = True ' Returning true consumes the event, preventing the 'Back' action
	End If

	Return rtnValue
End Sub

Sub Activity_Resume
	'lblLocation.Text = "Getting your location..."
	' lvwCentres.Clear
	Log("StartPlayCentre - Activity_Resume run!")	
	GetLocation
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If mClosingActivity Then Activity.Finish
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Refresh button, refreshed the displayed centre information.
Sub btnFresh_Click
'	mLocator.Initialize("mLocator")	' For Test only
	lShowCentreInformation
End Sub

' Handles the ItemClick event of the Centres listview.
Sub lvwCentres_ItemClick (Position As Int, Value As Object)
	Dim centreDetails As clsEposWebCentreLocationRec = Value
	If centreDetails.centreopen Then
		Starter.centreID = centreDetails.id
		Starter.ServerIP = centreDetails.lanIpAddress
		mClosingActivity = True
	'	CallSubDelayed3(Connection, "pSelectedCentre", centreDetails.centreName, centreDetails.lanIpAddress)
		CallSubDelayed2(ValidateCentreSelection, "pValidateCentreSelection", centreDetails)
	Else ' Selected centre is not open
		Msgbox("That centre is not currently open. Please select a different centre.", "Centre Closed")
	End If
End Sub

' Handles the ConnectionFailed event of the Fused Location Provider object.
Private Sub mLocator_ConnectionFailed(ConnectResult As Int)
	Log("Failed to connect to location services. Reason code: " & ConnectResult)
	MsgboxAsync("An error occurred while trying to get your location. All centres will now be displayed.", "Cannot Get Location")
	GetAllCentres
End Sub

' Handles the ConnectionSuccess event of the Fused Location Provider object.
Private Sub mLocator_ConnectionSuccess
	Log("Successfully connected to location services. Getting last known location...")
	
	Dim lastLocation As Location= mLocator.GetLastKnownLocation
	If lastLocation.IsInitialized Then
		Log("New location – lat: " & lastLocation.Latitude & ", lon: " & lastLocation.Longitude)
		mLocator.Disconnect ' Must always do this otherwise it will drain the battery
		GetLocalCentres(lastLocation)
	Else ' No last known location is available
		Log("No last known location is available.")
		mLocator.Disconnect ' Must always do this otherwise it will drain the battery
		MsgboxAsync("Your current location is unavailable. All centres will now be displayed.", "Cannot Get Location")
		GetAllCentres
	End If
End Sub

' Handles menu option About.
Private Sub mnuAbout_Click
	StartActivity(About)
End Sub

' Handles menu option Change Customer information
Private Sub mnuChangeAccountInfo_Click
	lChangeAccountInfo
End Sub

' Handles menu option Settings
Private Sub mnuChangeSettings_Click
	lChangeSettings
End Sub

' Handles menu option New Account
Private Sub mnuNewAccount_Click
	StartActivity(QueryNewInstall)
End Sub
#End Region  Event Handlers

#Region  Public Subroutines
' Main method
Public Sub pSelectPlayCentre
	lShowCentreInformation
	' GetLocation
End Sub

#End Region  Public Subroutines


#Region  Local Subroutines

' Parses the specified JSON string into centre details objects, and displays them on the listview.
Private Sub DisplayOnListview(inputJson As String)
	' Get all the centres out of the JSON and put them in a list
	Dim jp As JSONParser
	jp.Initialize(inputJson)
	Dim centreList As List = jp.NextArray
		
	' Convert each centre details object to a clsEposWebCentreLocationRec and add it to the listview
	lvwCentres.Clear ' clear previously displayed information.
	For Each centreDetailsMap As Map In centreList
		Dim centre As clsEposWebCentreLocationRec
		centre.centreName = centreDetailsMap.Get("centreName")
		centre.id = centreDetailsMap.Get("id")
		centre.lanIpAddress = centreDetailsMap.Get("lanIpAddress")
		centre.centreopen = centreDetailsMap.Get("centreOpen")
		centre.postCode = centreDetailsMap.Get("postCode")
		Dim openStr As String = "Closed"
		If centre.centreopen Then openStr = "Open"
		lvwCentres.AddTwoLines2(centre.id & ": " & centre.centreName, openStr & " - " & centre.postCode, centre)
	Next
End Sub

' Invokes the check for the user's location (which leads to the neraby centre list being displayed).
Private Sub GetLocation
	Log("Checking fine location permission...")
	Dim perms As RuntimePermissions
	perms.CheckAndRequest(perms.PERMISSION_ACCESS_FINE_LOCATION)
	Wait For Activity_PermissionResult(permission As String, result As Boolean)
	If result Then ' Permission has been granted to use the location services
		Log("Fine location permission OK. Connecting to location services...")
		mLocator.Connect ' This will then be handled in either mLocator_ConnectionSuccess() or mLocator_ConnectionFailed()
	Else ' Location permission has been denied
		Msgbox("The fine location permission has been denied. All centres will now be displayed.", "Cannot Get Location")
		GetAllCentres
	End If
End Sub

' Downloads a list of centres near to the specified location, and displays them on the listview. 
'  This invokes the location object to get centre information - (see handler for next stage in the process).
Private Sub GetLocalCentres(currentLocation As Location)
	'lblLocation.Text = "Location: lat " & currentLocation.Latitude & ", lon " & currentLocation.Longitude & CRLF & "Select a centre to connect to:"
	ProgressDialogShow("Finding centres close to you, please wait...")
	
	Log("Sending the coordinates to the Web API...")
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	job.Download("https://www.superord.co.uk/api/centre?lat=" & currentLocation.Latitude & "&lon=" & currentLocation.Longitude)'  & "&max=25")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		Dim rxMsg As String = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)
		DisplayOnListview(rxMsg)
	Else ' An error of some sort occurred
		If job.Response.StatusCode = 204 Or job.Response.StatusCode = 404 Then
			Log("The Web API returned no nearby centres")
			MsgboxAsync("There are no centres near your current location. All centres will now be displayed.", "No Nearby Centres")
			GetAllCentres
		Else ' Any other error
			Log("An error occurred with the HTTP job: " & job.ErrorMessage)
			MsgboxAsync("An error occurred while trying to find nearby centres. All centres will now be displayed.", "Cannot Get Nearby Centres")
			GetAllCentres
		End If
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
	
	ProgressDialogHide
End Sub

' Downloads the list of all centres from the Web API and displays them on the listview.
Private Sub GetAllCentres
	ProgressDialogShow("Getting a list of all centres, please wait...")
	Log("Request the Web API to give list of all centres...")
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	job.Download("https://www.superord.co.uk/api/centre?lat=" & "all" & "&lon=" & "all")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		Dim rxMsg As String = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)
		DisplayOnListview(rxMsg)
	Else ' An error of some sort occurred
		If job.Response.StatusCode = 204 Or job.Response.StatusCode = 404 Then
			Log("The Web API returned no centres available")
			MsgboxAsync("There are no centres on the system.", "No Nearby Centres")
			GetAllCentres
		Else ' Any other error
			Log("An error occurred with the HTTP job: " & job.ErrorMessage)
			MsgboxAsync("An error occurred while trying to get All centres.", "Cannot Get All Centres")
		End If
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
	ProgressDialogHide
End Sub

' Change customer information
private Sub lChangeAccountInfo
	CallSubDelayed(ChangeAccountInfo, "pChangeAccountInfo")
End Sub

' Change operation settings
private Sub lChangeSettings
	CallSubDelayed(ChangeSettings, "pChangeSettings")
End Sub

' Shows a list of centre's available.
private Sub lShowCentreInformation
	' lvwCentres.Clear
	GetLocation
End Sub
#End Region  Local Subroutine
