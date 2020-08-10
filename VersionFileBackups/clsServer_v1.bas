B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
'
' Class for handling Servers
'
#Region  Documentation
	'
	' Name......: clsServer
	' Release...: 1
	' Date......: 11/06/20
	'
	' History
	' Date......: 11/06/20
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
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
	' Server information
	''' <summary> Web Server Centre API URL prefix.</summary>
	Public URL_CENTRE_API As String

	' Constants used by API call to select the appropriate controller.
	''' <summary> Web Server Customer API URL prefix.</summary>
	Public URL_CUSTOMER_API As String

	''' <summary> Web Server Communications API URL prefix.</summary>
	Public URL_COMMS_API As String

	''' <summary> Web Server centre-menu API URL prefix.</summary>
	Public URL_CENTREMENU_API As String
	
	
	' Private currentServerUrl As String
	
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(serverUrl As String)
	SelectServerUrl(serverUrl)
End Sub

' Get the current selected Server number
' Returns 1 (server #1) or 2 (server #2).
Public Sub GetServerNumber() As Int
	Dim serverNumber As Int = 1
	If Starter.settings.serverApiUrl = modEposWeb.URL_WEB_SERVER_2_API Then
		serverNumber = 2 
	End If
	Return serverNumber
End Sub

' Select a server (using number)
' Default is server #1
Public Sub SelectServer(serverNumber As Int) 
	If serverNumber = 2 Then
		SelectServerUrl(modEposWeb.URL_WEB_SERVER_2_API)
	Else
		SelectServerUrl(modEposWeb.URL_WEB_SERVER_1_API)
	End If
End Sub

' Toggle to other server
Public Sub ToggleServer()
	If Starter.settings.serverApiUrl = modEposWeb.URL_WEB_SERVER_1_API Then
		SelectServerUrl(modEposWeb.URL_WEB_SERVER_2_API)
	Else
		SelectServerUrl(modEposWeb.URL_WEB_SERVER_1_API)
	End If
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines
' Select server (using URL)
' This sub will chage all the controller URLs
private Sub SelectServerUrl(newServerUrl_API As String)
	Starter.settings.serverApiUrl = newServerUrl_API
	Starter.settings.SaveSettings
	URL_CENTRE_API = newServerUrl_API & modEposWeb.CONTROLLER_CENTRE_API
	URL_CUSTOMER_API = newServerUrl_API & modEposWeb.CONTROLLER_CUSTOMER_API
	URL_COMMS_API = newServerUrl_API & modEposWeb.CONTROLLER_COMMS_API
	URL_CENTREMENU_API = newServerUrl_API & modEposWeb.CONTROLLER_CENTREMENU_API
End Sub
#End Region  Local Subroutines