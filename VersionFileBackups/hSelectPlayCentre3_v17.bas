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
	' Release...: 17
	' Date......: 03/02/21
	'
	' History
	' Date......: 02/08/20
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on hSelectPlayCentre2_v4.
	'
	' Versions
	'   2 - 8 see v9
	'
	' Date......: 26/11/20
	' Release...: 9
	' Overview..: Bugfix: Select Centre - not scrolling to top list after refresh.
 	' 			    Mod: Usage of null for strings and objects removed.
	' Amendee...: D Morris
	' Details...: Mod: DisplayCentreList() call to ScrollToItem() added.
	'		
	' Date......: 15/12/20
	' Release...: 10
	' Overview..: Bugfix: iOS not displaying centres correctly when only a few.
	' Amendee...: D Morris
	' Details...: Mod: DisplayCentreList() code excluded for B4i.
	'
	' Date......: 03/01/21
	' Release...: 11
	' Overview..: Bugfix: iOS not restarted when account information is cleared.
	' Amendee...: D Morris
	' Details...: Mod: ClearAccount() Code fixed.
	'		
	' Date......: 23/01/21
	' Release...: 12
	' Overview..: Maintenance release Update to latest standards for CheckAccountStatus and associated modules. 
	' Amendee...: D Morris
	' Details...: Mod: ClearAccount() calls to CheckAccountStatus changed to aCheckAccountStatus and xCheckAccountStatus.
	'
	' Date......: 27/01/21 
	' Release...: 13
	' Overview..: Mod: Progress indicated added to select centre operation.
	' Amendee...: D Morris
	' Details...: Mod: clvCentres_ItemClick().
	'
	' Date......: 28/01/21
	' Release...: 14
	' Overview..: Maintenance release - QueryNewInstall updated.
	' Amendee...: D Morris
	' Details...: Mod: NewAccount().
	'
	' Date......: 30/01/21
	' Release...: 15
	' Overview..: Support for renamed modules.
	' Amendee...: D Morris
	' Details...: Mod: Initialize(), imgAccount_Click(), IsVisible().
	'			  Mod: Prefixed 'p' and 'l' removed.
	'			  Mod: ShowAbout().
	'			  Mod: ShowValidateCentreSelectionPage().
	'			  Mod: ShowChangeAccountInfoPage().
	'			  Mod: ShowChangeSettingsPage().
	' 			  Mod: DisplayAllCentres() and GetNearbyCentres() now uses clsEposApiHelper.
	'
	' Date......: 31/01/21
	' Release...: 16
	' Overview..: Bugfix: Problems with calling Change settings, Change Account info.
	' Amendee...: D Morris.
	' Details...: Mod: ShowChangeSettingsPage().
	'			  Mod: ShowChangeAccountInfoPage().
	'
	' Date......: 03/02/21
	' Release...: 17
	' Overview..: General maintenance.
	' Amendee...: D Morris
	' Details...: Mod: Old commented code removed.
	'			  Added: Code to handle menu (moved from aSelectPlayCentre).
	'		      Mod: OnClose() - closes the dialog object. 
	'			  Mod: SelectCentre() permission result parameter removed.
	'             Rename: DisplayAllCentres() to GetAllCentres().
	'			  Rename: GetNearbyCentres() to GetNearbyCentres().
	'			  Rename: DisplayCentreList() to DisplayCentreList().
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 

#End Region  Documentation


#Region  Mandatory Subroutines & Data

Sub Class_Globals
	
	' Constants
	Private const CENTRE_OPEN	As String = "Open"		' Text to indicate centre is open.
	Private const CENTRE_CLOSED As String = "Closed"	' Text to Indicate centre is closed.
	Private Const DFT_DELAYNEWLOCATION As Int = 20000	' Default for initialise the tmrDelayNewLocation timer(msecs).
	
	Private xui As XUI									'ignore (to remove warning) -  Required for X platform operation.
	
	' Local variables	
	Private displayUpdateInProgress As Boolean			' Indicates updating the displayed Centre list is in-progress. 
	Private forceDisplayUpdate As Boolean				' When set location change will for display to update Centre List.

	' misc objects
	Private apiHelper As clsEposApiHelper				' API helper.
	Private locationDevice As clsLocation				' Device location.
	Private progressbox As clsProgress					' Progress indicator/box
	Private tmrDelayNewLocation As Timer				' Timer to limit how quickly the new location is used to search for centres.

#if B4A	
	Private saveParent As Activity						' Storage for the parent activity.
#else B4i
	Private saveParent As B4XView
#end if

#if B4A
	' For the option menu
	Private dialog As B4XDialog 						'ignore
	Private menuOptions As B4XListTemplate
#End If

	' View declarations
	Private clvCentres As CustomListView				' Custom listview used to show the list of centres available as options.
	Private imgAccount As B4XView 						' Account info button 
	Private imgLogo As B4XView							' Centre logo	
	Private imgRefresh As B4XView						' Refresh displayed centre list button (See pnlRefreshTouch).
	Private indLoading As B4XLoadingIndicator			' In progress indicator
	Private lblStatus As B4XView						' Centre status (open, closed etc)
	Private lblName As B4XView							' Centre name
	Private lblDistance As B4XView						' Distance
	Private pnlLoadingTouch As B4XView					' Clickable loading circles to show progress dialog.
	Private pnlRefreshTouch As B4XView					' Clickable refresh show progress dialog.
End Sub

'Initializes the object. You can add parameters to this method if needed.
'Public Sub Initialize (parent As B4XView)
#if B4A
Public Sub Initialize (parent As Activity)
	saveParent = parent
#else ' B4I
public Sub Initialize(parent As B4XView)
#End If	
	
#if b4A
	parent.LoadLayout("frmaSelectPlayCentre3")
#Else ' B4i
	parent.LoadLayout("frmXSelectPlayCentre3")
	Starter.lastPageShown = "xSelectPlayCentre3"	
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
		progressbox.Show("Getting selected centre please wait...")
		ShowValidateCentreSelectionPage(centreDetails)
	Else
		RefreshCentreList
	End If
End Sub

' Display accounts options
Private Sub imgAccount_Click
#if B4A
	ShowMenu
#else
	xSelectPlayCentre3.ShowActionMenu
#End If
End Sub

' Location ready (or timeout)
'  thisLocation() = 0,0 timoutoccurred. 
private Sub locationDevice_LocationReady(location1 As Location)
	Log("Location Changed: " & location1) 'ignore
	If forceDisplayUpdate Then
		forceDisplayUpdate = False
		SelectCentre		
	End If
End Sub

' Click on progress circles to show progress dialog box
Private Sub pnlLoadingTouch_Click
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
	SelectCentre
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
		StartActivity(aCheckAccountStatus)
#else ' B4I
		xCheckAccountStatus.show(False)
#End If
	End If
End Sub

' Change customer information
public Sub ChangeAccountInfo
	ShowChangeAccountInfoPage
End Sub

' Change operation settings
public Sub ChangeSettings
	ShowChangeSettingsPage
End Sub

' Show Create new account form
public Sub NewAccount
#if B4A
	StartActivity(aQueryNewInstall)
#else
	xQueryNewInstall.show
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
#if B4A
	If dialog.IsInitialized Then
		' See code snippets in https://www.b4x.com/android/forum/threads/b4x-xui-views-cross-platform-views-and-dialogs.100836/#content
		dialog.Close(xui.DialogResponse_Cancel)  ' Important - need to close it.		
	End If
#End If
End Sub

' Refrest the list of centres.
Public Sub Refresh
	RefreshCentreList
End Sub

#if B4i
Public Sub Resize(Width As Int, Height As Int)
'	If Dialog.Visible Then
'		Dialog.Resize(Width, Height)	
'	End If
End Sub
#End If

' Select Play Centre - This displays a list of nearby centres and allows the user to select a centre.
Public Sub SelectCentre
	If Not(displayUpdateInProgress) Then ' OK to update display?
		displayUpdateInProgress = True
		progressbox.Show("Finding centres close to you, please wait...")
		If locationDevice.IsLocationAvailable Then
			wait for (GetNearbyCentres(locationDevice.GetLocation)) complete(rxMsg As String)
		Else ' Location permission has been denied
#if B4A
			xui.MsgboxAsync("The fine location permission has been denied. All centres will now be displayed.", "Cannot Get Location")
#else ' B4i
			Dim msg As String = "This App will not run correctly without location permissions." & CRLF & _
				"You can goto settings and allow location for SuperOrder or."  & CRLF & _
				"remove and re-install the SuperOrder, then Allow location when asked."
			xui.Msgbox2Async(msg, "Location permission", "Settings", "Ok","", Null)
			Wait For Msgbox_Result (Result As Int)
			If Result = xui.DialogResponse_Positive Then
				Main.DisplaySettings
			End If
#End If ' End B4i			
			Wait For (GetAllCentres) complete(rxMsg As String)
		End If	
		If rxMsg <> "" Then
			wait for (DisplayCentreList(rxMsg)) complete(ok As Boolean)
		End If
		RestartDisplayNewLocationTimer 	' Do this after the information is displayed (to avoid calling before previous task is complete)
		progressbox.Hide
		displayUpdateInProgress = False ' Release the display for update.
	End If
End Sub

' Handle the selection of a menu item.
Public Sub SelectMenuItem(item As String)
	Select item
		Case "About"
	#if B4A
			StartActivity(aAbout)
	#else ' B4i
			xAbout.Show
	#End If
		Case "Edit Account"
			ChangeAccountInfo
		Case "New Account"
			NewAccount
		Case "Remove Account"
			ClearAccount
		Case "Settings"
			ChangeSettings
		Case "Show Location"
			ShowLocation
	End Select
End Sub

' Show about form
public Sub ShowAbout
#if B4A
	StartActivity(aAbout)
#Else
	xAbout.show
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

' Handle a menu items
#End Region  Public Subroutines

#Region  Local Subroutines

' See https://www.b4x.com/android/forum/threads/cards-list-with-customlistview.87720/#content
' Create a Panel item
Private Sub CreateItem(Width As Int, centre As clsEposWebCentreLocationRec, img As ImageView ) As Panel
	Dim p As B4XView = xui.CreatePanel("")
	Dim height As Int = 130dip
#if B4A
	' Required to look OK on Android tablets.
	Dim a As Float = GetDeviceLayoutValues.ApproximateScreenSize 
	If a > 6 Then
		height = 245dip
	End If
#End If
	p.SetLayoutAnimated(0, 0, 0, Width, height)
	p.LoadLayout("cardSelectCentreDetails2")
	If centre.centreOpen Then
		lblStatus.Text = CENTRE_OPEN
		lblStatus.TextColor = xui.Color_RGB(0,100,0) ' Don't get a good green if xui.Color_Green used!
	Else
		lblStatus.Text = CENTRE_CLOSED
		lblStatus.TextColor = xui.Color_Red
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

#if B4A
' Creates the menu options template (See C:\Projects\B4A_Dev\TestMenu for example of usage).
Private Sub CreateMenuTemplate
	dialog.Title = "Select option"
	menuOptions.Options = Array("Edit Account", "Settings", "New Account", _
									"Remove Account", "Show Location","About" )
	menuOptions.AllowMultiSelection = False
	menuOptions.MultiSelectionMinimum = 1
End Sub
#End If


' Display a list of centres.
' Parses the specified JSON string into centre details objects, and displays them on the listview.
'  Return displayListOk = true if all centres downloaded ok. 
Private Sub DisplayCentreList(inputJson As String) As ResumableSub
	Dim displayListOk As Boolean = True
	Dim jp As JSONParser	' Get all the centres out of the JSON and put them in a list
	jp.Initialize(inputJson)
	Dim centreList As List = jp.NextArray
	Dim centreInfoList As List : centreInfoList.Initialize	' First stage write centre info to memory
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
		centreInfo.imgPanel = CreateItem(clvCentres.AsView.Width, centreInfo.centre, img)
		centreInfoList.Add(centreInfo)
	Next
	clvCentres.Clear	' Second stage displays the information
	For Each centreInfoRec As clsCentreInfoAndImgRec In centreInfoList
		clvCentres.Add(centreInfoRec.imgPanel, centreInfoRec.centre)
	Next
	clvCentres.DefaultTextColor = Colors.White
#if B4A
	clvCentres.ScrollToItem(0)
#end if
	Dim noMoreCentres As clsEposWebCentreLocationRec
	noMoreCentres.id = 0 	' Indicates no more centres.
	clvCentres.AddTextItem(CRLF & "No more centres nearby", noMoreCentres)
	Return displayListOk
End Sub

' Gets a list of all centres.
'   returns rxMsg if download ok else null if error.
Private Sub GetAllCentres() As ResumableSub
	wait for (apiHelper.GetAllCentres) complete(rxMsg As String)
	Return rxMsg
End Sub

' Gets a list of nearby centres.
'  returns rxMsg if download ok else null if error.
Private Sub GetNearbyCentres(pCurrentLocation As Location) As ResumableSub
	wait for( apiHelper.GetNearbyCentres(pCurrentLocation)) complete (rxMsg As String)
	Return rxMsg
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
	progressbox.Show("Getting your location.")
	apiHelper.Initialize()
#if B4A
	dialog.Initialize(saveParent)
	menuOptions.Initialize
#End If
	tmrDelayNewLocation.Initialize("tmrDelayNewLocation", DFT_DELAYNEWLOCATION)
	displayUpdateInProgress = False
	locationDevice.Initialize(Me, "locationDevice")
End Sub

' Is this form shown
private Sub IsVisible As Boolean
#if B4A
	Return (CallSub(aSelectPlayCentre3, "IsVisible"))
#else ' B4i
	Return xSelectPlayCentre3.IsVisible
#End If
End Sub

' Restart Display new location timer
private Sub RestartDisplayNewLocationTimer
	tmrDelayNewLocation.Enabled = False
	If IsVisible = True Then
		tmrDelayNewLocation.Enabled = True
	End If
End Sub

' Refreshes the list of centres.
private Sub RefreshCentreList
	SelectCentre
End Sub


' Show ChangeAccountInfo page.
private Sub ShowChangeAccountInfoPage
#if B4A
	StartActivity(aChangeAccountInfo)
#else
	xChangeAccountInfo.Show
#End If
End Sub

' Show ChangeSettings page.
private Sub ShowChangeSettingsPage
#if B4A
	StartActivity(aChangeSettings)
#else
	xChangeSettings.Show
#End If
End Sub

' Show ValidateCentreSelection Page.
Private Sub ShowValidateCentreSelectionPage(centreDetails As clsEposWebCentreLocationRec )
#if B4A
	CallSubDelayed2(aValidateCentreSelection2, "ValidateSelection", centreDetails)
#else
	xValidateCentreSelection2.Show(centreDetails)
#End If
End Sub

#if B4A
' Show the Account menu
Private Sub ShowMenu
	CreateMenuTemplate
	Wait for (dialog.ShowTemplate(menuOptions, "", "", "CANCEL")) complete(result As Int)

	If result = xui.DialogResponse_Positive Then
		SelectMenuItem(menuOptions.SelectedItem)
	End If
End Sub
#End If


#End Region  Local Subroutines


