B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
'
' This is a help class for SelectPlayCentre2 (suport for centre logos)
'
#Region  Documentation
	'
	' Name......: hSelectPlayCentre3
	' Release...: 3
	' Date......: 09/08/20
	'
	' History
	' Date......: 02/08/20
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on hSelectPlayCentre2_v4.
	'
	' Date......: 08/08/20
	' Release...: 2
	' Overview..: Old commented code removed.
	' Amendee...: D Morris
	' Details...:  Mod: Old comments removed - no code changed.
	'
	' Date......: 09/08/20
	' Release...: 3
	' Overview..: Colour of "No more centres nearby" changed.
	' Amendee...: D Morris
	' Details...: Mod: Code changed in DisplayOnListview()
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
	Private CENTRE_OPEN	As String = "Open"		' Text to indicate centre is open.
	Private CENTRE_CLOSED As String = "Closed"	' Text to Indicate centre is closed.
	
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
	'Private progressbox As clsProgressDialog
	Private progressbox As clsProgressIndicator	' Progress box
	
	' View declarations
	Private clvCentres As CustomListView		' Custom listview used to show the list of centres available as options.
	
	Private imgAccount As B4XView 				' Account info button 
	Private imgLogo As B4XView					' Centre logo	
	Private imgRefresh As B4XView				' Refresh displayed centre list button.
	Private indLoading As B4XLoadingIndicator	' In progress indicator

	Private lblStatus As B4XView				' Centre status (open, closed etc)
	Private lblName As B4XView					' Centre name
	Private lblDistance As B4XView				' Distance
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
#if b4A
	parent.LoadLayout("frmaSelectPlayCentre3")
#Else
	parent.LoadLayout("frmXSelectPlayCentre3")
#End If
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
Private Sub imgRefresh_Click
	RefreshCentreList
End Sub

' Handles the ItemClick event of the Centres listview.
Private Sub clvCentres_ItemClick (Position As Int, Value As Object)
	Dim centreDetails As clsEposWebCentreLocationRec = Value
	If centreDetails.id <> 0  Then ' Clicked on a valid entry in list?
		Starter.myData.centre.centreId = centreDetails.id
		Starter.ServerIP = centreDetails.lanIpAddress
		ShowValidateCentreSelectionPage(centreDetails)
	Else
		RefreshCentreList
	End If
End Sub

' Display accounts options
PRivate Sub imgAccount_Click
#if B4A
	CallSubDelayed(aSelectPlayCentre3, "ShowMenu")
#else
	frmXSelectPlayCentre3.ShowActionMenu
#End If
End Sub

' Handles the More button
private Sub lblMore_Click
	Dim Index As Int = clvCentres.GetItemFromView(Sender)
	Log($"Action 1 clicked. Index: ${Index}"$)
	Dim centreDetails As clsEposWebCentreLocationRec = clvCentres.GetValue(Index)
#if B4A
	Dim p As PhoneIntents
	If centreDetails.webSite <> "" Then
		StartActivity(p.OpenBrowser("http://" & centreDetails.webSite))
	Else
		StartActivity(p.OpenBrowser("http://" & "superord.co.uk/nocentredetailsavailable.html"))
	End If
#else ' B4i
	If centreDetails.website <> "" Then
		Main.App.OpenURL("http://" & centreDetails.webSite)
	Else
		Main.App.OpenURL("http://" & "superord.co.uk/nocentredetailsavailable.html")
	End If
#End If

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
				SelectCentre(True)							
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
	SelectCentre(True)
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

' Refrest the list of centres.
Public Sub Refresh
	RefreshCentreList
End Sub

' (Main entry sub) Select Play Centre - This displays a list of nearby centres and allows the user to select a centre.
' 
Public Sub SelectCentre(permissionResult As Boolean)
	RestartDisplayNewLocationTimer
#if B4A
	If mLocator.IsInitialized Then ' Help to handle the bug #0180 Starting GPS
		mLocator.Disconnect
	End If
	If permissionResult Then ' Permission has been granted to use the location services
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


' See https://www.b4x.com/android/forum/threads/cards-list-with-customlistview.87720/#content
' Create a Panel item
Private Sub CreateItem(Width As Int, centre As clsEposWebCentreLocationRec, img As ImageView ) As Panel
	Dim p As B4XView = xui.CreatePanel("")
	Dim height As Int = 130dip
'	If GetDeviceLayoutValues.ApproximateScreenSize < 4.5 Then
'		height = 310dip
'	End If
	p.SetLayoutAnimated(0, 0, 0, Width, height)
	p.LoadLayout("cardSelectCentreDetails2")
	If centre.centreOpen Then
		lblStatus.Text = CENTRE_OPEN
		lblStatus.TextColor = xui.Color_RGB(0,100,0)
	Else
		lblStatus.Text = CENTRE_CLOSED
		lblStatus.TextColor = Colors.Red
	End If
	Dim processedName As String = centre.centreName
	If processedName.Length > 32 Then
		processedName = processedName.SubString2(0, 30)
	End If
	lblName.Text = processedName
	Dim c As clsEposWebCentreLocationRec: c.initialize()
	lblDistance.text = c.ConvertDistanceToString(centre.distance)
'#if B4A 
'	SetColorStateList(lblMore, xui.Color_LightGray, lblMore.TextColor)
'#else ' B4I
'	' TODO
'#End If
	Dim bt As Bitmap
	bt = img.Bitmap
	imgLogo.SetBitmap(bt.Resize(imgLogo.Width, imgLogo.Height, True))
	Return p
End Sub

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
		centre.address = centreDetailsMap.Get("address")
		centre.centreName = centreDetailsMap.Get("centreName")
		centre.centreopen = centreDetailsMap.Get("centreOpen")
		centre.description = centreDetailsMap.Get("description")
		centre.distance = centreDetailsMap.GetDefault("distance", modEposApp.CENTRE_DISTANCE_UNKNOWN)
		centre.id = centreDetailsMap.Get("id")
		centre.lanIpAddress = centreDetailsMap.Get("lanIpAddress")
		centre.picture = centreDetailsMap.Get("picture")
		centre.postCode = centreDetailsMap.Get("postCode")
		centre.thumbnail = centreDetailsMap.Get("thumbnail")
		centre.webSite = centreDetailsMap.Get("website")
		Dim img  As ImageView
		img.Initialize("test")
		'TODO Need check if something wrong with the download?
		' Wait For (Starter.DownloadImage(centre.thumbnail, img)) complete(a As Boolean)
		Wait For (Starter.DownloadImage(centre.picture, img)) complete(a As Boolean)
		clvCentres.Add(CreateItem(clvCentres.AsView.Width, centre, img), centre)
	Next
	clvCentres.DefaultTextColor = Colors.White
	Dim noMoreCentres As clsEposWebCentreLocationRec
	noMoreCentres.id = 0 	' Indicates no more centres.
	clvCentres.AddTextItem(CRLF & "No more centres nearby", noMoreCentres)
End Sub

' Downloads the list of all centres from the Web API and displays them on the listview.
Private Sub DisplayAllCentres
	ProgressShow("Getting a list of all centres, please wait...")
	Log("Request the Web API to give list of all centres...")
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
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
	progressbox.Initialize(Me, "progressbox",modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
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
'	progressbox.Show(message)
	progressbox.Show
End Sub

' Restart Display new location timer
private Sub RestartDisplayNewLocationTimer
	allowCentreUpdate = False
	tmrDelayNewLocation.Enabled = False
	tmrDelayNewLocation.Enabled = True
End Sub

' Refreshes the list of centres.
private Sub RefreshCentreList
	SelectCentre(True)
	clvCentres.ScrollToItem(0)	' Always move to top of list.
End Sub

#if B4A 
'' See https://www.b4x.com/android/forum/threads/cards-list-with-customlistview.87720/#content
'Private Sub SetColorStateList(Btn As Label,Pressed As Int,Enabled As Int)
'	Dim States(2,1) As Int
'	States(0,0) = 16842919    'Pressed
'	States(1,0) = 16842910    'Enabled
'	Dim CSL As JavaObject
'	CSL.InitializeNewInstance("android.content.res.ColorStateList",Array(States,Array As Int(Pressed, Enabled)))
'	Dim B1 As JavaObject = Btn
'	B1.RunMethod("setTextColor",Array As Object(CSL))
'End Sub
#End If

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
	CallSubDelayed2(ValidateCentreSelection2, "ValidateSelection", centreDetails)
#else
	frmXValidateCentreSelection2.Show(centreDetails)
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
'		request.SetFastestInterval(5000)
		request.SetSmallestDisplacement(1) ' Set minimum displacement to 1M.
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

