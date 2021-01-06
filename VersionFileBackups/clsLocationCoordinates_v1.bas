B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'
' Class for storing Location coordinates
'
#Region  Documentation
	'
	' Name......: clsLocationCoordinates
	' Release...: 1
	' Date......: 03/01/21
	'
	' History
	' Date......: 03/01/21
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
	Public latitude As Double		' Latitude storage
	Public longitude As Double 		' Longitude storage
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	latitude = 0
	longitude = 0
End Sub

' Updates the stored coordinates.
Public Sub Update(platitude As Double, plongitude As Double)
	latitude = platitude
	longitude = plongitude
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines