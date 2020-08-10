B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' Class to store device information
'

#Region  Documentation
	'
	' Name......: clsDeviceInfo
	
	' Release...: 1
	' Date......: 08/08/19
	'
	' History
	' Date......: 08/08/19
	' Release...: 1
	' Created by: D Morris (started 5/8/19)
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
	Private Const DEVICEINFO_FILENAME As String = "DeviceInfoFile.map" ' Name of the file in which this class is stored.
	
	Public fcmToken	As String		' FCM token
	Public deviceType As String 		' Device type (andriod or IOS device).
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

' Clears device information.
Public Sub Clear
	fcmToken = ""
	deviceType = GetDeviceType ' Device type is fixed by hardware
End Sub
' Convert information from a map
public Sub CvtFromMap(mapDevice As Map)
	fcmToken = mapDevice.GetDefault("fcmToken", "")
	deviceType = mapDevice.GetDefault("deviceType", GetDeviceType)
End Sub

' Convert information to a map
Public Sub CvtToMap As Map
	Dim mapDevice As Map : mapDevice.initialize
	mapDevice.Put("fcmToken", fcmToken)
	mapDevice.Put("deviceType", deviceType)
	Return mapDevice
End Sub

' Deletes the file in which the Device info is stored.
public Sub Delete
#if B4A
	If File.Exists(File.DirInternal, DEVICEINFO_FILENAME) Then
		File.Delete(File.DirInternal, DEVICEINFO_FILENAME)
	End If
#else
	If File.Exists(File.DirLibrary, DEVICEINFO_FILENAME) Then
		File.Delete(File.DirLibrary, DEVICEINFO_FILENAME)
	End If
#End If

End Sub

' Return the device type (fixed by the hardware)
public Sub GetDeviceType As String
#if B4A
	Return "0"
#else ' B4I
	Return "1"	
#End If
End Sub

' Attempts to load the Device info from the file in which it is stored, and returns whether the file exists.
Public Sub Load As Boolean
#if B4A
	Dim fileExists As Boolean = False
	If File.Exists(File.DirInternal, DEVICEINFO_FILENAME) Then
		Dim mapDeviceInfo As Map = File.ReadMap(File.DirInternal, DEVICEINFO_FILENAME)
		CvtFromMap(mapDeviceInfo)
		deviceType = GetDeviceType	' Device type fixed by hardware.
		fileExists = True
	End If
	Return fileExists

#else
	Dim fileExists As Boolean = False
	If File.Exists(File.DirLibrary, DEVICEINFO_FILENAME) Then
		Dim mapDeviceInfo As Map = File.ReadMap(File.DirLibrary, DEVICEINFO_FILENAME)
		CvtFromMap(mapDeviceInfo)
		deviceType = GetDeviceType	' Device type fixed by hardware.
		fileExists = True
	End If
	Return fileExists
#End If
End Sub
	
' Saves the centre info to its file.
Public Sub Save
#if B4A
	Dim mapDevice As Map : mapDevice.Initialize
	mapDevice = CvtToMap
	File.WriteMap(File.DirInternal, DEVICEINFO_FILENAME, mapDevice)
#else
	Dim mapDevice As Map : mapDevice.Initialize
	mapDevice = CvtToMap
	File.WriteMap(File.DirLibrary, DEVICEINFO_FILENAME, mapDevice)
#End If

End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines