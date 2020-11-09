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
	' Release...: 7
	' Date......: 08/11/20
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
	' Details...: Mod: Code changed in DisplayOnListview().
	'		
	' Date......: 02/10/20
	' Release...: 4
	' Overview..: Bugfix: #0500 - Validate Centre screen not showing picture after communication timeout.
	' Amendee...: D Morris
	' Details...: Bugfix: clvCentres_ItemClick() updates Starter.selectedCentreLocationRec.
	'
	' Date......: 15/10/20
	' Release...: 5
	' Overview..: Bugfix: #0519 - Now periodically updates the Centre list.
	' Amendee...: D Morris
	' Details...:  Mod: LocManager_LocationChanged() and tmrDelayNewLocation_Tick().
	'	           Mod: RestartDisplayNewLocationTimer() check if page visible. 
	'
	' Date......: 02/11/20
	' Release...: 6
	' Overview..: Issue: #0529 GPS not always working at startup
	'			  Issue: #0530 Mixed up centre images.
	'			  Issue: #0536 Power comsumption - now will ensure location is off when not shown.  
	' Amendee...: D Morris
	' Details...: Mod: Constants added for timer values.
	' 			  Mod: Restructured code to wait for the download to complete before next download 
	'						DisplayAllCentres(), DisplayNearbyCentres() and DisplayOnListview return values.
	'			  Mod: SelectCentre() "wait for" inserted (to help with mixed up Centre images).
	'             Removed: lblMore_Click().
	'			  Mod: LocationDeviceOFF() is now private.
	'
	' Date......: 08/11/20
	' Release...: 7
	' Overview..: Issue: #0544 Slow screen rebuild after refresh.
	' Amendee...: D Morris
	' Details...: Mod: DisplayOnListview() code changed to split processing and rendering code.
	'			  Mod: SelectCentre() - now controls the progress indicator.
	'			  Mod: Progress indicator removed from DisplayNearbyCentres() and DisplayNearbyCentres()
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
	Private CENTRE_OPEN	As String = "Open"			' Text to indicate centre is open.
	Private CENTRE_CLOSED As String = "Closed"		' Text to Indicate centre is closed.

	Private DFT_DELAYNEWLOCATION As Int	= 20000		' Default for initialise the tmrDelayNewLocation timer(msecs).
	
	' X-platform related.
	Private xui As XUI								'ignore (to remove warning) -  Required for X platform operation.
	
	' Local variables	
	Private displayUpdateInProgress As Boolean		' Indicates updating the displayed Centre list is in-progress. 
	Private forceDisplayUpdate As Boolean			' When set location change will for display to update Centre List.

	' misc objects
	Private locationDevice As clsLocation	
	Private progressbox As clsProgress				' Progress box
	Private tmrDelayNewLocation As Timer			' Timer to limit how quickly the new location is used to search for centres.	
	
	' View declarations
	Private clvCentres As CustomListView		' Custom listview used to show the list of centres available as options.
	
	Private imgAccount As B4XView 				' Account info button 
	Private imgLogo As B4XView					' Centre logo	
	Private imgRefresh As B4XView				' Refresh displayed centre list button (See pnlRefreshTouch).
	Private indLoading As B4XLoadingIndicator	' In progress indicator

	Private lblStatus As B4XView				' Centre status (open, closed etc)
	Private lblName As B4XView					' Centre name
	Private lblDistance As B4XView				' Distance
	Private pnlLoadingTouch As B4XView			' Clickable loading circles to show progress dialog.
	Private pnlRefreshTouch As B4XView			' Clickable refresh show progress dialog.
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
#if b4A
	parent.LoadLayout("frmaSelectPlayCentre3")
#Else ' B4i
	parent.LoadLayout("frmXSelectPlayCentre3")
	Starter.lastPageShown = "frmXSelectPlayCentre3"	
#End If
	InitializeLocals
End Sub
#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the ItemClick event of the Centres listview.
Private Sub clvCentres_ItemClick (Position As Int, Value As Object)
	Dim centreDetails As clsEposWebCentreLocationRec = Value
	If centreDetails.id <> 0  Then ' Clicked on a valid entry in list?
		Starter.myData.centre.centreId = centreDetails.id
		Starter.ServerIP = centreDetails.lanIpAddress
		Starter.selectedCentreLocationRec = centreDetails
		ShowValidateCentreSelectionPage(centreDetails)
	Else
		RefreshCentreList
	End If
End Sub

' Display accounts options
Private Sub imgAccount_Click
#if B4A
	CallSubDelayed(aSelectPlayCentre3, "ShowMenu")
#else
	frmXSelectPlayCentre3.ShowActionMenu
#End If
End Sub

'' Handles refresh display button.
'Private Sub imgRefresh_Click
'	RefreshCentreList
'End Sub

' Location ready (or timeout)
'  thisLocation() = 0,0 timoutoccurred. 
private Sub locationDevice_LocationReady(location1 As Location)
	Log("Location Changed: " & location1) 'ignore
	If forceDisplayUpdate Then
		forceDisplayUpdate = False
		SelectCentre(True)		
	End If
End Sub

' Click on progress circles to show progress dialog box
Sub pnlLoadingTouch_Click
	progressbox.ShowDialog
End Sub

' Refresh list (touch area).
Private Sub pnlRefreshTouch_Click
	If displayUpdateInProgress And Not(progressbox.IsShown) Then ' Code to clear a sticky displayUpdateInProgress flag.
		displayUpdateInProgress = False 
	End If
	RefreshCentreList
End Sub

' Progress dialog has timed out.
Private Sub progressbox_Timeout()
	Log("hSelectPlayCentre - Progress dialog tripped!")
End Sub

' Handle delay display new location timer.
Private Sub tmrDelayNewLocation_Tick
	tmrDelayNewLocation.Enabled = False
	SelectCentre(True)
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Handles clear account option.
public Sub ClearAccount
	xui.Msgbox2Async("Are you sure you want to clear the account information stored on this phone?", "Clear Account Information", "Yes", "No", "", Null)
	wait for Msgbox_Result(result As Int)
	If result = xui.DialogResponse_Positive Then
		Starter.myData.Clear						' Clear customer data
		Starter.myData.Delete
		Starter.customerInfoAvailable = False
		Starter.settings.SaveDefaults				' Setting back to default
#if B4A
		StartActivity(CheckAccountStatus)
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
	If progressbox.IsInitialized = True Then
		progressbox.Hide		' Just in-case.
	End If
	If locationDevice.IsInitialized Then
		locationDevice.Stop		
	End If
' removed this line because it caused problem with displaying centre list.
'	displayUpdateInProgress = False ' TODO to try to do this another way. There is a temporary fix in pnlRefreshTouch_Click().
End Sub

' Refrest the list of centres.
Public Sub Refresh
	RefreshCentreList
End Sub

' Select Play Centre - This displays a list of nearby centres and allows the user to select a centre.
Public Sub SelectCentre(permissionResult As Boolean)
	If Not(displayUpdateInProgress) Then ' OK to update display?
		displayUpdateInProgress = True
		progressbox.Show("Finding centres close to you, please wait...")
#if B4A
		If locationDevice.IsLocationAvailable Then
			' DisplayNearbyCentres(currentLocation)
			wait for (DisplayNearbyCentres(locationDevice.GetLocation)) complete(rxMsg As String)
		Else ' Location permission has been denied
			xui.MsgboxAsync("The fine location permission has been denied. All centres will now be displayed.", "Cannot Get Location")
			' DisplayAllCentres
			Wait For (DisplayAllCentres) complete(rxMsg As String)	
		End If	
#else ' B4i
		If locationDevice.IsLocationAvailable Then
			' DisplayNearbyCentres(currentLocation)
			wait for (DisplayNearbyCentres(locationDevice.GetLocation)) complete(rxMsg As String)
		Else ' Location permission has been denied
			Dim msg As String = "This App will not run correctly without location permissions." & CRLF & _
				"You can goto settings and allow location for SuperOrder or."  & CRLF & _
				"remove and re-install the SuperOrder, then Allow location when asked."
			xui.Msgbox2Async(msg, "Location permission", "Settings", "Ok","", Null)
			Wait For Msgbox_Result (Result As Int)
			If Result = xui.DialogResponse_Positive Then
				Main.DisplaySettings
			End If
			'DisplayAllCentres
			Wait For (DisplayAllCentres) complete(rxMsg As String)
		End If
#End If ' End B4i	
		If rxMsg <> Null Then
			wait for (DisplayOnListview(rxMsg)) complete(ok As Boolean)
		End If
		RestartDisplayNewLocationTimer 	' Do this after the information is display (to avoid calling before previous task is complete)
		progressbox.Hide
		displayUpdateInProgress = False ' Release the display for update.
	End If
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
	Dim loc As Location = locationDevice.GetLocation
	locationString = "LAT:" & loc.Latitude & CRLF & "LONG:" & loc.Longitude
	xui.MsgboxAsync(locationString, "Location")
	wait for MsgBox_result(tempResult As Int)
End Sub

' Start the locations updates
Public Sub StartLocationUpdates
	forceDisplayUpdate = True
	locationDevice.Start
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
	Dim bt As Bitmap
	bt = img.Bitmap
	imgLogo.SetBitmap(bt.Resize(imgLogo.Width, imgLogo.Height, True))
	Return p
End Sub

' Parses the specified JSON string into centre details objects, and displays them on the listview.
'  Return displayListOk = true if all centres downloaded ok. 
Private Sub DisplayOnListview(inputJson As String) As ResumableSub
	Dim displayListOk As Boolean = True
	' Get all the centres out of the JSON and put them in a list
	Dim jp As JSONParser
	jp.Initialize(inputJson)
	Dim centreList As List = jp.NextArray
	' Loop to convert each centre details object to a clsEposWebCentreLocationRec and add it to the listview
'	clvCentres.Clear	' clear previously displayed information.
'	For Each centreDetailsMap As Map In centreList
'		Dim centre As clsEposWebCentreLocationRec
'		centre.address = centreDetailsMap.Get("address")
'		centre.centreName = centreDetailsMap.Get("centreName")
'		centre.centreopen = centreDetailsMap.Get("centreOpen")
'		centre.description = centreDetailsMap.Get("description")
'		centre.distance = centreDetailsMap.GetDefault("distance", modEposApp.CENTRE_DISTANCE_UNKNOWN)
'		centre.id = centreDetailsMap.Get("id")
'		centre.lanIpAddress = centreDetailsMap.Get("lanIpAddress")
'		centre.picture = centreDetailsMap.Get("picture")
'		centre.postCode = centreDetailsMap.Get("postCode")
'		centre.thumbnail = centreDetailsMap.Get("thumbnail")
'		centre.webSite = centreDetailsMap.Get("website")
'		Dim img  As ImageView
'		img.Initialize("test")
'		Wait For (Starter.DownloadImage(centre.picture, img)) complete(downloadOk As Boolean)
'		If downloadOk = True Then
'			clvCentres.Add(CreateItem(clvCentres.AsView.Width, centre, img), centre)
'		Else
'			displayListOk = False
'		End If
'	Next

	' First stage write centre info to memory
	Dim centreInfoList As List : centreInfoList.Initialize
	For Each centreDetailsMap As Map In centreList
		Dim centreInfo As clsCentreInfoAndImgRec : centreInfo.Initialize
		centreInfo.centre.address = centreDetailsMap.Get("address")
		centreInfo.centre.centreName = centreDetailsMap.Get("centreName")
		centreInfo.centre.centreopen = centreDetailsMap.Get("centreOpen")
		centreInfo.centre.description = centreDetailsMap.Get("description")
		centreInfo.centre.distance = centreDetailsMap.GetDefault("distance", modEposApp.CENTRE_DISTANCE_UNKNOWN)
		centreInfo.centre.id = centreDetailsMap.Get("id")
		centreInfo.centre.lanIpAddress = centreDetailsMap.Get("lanIpAddress")
		centreInfo.centre.picture = centreDetailsMap.Get("picture")
		centreInfo.centre.postCode = centreDetailsMap.Get("postCode")
		centreInfo.centre.thumbnail = centreDetailsMap.Get("thumbnail")
		centreInfo.centre.webSite = centreDetailsMap.Get("website")
		Dim img  As ImageView
		img.Initialize("test")
		Wait For (Starter.DownloadImage( centreInfo.centre.picture, img)) complete(downloadOk As Boolean)
'		If downloadOk = True Then
			centreInfo.imgPanel = CreateItem(clvCentres.AsView.Width, centreInfo.centre, img)
			centreInfoList.Add(centreInfo)
'		End If	
	Next
	' Second stage displays the information
	clvCentres.Clear	' clear previously displayed information.
	' Hide the customerListView to stop it jumping when refreshed.
'	clvCentres.AsView.Visible = False ' See https://www.b4x.com/android/forum/threads/moving-or-hiding-a-customlistview.36861/
	For Each centreInfoRec As clsCentreInfoAndImgRec In centreInfoList
		clvCentres.Add(centreInfoRec.imgPanel, centreInfoRec.centre)
		' Sleep(100) ' This appears to cause problems if switching quick between list centres and centre confirmation pages. 		
	Next
	clvCentres.DefaultTextColor = Colors.White
	Dim noMoreCentres As clsEposWebCentreLocationRec
	noMoreCentres.id = 0 	' Indicates no more centres.
	clvCentres.AddTextItem(CRLF & "No more centres nearby", noMoreCentres)
'	clvCentres.AsView.Visible = True
	Return displayListOk
End Sub

'' Downloads the list of all centres from the Web API and displays them on the listview.
' Downloads a list of all centres.
'   returns rxMsg if download ok else null if error.
Private Sub DisplayAllCentres() As ResumableSub
	Dim rxMsg As String = Null	
'	ProgressShow("Getting a list of all centres, please wait...")
	Log("Request the Web API to give list of all centres...")
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	Dim urlStr As String = 	Starter.server.URL_CENTRE_API & _
	"?" & modEposWeb.API_LATITUDE & "=" & modEposWeb.API_GET_ALL & _
									"&" & modEposWeb.API_LONGITUDE & "=" & modEposWeb.API_GET_ALL					
	job.Download(urlStr)
	Wait For (job) JobDone(job As HttpJob)
'	ProgressHide
	If job.Success And job.Response.StatusCode = 200 Then
		' 		Dim rxMsg As String = job.GetString
		rxMsg = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)
		'	DisplayOnListview(rxMsg)
	Else ' An error of some sort occurred
		If job.Response.StatusCode = 204 Or job.Response.StatusCode = 404 Then
			Log("The Web API returned no centres available")
			xui.MsgboxAsync("There are no centres on the system.", _ 
								"No Nearby Centres" & "Error:" & job.Response.StatusCode)
	'		DisplayAllCentres 'TODO Check this out it appears to call itself!
		Else ' Any other error
			Log("An error occurred with the HTTP job: " & job.ErrorMessage)
			xui.MsgboxAsync("An error occurred while trying to get All centres.", _
								"Cannot Get All Centres" & "Error:" & job.Response.StatusCode)
		End If
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
	Return rxMsg
End Sub

' Downloads a list of nearby centres.
'  returns rxMsg if download ok else null if error.
Private Sub DisplayNearbyCentres(pCurrentLocation As Location) As ResumableSub
	Dim rxMsg As String = Null
'	ProgressShow("Finding centres close to you, please wait...")
	Log("Sending the coordinates to the Web API...")
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	Dim urlStr As String = Starter.server.URL_CENTRE_API & _
	"?" & modEposWeb.API_LATITUDE & "=" & pCurrentLocation.Latitude & _
							"&" & modEposWeb.API_LONGITUDE & "=" & pCurrentLocation.Longitude & _
							"&" & modEposWeb.API_MAX_LIMIT & "=" & Starter.settings.maxCentres & _
							"&" & modEposWeb.API_SEARCH_RADIUS & "=" & Starter.settings.searchRadius 	
	If Starter.settings.showTestCentres = True Then ' Include Test Centres?
		urlStr = urlStr & "&" & modEposWeb.API_SHOW_TEST_CENTRES & "=1"
	End If
	job.Download(urlStr)
	Wait For (job) JobDone(job As HttpJob)
'	ProgressHide
	If job.Success And job.Response.StatusCode = 200 Then
		' Dim rxMsg As String = job.GetString
		rxMsg = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)
		' DisplayOnListview(rxMsg)
	Else ' An error of some sort occurred
		If job.Response.StatusCode = 204 Or job.Response.StatusCode = 404 Then
			Log("The Web API returned no nearby centres")
			xui.MsgboxAsync("There are no centres near your current location. All centres will now be displayed.", _
								"No Nearby Centres" & "Error:" & job.Response.StatusCode)
			wait for MsgBox_result(tempResult As Int) '' inserted
		'	DisplayAllCentres 'TODO Check this out it appears to call itself!
		Else ' Any other error
			Log("An error occurred with the HTTP job: " & job.ErrorMessage)
			xui.MsgboxAsync("An error occurred while trying to find nearby centres. All centres will now be displayed.", _
								 "Cannot Get Nearby Centres" & "Error:" & job.Response.StatusCode)
		'	DisplayAllCentres 'TODO Check this out it appears to call itself!
		End If
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
	Return rxMsg
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
	progressbox.Show("Getting your location.")
	tmrDelayNewLocation.Initialize("tmrDelayNewLocation", DFT_DELAYNEWLOCATION)
'	tmrLockDisplayUpdTimeout.Initialize("tmrLockDisplayUpdTimeout", DFT_LOCKDISPLAYUPD_TIMEOUT)
	displayUpdateInProgress = False
	locationDevice.Initialize(Me, "locationDevice")
'	progressbox.Initialize(Me, "progressbox",modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
End Sub

' Is this form shown
private Sub IsVisible As Boolean
#if B4A
	Return (CallSub(aSelectPlayCentre3, "IsVisible"))
#else ' B4i
	Return frmXSelectPlayCentre3.IsVisible
#End If
End Sub

'' Show the process box
'Private Sub ProgressHide
'	progressbox.Hide
'End Sub

'' Hide The process box.
'Private Sub ProgressShow(message As String)
'	progressbox.Show(message)
'End Sub

' Restart Display new location timer
private Sub RestartDisplayNewLocationTimer
	tmrDelayNewLocation.Enabled = False
	If IsVisible = True Then
		tmrDelayNewLocation.Enabled = True
	End If
End Sub

' Refreshes the list of centres.
private Sub RefreshCentreList
	SelectCentre(True)
'	clvCentres.ScrollToItem(0)	' Always move to top of list.
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

#End Region  Local Subroutines


