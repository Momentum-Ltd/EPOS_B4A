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
	' Release...: 9
	' Date......: 11/06/20
	'
	' History
	' Date......: 01/07/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 07/08/19
	' Release...: 2
	' Overview..: Support myData.
	' Amendee...: D Morris
	' Details...:  mod: SyncPhoneFromWebServer() and SyncWebServerToPhone().
	'
	' Date......: 09/08/19
	' Release...: 3
	' Overview..: Support check and update of FCM token and device type.
	' Amendee...: D Morris
	' Details...:   Mod: Constants from modEposWeb used.
	'			  Added: QueryUpdateFCMandDeviceType().
	'
	' Date......: 09/08/19
	' Release...: 4
	' Overview..: Mods to support x-platform.
	' Amendee...: D Morris
	' Details...: mod: SyncWebServerToPhone() and SyncPhoneFromWebServer() - ref old files
	'			  mod: msgboxasync - x-platform version used.
	'
	' Date......: 12/10/19
	' Release...: 5
	' Overview..: Changes to support starter.myData.
	' Amendee...: D Morris
	' Details...:  Mods: SyncPhoneFromWebServer() and SyncWebServerToPhone() support for B4I code.
	'
	' Date......: 22/10/19
	' Release...: 6
	' Release...: Bugfix problem  B4I code  "wait for MsgBox_result()"
	' Amendee...: D Morris
	' Details...: Bugfix: MsgBox_result() changed to MsgBox_result(tempResult as int): ForgotPasswordIdKnown().
	'
	' Date......: 25/03/20
	' Release...: 7
	' Overview..: Bugfix: 0259 - Menu revision not checked.
	' Amendee...: D Morris.
	' Details...:  Added:CheckMenuRevision().
	'
	' Date......: 26/04/20
	' Release...: 8
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	' Amendee...: D Morris.
	' Details...:  Added: IncrementCustomerIdRevision().
	' 				 Mod: UpdateCustomerInfo(), QueryUpdateDeviceType(), SendPasswordEmail(), QueryUpdateFcm(),
	'						CheckCustomerEmailAndPassword(), GetCustomerInfo(), CheckMenuRevision(),
	'						ForgotPasswordEmailKnown(), ForgotPasswordIdKnown(), QueryUpdateFCMandType(),
	'						SyncPhoneFromWebServer(), SyncWebServerToPhone(),
	'						UpdateCustomerInfo().
	'
	' Date......: 11/06/20
	' Release...: 9
	' Overview..: Mod: Support for second Server.
	' Amendee...: D Morris.
	' Details...:  Mod: CheckCustomerEmailAndPassword(), IncrementCustomerIdRevision(), CheckMenuRevision(),
	'					 GetCustomerId(), GetCustomerInfo(), SendPasswordEmail(), UpdateCustomerInfo(),
	'					 QueryUpdateDeviceType(), QueryUpdateFcm(),
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
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

#End Region  Public Subroutines

' Checks if valid email and password
' returns >0 email and password correct, =0 email ok but error in password, -1 both wrong.
public Sub CheckCustomerEmailAndPassword(email As String, password As String) As ResumableSub
	Dim emailPwResult As Int = -1
	
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
'	job.Download("http://www.superord.co.uk/api/customer?email=" & email & "&pw=" & password)
'	job.Download(modEposWeb.URL_CUSTOMER_API & "/" & modEposWeb.BuildApiCustomerId() & _
'						 "?" & modEposWeb.API_EMAIL & "=" & email & _
'						 "&" & modEposWeb.API_PASSWORD  & "=" & password)
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

' Increments the customer's revision and returns the new api Customer ID.
' returns new apiCustomerId if email and password are ok (else -1: both wrong or 0: email ok).
Public Sub IncrementCustomerIdRevision(email As String, password As String) As ResumableSub
	Dim apiCustomerId As Int = -1
	
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
'	job.Download("http://www.superord.co.uk/api/customer?EMAIL=" & email & "&PW=" & password & "&UPD=TRUE")
'	Dim msg As String = modEposWeb.URL_CUSTOMER_API & _
'						"?" & modEposWeb.API_EMAIL & "=" & email & _
'						"&" & modEposWeb.API_PASSWORD  & "=" & password & _
'						"&" & modEposWeb.API_INCREV & "=TRUE"
	Dim msg As String = Starter.server.URL_CUSTOMER_API & _
						"?" & modEposWeb.API_EMAIL & "=" & email & _
						"&" & modEposWeb.API_PASSWORD  & "=" & password & _
						"&" & modEposWeb.API_INCREV & "=TRUE"
	job.Download(msg)
	Wait For (job) JobDone(job As HttpJob)
'	Dim customerIdStrg As String
	If job.Success And job.Response.StatusCode = 200 Then
		apiCustomerId = job.GetString		' Need to get string before releasing job.
'		customerId = customerIdStrg
	End If
	job.Release
	Return apiCustomerId
End Sub

' Checks the Database menu revision against the Web server menu revision.
' Returns boolean true both are the same. 
Public Sub CheckMenuRevision As ResumableSub
	Dim menuOK As Boolean = False
	Dim centreId As Int = Starter.myData.centre.centreId
	Dim menuRevision As Int = Starter.menuRevision
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
'	Dim urlStr As String = modEposWeb.URL_CENTREMENU_API & "/" & centreId & _
'							"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_REVISION 
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
	job.Release
	Return menuOK
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

' Gets customer id from server using the email
' returns customerId associated with email address (valid customerId >= 1)
public Sub GetCustomerId(email As String) As ResumableSub
	Dim customerId As Int = -1
	
	Dim job As HttpJob : job.Initialize("UseWebAPI", Me)
'	Dim urlStrg As String = "http://www.superord.co.uk/api/customer" & "?" & modEposWeb.API_EMAIL & "=" & email
'	Dim urlStrg As String = modEposWeb.URL_CUSTOMER_API & "?" & modEposWeb.API_EMAIL & "=" & email
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
'	job.Download("http://www.superord.co.uk/api/customer/" & customerId)
	
'	job.Download(modEposWeb.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False))
	job.Download(Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False))
	Wait For (job) JobDone(job As HttpJob)
	Dim jsonCustomerInfoStrg As String
	If job.Success And job.Response.StatusCode = 200 Then
		customerInfoRec.Initialize
		jsonCustomerInfoStrg = job.GetString		' Need to get string before releasing job.
		job.Release ' Must always be called after the job is complete, to free its resources
		customerInfoRec.pJsonDeserialize(jsonCustomerInfoStrg)
	Else
		job.Release
	End If
	Return customerInfoRec
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
'	Dim urlString As String =  modEposWeb.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0 ,0, False)  & _
'							"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_SEND_PW_EMAIL 
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
'#if B4A
		Starter.myData.customer.address = customerInfoRec.address
		Starter.myData.customer.email = customerInfoRec.email
		Starter.myData.customer.name = customerInfoRec.name
		Starter.myData.customer.phoneNumber = customerInfoRec.telephone
		Starter.myData.customer.postCode = customerInfoRec.postCode
		Starter.myData.customer.Save
'#Else ' TODO This is the same code to could be removed later!
''		Starter.CustomerInfoData.address = customerInfoRec.address
''		Starter.CustomerInfoData.email = customerInfoRec.email
''		Starter.CustomerInfoData.foreName = customerInfoRec.name
''		Starter.CustomerInfoData.phoneNumber = customerInfoRec.telephone
''		Starter.CustomerInfoData.postCode = customerInfoRec.postCode
''		Starter.CustomerInfoData.SaveCustomerInfo
'		' TODO This is the same code so conditionals could be removed later!
'		Starter.myData.customer.address = customerInfoRec.address
'		Starter.myData.customer.email = customerInfoRec.email
'		Starter.myData.customer.name = customerInfoRec.name
'		Starter.myData.customer.phoneNumber = customerInfoRec.telephone
'		Starter.myData.customer.postCode = customerInfoRec.postCode
'		Starter.myData.customer.Save
'#End If

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
'#if B4A
		customerInfoRec.address = Starter.myData.customer.address
		customerInfoRec.email = Starter.myData.customer.email
		customerInfoRec.name = Starter.myData.customer.name 
		customerInfoRec.telephone = Starter.myData.customer.phoneNumber 
		customerInfoRec.postCode = Starter.myData.customer.postCode 
'#else
''		customerInfoRec.address = Starter.CustomerInfoData.address
''		customerInfoRec.email = Starter.CustomerInfoData.email
''		customerInfoRec.name = Starter.CustomerInfoData.foreName
''		customerInfoRec.telephone = Starter.CustomerInfoData.phoneNumber
''		customerInfoRec.postCode = Starter.CustomerInfoData.postCode
'		' TODO This is the same code so conditionals could be removed later!
'		customerInfoRec.address = Starter.myData.customer.address
'		customerInfoRec.email = Starter.myData.customer.email
'		customerInfoRec.name = Starter.myData.customer.name
'		customerInfoRec.telephone = Starter.myData.customer.phoneNumber
'		customerInfoRec.postCode = Starter.myData.customer.postCode
'#End If

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
	
'	Dim urlStrg As String = modEposWeb.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False)
	Dim urlStrg As String = Starter.server.URL_CUSTOMER_API & "/" & NumberFormat2(apiCustomerId, 3, 0, 0, False)
	job.PutString(urlStrg, jsonToSend)
	job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		updateOk = True
	End If
	Return updateOk
End Sub

#Region  Local Subroutines


' Query update device type - Returns true if device types are the same or the device type updated successfully.
private Sub QueryUpdateDeviceType(apiCustomerId As Int, deviceType As Int)As ResumableSub
	Dim deviceTypeUpdatedOk As Boolean = False
	Dim apiCustomerIdStr As String = NumberFormat2(apiCustomerId, 3, 0, 0, False)
	Dim jobGet As HttpJob: jobGet.Initialize("UseWebApi", Me)
'	jobGet.Download(modEposWeb.URL_CUSTOMER_API & "/" & apiCustomerIdStr & _
'							"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_DEVICE_TYPE)
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
'			jobPut.PutString(modEposWeb.URL_CUSTOMER_API & "/" & apiCustomerIdStr & _
'								"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_DEVICE_TYPE & _
'								"&" & modEposWeb.API_SETTING_1 & "=" & deviceType, "")
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
	'		jobPut.Release
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
'	Dim urlStr As String = modEposWeb.URL_CUSTOMER_API & "/" & apiCustomerIdStr & _
'							"?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_GET_FCMTOKEN
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
'			Dim urlStrg As String = modEposWeb.URL_CUSTOMER_API & "/" & apiCustomerIdStr & _
'									"?" & modEposWeb.API_SETTING & "=" & modEposWeb.API_SET_FCMTOKEN & _ 
'									"&" & modEposWeb.API_SETTING_1 & "=" & fcmToken
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
'			jobPut.Release
		End If
	Else
		'TODO Log get WebServer FCM failed 
	End If
	jobGet.Release
	Return fcmUpdatedOk	
End Sub



#End Region  Local Subroutines
