B4A=true
Group=Modules
ModulesStructureVersion=1
Type=StaticCode
Version=9.01
@EndOfDesignText@
'
' Module that contains constants and methods used in EPOS web communications.
'

#Region  Documentation
	'
	' Name......: modEposWeb
	' Release...: 12
	' Date......: 02/11/20
	'
	' History
	' Date......: 01/07/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' History 2 - 10 see v10.
	'
	' Date......: 05/10/20
	' Release...: 11
	' Overview..: Privacy url changed and support for test centres.
	' Amendee...: D Morris
	' Details...:   Mod: URL_PRIVACY_POLICY changed to superorder.co.uk.
	'			  Added: API_SEARCH_RADIUS, API_SHOW_TEST_CENTRES.
	'               Mod: URL_WEB_SERVER_2_API changed to http:
	'
	' Date......: 02/11/20
	' Release...: 12
	' Overview..: Problems with accessing Server #2.
	' Amendee...: D Morris.
	' Details...:   Mod: URL_WEB_SERVER_2 and URL_WEB_SERVER_2_API now https://...
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	' URL constants
	
	''' <summary>To support old phones with old customerID.<br/>
	''' CustomerId's with ID less than to this value (and a rev == 0) don't append the revision number to
	''' the customerId in web communications.
	''' </summary>
	Public Const CUSTOMERID_LEGACY_THRESHOLD As Int = 200300
	
	' Constants Web Server API controller names (issue with B4A need to be first).
	''' <summary>Select centre api controller name.</summary>
	Public Const CONTROLLER_CENTRE_API As String = "/centre"

	''' <summary>Select customer api controller name.</summary>
	Public Const CONTROLLER_CUSTOMER_API As String = "/customer"

	''' <summary>Select communications api controller name.</summary>
	Public Const CONTROLLER_COMMS_API As String = "/comms"

	''' <summary>Select centre-menu api controller name.</summary>
	Public Const CONTROLLER_CENTREMENU_API As String = "/centremenu"
	
	''' <summary>Privacy policy.</summary>
    Public Const URL_PRIVACY_POLICY As String = "https://www.superorder.co.uk/legal/privacypolicy.html"

	''' <summary>Web Server URL.</summary>
	Public Const URL_WEB_SERVER_1 As String = "https://www.superord.co.uk"
	Public Const URL_WEB_SERVER_2 As String = "https://www.superorderapp.co.uk"

	''' <summary>Web Server API prefix.</summary>
	Public Const URL_WEB_SERVER_1_API As String = "https://www.superord.co.uk/api"
	Public Const URL_WEB_SERVER_2_API As String = "https://www.superorderapp.co.uk/api"
	
'	''' <summary> Web Server Centre API URL prefix.</summary>
'	Public Const URL_CENTRE_API As String = URL_WEB_SERVER_API & CONTROLLER_CENTRE_API
'
'	' Constants used by API call to select the appropriate controller.
'	''' <summary> Web Server Customer API URL prefix.</summary>
'	Public Const URL_CUSTOMER_API As String = URL_WEB_SERVER_API & CONTROLLER_CUSTOMER_API
'
'	''' <summary> Web Server Communications API URL prefix.</summary>
'	Public Const URL_COMMS_API As String = URL_WEB_SERVER_API & CONTROLLER_COMMS_API
'
'	''' <summary> Web Server centre-menu API URL prefix.</summary>
'	Public Const URL_CENTREMENU_API As String = URL_WEB_SERVER_API & CONTROLLER_CENTREMENU_API

	' Constants for Web Server Directories
	''' <summary>Centre image directory.</summary>
	Public Const WEB_DIR_IMG As String = "/centreimages"

	''Constants used for API calls search parameters (before the "=").
	''' <summary>API call search parameter for specifying the centre ID.</summary>
	Public Const API_CENTRE_ID As String = "CENTREID"

	''' <summary>API call search parameter for specifying the customer ID.</summary>
	Public Const API_CUSTOMER_ID As String = "CUSTOMERID"

	''' <summary>API call search parameter for specifying increment customer revision number.</summary>
	Public Const API_INCREV As String = "UPD"
	
	''' <summary>API call search parameter for the coordinate latitude value (inserted after the "=").</summary>
	Public Const API_LATITUDE As String = "LAT"

	''' <summary>API call search parameter for the coordinate longitude value (inserted after the "=").</summary>
	Public Const API_LONGITUDE As String = "LON"

	''' <summary>API call search parameter for specifying the update limit.</summary>
	Public Const API_MAX_LIMIT As String = "MAX"
		
	''' <summary>API call to specify the search radius."</summary>
	Public Const API_SEARCH_RADIUS As String = "RAD"

	''' <summary>API call show test centres in searches."</summary>
	Public Const API_SHOW_TEST_CENTRES As String = "TEST"

	''' <summary>API call search parameter for emails.</summary>
	Public Const API_EMAIL As String = "EMAIL"

	''' <summary>API call search parameter for passwords.</summary>
	Public Const API_PASSWORD As String = "PW"

	''' <summary>API call search parameter for queries.</summary>
	Public Const API_QUERY As String = "SEARCH"

	''' <summary>API call search parameter #1 for queries.</summary>
	Public Const API_QUERY_1 As String = "SEARCH1"

	''' <summary>API call search parameter #2 for queries.</summary>
	Public Const API_QUERY_2 As String = "SEARCH2"
	
	''' <summary>API call search parameter to send messages.</summary>
	Public Const API_SEND_MSG As String = "MSGSRCDST"

	''' <summary>API call setting parameter for main setting.</summary>
	Public Const API_SETTING  As String = "SETTING"

	''' <summary>API call setting parameter for first sub setting.</summary>
	Public Const API_SETTING_1  As String = "SETTING1"

	''' <summary>API call setting parameter for second sub setting.</summary>
	Public Const API_SETTING_2 As String = "SETTING2"

	''' <summary>API call search parameter for specifying the status.</summary>
	Public Const API_STATUS As String = "STATUS"


	'' Constants used in API calls, as search tokens inserted after the "=".


	''' <summary>API token to set/get the device type.</summary>
	Public Const API_DEVICE_TYPE As String = "TYPE"

	''' <summary>API enable timeout.</summary>
	Public Const API_ENABLE_TIMEOUT As String = "TIMEOUT"	

	''' <summary>API token get all values available (inserted after the "=").</summary>
	Public Const API_GET_ALL As String = "ALL"

	''' <summary>API token to get the FCM token (inserted after the "=").</summary>
	Public Const API_GET_FCMTOKEN As String = "FCM"	
		
	''' <summary>API token to invoke user must activate their account (inserted after the "=").</summary>
	Public Const API_MUST_ACTIVATE As String = "MUSTACTIVATE"

	''' <summary>API token to send password email (inserted after the "=").</summary>
	Public Const API_SEND_PW_EMAIL As String = "PWEMAIL"
	
	''' <summary>API token to check if account activate (inserted after the "=").</summary>
	Public Const API_QUERY_ACTIVATED As String = "ACTIVATED"

	''' <summary>API token to check if centre is open (inserted after the "=").</summary>
	Public Const API_OPEN_QUERY As String = "OPEN"

	''' <summary>API token to check if customer signed on/off to centre (inserted after the "=").</summary>
	Public Const API_QUERY_SIGNON As String = "SIGNON"

	''' <summary>API token get revision number of document (inserted after the "=").</summary>
	Public Const API_REVISION As String = "REV"

	''' <summary>API token to set the fcm token (inserted after the "=").</summary>
	Public Const API_SET_FCMTOKEN As String = "FCMTOKEN"

	''' <summary>API token to set the centre signon value (inserted after the "=").</summary>
	Public Const API_SET_SIGNON As String = "CENTRESIGNON"

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

' Builds the API CustomerId string. 
Public Sub BuildApiCustomerId() As String
	Dim aspCustomerIdStr As String = NumberFormat2(Starter.myData.customer.customerId, 3, 0, 0, False)
	If Starter.myData.customer.customerId >= CUSTOMERID_LEGACY_THRESHOLD Or Starter.myData.customer.rev > 0 Then
		aspCustomerIdStr = aspCustomerIdStr  + NumberFormat(Starter.myData.customer.rev, 2, 0)
	End If
	Return aspCustomerIdStr
End Sub

' Convert ApiCustomerId integer to a string for inserting in URLs
Public Sub ConvertApiId(apiCustomerId As Int) As String
	Return NumberFormat2(apiCustomerId, 3, 0, 0, False)
End Sub

' Converts a apiCustomerId to customerId.
public Sub ConvertApiIdToCustomerId(apiId As Int) As Int
	If apiId >= CUSTOMERID_LEGACY_THRESHOLD Then
		Return apiId/100
	Else
		Return apiId	
	End If
End Sub

' Converts a apiCustomerId to rev
Public Sub ConvertApiIdtoRev(apiId As Int) As Int
	If apiId >= CUSTOMERID_LEGACY_THRESHOLD Then
		Return apiId Mod 100
	Else
		Return 0
	End If
End Sub

' Converts a integer to string for embedding in the messages.
Public Sub ConvertToString(customerId As Int) As String
	Return NumberFormat2(customerId, 3, 0, 0, False)
End Sub

' Filters a email string (removes spaces and return it as lowercase).
Public Sub FilterEmailInput(email As String) As String
	Dim processedEmail As String = Regex.Replace( " ", email, "")
	Return processedEmail.ToLowerCase
End Sub

' Filters invalid character from inputStrg.
' Returns a filtered string
Public Sub FilterStringInput(inputStrg As String) As String
	Return Regex.Replace("[<>:\\""/\'&]", inputStrg, "")
End Sub

' Filter text in a textbox and updates it accordingly.
' textCntrl - text box control
' old the previous string in text box.
' new the new string in text box.
' Returns with invalid character filtered.
Public Sub TextBoxFilter(textCntrl As Object, old As String, new As String)
	Dim matchPattern As String = "[<>:\\""/\'&]"
	TextBoxFilterUsingPattern(textCntrl, new, matchPattern)
End Sub

' Filter text for emails in a textbox and updates it accordingly.
' textCntrl - text box control
' old the previous string in text box.
' new the new string in text box.
' Returns with invalid character filtered.
Public Sub TextBoxFilterEmail(textCntrl As Object, old As String, new As String)
	Dim matchPattern As String = "[<>:\\""/\'& ]" ' Includes a space (no spaces in emails)
	TextBoxFilterUsingPattern(textCntrl, new, matchPattern)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Filter text in a textbox and updates it accordingly.
' textCntrl - text box control
' new the new string in text box.
' match pattern as string.
' Returns with invalid character filtered.
Private Sub TextBoxFilterUsingPattern(textCntrl As Object, new As String, matchPattern As String)
	' code based on  https://www.b4x.com/android/forum/threads/need-help-with-textchanged.73301/#content
	
#if B4A 
	Dim edtTextCntrl As EditText = textCntrl
#else ' B4i
	Dim edtTextCntrl As TextField = textCntrl
#end if
	Try
		Dim m As Matcher ' IsMatch dont' work so having to use the matcher.
'		m = Regex.Matcher("[<>:\\""/\'&]", new)
		m = Regex.Matcher(matchPattern, new)
		If  m.Find = True Then ' Invalid character found?		
#if B4A	
			edtTextCntrl.Text = FilterStringInput(new)
'			Dim a As String = edtTextCntrl.text
			edtTextCntrl.SelectionStart = edtTextCntrl.Text.Length
#else
'			' using suggestion from https://www.b4x.com/android/forum/threads/strange-text_changed-behaviour.107128/#post-670192
			edtTextCntrl.Text = ""	' Workaround problem with iphone edtTextCntrl.text.
			edtTextCntrl.Text = FilterStringInput(new)
#end if
		End If
	Catch
		Log(LastException)
	End Try
End Sub

#End Region  Local Subroutines