B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
'
' This is a class to handle GPS operation
'

#Region  Documentation
	'
	' Name......: clsGps
	' Release...: -
	' Date......: 16/11/19
	'
	' History
	' Date......: --/10/19
	' Release...: 1
	' Created by: 
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
'	Public rp As RuntimePermissions
	Public device As GPS
	
	Public latestLocation As Location
	
	Private gpsStarted As Boolean
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	device.Initialize("GPS")
End Sub

' Start GPS device
Public Sub StartGps
	If gpsStarted = False Then
		device.Start(0, 0)
		gpsStarted = True
	End If
End Sub

' Stop GPS device.
Public Sub StopGps
	If gpsStarted Then
		device.Stop
		gpsStarted = False
	End If
End Sub


Sub GPS_LocationChanged (Location1 As Location)
	'CallSub2(Main, "LocationChanged", Location1)
	' Generate events if required.
	Dim a As Int
	a = 2
	
	latestLocation = Location1	
End Sub


#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines