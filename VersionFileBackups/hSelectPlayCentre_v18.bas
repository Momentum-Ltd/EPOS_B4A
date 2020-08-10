B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' This is a help class for SelectPlayCentre
'
#Region  Documentation
	'
	' Name......: hSelectPlayCentre
	' Release...: 18
	' Date......: 14/07/20
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 2/8/19)
	' Details...: First release to support version tracking
	' Version 2 - 9 see hSelectPlayCentre_v10.
	'
	' Date......: 27/12/19
	' Release...: 10
	' Overview..: Bugfix for Location initialisation.
	' Amendee...: D Morris
	' Details...:  Mod: Initialize() code fixed for B4I operation.
		'
	' Date......: 20/02/20
	' Release...: 11
	' Overview..: Added: If no sites Always adds not other sites nearby to end of list.
	' Amendee...: D Morris
	' Details...:  Mod: DisplayOnListview() Append "No more centres nearby" message to end of list.
	'			   Mod: clvCentres_ItemClick() will now refresh the list if user clicks on the appended message.
	'			   Mod: Press refresh will scroll to top of list.
	'		     Added: RefreshCentreList.
	'
	' Date......: 02/04/20
	' Release...: 12
	' Overview..: Added explanation why location is required.
	' Amendee...: D Morris
	' Details...:  Mod: SelectCentre().
	'			
	' Date......: 26/04/20
	' Release...: 13
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	' Amendee...: D Morris.
	' Details...:  Mod: API call now uses constants from modEposWeb - DisplayAllCentres(), DisplayNearbyCentres().
	'
	' Date......: 05
	' Release...: 14
	' Overview..: Changed xCardEntry.Show().
	' Amendee...: D Morris
	' Details...:  Mod: Show() parameter removed from call.
		'
	' Date......: 11/05/20
	' Release...: 15
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mod: OnClose().
	'
	' Date......: 13/05/20
	' Release...: 16
	' Overview..:  Added: #0232 - Support EPOS_GET_LOCATION. 
	' Amendee...: D Morris.
	' Details...: Mod: (Android) mLocator_LocationChanged() updates current location in starter.
	'			  Mod: (iOS) LocManager_LocationChanged() updates current location in starter.
	'
	' Date......: 11/06/20
	' Release...: 17
	' Overview..: Mod: Support for second Server.
	' Amendee...: D Morris.
	' Details...:  Mod: DisplayAllCentres(), DisplayNearbyCentres().
	'			
	' Date......: 14/07/20
	' Release...: 18
	' Overview..: Warning removed.
	' Amendee...: D Morris
	' Details...: 	 Mod: clvCentres_ItemClick() fixed warning about objects.
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
	
	' X-platform related.
	Private xui As XUI							'ignore (to remove warning) -  Required for X platform operation.
	
	' Local variables
	Private prevLocation As Location			' Storage for previous location -(used to prevent redisplay centre list when location not changed)	
	Private tmrDelayNewLocation As Timer		' Timer to limit how quickly the new location is used to search for centres.
	Private allowCentreUpdate As Boolean		' Allows location to be used to update the list of centres (works conjunction with tmrDelayNewLocation)
	
	#if B4A 
	Private mLocator As FusedLocationProvider 	' Object used to get the phone's location.
	Private LocationUpdatesRunning As Boolean	' Indicates location update service running
	#else
	Private LocManager As LocationManager
	Private currentLocation As Location
	
	Private locationAvailable As Boolean 
	Private centresDisplayed As Boolean		
	Private tmrAutoStartDisplayCentres As Timer
	#End If

	' misc objects
	Private progressbox As clsProgressDialog

	' View declarations
	Private clvCentres As CustomListView		' Custom listview used to show the list of centres available as options.
	Private btnRefresh As B4XView				' Refresh displayed centre list button.
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmXSelectPlayCentre")
'	saveParent = parent	
	tmrDelayNewLocation.Initialize("tmrDelayNewLocation", 20000)
	allowCentreUpdate = True
#if B4A
	' mLocator.Initialize("mLocator")	
#else ' B4i
	LocManager.Initialize("LocManager")
	tmrAutoStartDisplayCentres.Initialize("tmrAutoStartDisplayCentres",  1000)
#End If
	InitializeLocals
#if B4I	
	StartLocationUpdates	' Could be an overkill but appears necessary to sometime get the GPS running.
#end if 
	prevLocation.Initialize2(0, 0)
End Sub
#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles refresh display button.
Private Sub btnRefresh_Click
	RefreshCentreList
End Sub

' Handles the ItemClick event of the Centres listview.
Private Sub clvCentres_ItemClick (Position As Int, Value As Object)
	If 0 <> Value Then ' Clicked on a valid entry in list?
		Dim centreDetails As clsEposWebCentreLocationRec = Value
		If centreDetails.centreopen Then
	'		Starter.centreID = centreDetails.id
			Starter.myData.centre.centreId = centreDetails.id
			Starter.ServerIP = centreDetails.lanIpAddress
			ShowValidateCentreSelectionPage(centreDetails)
		Else ' Selected centre is not open - show message and refresh list.
			xui.MsgboxAsync("That centre is not currently open. Please select a different centre.", "Centre Closed")
			wait for msgbox_result(tempResult As Int)
			RefreshCentreList 
		End If	
	Else
		RefreshCentreList 
	End If
End Sub

#if B4A
' Handles the ConnectionFailed event of the Fused Location Provider object.
Private Sub mLocator_ConnectionFailed(ConnectResult As Int)
	Log("Failed to connect to location services. Reason code: " & ConnectResult)
	xui.MsgboxAsync("An error occurred while trying to get your location. All centres will now be displayed.", "Cannot Get Location")
	DisplayAllCentres
End Sub

' Handles the ConnectionSuccess event of the Fused Location Provider object.
Private Sub mLocator_ConnectionSuccess
	StartLocationUpdates
	Log("Successfully connected to location services. Getting last known location...")
	Dim lastLocation As Location = mLocator.GetLastKnownLocation
	
	lastLocation = mLocator.GetLastKnownLocation
	If lastLocation.IsInitialized Then
		Log("New location – lat: " & lastLocation.Latitude & ", lon: " & lastLocation.Longitude)
		prevLocation = lastLocation
'		mLocator.Disconnect ' Must always do this otherwise it will drain the battery
		LocationUpdatesRunning = False
		DisplayNearbyCentres(lastLocation)
	Else ' No last known location is available
		Log("No last known location is available.")
		xui.MsgboxAsync("Your current location is unavailable. All centres will now be displayed.", "Cannot Get Location")
		DisplayAllCentres			
	End If
End Sub

' Handles the Location changed event of the Fused Location Provider object.
' This helps with fixing the problem of switching on GPS whilst the App is running, but
'  only if you move off the activity and back on again.
Private Sub mLocator_LocationChanged(Location1 As Location)
	Log("Location Changed: " & Location1) 'ignore
	Starter.currentLocation = Location1
	If Abs(prevLocation.Latitude - Location1.Latitude) >  0.0001 Or Abs(prevLocation.Longitude - Location1.Longitude) > 0.0001 Then
		If allowCentreUpdate Then
			UpdateCentreList(Location1)	
			RestartDisplayNewLocationTimer
		End If
		prevLocation = Location1
	End If
End Sub

#else ' B4i

' Raised when Authorizations status changed (not sure when this is raised).
Private Sub LocManager_AuthorizationStatusChanged (Status As Int)
	StartLocationUpdates
End Sub

' Event triggered when location changed (also appears to be raised when first started)
Private Sub LocManager_LocationChanged (Location1 As Location)
	Log("Location Changed: " & Location1) 'ignore
	currentLocation = Location1
	locationAvailable = True
	If prevLocation.IsInitialized = False Then
		prevLocation.Initialize2(0, 0)
	End If
	Starter.currentLocation = Location1
	If centresDisplayed = False Then
		If Abs(prevLocation.Latitude - Location1.Latitude) >  0.0001 Or Abs(prevLocation.Longitude - Location1.Longitude) > 0.0001 Then
			If allowCentreUpdate Then
				SelectCentre							
			End If
			prevLocation = Location1
		End If		
	End If
End Sub
#end if ' Endif B4i

' Progress dialog has timed out
Sub progressbox_Timeout()
	Log("hSelectPlayCentre - Progress dialog tripped!")
End Sub

#if B4I
' Handle timer to overcome the not display centres when location off.
Private Sub tmrAutoStartDisplayCentres_Tick
	tmrAutoStartDisplayCentres.Enabled = False
	SelectCentre
End Sub
#End If

' Handle delay display new location timer.
Private Sub tmrDelayNewLocation_Tick
	tmrDelayNewLocation.Enabled = False
	allowCentreUpdate = True	
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Handles clear account option.
public Sub ClearAccount
	xui.Msgbox2Async("Are you sure you want to clear the account information stored on this phone?", "Clear Account Information", "Yes", "No", "", Null)
	wait for Msgbox_Result(result As Int)
	If result = xui.DialogResponse_Positive Then
#if B4A
		Starter.myData.Clear						' Clear customer data
		Starter.myData.Delete
#Else ' B4I
'		Starter.CustomerInfoData.ClearCustomerInfo
'		Starter.CustomerInfoData.DeleteCustomerInfo
		Starter.myData.Clear
		Starter.myData.Delete
#End If
		Starter.customerInfoAvailable = False
		Starter.settings.SaveDefaults				' Setting back to default
#if B4A
		StartActivity(CheckAccountStatus)	
#else ' B4i
	'	frmCheckAccountStatus.show
#End If
	End If
End Sub

' Change customer information
public Sub IChangeAccountInfo
	ShowChangeAccountInfoPage
End Sub

' Change operation settings
public Sub lChangeSettings
	ShowChangeSettingsPage
End Sub

' Switch off location device.
public Sub LocationDeviceOFF
#if B4A
	If mLocator.IsInitialized Then ' bit of protect - disconnect has thrown exception
		mLocator.Disconnect		
	End If
#Else	
	LocManager.Stop ' looks like check not required for iOS.
#End If
End Sub

' Show Create new account form
public Sub NewAccount
#if B4A
	StartActivity(QueryNewInstall)
#else
	frmQueryNewInstall.show
#End If
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	tmrDelayNewLocation.Enabled = False
#if B4I
	tmrAutoStartDisplayCentres.Enabled = False
#End If
	If progressbox.IsInitialized = True Then
		ProgressHide		' Just in-case.
	End If
End Sub

' (Main entry sub) Select Play Centre - This displays a list of nearby centres and allows the user to select a centre.
Public Sub SelectCentre
	RestartDisplayNewLocationTimer		
#if B4A
	If mLocator.IsInitialized Then ' Help to handle the bug #0180 Starting GPS
		mLocator.Disconnect
	End If
	Log("Checking fine location permission...") 						
	Dim perms As RuntimePermissions'
	If perms.Check(perms.PERMISSION_ACCESS_FINE_LOCATION) = False Then
		Dim msg As String = "This App will ask permission to use your device's location." & CRLF & _
		"This information is used within the App to find local centres or to check you are in the centre." & CRLF & _
		"It is not disclosed to any third parties!" & CRLF & CRLF & _
		"THE APP CANNOT RUN WITHOUT YOU ALLOWING LOCATION"
		xui.MsgboxAsync( msg, "Location permission")
		wait for MsgBox_result(resultPermission As Int)			
	End If
	perms.CheckAndRequest(perms.PERMISSION_ACCESS_FINE_LOCATION)
	Wait For Activity_PermissionResult(permission As String, result As Boolean)
	If result Then ' Permission has been granted to use the location services
		Log("Fine location permission OK. Connecting to location services...")
		StartLocationService
		mLocator.Connect ' This will then be handled in either mLocator_ConnectionSuccess() or mLocator_ConnectionFailed()
	Else ' Location permission has been denied
		xui.MsgboxAsync("The fine location permission has been denied. All centres will now be displayed.", "Cannot Get Location")
		DisplayAllCentres
	End If
#else ' B4i
	If locationAvailable = True And LocManager.IsAuthorized Then
		DisplayNearbyCentres(currentLocation)
	Else ' Location permission has been denied
'		xui.MsgboxAsync("The fine location permission has been denied. All centres will now be displayed.", "Cannot Get Location")
'		wait for MsgBox_result(tempResult As Int) '' inserted
		
		Dim msg As String = "This App will not run correctly without location permissions." & CRLF & _
				"You can goto settings and allow location for SuperOrder or."  & CRLF & _
				"remove and re-install the SuperOrder, then Allow location when asked."
		'		xui.MsgboxAsync( msg, "Notification permission") ' This code can't be used - get a blank screeen!
		'		wait for MsgBox_result(resultPermission As Int)
		xui.Msgbox2Async(msg, "Location permission", "Settings", "Ok","", Null)
		Wait For Msgbox_Result (Result As Int)
		If Result = xui.DialogResponse_Positive Then
			Main.DisplaySettings
		End If		
		DisplayAllCentres
	End If
#End If ' End B4i
End Sub

' Show about form
public Sub ShowAbout
#if B4A
	StartActivity(About)
#Else
	frmAbout.show
#End If
End Sub

' Show location
Public Sub ShowLocation
	Dim locationString As String 
	locationString = "LAT:" & prevLocation.Latitude & CRLF & "LONG:" & prevLocation.Longitude
	xui.MsgboxAsync(locationString, "Location")
	wait for MsgBox_result(tempResult As Int) 
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

' Parses the specified JSON string into centre details objects, and displays them on the listview.
Private Sub DisplayOnListview(inputJson As String)
	' Get all the centres out of the JSON and put them in a list
	Dim jp As JSONParser
	jp.Initialize(inputJson)
	Dim centreList As List = jp.NextArray
	' Loop to convert each centre details object to a clsEposWebCentreLocationRec and add it to the listview
	clvCentres.Clear	' clear previously displayed information.
	For Each centreDetailsMap As Map In centreList 
		Dim centre As clsEposWebCentreLocationRec
		centre.centreName = centreDetailsMap.Get("centreName")
		centre.id = centreDetailsMap.Get("id")
		centre.lanIpAddress = centreDetailsMap.Get("lanIpAddress")
		centre.centreopen = centreDetailsMap.Get("centreOpen")
		centre.postCode = centreDetailsMap.Get("postCode")
		Dim openStr As String = "Closed"
		If centre.centreopen Then
			 openStr = "Open"
		End If
		clvCentres.AddTextItem(centre.id & ": " & centre.centreName & CRLF & openStr & " - " & centre.postCode, centre)
	Next
	clvCentres.AddTextItem(CRLF & "No more centres nearby" & CRLF, 0)
End Sub

' Downloads the list of all centres from the Web API and displays them on the listview.
Private Sub DisplayAllCentres
	ProgressShow("Getting a list of all centres, please wait...")
	Log("Request the Web API to give list of all centres...")
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	'job.Download(modEposWeb.URL_CENTRE_API & "?lat=" & "all" & "&lon=" & "all")
'	Dim urlStr As String = 	modEposWeb.URL_CENTRE_API & _
'									"?" & modEposWeb.API_LATITUDE & "=" & modEposWeb.API_GET_ALL & _
'									"&" & modEposWeb.API_LONGITUDE & "=" & modEposWeb.API_GET_ALL
	Dim urlStr As String = 	Starter.server.URL_CENTRE_API & _
									"?" & modEposWeb.API_LATITUDE & "=" & modEposWeb.API_GET_ALL & _
									"&" & modEposWeb.API_LONGITUDE & "=" & modEposWeb.API_GET_ALL
	job.Download(urlStr)
	Wait For (job) JobDone(job As HttpJob)
	ProgressHide	
	If job.Success And job.Response.StatusCode = 200 Then
		Dim rxMsg As String = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)
		DisplayOnListview(rxMsg)
	Else ' An error of some sort occurred
		If job.Response.StatusCode = 204 Or job.Response.StatusCode = 404 Then
			Log("The Web API returned no centres available")
			xui.MsgboxAsync("There are no centres on the system.", "No Nearby Centres")
			DisplayAllCentres
		Else ' Any other error
			Log("An error occurred with the HTTP job: " & job.ErrorMessage)
			xui.MsgboxAsync("An error occurred while trying to get All centres.", "Cannot Get All Centres")
		End If
	End If
	job.Release ' Must always be called after the job is complete, to free its resources

End Sub

' Downloads a list of centres near to the specified location, and displays them on the listview. 
'  This invokes the location object to get centre information - (see handler for next stage in the process).
Private Sub DisplayNearbyCentres(pCurrentLocation As Location)
	ProgressShow("Finding centres close to you, please wait...")
	Log("Sending the coordinates to the Web API...")
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	'job.Download(modEposWeb.URL_CENTRE_API & "?lat=" & pCurrentLocation.Latitude & "&lon=" & pCurrentLocation.Longitude)'  & "&max=25")
'	Dim urlStr As String = modEposWeb.URL_CENTRE_API & _
'							"?" & modEposWeb.API_LATITUDE & "=" & pCurrentLocation.Latitude & _
'							"&" & modEposWeb.API_LONGITUDE & "=" & pCurrentLocation.Longitude
	Dim urlStr As String = Starter.server.URL_CENTRE_API & _
							"?" & modEposWeb.API_LATITUDE & "=" & pCurrentLocation.Latitude & _
							"&" & modEposWeb.API_LONGITUDE & "=" & pCurrentLocation.Longitude
	job.Download(urlStr)
	Wait For (job) JobDone(job As HttpJob)
	ProgressHide	
	If job.Success And job.Response.StatusCode = 200 Then
		Dim rxMsg As String = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)
		DisplayOnListview(rxMsg)
	Else ' An error of some sort occurred
		If job.Response.StatusCode = 204 Or job.Response.StatusCode = 404 Then
			Log("The Web API returned no nearby centres")
			xui.MsgboxAsync("There are no centres near your current location. All centres will now be displayed.", "No Nearby Centres")
			wait for MsgBox_result(tempResult As Int) '' inserted
			DisplayAllCentres 'TODO Check this out it appears to call itself!
		Else ' Any other error
			Log("An error occurred with the HTTP job: " & job.ErrorMessage)
			xui.MsgboxAsync("An error occurred while trying to find nearby centres. All centres will now be displayed.", "Cannot Get Nearby Centres")
			DisplayAllCentres 'TODO Check this out it appears to call itself!
		End If
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox",modEposApp.DFT_PROGRESS_TIMEOUT)
#if B4I
	centresDisplayed = False
#End If
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

' Restart Display new location timer
private Sub RestartDisplayNewLocationTimer
	allowCentreUpdate = False
	tmrDelayNewLocation.Enabled = False
	tmrDelayNewLocation.Enabled = True
End Sub

' Refreshes the list of centres.
private Sub RefreshCentreList
	SelectCentre
	clvCentres.ScrollToItem(0)	' Always move to top of list.
End Sub

' Show ChangeAccountInfo page.
private Sub ShowChangeAccountInfoPage
	#if B4A
		StartActivity(ChangeAccountInfo)	
	#else
		frmChangeAccountInfo.Show
	#End If
End Sub

' Show ChangeSettings page.
private Sub ShowChangeSettingsPage
#if B4A
	StartActivity(ChangeSettings)	
#else
	frmChangeSettings.Show
#End If
End Sub

' Show ValidateCentreSelection Page.
Private Sub ShowValidateCentreSelectionPage(centreDetails As clsEposWebCentreLocationRec )
#if B4A
	CallSubDelayed2(ValidateCentreSelection, "ValidateSelection", centreDetails)
#else
	frmXValidateCentreSelection.Show(centreDetails)
#End If
End Sub

#if B4i
' Start the locations updates
Private Sub StartLocationUpdates
	'if the user allowed us to use the location service or if we never asked the user before then we call LocationManager.Start.
	If LocManager.IsAuthorized Or LocManager.AuthorizationStatus = LocManager.AUTHORIZATION_NOT_DETERMINED Then
		LocManager.Start(0)
	Else
		tmrAutoStartDisplayCentres.Enabled = True ' Location device not working so use autoStart to invoke a list of centres.
	End If
End Sub
#End If

#if B4A

' Start location service
public Sub StartLocationService
	If mLocator.IsInitialized = False Then
		mLocator.Initialize("mLocator")
	End If
End Sub

' Added for tests on FusedLocationProvider
Public Sub StartLocationUpdates
'	If LocationUpdatesRunning = False And flp.IsConnected And rp.Check(rp.PERMISSION_ACCESS_FINE_LOCATION) Then
	If LocationUpdatesRunning = False And mLocator.IsConnected  Then
		LocationUpdatesRunning = True
		Log("Starting location updates")
		Dim request As LocationRequest
		request.Initialize
		request.SetPriority(request.Priority.PRIORITY_HIGH_ACCURACY)
		request.SetInterval(5000)
		request.SetFastestInterval(5000)
		mLocator.RequestLocationUpdates(request)
	End If
End Sub

' Update form with list of Centres.
Private Sub UpdateCentreList(newLocation As Location)
	Log("Successfully connected to location services. Getting last known location...")
	Dim lastLocation As Location = mLocator.GetLastKnownLocation
	If lastLocation.IsInitialized Then
		Log("New location – lat: " & lastLocation.Latitude & ", lon: " & lastLocation.Longitude)
		mLocator.Disconnect ' Must always do this otherwise it will drain the battery
		LocationUpdatesRunning = False
		DisplayNearbyCentres(newLocation)
	Else ' No last known location is available
		Log("No last known location is available.")
		xui.MsgboxAsync("Your current location is unavailable. All centres will now be displayed.", "Cannot Get Location")
		DisplayAllCentres
	End If
End Sub

#end if


#End Region  Local Subroutines

