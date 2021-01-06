B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' Class to handle card operations using Stripe.
'

#Region  Documentation
	'
	' Name......: clsStripe
	' Release...: 6
	' Date......: 15/12/20
	'
	' History
	' Date......: 03/09/19
	' Release...: 1
	' Created by: D Morris.
	' Details...: First release to support version tracking (Code based on example
	' from DonManfred see https://www.b4x.com/android/forum/threads/order-and-pay-app.108672/ 
		'
	' Date......: 13/10/19
	' Release...: 2
	' Overview..: Compiler warning removed.
	' Amendee...: D Morris
	' Details...: Mods: GetCardToken() Taken object type now defined.
	'
	' Date......: 22/10/19
	' Release...: 3
	' Overview..: Now handles errors returned from Stripe.
	' Amendee...: D Morris
	' Details...: Mod: Descriptions and header text changed.
		'
	' Date......: 10/01/20
	' Release...: 4
	' Overview..: Bugfix: #0251 - Error access Stripe account. 
	' Amendee...: D Morris.
	' Details...: Mod: GetCardToken() now uses the starter.myData.centre.publishedKey value.
	'			  Removed: local references to publishKey and secretKey.
	'
	' Date......: 06/04/20
	' Release...: 5
	' Overview..: Issue: #0315 (ongoing) compiler warnings removed. 
	' Amendee...: D Morris
	' Details...:  Mod: Class_Globals - unused variables cb and apptocken ignored.
	'
	' Date......: 15/12/20
	' Release...: 6
	' Overview..: Issue: #0475 Card operation - internal problem with callback. 
	' Amendee...: D Morris.
	' Details...: Mod: GetCardToken() SubExits() now used for raising the event.
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
	'TOOD This should be provided by the Centre.
'	Private Const publishedKey As String = "pk_test_SHzfU1eChNxeqK9vEO8lKWOR"
	
	'TODO Not required check.
'	Private const secretKey As String = "sk_test_kgFPxOa8g3heBdIhP0YjBgmV"
	
	' X-platform related.
	Private xui As XUI									'ignore (to remove warning) -  Required for X platform operation.
	
	Private cb As Object 'ignore
	Private apptoken As String 'ignore
	Private mEventName As String 
	Private sdkurl As String = "https://api.stripe.com/v1"
End Sub

#Event: Charges
#Event: CardToken

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(TargetModule As Object, token As String, EventName As String)
	cb = TargetModule
	apptoken = token
	mEventName = EventName
End Sub

'' Get Charges
'public Sub GetCharges(TargetModule As Object)
'	Dim job As HttpJob
'	job.Initialize("",Me)
'	job.Tag = "GetCharges"
'	job.Download($"${sdkurl}/charges"$)
'	job.GetRequest.SetHeader("Authorization", "Bearer "&apptoken)
'	Wait For (job) JobDone(j As HttpJob)
'	Dim result As String
'	If j.Success Then
'		Log(j.GetString)
'		result = j.GetString
'		CallSub3(TargetModule, mEventName & "_" & "Charges",True,result)
'	Else
'		result = j.ErrorMessage
'		'Log(j.ErrorMessage)
'		CallSub3(TargetModule, mEventName & "_" & "Charges",False,result)
'	End If
'	j.Release
'End Sub

' Send card details to stripe - and raises an event when a response is received. 
Public Sub GetCardToken(TargetModule As Object, cardInfo As clsStripeTokenRec)
	'Dim ttt As String = "card[number]=4242424242424242&card[exp_month]=12&card[exp_year]=2020&card[cvc]=123"
	Dim cardStrgToSend As String = cardInfo.UrlEncoded ' Needs a string as above.(application/x-www-form-urlencoded;charset=utf-8)

	Dim job As HttpJob
	job.Initialize("",Me)
	job.Tag = "GetCardToken"
	
	job.poststring($"${sdkurl}/tokens"$, cardStrgToSend)
	'job.poststring($"${sdkurl}/tokens"$, ttt)

	job.GetRequest.SetContentType("application/x-www-form-urlencoded;charset=utf-8")
	
'	job.GetRequest.SetHeader("Authorization", "Bearer "& publishedKey)
'	job.GetRequest.SetHeader("Authorization", "Bearer "& secretKey)
	job.GetRequest.SetHeader("Authorization", "Bearer "& Starter.myData.centre.publishedKey)

	Wait For (job) JobDone(j As HttpJob)
	Dim result As String
	If j.Success Then
		Log(j.GetString)
		result = j.GetString
		
		Dim token As String = GetToken(result)
		j.Release	' Release job maybe used by called activities.
		
	'	CallSub3(TargetModule, mEventName & "_" & "CardToken", True, token)
		If xui.SubExists(TargetModule, mEventName & "_CardToken", 0) Then ' Raise Sync Complete event
			CallSubDelayed3(TargetModule, mEventName & "_CardToken", True, token)
		End If
	Else
		result = j.ErrorMessage
		Log(j.ErrorMessage)
		Dim errorMsg As String
		If result <> "unknown error" Then 	' TODO - Problem with B4I and error codes.
			errorMsg = GetErrorMsg(result)
		Else
			errorMsg = "Please re-enter"	' Workaround for B4I not handling errors correctly.Http 
		End If
		j.Release ' Release job maybe used by called activities.

'		CallSub3(TargetModule, mEventName & "_" & "CardToken", False, errorMsg)
		If xui.SubExists(TargetModule, mEventName & "_CardToken", 0) Then ' Raise Sync Complete event
			CallSubDelayed3(TargetModule, mEventName & "_CardToken", False, errorMsg)
		End If
	End If
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines
' Get a error message from a response string.
Private Sub GetErrorMsg(responseString As String) As String
	Dim map1 As Map
	Dim json As JSONParser
	json.Initialize(responseString)
	' TODO We need an error - just in case the string is corrupted.
	map1 = json.NextObject
	Dim m As Map
	m = map1.Get("error")
	Return m.GetDefault("message", "")	
End Sub

' Gets the Card token from a response string.
Private Sub GetToken(responseString As String) As String
	Dim map1 As Map
	Dim json As JSONParser

	json.Initialize(responseString)
	' TODO We need an error - just in case the string is corrupted.
	map1 = json.NextObject
'	Dim m As Map' If you wanted card information - something like this. 
' 	m = map1.Get("card") 
'   Dim t as string = m.Get("card)
	
	Return map1.GetDefault("id", "")
End Sub

#End Region  Local Subroutines
