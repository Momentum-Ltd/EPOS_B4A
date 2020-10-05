B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.01
@EndOfDesignText@
'
' Class to provide Centre Location information.
'

#Region  Documentation
	'
	' Name......: clsEposWebCentreLocationRec
	' Release...: 4
	' Date......: 05/10/20
	'
	' History
	' Date......: 06/06/19
	' Release...: 1
	' Created by: D Hathway
	' Details...: First release to support version tracking.
	'
	' Date......: 28/06/20
	' Release...: 2
	' Overview..: Add #0395 Select centre pictures (More work to download from Web Server).
	' Amendee...: D Morris
	' Details...:    Mod: address, description, picture, thumbnail and webSite.
	'
	' Date......: 02/08/20
	' Release...: 3
	' Overview..: Add support for distance.
	' Amendee...: D Morris
	' Details...: Added: distance element.
	'					 ConvertDistanceToString().
	'
	' Date......: 05/10/20
	' Release...: 4
	' Overview..: Support for units (km/miles).
	' Amendee...: D Morris
	' Details...: Mod: ConvertDistanceToString() now displays distance in km/miles.
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
	

	' Public data
	Public address As String 		' Centre address.
	Public centreName As String 	' The name of the centre.
	Public centreOpen As Boolean 	' Whether the centre's SuperServer instance is currently running.
	Public description As String	' Description of the Centre.
	Public distance As Float		' Distance (between customer and centre).
	Public id As Int 				' The ID of the centre.
	Public lanIpAddress As String 	' The most recent local IP address of the centre, for use when connecting via TCP socket.
	Public picture As String		' Centre picture (URL).
	Public postCode As String 		' The postcode of the centre (included as extra identifying information).
	Public thumbnail As String		' Centre Logo/thumbnail (URL).
	Public webSite As String		' Centre's Website (URL).
	
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

' Convert distance value to the appropriate string.
' Not pDistance is always km.
Public Sub ConvertDistanceToString(pDistance As Float) As String
	Dim distanceStrg As String = ""
	If pDistance >= 0 Then
		If Starter.settings.unitKm = True Then
			distanceStrg = NumberFormat(pDistance, 1, 1) & "km"		
		Else
			distanceStrg = NumberFormat(modConvert.ConvertKmToMiles(pDistance), 1, 1) & "ml" 	
		End If
	else if pDistance = modEposApp.CENTRE_DISTANCE_NA Then
		distanceStrg = "N.A."
	Else
		distanceStrg = ""
	End If
	Return distanceStrg
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize()
	' Currently nothing
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines
