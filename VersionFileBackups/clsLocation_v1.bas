B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.9
@EndOfDesignText@
'
' Location class 
'
' NOTE: Currently only to be used in B4A projects
#Region  Documentation
	'
	' Name......: clsLocation
	' Release...: 1
	' Date......: 12/07/20
	'
	' History
	' Date......: 12/07/20
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
	Private xui As XUI 'Ignore
	Public FLP As FusedLocationProvider
	Private flpStarted As Boolean
	
	' Required for event handling
	Private mCallback As String ' Can't use "me"
	Private mEvent As String


End Sub

' Initialize and start 
' String used for call back ' Can't use "me" if used with starter server.
Public Sub Initialize(callback As String, eventName As String)
	mCallback = callback
	mEvent = eventName
	FLP.Initialize("flp")
	Connect

End Sub

#End Region  Mandatory Subroutines & Data
' Handles Connection Success event.
Private Sub flp_ConnectionSuccess
	Log("Connected to location provider")
End Sub

' Handles Connection Failed event.
Sub flp_ConnectionFailed(ConnectionResult1 As Int)
	Log("Failed to connect to location provider")
End Sub

' Raised when location changed (new location available)
' See note in header about call from Starter service.
Private Sub flp_LocationChanged (Location1 As Location)
'	If xui.SubExists(mCallback, mEvent & "_LocationChanged", Location1) Then
	CallSubDelayed2(mCallback, mEvent & "_LocationChanged", Location1)
'	End If
End Sub
#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

' Connect to GPS service.
Public Sub Connect
	FLP.Connect()
End Sub

' Is device connected Query.
Public Sub IsConnected As Boolean
	Return FLP.IsConnected
End Sub

' Gets the Last known location.
Public Sub GetLastLocation As Location
	Return FLP.GetLastKnownLocation	
End Sub

' Restart Location
' interval - time interval in mSecs, displacement is smallest displacement in meters.
Public Sub RestartFLP(interval As Int, displacement As Int) As ResumableSub
	StopFLP
	wait for (StartFLP(interval, displacement)) complete (success As Boolean)
	Return success
End Sub

' Start Location
' interval - time interval in mSecs, displacement is smallest displacement in meters.
Public Sub StartFLP(interval As Int, displacement As Int) As ResumableSub
	Do While IsConnected = False
		Sleep(1000)
	Loop

	If flpStarted = False Then
		RequestLocationUpdates(interval, displacement)
		flpStarted = True
	End If
	Dim success As Boolean = True
	Return success
End Sub

' Stop Location
Public Sub StopFLP
	If flpStarted Then
		RemoveLocationUpdates
		flpStarted = False
	End If
End Sub


#End Region  Public Subroutines

#Region  Local Subroutines
' Sets up the location request.
Private Sub CreateLocationRequest(interval As Int, displacement As Int) As LocationRequest
	Dim lr As LocationRequest
	lr.Initialize
	lr.SetInterval(interval)
	lr.SetFastestInterval(lr.GetInterval / 2)
	lr.SetPriority(lr.Priority.PRIORITY_HIGH_ACCURACY)
	lr.SetSmallestDisplacement(displacement)
	Return lr
End Sub

' Remove location updates.
Private Sub RemoveLocationUpdates
	FLP.RemoveLocationUpdates
End Sub

' Request location updates
' interval - time interval in mSecs, displacement is smallest displacement in meters.
Private Sub RequestLocationUpdates(interval As Int, displacement As Int)
	FLP.RequestLocationUpdates(CreateLocationRequest(interval, displacement))
End Sub
#End Region  Local Subroutines
