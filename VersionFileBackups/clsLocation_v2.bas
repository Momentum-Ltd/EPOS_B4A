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
	' Release...: 2-
	' Date......: 01/11/20
	'
	' History
	' Date......: 12/07/20
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version.
	'
	' Date......: 01/11/20
	' Release...: 2
	' Overview..: Support for iOS
	' Amendee...: D Morris
	' Details...: Working version fo iOS
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
#if B4A
	Public flp As FusedLocationProvider
	Private flpStarted As Boolean

#else ' B4i
	Private locManager As LocationManager
	Private mCurrentLocation As Location
	
	Private locationAvailable As Boolean
	Private centresDisplayed As Boolean
'	Private tmrAutoStartDisplayCentres As Timer
#End If
	' Required for event handling
	Private mCallback As Object
	Private mEvent As String
	Private tmrLocationReadyTimeout As Timer
	
	Private LOCATION_RERDY_TIMEOUT As Int = 3000
End Sub

#Event: LocationReady

' Initialize and start 
' String used for call back ' Can't use "me" if used with starter server.
Public Sub Initialize(callback As Object, eventName As String)
	mCallback = callback
	mEvent = eventName
#if B4A
	flp.Initialize("flp")
	Connect
#else ' B4i
	locManager.Initialize("locManager")
#End If
	mCurrentLocation.Initialize2(0,0)
	tmrLocationReadyTimeout.Initialize("tmrLocationReadyTimeout", LOCATION_RERDY_TIMEOUT)
End Sub

#End Region  Mandatory Subroutines & Data



#Region  Event Handlers

'#if B4i
'Private Sub EventName_LocationChanged (Location1 As Location)
'	
'End Sub
'#End If


#if B4A
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
#else ' B4i

' iOS Location ready handler.
private Sub locManager_LocationChanged (thisLocation As Location)
	tmrLocationReadyTimeout.Enabled = False
	mCurrentLocation = thisLocation
	CallSub2(mCallback, mEvent & "_" & "LocationReady" , thisLocation)
End Sub
#End If
' Raised when Authorizations status changed (raised when the location manager is intialiized).
Private Sub LocManager_AuthorizationStatusChanged (Status As Int)
	Log("Location authorization changed Status = " & Status)
End Sub

' Location ready timeout
Private Sub tmrLocationReadyTimeout_Tick
	tmrLocationReadyTimeout.Enabled = False
	CallSub2(mCallback, mEvent & "_" & "LocationReady" , mCurrentLocation)
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

'' Connect to GPS Location service.
'Public Sub Connect
'#if B4A
'	flp.Connect()
'#else ' B4i
'
'#End If
'
'End Sub

'' Is device connected Query.
'Public Sub IsConnected As Boolean
'#if B4A
'	Return flp.IsConnected
'#else ' B4i
'
'#End If
'
'End Sub

' Gets the Last known location.
Public Sub GetLocation As Location
#if B4A
	Return flp.GetLastKnownLocation	
#else ' B4i
	Return mCurrentLocation
#End If
End Sub

' Is location device authorized?
public Sub IsLocationAuthorized() As Boolean
	Return locManager.IsAuthorized 
End Sub

' Is Location available
Public Sub IsLocationAvailable() As Boolean
	Dim locationAvailable As Boolean = False
	If locManager.IsAuthorized = True Then
		If mCurrentLocation.IsInitialized = True Then
			If mCurrentLocation.Latitude <> 0 And mCurrentLocation.Longitude <> 0 Then
				locationAvailable = True
			End If
		End If
	End If
	Return locationAvailable
End Sub

'' Restart Location
'' interval - time interval in mSecs, displacement is smallest displacement in meters.
'Public Sub Restart(interval As Int, displacement As Int) As ResumableSub
'	Stop
'	wait for (Start(interval, displacement)) complete (success As Boolean)
'	Return success
'End Sub

'' Start Location
'' interval - time interval in mSecs, displacement is smallest displacement in meters.
'Public Sub Start(interval As Int, displacement As Int) As ResumableSub
'	Do While IsConnected = False
'		Sleep(1000)
'	Loop
'#if B4A
'	If flpStarted = False Then
'		RequestLocationUpdates(interval, displacement)
'		flpStarted = True
'	End If
'#Else ' B4i
'	StartLocationUpdates
'#End If
'	Dim success As Boolean = True
'	Return success
'End Sub

' Start Location
public Sub Start
	LocationDeviceStart
	tmrLocationReadyTimeout.Enabled = True
End Sub

' Stop Location
Public Sub Stop
	tmrLocationReadyTimeout.Enabled = False	
	LocationDeviceOFF
End Sub


#End Region  Public Subroutines

#Region  Local Subroutines
' Sets up the location request.
' Switch off location device.
private Sub LocationDeviceOFF
#if B4A
	If mLocator.IsInitialized Then ' bit of protect - disconnect has thrown exception
		mLocator.Disconnect
	End If
#Else	
	locManager.Stop ' looks like check not required for iOS.
#End If
End Sub

#if B4A
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
	flp.RemoveLocationUpdates
End Sub

' Request location updates
' interval - time interval in mSecs, displacement is smallest displacement in meters.
Private Sub RequestLocationUpdates(interval As Int, displacement As Int)
	flp.RequestLocationUpdates(CreateLocationRequest(interval, displacement))
End Sub
#else ' B4i
' Start the locations updates
Private Sub LocationDeviceStart
	'if the user allowed us to use the location service or if we never asked the user before then we call LocationManager.Start.
'	If locManager.IsAuthorized Or locManager.AuthorizationStatus = locManager.AUTHORIZATION_NOT_DETERMINED Then
		locManager.Start(0)
'	Else
'		tmrAutoStartDisplayCentres.Enabled = True ' Location device not working so use autoStart to invoke a list of centres.
'	End If
End Sub
#End If


#End Region  Local Subroutines
