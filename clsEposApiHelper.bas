B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.01
@EndOfDesignText@
'
' Class to help with EPOS API operation
'
#Region  Documentation
	'
	' Name......: clsEposApiHelper
	' Release...: 11-
	' Date......: 30/01/21
	'
	' History
	' Date......: 01/07/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Versions
	'	2 - 9 see v9
	'
	' Date......: 11/06/20
	' Release...: 9
	' Overview..: Mod: Support for second Server.
	' Amendee...: D Morris.
	' Details...:  Mod: CheckCustomerEmailAndPassword(), IncrementCustomerIdRevision(), CheckMenuRevision(),
	'					 GetCustomerId(), GetCustomerInfo(), SendPasswordEmail(), UpdateCustomerInfo(),
	'					 QueryUpdateDeviceType(), QueryUpdateFcm().
	'
	' Date......: 15/02/20
	' Release...: 10
	' Overview..: New features added.
	' Amendee...: D Morris
	' Details...: Mod: Old commented out code removed.
	'			  Added: IsCustomerActivated(), CustomerMustActivate(), IsInternetAvailable() and CheckWebServerStatus().
	'			  Added: GetCustomerEmail().
	'
	' Date......: 28/01/21
	' Release...: 11
	' Overview..: Maintenance release.
	'			  Bugfix: A release is missing, 
	' Amendee...: D Morris.
	' Details...: Added: AddCustomer()
	'			  Bugfix: UpdateCustomerInfo() - release added.
	'			  Mod: GetCustomerInfo() redundant code removed.
	'
	' Date......: 
	' Release...: 
	' Overview..: More methods added.
	' Amendee...: D Morris
	' Details...: Added: DisplayAllCentres() and DisplayNearbyCentres().
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
	Private xui As XUI		'Ignore
	
	' Constants
	Private const DFT_ONLINE_TIMEOUT As Int	= 7000		' Timeout on check for server on-line (and internet) - in msecs.
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

#End Region  Public Subroutines
' Add a new Customer
' Returns >0 new apiCustomerId (customerId with revision number).
Public Sub AddCustomer(customerObj As clsEposWebCustomerRec) As ResumableSub
	Dim apiCustomerId As Int = 0
	
	Dim jsonToSend As String = customerObj.GetJson
	Dim job As HttpJob : job.Initialize("NewCustomer", Me)
	Dim msg As String = Starter.server.URL_CUSTOMER_API
	job.PostString(msg, jsonToSend)
	job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		Dim rxCustomerIDStr As String = job.GetString
		If rxCustomerIDStr <> "" Then
			apiCustomerId = rxCustomerIDStr
		End If
	End If
	job.Release
	Return apiCustomerId
End Sub

' Checks if valid email and password
' returns >0 email and password correct, =0 email ok but error in password, -1 both wrong.
public Sub CheckCustomerEmailAndPassword(email As String, password As String) As ResumableSub
	Dim emailPwResult As Int = -1
	
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	job.Download(Starter.server.URL_CUSTOMER_API & "/" & modEposWeb.BuildApiCustomerId() & _
						 "?" & modEposWeb.API_EMAIL & "=" & email & _
						 "&" & modEposWeb.API_PASSWORD  & "=" & password)
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		emailPwResult = job.GetString		' Need to get string before releasing job.
	End If
	job.Release
	Return emailPwResult
End Sub

' Checks Web Server status (i.e. Internet connected and Server is on-line).
' Returns 1 if Server online
' Returns 0 if not on-line (Internet is ok)
' Returns -1 if No internet
public Sub CheckWebServerStatus As ResumableSub
	Dim internetStatus As Int   = -1 ' Default to both Server and Internet down.
	wait for (IsInternetAvailable) complete (ok As Boolean)
	If ok Then
		Dim job As HttpJob : job.Initialize("UseWebApi", Me)
		job.Download(Starter.server.URL_CENTRE_API)
		job.GetRequest.Timeout = DFT_ONLINE_TIMEOUT' (timout is set before the downloads starts)
		Wait For (job) JobDone(job As HttpJob)
		If job.Success And job.Response.StatusCode = 200 Then
			internetStatus = 1 ' Server online.
		Else ' Problem check if internet
			Wait For (IsInternetAvailable) complete (internetOk As Boolean)
			If internetOk Then
				internetStatus = 0	' Internet ok (no Server)
			End If
		End If
		job.release
	End If
	Return internetStatus
End Sub

' Check customer is activated (reports activated, not-activated or customer not found) 
' Returns int (customer account status)
'				 	= 1 customer activated.
'			  		= 0 not activated (customer found).
'			  		= -1 customer NOT found.
'			  		= -2 internet problem.
Public Sub CheckCustomerActivated(apiCustomerId As Int) As ResumableSub
	Dim customerAccountStatus As Int = -2
	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
	Dim urlStr As String = Starter.server.URL_CUSTOMER_API & "/" & modEposWeb.ConvertApiId(apiCustomerId) & _
				"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_QUERY_ACTIVATED 
	job.Download(urlStr)
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then 'Account valid?
		Dim rxActivated As String = job.GetString
		If rxActivated = "1" Then ' Activated?
			customerAccountStatus = 1
		Else ' Customer has NOT activated their account
			customerAccountStatus = 0
		End If
	Else if job.Success And job.Response.StatusCode = 204 Then ' Customer not found (or invalid customer number)
		customerAccountStatus = -1
	End If
	job.Release
	Return customerAccountStatus
End Sub

' Checks the Database menu revision against the Web server menu revision.
' Returns boolean true both are the same. 
Public Sub CheckMenuRevision As ResumableSub
	Dim menuOK As Boolean = False
	Dim centreId As Int = Starter.myData.centre.centreId
	Dim menuRevision As Int = Starter.menuRevision
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	Dim urlStr As String = Starter.server.URL_CENTREMENU_API & "/" & centreId & _
							"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_REVISION
	job.Download(urlStr)
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		Dim jsonMenuStrg As String = job.GetString' Need to get string before releasing job.
		Dim jParser As JSONParser
		jParser.Initialize(jsonMenuStrg)
		Dim root As Map = jParser.NextObject
		Dim apiCentreId As Int  = root.Get("ID")	' Get teh API menu info (skips the "menuItems".
		Dim apiMenuRevision As Int = root.Get("menuRevision")
		If (apiCentreId = centreId) And (apiMenuRevision = menuRevision) Then
			menuOK = True    
		End If
	End If
	job.Release ' Always release the Http job!
	Return menuOK
End Sub

' Force a customer to activate.
' Returns true if request to a activate successful, false otherwise.
Public Sub CustomerMustActivate(apiCustomerId As Int)As ResumableSub
	Dim successful As Boolean = False
	Dim job As HttpJob : job.Initialize("UseWebApi", Me)
	Dim urlStrg As String = Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False) & _
										"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_MUST_ACTIVATE
	job.PutString(urlStrg, "")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		successful = True
	End If
	job.Release ' Always release the Http job!
	Return successful
End Sub

' Downloads a list of all centres.
'   returns rxMsg if download ok else null if error.
Public Sub DisplayAllCentres() As ResumableSub
	Dim rxMsg As String = ""
'	ProgressShow("Getting a list of all centres, please wait...")
	Log("Request the Web API to give list of all centres...")
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	Dim urlStr As String = 	Starter.server.URL_CENTRE_API & _
	"?" & modEposWeb.API_LATITUDE & "=" & modEposWeb.API_GET_ALL & _
									"&" & modEposWeb.API_LONGITUDE & "=" & modEposWeb.API_GET_ALL					
	job.Download(urlStr)
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		rxMsg = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)
	Else ' An error of some sort occurred
		If job.Response.StatusCode = 204 Or job.Response.StatusCode = 404 Then
			Log("The Web API returned no centres available")
			xui.MsgboxAsync("There are no centres on the system.", _
								"No Nearby Centres" & "Error:" & job.Response.StatusCode)
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
Public Sub DisplayNearbyCentres(pCurrentLocation As Location) As ResumableSub
	Dim rxMsg As String = ""
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
	If job.Success And job.Response.StatusCode = 200 Then
		rxMsg = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)
	Else ' An error of some sort occurred
		If job.Response.StatusCode = 204 Or job.Response.StatusCode = 404 Then
			Log("The Web API returned no nearby centres")
			xui.MsgboxAsync("There are no centres near your current location. All centres will now be displayed.", _
								"No Nearby Centres" & "Error:" & job.Response.StatusCode)
			wait for MsgBox_result(tempResult As Int) '' inserted
		Else ' Any other error
			Log("An error occurred with the HTTP job: " & job.ErrorMessage)
			xui.MsgboxAsync("An error occurred while trying to find nearby centres. All centres will now be displayed.", _
								 "Cannot Get Nearby Centres" & "Error:" & job.Response.StatusCode)
		End If
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
	Return rxMsg
End Sub

' Forgot Password handler (when email address known) - sends a email with information. 
'(retrieves forgotten password and displays message boxes accordingly).
'  return apiCustomerId > 0 if valid.
public Sub ForgotPasswordEmailKnown(email As String) As ResumableSub
	Wait for (GetCustomerId(email)) complete (apiCustomerId As Int)
	If apiCustomerId > 0 Then
		wait for (ForgotPasswordIdKnown(apiCustomerId)) complete (emailSent As Boolean)
		If emailSent = False Then
			apiCustomerId = -1		' Error
		End If
	Else
		xui.MsgboxAsync("Email not found.", "Error")
		wait for MsgBox_result(tempResult As Int)
	End If
	Return apiCustomerId
End Sub

' Forgot Password (apiCustomerId known) - sends a email with information. 
'(retrieves forgotten password and displays message boxes accordingly).
'  Returns true if valid apiCustomerId and email has been sent.
public Sub ForgotPasswordIdKnown(apiCustomerId As Int) As ResumableSub
	wait for (SendPasswordEmail(apiCustomerId)) Complete (emailSent As Boolean)
	If emailSent Then
		xui.MsgboxAsync("Information sent to your email address", "Password email sent")
		wait for MsgBox_result(tempResult As Int)
	Else
		xui.msgboxAsync("Unable to send email!", "Error")
		wait for MsgBox_result(tempResult As Int)
	End If
	Return emailSent
End Sub

' Get Customer's Email address 
' Returned as string ("" not available)
Public Sub GetCustomerEmail(apiCustomerId As Int) As ResumableSub
	Wait for (GetCustomerInfo(apiCustomerId)) complete(customerInfo As clsEposWebCustomerRec)
	Dim emailAddress As String = ""
	If customerInfo.IsInitialized Then
		emailAddress = customerInfo.email
	End If
	Return emailAddress
End Sub

' Gets customer id from server using the email
' returns customerId associated with email address (valid customerId >= 1)
public Sub GetCustomerId(email As String) As ResumableSub
	Dim customerId As Int = -1
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	Dim urlStrg As String = Starter.server.URL_CUSTOMER_API & "?" & modEposWeb.API_EMAIL & "=" & email
	job.Download(urlStrg)
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		customerId = job.GetString
	End If
	job.Release 	
	Return customerId
End Sub

' Get the customer information from the Web Server (using the apiCustomerId)
' Returns clsEposWebCustomerRec (if error the clsEposWebCustomerRec it not initialised)
public Sub GetCustomerInfo(apiCustomerId As Int) As ResumableSub
	Dim customerInfoRec As clsEposWebCustomerRec  
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	job.Download(Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False))
	Wait For (job) JobDone(job As HttpJob)
	Dim jsonCustomerInfoStrg As String
	If job.Success And job.Response.StatusCode = 200 Then
		customerInfoRec.Initialize
		jsonCustomerInfoStrg = job.GetString		' Need to get string before releasing job.
'		job.Release ' Must always be called after the job is complete, to free its resources
		customerInfoRec.pJsonDeserialize(jsonCustomerInfoStrg)
'	Else
'		job.Release
	End If
	job.Release
	Return customerInfoRec
End Sub

' Increments the customer's revision and returns the new api Customer ID.
' returns new apiCustomerId if email and password are ok (else -1: both wrong or 0: email ok).
Public Sub IncrementCustomerIdRevision(email As String, password As String) As ResumableSub
	Dim apiCustomerId As Int = -1
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
	Dim msg As String = Starter.server.URL_CUSTOMER_API & _
	"?" & modEposWeb.API_EMAIL & "=" & email & _
						"&" & modEposWeb.API_PASSWORD  & "=" & password & _
						"&" & modEposWeb.API_INCREV & "=TRUE"
	job.Download(msg)
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		apiCustomerId = job.GetString		' Need to get string before releasing job.
	End If
	job.Release
	Return apiCustomerId
End Sub

' Check If internet available.
Public Sub IsInternetAvailable() As ResumableSub
	Dim internetOk As Boolean = False
	Dim j As HttpJob
	j.Initialize("checkInternet", Me)
	j.Download( "https://www.google.com") ' Hopefully google is always running.
	j.GetRequest.Timeout = DFT_ONLINE_TIMEOUT ' 5 second timeout (timout is set before the downloads starts)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		internetOk = True
	End If
	j.Release		' Important.
	Return internetOk
End Sub

' Will check if FCM token and deviceType compared to values stored on the Web Server and udpates 
' the Web server accordingly 
public Sub QueryUpdateFCMandType(apiCustomerId As Int, fcmToken As String, deviceType As Int) As ResumableSub
	Dim updateOk As Boolean = False
	Wait For (QueryUpdateFcm(apiCustomerId, fcmToken)) complete (fcmUpdatedOk As Boolean)
	If fcmUpdatedOk Then
		Wait For (QueryUpdateDeviceType(apiCustomerId, deviceType)) complete (deviceTypeUpdatedOk As Boolean)
		If deviceTypeUpdatedOk Then
			updateOk = True
		End If
	End If
	Return updateOk
End Sub

' Sends a password email to a customer (using apiCustomerId).
public Sub SendPasswordEmail(apiCustomerId As Int) As ResumableSub
	Dim emailSentOk As Boolean = False
	Dim job As HttpJob : job.Initialize("NewCustomer", Me)
	Dim urlString As String =  Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0 ,0, False)  & _
							"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_SEND_PW_EMAIL 
	Dim jsonToSend As String = ""
	job.PutString(urlString, jsonToSend)
	job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		emailSentOk = True
	End If
	job.Release
	Return emailSentOk
End Sub

' Sync's (overwrites) the phone with information stored on the web server.
' Returns true if synchronisation successful.
' TODO Not sure the is the correct (or meaningful) name for this sub.
public Sub SyncPhoneFromWebServer(apiCustomerId As Int) As ResumableSub
	Dim syncOk As Boolean = False
	
	Wait For (GetCustomerInfo(apiCustomerId)) complete (customerInfoRec As clsEposWebCustomerRec)
	If customerInfoRec.IsInitialized Then 'Get web data ok?
		Starter.myData.customer.address = customerInfoRec.address
		Starter.myData.customer.email = customerInfoRec.email
		Starter.myData.customer.name = customerInfoRec.name
		Starter.myData.customer.phoneNumber = customerInfoRec.telephone
		Starter.myData.customer.postCode = customerInfoRec.postCode
		Starter.myData.customer.Save
		syncOk = True
	End If
	Return syncOk
End Sub

' Sync (overwrites) the Web Server with information stored on the phone.
' Returns true if synchronisation successful.
' TODO Not sure the is the correct (or meaningful) name for this sub.
public Sub SyncWebServerToPhone(apiCustomerId As Int) As ResumableSub
	Dim syncOk As Boolean = False
	Wait For (GetCustomerInfo(apiCustomerId)) complete (customerInfoRec As clsEposWebCustomerRec)
	If customerInfoRec.IsInitialized Then 'Get web data ok?
		customerInfoRec.address = Starter.myData.customer.address
		customerInfoRec.email = Starter.myData.customer.email
		customerInfoRec.name = Starter.myData.customer.name 
		customerInfoRec.telephone = Starter.myData.customer.phoneNumber 
		customerInfoRec.postCode = Starter.myData.customer.postCode 
		Wait For (UpdateCustomerInfo(apiCustomerId, customerInfoRec)) complete (updateOk As Boolean)
		If updateOk Then
			syncOk = True
		End If
	End If
	Return syncOk
End Sub

' Updates the Web Server customer record.
' Returns true of update successful
Public Sub UpdateCustomerInfo(apiCustomerId As Int, customerInfoRec As clsEposWebCustomerRec) As ResumableSub
	Dim updateOk As Boolean = False
	Dim jsonToSend As String = customerInfoRec.GetJson
	Log("Updating customer details to the Web Server:" & CRLF & jsonToSend)
	Dim job As HttpJob : job.Initialize("NewCustomer", Me)
	Dim urlStrg As String = Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False)
	job.PutString(urlStrg, jsonToSend)
	job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		updateOk = True
	End If
	job.Release
	Return updateOk
End Sub

#Region  Local Subroutines

' Query update device type - Returns true if device types are the same or the device type updated successfully.
private Sub QueryUpdateDeviceType(apiCustomerId As Int, deviceType As Int)As ResumableSub
	Dim deviceTypeUpdatedOk As Boolean = False
	Dim apiCustomerIdStr As String = NumberFormat2(apiCustomerId, 3, 0, 0, False)
	Dim jobGet As HttpJob: jobGet.Initialize("UseWebApi", Me)
	jobGet.Download(Starter.server.URL_CUSTOMER_API & "/" & apiCustomerIdStr & _
							"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_DEVICE_TYPE)
	wait for (jobGet) jobDone(jobGet As HttpJob)
	If jobGet.Success And jobGet.Response.StatusCode = 200 Then
		Dim webDeviceType As String = jobGet.GetString
		Log(deviceType)
		Log(webDeviceType)
		If webDeviceType = deviceType Then
			deviceTypeUpdatedOk = True
		Else
			Dim jobPut As HttpJob: jobPut.Initialize("UseWebApi", Me)
			jobPut.PutString(Starter.server.URL_CUSTOMER_API & "/" & apiCustomerIdStr & _
								"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_DEVICE_TYPE & _
								"&" & modEposWeb.API_SETTING_1 & "=" & deviceType, "")
			Wait For (jobPut) jobDone (jobPut As HttpJob)
			Log("Fcm device type updated on Web Server")
			If jobPut.Success And jobPut.Response.StatusCode = 200 Then
				deviceTypeUpdatedOk = True
			Else
				'TODO Log write device type to WebServer failed
			End If
		End If
	Else
		'TODO Log get WebServer device type failed
	End If
	jobGet.Release
	Return deviceTypeUpdatedOk
End Sub

' Query update FCM token - Returns true if FCM tokens are the same or the FCM token updated successfully.
private Sub QueryUpdateFcm(apiCustomerId As Int, fcmToken As String)As ResumableSub
	Dim fcmUpdatedOk As Boolean = False
	Dim apiCustomerIdStr As String = modEposWeb.ConvertApiId(apiCustomerId)
	Dim jobGet As HttpJob: jobGet.Initialize("UseWebApi", Me)
	Dim urlStr As String = Starter.server.URL_CUSTOMER_API & "/" & apiCustomerIdStr & _
							"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_GET_FCMTOKEN
	jobGet.Download(urlStr)
	jobGet.GetRequest.SetHeader("Accept-Encoding","utf8")
	wait for (jobGet) jobDone(jobGet As HttpJob)
	If jobGet.Success And jobGet.Response.StatusCode = 200 Then
		Dim webFcmToken As String = jobGet.GetString ' Bug GetString enclosed string in quotes
		Log(fcmToken)
		Log(webFcmToken)		
		webFcmToken = webFcmToken.SubString2(1, (webFcmToken.Length -1)) ' Bugfix removed quotes (see Getstring above).
		Log("Processed token:" & webFcmToken)
		If fcmToken = webFcmToken Then
			fcmUpdatedOk = True
		Else
			Dim jobPut As HttpJob: jobPut.Initialize("UseWebApi", Me)
			Dim urlStrg As String = Starter.server.URL_CUSTOMER_API & "/" & apiCustomerIdStr & _
									"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_SET_FCMTOKEN & _ 
									"&" & modEposWeb.API_SETTING_1 & "=" & fcmToken

			jobPut.PutString(urlStrg, "")
			Wait For (jobPut) jobDone (jobPut As HttpJob)
			Log("Fcm token updated on Web Server")
			If jobPut.Success And jobPut.Response.StatusCode = 200 Then
				fcmUpdatedOk = True
			Else
				'TODO Log write FCM to WebServer failed
			End If
		End If
	Else
		'TODO Log get WebServer FCM failed 
	End If
	jobGet.Release
	Return fcmUpdatedOk	
End Sub

#End Region  Local Subroutines
