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
	' Release...: 4
	' Date......: 03/01/21
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
	' Details...: Working version for iOS.
	'
	' Date......: 02/11/20
	' Release...: 3
	' Overview..: Version for B4A.
	' Amendee...: D Morris
	' Details...: Working version for B4A.
		'
	' Date......: 03/01/21
	' Release...: 4
	' Overview..: Updates Starter.latestLocation.
	' Amendee...: D Morris.
	' Details...: Mod: flp_LocationChanged() and locManager_LocationChanged().
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
	Private xui As XUI								'ignore (to remove warning) -  Required for X platform operation.	
#if B4A
	Public flp As FusedLocationProvider
	Private flpStarted As Boolean
#else ' B4i
	Private locManager As LocationManager
	Private locationAvailable As Boolean
	Private centresDisplayed As Boolean
'	Private tmrAutoStartDisplayCentres As Timer
#End If
	' Required for event handling
	Private mCallback As Object
	Private mEvent As String
	Private tmrLocationReadyTimeout As Timer
	Private mCurrentLocation As Location	
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
	flp.Connect ' This will then be handled in either mLocator_ConnectionSuccess() or mLocator_ConnectionFailed()
#else ' B4i
	locManager.Initialize("locManager")
#End If
	mCurrentLocation.Initialize2(0,0)
	tmrLocationReadyTimeout.Initialize("tmrLocationReadyTimeout", LOCATION_RERDY_TIMEOUT)
End Sub

#End Region  Mandatory Subroutines & Data



#Region  Event Handlers

#if B4A
' Handles Connection Success event.
Private Sub flp_ConnectionSuccess
	Log("Successfully connected to location services. Getting last known location...")
End Sub

' Handles Connection Failed event.
Sub flp_ConnectionFailed(ConnectResult As Int)
	Log("Failed to connect to location services. Reason code: " & ConnectResult)
	xui.MsgboxAsync("An error occurred while trying to get your location. All centres will now be displayed.", "Cannot Get Location")
End Sub

' Raised when location changed (new location available)
' See note in header about call from Starter service.
Private Sub flp_LocationChanged (thisLocation As Location)
	tmrLocationReadyTimeout.Enabled = False
	mCurrentLocation = thisLocation
	Starter.latestLocation.update(thisLocation.Latitude, thisLocation.Longitude)
	If xui.SubExists(mCallback, mEvent & "_LocationReady", 1) Then
		CallSubDelayed2(mCallback, mEvent & "_LocationReady", thisLocation)
	End If
End Sub
#else ' B4i

' iOS Location ready handler.
private Sub locManager_LocationChanged (thisLocation As Location)
	tmrLocationReadyTimeout.Enabled = False
	mCurrentLocation = thisLocation
	Starter.latestLocation.update(thisLocation.Latitude, thisLocation.Longitude)
	If xui.SubExists(mCallback, mEvent & "_LocationReady", 1) Then
		CallSubDelayed2(mCallback, mEvent & "_LocationReady" , thisLocation)	
	End If
End Sub

' Raised when Authorizations status changed (raised when the location manager is intialiized).
Private Sub LocManager_AuthorizationStatusChanged (Status As Int)
	Log("Location authorization changed Status = " & Status)
End Sub

#End If


' Location ready timeout
Private Sub tmrLocationReadyTimeout_Tick
	tmrLocationReadyTimeout.Enabled = False
	CallSub2(mCallback, mEvent & "_LocationReady" , mCurrentLocation)
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

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
#if B4A
	Return flp.IsConnected ' HACK - not sure this is the best thing to do!
#else ' B4i
	Return locManager.IsAuthorized 
#End If
End Sub

' Is Location available
Public Sub IsLocationAvailable() As Boolean
	Dim locationAvailable As Boolean = False
	If IsLocationAuthorized = True Then
		If mCurrentLocation.IsInitialized = True Then
			If mCurrentLocation.Latitude <> 0 And mCurrentLocation.Longitude <> 0 Then
				locationAvailable = True
			End If
		End If
	End If
	Return locationAvailable
End Sub

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
'	If flp.IsInitialized Then ' bit of protect - disconnect has thrown exception
'		flp.Disconnect
'	End If
	If flpStarted Then
		flp.RemoveLocationUpdates
		flpStarted = False
	End If
#Else	
	locManager.Stop ' looks like check is not required for iOS.
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
#End If

' Start the locations updates
Private Sub LocationDeviceStart
#if B4A
'	flp.Connect ' This will then be handled in either mLocator_ConnectionSuccess() or mLocator_ConnectionFailed()
	Do While flp.IsConnected = False
		Sleep(1000)
	Loop
	If flpStarted = False Then
		flp.RequestLocationUpdates(CreateLocationRequest(10000, 1))
		flpStarted = True
	End If
#else ' B4i
	'if the user allowed us to use the location service or if we never asked the user before then we call LocationManager.Start.
'	If locManager.IsAuthorized Or locManager.AuthorizationStatus = locManager.AUTHORIZATION_NOT_DETERMINED Then
		locManager.Start(0)
'   End if
#End If
End Sub




#End Region  Local Subroutines
