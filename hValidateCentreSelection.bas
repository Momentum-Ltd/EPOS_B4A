B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@

'
' This is a help class for ValidateCentreSelection
'
#Region  Documentation
	'
	' Name......: hValidateCentreSelection
	' Release...: 21
	' Date......: 17/07/20
	'
	' History
	' Date......: 03/08/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking.
	'
	' Versions v2 - 8 see v9.
	'          v9 - 17 see v20
	'
	' Date......: 18/06/20
	' Release...: 18
	' Overview..: Add #0395: Select Centre with Logos (Experimental).
	' Amendee...: D Morris.
	' Details...:    Mod: lExitBackToSelectCentre() code to support image versions of activities.
	'				 Mod: Initialize() handles both image and normal forms.
	'			   Added: Handles imgCentrePicture.
	'				 Mod: MainValidateCentreSelection() displays the centre's picture.
	'
	' Date......: 22/06/20
	' Release...: 19
	' Overview..: Add #0395 Select centre pictures (experimental - images changed to "your business")
	' Amendee...: D Morris
	' Details...:    Mod: MainValidateCentreSelection().
	'
	' Date......: 28/06/20
	' Release...: 20
	' Overview..: Add #0395 Select centre pictures (More work to download from Web Server).
	' Amendee...: D Morris
	' Details...:    Mod: MainValidateCentreSelection(), btnYes_Click().
	'
	' Date......: 17/07/20
	' Release...: 21
	' Overview..: Start on new UI theme (First phase changing buttons to Orange with rounded corners.. 
	' Amendee...: D Morris.
	' Details...: Mod: Buttons changed to swiftbuttons.
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
	Private xui As XUI			'ignore
	
	' Local constants
	' NOTE on setting the timeout - If the customer is new to the centre, it needs extra time 
	'  to add it to its database - (looks like over 10secs).  
	Private Const DFT_CONNECTION_TIMEOUT As Int = 15000			' Connection timeout (mSecs).
	 
	' View declarations
'	Private btnNo As B4XView									'ignore Confirm wrong centre selected button
'	Private btnYes As B4XView									'ignore Confirm correct centre selected
	Private btnNo As SwiftButton									'ignore Confirm wrong centre selected button
	Private btnYes As SwiftButton									'ignore Confirm correct centre selected
#if CENTRE_LOGOS
	Private imgCentrePicture As B4XView							' Holder for the center's picture.
#End If
	Private lblInstructions As B4XView							'ignore Instructions about accepting the centre selection.
	Private lblSelectedCentreDetails As B4XView					'ignore Selected centre details
	
	' misc objects
	Private progressbox As clsProgressDialog
	Private tmrConnectToCentreTimout As Timer					' Connect to centre timeout.
	Private selectCentreDetails As clsEposWebCentreLocationRec	' Storage for selected centre.
		
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
#if B4A
	#if CENTRE_LOGOS
	parent.LoadLayout("frmValidateCentreSelection2")
	#else
	parent.LoadLayout("frmValidateCentreSelection")	
	#End If
#else
	#if CENTRE_LOGOS
	parent.LoadLayout("frmXValidateCentreSelection2")
	#else
	parent.LoadLayout("frmXValidateCentreSelection")	
	#End If
#End If
	InitializeLocals
'	lXSelectPlayCentre
End Sub
#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Customer rejects the Centre selected.
Sub btnNo_Click()
	lExitBackToSelectCentre
End Sub

' Customer accepts Centre selection.
Sub btnYes_Click()
	Starter.myData.centre.name = selectCentreDetails.centreName
	Starter.myData.centre.postCode = selectCentreDetails.postCode
	Starter.myData.centre.picture = selectCentreDetails.picture
	ProgressShow("Connecting to centre, please wait...")
	lStartSignOnToCentre
End Sub

' Connect to centre timout triggered
Sub ConnnectToCentreTimeout_tick
	ProgressHide
	tmrConnectToCentreTimout.Enabled = False
	xui.MsgboxAsync("Unable to communicate with the selected centre - please retry or select another centre.", "Timeout Error")
	wait for Msgbox_Result(result As Int)
	lExitBackToSelectCentre
End Sub
#End Region  Event Handlers

#Region  Public Subroutines

' Handles a response to the Sign-on (Connect to centre) sent with pValidateCentreSelect().
'  Invoked when starter receives the response.
public Sub HandleConnectToServerResponse(centreSignonOk As Boolean)
'	Dim outputXml As String = CallSub(Starter, "BuildEposCustomerDetailsXml")
'	Dim msg As String = modEposApp.EPOS_OPENTAB_CONFIRM & outputXml
'	tmrConnectToCentreTimout.Enabled = False ' restart the timeout timer
'	tmrConnectToCentreTimout.Enabled = True
'#if B4A
'	CallSub2(Starter, "pSendMessage", msg) ' Send Opentab Confirm message
'#Else
'	Main.SendMessage(msg) ' Send Opentab Confirm message
'#End If

	If centreSignonOk Then
		wait for (lWebSignedOntoCentre) complete (signonOk As Boolean)
		If signonOk Then
			lExitToSyncData
		Else
			lExitBackToSelectCentre
		End If		
	Else
		lExitBackToSelectCentre
	End If
End Sub

' Handle response to Open Tab confirm message
Public Sub HandleOpenTabConfirmResponse
	tmrConnectToCentreTimout.Enabled = False ' Stop the timeout timer
	wait for (lWebSignedOntoCentre) complete (signonOk As Boolean)
	If signonOk Then
		lExitToSyncData
	Else
		lExitBackToSelectCentre
	End If
End Sub

' Main method.
' centreId is the selected centreId.
Public Sub MainValidateCentreSelection(centreDetails As clsEposWebCentreLocationRec) 
	' TODO May new function to get more information about the centre (to establish ok for customer)
	selectCentreDetails = centreDetails	' update local copy of Centre information
	tmrConnectToCentreTimout.Enabled = False	' ensure timeout timer is stopped.
	lblSelectedCentreDetails.Text = "You have selected Centre:" & CRLF & selectCentreDetails.centreName & CRLF & "Postcode:" &selectCentreDetails.postCode
	Dim checkOkForCentreReponse As String = lCustomerOkForCentre(centreDetails) ' Customer allowed to use this centre
	If checkOkForCentreReponse = "OK" Then	
'		' Code removed until the ping server is supported.
'		If lCheckWifiPingServer(selectCentreDetails.lanIpAddress) = False Then ' Check if located in centre
'			lblSelectedCentreDetails.Text = lblSelectedCentreDetails.Text & CRLF & "Unable to verify using WIFI"
'			lblSelectedCentreDetails.Text = lblSelectedCentreDetails.Text & CRLF & "Are you sure."
'		End If
		

'		If centreDetails.id = 55 Then
'			imgCentrePicture.SetBitmap(xui.LoadBitmapResize(File.DirAssets, "momentumoffices_001.jpg", imgCentrePicture.Width, imgCentrePicture.Height, True))
'		Else
'			imgCentrePicture.SetBitmap(xui.LoadBitmapResize(File.DirAssets, "orderandpayapp.jpg", imgCentrePicture.Width, imgCentrePicture.Height, True))
'		End If
		Dim img  As ImageView
		img.Initialize("test")
		Wait For (Starter.DownloadImage(centreDetails.picture, img)) complete(a As Boolean)
		Dim bt As Bitmap = img.Bitmap
		imgCentrePicture.SetBitmap(bt.Resize(imgCentrePicture.Width, imgCentrePicture.Height, True))
		btnNo.mBase.Visible = True ' Wait for customer to confirm or reject centre.
		btnYes.mBase.Visible = True
	Else 
		lblSelectedCentreDetails.Text = lblSelectedCentreDetails.Text & CRLF & "Unable to select" & CRLF & "Reason:" & checkOkForCentreReponse
		xui.MsgboxAsync(lblSelectedCentreDetails.Text, "Invalid Centre Selection")
		wait for Msgbox_Result(result As Int)
		lExitBackToSelectCentre
	End If	
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then
		ProgressHide		' Just in-case.
	End If
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Checks if Customer is ok to place orders at the selected centre
' Returns reason as text "OK" Means it is ok to select.
Private Sub lCustomerOkForCentre(centreDetails As clsEposWebCentreLocationRec) As String
	Dim resultMsg As String
	' Currently only checks if centre is open for business
	If centreDetails.centreOpen Then
		resultMsg = "OK"
	Else
		resultMsg = "Centre is CLOSED!"
	End If
	Return resultMsg
End Sub

'' Checks if Centre Server is available (using a Ping)
'' Problem with pPingAddress() when trying to detect a local Centre Server on he LAN.
''  until fixed this will always return false.
'private Sub lCheckWifiPingServer(lanIpAddress As String) As Boolean
'#if B4A
''	' This really EPOS ping (which will also check if the Centre server is running the App) - see clsConnect for ideas using EPOS Ping.
''	Dim diff As Int = Starter.connect.pPingAddress(lanIpAddress)
''	Dim found As Boolean = False
''	If diff < 5000 Then
''		found = True
''	End If
''	Return found
'	' See not in header.
''	Return False	' until pPingAddress() fixed.	
'	Dim centreServerOnWifi As Boolean = False
'	If Starter.connect.IsServerAvailableOnWifi Then
'		centreServerOnWifi = True
'	End If
'	Return centreServerOnWifi
'#else ' B4A
'	Return False
'#End If
'End Sub

' Exits back to Select Centre - usually called when an error has occurred.
private Sub lExitBackToSelectCentre
	ProgressHide
	tmrConnectToCentreTimout.Enabled = False
#if B4A
	#if CENTRE_LOGOS
	StartActivity(aSelectPlayCentre2)
	#else 
	StartActivity(xSelectPlayCentre)	
	#End If
#else
	#if CENTRE_LOGOS
	frmXSelectPlayCentre2.Show	
	#Else
	frmXSelectPlayCentre.Show	
	#End If
#End If
End Sub

'' Exits to normal operation (validate centre successful)
'private Sub lExitToTaskSelect
'	ProgressHide
'	tmrConnectToCentreTimout.Enabled = False
'#if B4A
'	StartActivity(TaskSelect)	' Normal operation
'#Else
'	frmTaskSelect.Show
'#End If
'End Sub

' Exits to Sync Data 
private Sub lExitToSyncData
	ProgressHide
	tmrConnectToCentreTimout.Enabled = False
#if B4A
	'StartActivity(SyncDataBase)	' Normal operation
	CallSubDelayed(aSyncDatabase, "pSyncDataBase")
#Else
	xSyncDatabase.Show
#End If
End Sub

'' Gets the centre menu from the Web Server
'private Sub lGetMenuFromWebServer(centreId As Int)As ResumableSub
'	Dim menuOk As Boolean = True
'	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
''	job.Download("http://www.superord.co.uk/api/centremenu/" & centreId)
'	job.Download( modEposWeb.URL_CENTREMENU_API &  "/" & centreId)
'	Wait For (job) JobDone(job As HttpJob)
'	Dim jsonMenuStrg As String
'	If job.Success And job.Response.StatusCode = 200 Then
'		jsonMenuStrg = job.GetString		' Need to get string before releasing job.
'		Dim jParser As JSONParser
'		jParser.Initialize(jsonMenuStrg)
'		Dim root As Map = jParser.NextObject
'		Dim ID As Int	'ignore
'		Dim menuRevision As Int 'ignore
'		Dim menuItems As String
'		ID = root.Get("ID")
'		menuRevision = root.Get("menuRevision")
'		menuItems  = root.Get("menuItems")
'		pProcessSyncDataResponse(menuItems)
'		menuOk = True
'	End If
'	job.Release ' Must always be called after the job is complete, to free its resources
'	Return menuOk
'End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
	selectCentreDetails.Initialize
	tmrConnectToCentreTimout.Initialize("ConnnectToCentreTimeout", DFT_CONNECTION_TIMEOUT)
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

'' Handles the response from the Server to the Sync Database command.
'Public Sub pProcessSyncDataResponse(syncDbResponseStr As String)
''	Dim xmlStr As String = syncDbResponseStr.SubString(modEposApp.EPOS_SYNC_DATA.Length) ' TODO - Need to detect if the XML string is valid
'#if B4A
'	Dim xmlStr As String = CallSub2(Starter,"TrimToXmlOnly",syncDbResponseStr) ' TODO - Need to detect if the XML string is valid
'#else
'	Dim xmlStr As String = Main.TrimToXmlOnly(syncDbResponseStr) ' TODO - Need to detect if the XML string is valid
'#End If
'	Dim responseObj As clsDataBaseTables
'	responseObj.Initialize
'	responseObj = responseObj.XmlDeserialize(xmlStr) ' TODO - need to determine if the deserialisation was successful
'	Starter.DataBase = responseObj
'End Sub

' Invokes signon to centre operation - this sub invokes a series
'  of operations to connect the Phone to a Centre Server via the Web
Private Sub lStartSignOnToCentre
	tmrConnectToCentreTimout.Enabled = False ' restart timeout.
	tmrConnectToCentreTimout.Enabled = True	
'	If Starter.settings.webOnlyComms Then
#if B4A
		CallSub(Starter, "pConnectToServer")
#Else
		Main.ConnectToServer
#End If
'	Else
'#if B4A
'		StartActivity(Connection)	' No web comms - Invoke the (TCP) connection form.
'#Else
'		frmConnection.Show(True)
'#End If
'	End If
End Sub

' Informs the Web Server that this device has signed onto a centre.
Private Sub lWebSignedOntoCentre As ResumableSub
	Dim signonSuccessful As Boolean = False
	
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	' Dim urlStrg As String = "https://www.superord.co.uk/api/customer/" & Starter.customerDetails.customerId

'	Dim urlStrg As String = modEposWeb.URL_CUSTOMER_API & "/" & Starter.myData.customer.customerIdStr
'	urlStrg = urlStrg & "?setting=centresignon&setting1=" & Starter.myData.centre.centreId & "&setting2=1"
'	Dim urlStrg As String = modEposWeb.URL_CUSTOMER_API & "/" & Starter.myData.customer.customerIdStr & _ 
'								"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_SET_SIGNON & _
'								"&" & modEposWeb.API_SETTING_1 & "=" & Starter.myData.centre.centreId & _
'								"&" & modEposWeb.API_SETTING_2 & "=1"
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