B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@

'
' This is a help class for ValidateCentreSelection2
'
#Region  Documentation
	'
	' Name......: hValidateCentreSelection2
	' Release...: 10
	' Date......: 15/12/20
	'
	' History
	' Date......: 02/08/20
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on hValidateCentreSelection_v21 First release to support version tracking.
	'
	' Versions
	'  2 - 8 see v9
	'		
	' Date......: 28/11/20
	' Release...: 9
	' Overview..: Issue: #0567 Download/sync menu now handled by the Validate centre activity.
	' Amendee...: D Morris
	' Details...:    Mod: ExitToSyncData() and renamed to ExitToCentreHomePage().
	'				 Mod: HandleConnectToServerResponse() and HandleOpenTabConfirmResponse() call ExitToCentreHomePage().
	'				 Mod: ExitToCentreHomePage() now calls Home activity/page.
	'		
	' Date......: 15/12/20
	' Release...: 10
	' Overview..: Issue: #0561(In-progress) only Viewing website information. 
	' Amendee...: D Morris
	' Details...:  Mod: Support for webView.
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
	Private xui As XUI											'ignore
	
	' Local varibles
	Private enableViews As Boolean								' When set views (controls) are enabled.
	
	' Local constants
	' NOTE on setting the timeout - If the customer is new to the centre, it needs extra time
	'  to add it to its database - (looks like over 10secs).
	Private Const DFT_CONNECTION_TIMEOUT As Int = 15000			' Connection timeout (mSecs).
	 
	' View declarations
	Private btnCancel As SwiftButton							' Cancel selection.
	Private btnSelect As SwiftButton							' Select centre button.
	Private btnWebClose As SwiftButton							' close web view button.
	Private imgAccount As B4XView 								' Account info button.
	Private imgCentrePicture As B4XView							' Holder for the center's picture.	
	Private imgHome As B4XView									' Home button ico.
	Private imgLogo As B4XView									' Centre logo.
	Private indLoading As B4XLoadingIndicator					' In progress indicator.
	Private lblAddress As Label									' Address of Centre.
	Private lblBackButton As Label								' Back button.
	Private lblCentreNAme As Label								' Name of the Centre.
	Private lblClosed As Label									' Closed label.
	Private lblDescription As Label								' Description of Centre.
	Private pnlLoadingTouch As B4XView							' Clickable loading circles to show progress dialog.
	Private lblMore As B4XView									' Hyperlink to display more centre information.
	Private pnlWeb As B4XView									' Web view panel
	Private web As WebView										' Web view	

	' misc objects
	Private progressbox As clsProgress							' Progress box.
	Private selectCentreDetails As clsEposWebCentreLocationRec	' Storage for selected centre.	
	Private tmrConnectToCentreTimout As Timer					' Connect to centre timeout.

End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
#if B4A
	parent.LoadLayout("frmValidateCentreSelection3")
#else
	parent.LoadLayout("frmXValidateCentreSelection3")
#End If
	InitializeLocals
End Sub
#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Customer rejects the Centre selected.
Sub btnCancel_Click()
	If enableViews = True Then
		ExitToSelectCentre		
	End If
End Sub

' Customer selects centre.
Sub btnSelect_Click()
	If enableViews = True Then
		Starter.myData.centre.name = selectCentreDetails.centreName
		Starter.myData.centre.postCode = selectCentreDetails.postCode
		Starter.myData.centre.picture = selectCentreDetails.picture
		ProgressShow("Connecting to centre, please wait...")
		StartSignOnToCentre		
	End If
End Sub

' Close web view.
Sub btnWebClose_Click
	pnlWeb.Visible = False
End Sub

' Connect to centre timout triggered
Sub ConnnectToCentreTimeout_tick
	ProgressHide
	tmrConnectToCentreTimout.Enabled = False
	xui.MsgboxAsync("Unable to communicate with the selected centre - please retry or select another centre.", "Timeout Error")
	wait for Msgbox_Result(result As Int)
	ExitToSelectCentre
End Sub

' Handle back button
private Sub lblBackButton_Click
	If enableViews = True Then
		ExitToSelectCentre		
	End If
End Sub

' Handles the More button
private Sub lblMore_Click
'	Dim centreUrl As String = selectCentreDetails.webSite
'	If Not (selectCentreDetails.webSite.StartsWith("http")) Then ' Prefix with http?
'		centreUrl =	"http://" & centreUrl
'	End If	
'#if B4A
'	Dim p As PhoneIntents
'
'	If selectCentreDetails.webSite <> "" Then
'		StartActivity(p.OpenBrowser(centreUrl))
'	Else
'		StartActivity(p.OpenBrowser("https://superord.co.uk/nocentredetailsavailable.html"))
'	End If
'#else ' B4i
'	If selectCentreDetails.website <> "" Then
'		Main.App.OpenURL(centreUrl)
'	Else
'		Main.App.OpenURL("https://" & "superord.co.uk/nocentredetailsavailable.html")
'	End If
'#End If
	HandleMoreInformation(True)
End Sub

' Click on the loading circle to show progress dialog.
Sub pnlLoadingTouch_Click
	progressbox.ShowDialog	
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Handles a response to the Sign-on (Connect to centre) sent with pValidateCentreSelect().
'  Invoked when starter receives the response.
public Sub HandleConnectToServerResponse(centreSignonOk As Boolean)
	If centreSignonOk Then
		wait for (WebSignedOntoCentre) complete (signonOk As Boolean)
		If signonOk Then
			ExitToCentreHomePage
		Else
			ExitToSelectCentre
		End If
	Else
		ExitToSelectCentre
	End If
End Sub

' Handle response to Open Tab confirm message
Public Sub HandleOpenTabConfirmResponse
	tmrConnectToCentreTimout.Enabled = False ' Stop the timeout timer
	wait for (WebSignedOntoCentre) complete (signonOk As Boolean)
	If signonOk Then
		ExitToCentreHomePage
	Else
		ExitToSelectCentre
	End If
End Sub

' Show/hide More information about centre.
Public Sub HandleMoreInformation(show As Boolean)
	If show Then
		Dim centreUrl As String = modEposWeb.URL_CENTRE_INFO_NOT_AVAILABLE
		If  selectCentreDetails.webSite <> "" Then
			centreUrl = selectCentreDetails.webSite
			If Not (centreUrl.StartsWith("http")) Then ' Prefix with http?
				centreUrl =	"http://" & centreUrl
			End If
		End If
		web.LoadUrl(centreUrl)		
	End If
	pnlWeb.Visible = show
	web.Visible = show
End Sub

' Main method.
' centreId is the selected centreId.
Public Sub MainValidateCentreSelection(centreDetails As clsEposWebCentreLocationRec)
	' TODO May new function to get more information about the centre (to establish ok for customer)
	selectCentreDetails = centreDetails	' update local copy of Centre information
	tmrConnectToCentreTimout.Enabled = False	' ensure timeout timer is stopped.
'	lblSelectedCentreDetails.Text = "You have selected Centre:" & CRLF & selectCentreDetails.centreName & CRLF & "Postcode:" &selectCentreDetails.postCode
	lblAddress.text = selectCentreDetails.postCode & ": " & modEposApp.GetFirstLine(selectCentreDetails.address) 
	lblCentreNAme.Text = selectCentreDetails.centreName
	lblDescription.Text = selectCentreDetails.description
	Dim img  As ImageView
	img.Initialize("test")
	Wait For (Starter.DownloadImage(centreDetails.picture, img)) complete(a As Boolean) ' Download and save centre picture.
	Dim bt As Bitmap = img.Bitmap
	Starter.myData.centre.pictureBitMap = bt
	imgCentrePicture.SetBitmap(bt.Resize(imgCentrePicture.Width, imgCentrePicture.Height, True))
	imgCentrePicture.Visible = True
	If selectCentreDetails.centreOpen Then
		btnSelect.mBase.Visible = True
		lblClosed.Visible = False
	Else
		btnSelect.mBase.Visible = False
		lblClosed.Visible = True
	End If
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	imgCentrePicture.Visible = False	' Clear out old image for next time.
	ProgressHide						' Just in-case.
	HandleMoreInformation(False)				
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Exits back to Select Centre - usually called when an error has occurred.
private Sub ExitToSelectCentre
	ProgressHide
	tmrConnectToCentreTimout.Enabled = False
	Starter.myData.centre.centreId = 0 	' This clears the centre information to it is not used after returning from Background
#if B4A
	StartActivity(aSelectPlayCentre3)
#else
	frmXSelectPlayCentre3.Show	
#End If
End Sub

' Exits to Home Page
private Sub ExitToCentreHomePage
	ProgressHide
	Starter.customerOrderInfo.tableNumber = 0
	tmrConnectToCentreTimout.Enabled = False
'#if B4A
'	CallSubDelayed(aSyncDatabase, "pSyncDataBase")
'#Else
'	xSyncDatabase.Show
'#End If
#if B4A
	StartActivity(aHome)
#else
	xHome.Show
#End If
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
	selectCentreDetails.Initialize
	tmrConnectToCentreTimout.Initialize("ConnnectToCentreTimeout", DFT_CONNECTION_TIMEOUT)
	ViewControl(True) ' Enable controls
	Private cs As CSBuilder
	cs.Initialize.Underline.Color(Colors.White).Append("View Website").PopAll
	lblMore.Text = cs
End Sub

' Hide the process box
Private Sub ProgressHide
	ViewControl(True)
	If progressbox.IsInitialized Then
		progressbox.Hide	
	End If
End Sub

' Show the process box.
Private Sub ProgressShow(message As String)
	ViewControl(False)
	progressbox.Show(message)
End Sub

' Invokes signon to centre operation - this sub invokes a series
'  of operations to connect the Phone to a Centre Server via the Web
Private Sub StartSignOnToCentre
	tmrConnectToCentreTimout.Enabled = False ' restart timeout.
	tmrConnectToCentreTimout.Enabled = True
#if B4A
	CallSub(Starter, "pConnectToServer")
#Else
	Main.ConnectToServer
#End If
End Sub

' Enable/disable controls.
Private Sub ViewControl( pEnableViews As Boolean)
	enableViews = pEnableViews
End Sub

' Informs the Web Server that this device has signed onto a centre.
Private Sub WebSignedOntoCentre As ResumableSub
	Dim signonSuccessful As Boolean = False
	
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	Dim urlStrg As String = Starter.server.URL_CUSTOMER_API & "/" & Starter.myData.customer.customerIdStr & _
								"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_SET_SIGNON & _
								"&" & modEposWeb.API_SETTING_1 & "=" & Starter.myData.centre.centreId & _
								"&" & modEposWeb.API_SETTING_2 & "=1"
	Dim jsonToSend As String = ""
	job.PutString(urlStrg, jsonToSend)
	job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		signonSuccessful = True
	End If
	job.Release
	Return signonSuccessful
End Sub
#End Region  Local Subroutines

