B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' Class to store centre information
'
#Region  Documentation
	'
	' Name......: clsCentreInfo
	' Release...: 11
	' Date......: 05/08/20
	'
	' History
	' Date......: 05/08/19
	' Release...: 1
	' Created by: D Morris (started 5/8/19)
	' Details...: First release to support version tracking
	'
	' Versions 2 - 8 see v10.
	'
	' Date......: 26/04/20
	' Release...: 9
	' Overview..: Bugfix: Always reporting corrupt files after installation.
	' Amendee...: D Morris
	' Details...: Added: SaveDefault().
	'			  Bugfix: Load().
	'				Mod: Save() now returns a boolean.
	'
	' Date......: 28/06/20
	' Release...: 10
	' Overview..: Add #0395 Select centre pictures (More work to download from Web Server).
	' Amendee...: D Morris
	' Details...:  Added: picture with support code.
	'
	' Date......: 05/08/20
	' Release...: 11
	' Overview..: Centre picture bitmap saved.
	' Amendee...: D Morris.
	' Details...:  Added: pictureBitMap
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
	' Constants
	Private Const CENTREINFO_FILENAME As String = "CentreInfoFile.map" ' Name of the file in which this class is stored.
	
	' X-platform related.
	Private xui As XUI						'Ignore
	
	' Public variables
	Public acceptCards As Boolean			' Cards accepted by centre.
	Public address As String				' Address of centre.
	Public allowDeliverToTable As Boolean 	' Indicates if option to delivery to table is available for this order.	
	Public centreId As Int					' Selected centre's ID (also see signed-on below).
	Public disableCustomMessage As Boolean	' Indicates whether the order's custom message should be inhibited.
	Public name As String					' Centre's name.
	Public picture As String				' Centres picture image file (situated on Web server in centreimages folder).
	Public postCode As String				' Centre's postcode.
	Public publishedKey As String			' The CPP published key for the centre.
	Public signedOn As Boolean				' Set whilst customer is signed onto the centre.
	
	' Tnis data is not saved to file
	Public 	pictureBitMap As Bitmap			' Picture of centre. 
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

' Clears centre information
Public Sub Clear
	acceptCards = False
	address = ""
	allowDeliverToTable = False
	centreId = 0
	disableCustomMessage = True
	name = ""
	picture = ""
	postCode = ""
	publishedKey = ""
	signedOn = False
End Sub

' Deletes the file in which the centre info is stored.
public Sub Delete
#if B4A
	If File.Exists(File.DirInternal, CENTREINFO_FILENAME) Then
		File.Delete(File.DirInternal, CENTREINFO_FILENAME)
	End If
#else
	If File.Exists(File.DirLibrary, CENTREINFO_FILENAME) Then
		File.Delete(File.DirLibrary, CENTREINFO_FILENAME)
	End If
#end if

End Sub

' Attempts to load the centre info from the file in which it is stored, and returns whether the file exists.
'Public Sub Load As ResumableSub
Public Sub Load As Boolean
	Dim loadOk As Boolean = False
#if B4A
	If File.Exists(File.DirInternal, CENTREINFO_FILENAME) Then
		Dim mapCustomerInfo As Map = File.ReadMap(File.DirInternal, CENTREINFO_FILENAME)
#else ' B4i
	If File.Exists(File.DirLibrary, CENTREINFO_FILENAME) Then
		Dim mapCustomerInfo As Map = File.ReadMap(File.DirLibrary, CENTREINFO_FILENAME)
#end if
		If CvtFromMap(mapCustomerInfo) = True Then
			loadOk = True
		Else ' ' Can't read the map.
			SaveDefault
#if B4A
			ToastMessageShow("Centre settings file corrupted, default loaded.", True)
#else ' B4I
			Main.ToastMessageShow("Centre settings file corrupted, default loaded.", True)
#end if	
#if B4A
			CallSubDelayed3(Starter, "LogReport", modEposApp.ERROR_LIST_FILENAME, "Default Centre settings loaded:" & CRLF & CENTREINFO_FILENAME & CRLF & LastException )
#else ' B4I
			' Starter.LogReport(Starter, "LogReport", modEposApp.ERROR_LIST_FILENAME, "Default Centre settings loaded:" & CRLF & CENTREINFO_FILENAME & CRLF & LastException  )
#end if
		End If
	Else ' File does not exist - create a new one!
		loadOk = SaveDefault
	End If
'	Log("IMPORTANT - A fixed is required here!")
	pictureBitMap = LoadBitmap(File.DirAssets, "ImageNotAvailableSmall.png")
	Return loadOk
End Sub

' Saves the centre info to its file.
Public Sub Save As Boolean
	Dim mapCentre As Map : mapCentre.Initialize
	mapCentre = CvtToMap
#if B4A
	File.WriteMap(File.DirInternal, CENTREINFO_FILENAME, mapCentre)
#else
	File.WriteMap(File.DirLibrary, CENTREINFO_FILENAME, mapCentre)
#end if
	Return True 'TODO Needs to check if Save() worked and return the correct value
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines
' Convert to information from a map
private Sub CvtFromMap(mapCentre As Map) As Boolean
	Dim convertOk As Boolean = False
	Try
		acceptCards = modConvert.ConvertStringToBoolean(mapCentre.GetDefault("acceptCards", False))
		address = mapCentre.GetDefault("address", "Address not available")
		allowDeliverToTable = modConvert.ConvertStringToBoolean(mapCentre.GetDefault("allowDeliverToTable", False))
		centreId = mapCentre.GetDefault("centreId", 0)
		disableCustomMessage = modConvert.ConvertStringToBoolean(mapCentre.GetDefault("disableCustomMessage", True))
		name = mapCentre.GetDefault("name", "Unknown name")
		picture = mapCentre.GetDefault("picture", "")
		postCode = mapCentre.GetDefault("postCode", "")
		publishedKey = mapCentre.GetDefault("publishedKey", "")
		signedOn = modConvert.ConvertStringToBoolean( mapCentre.GetDefault("signedOn", False))	
		convertOk = True	
	Catch
		Log(LastException)
	End Try
	Return convertOk
End Sub

' Convert information to a Map
Private Sub CvtToMap As Map
	Dim mapCentre As Map : mapCentre.Initialize
	mapCentre.Put("acceptCards", modConvert.ConvertBooleanToString(acceptCards))
	mapCentre.Put("address", address)
	mapCentre.Put("allowDeliverToTable", modConvert.ConvertBooleanToString(allowDeliverToTable))
	mapCentre.Put("centreId", centreId)
	mapCentre.Put("disableCustomMessage", modConvert.ConvertBooleanToString(disableCustomMessage))
	mapCentre.Put("name", name)
	mapCentre.Put("picture", picture)
	mapCentre.Put("postCode", postCode)
	mapCentre.Put("publishedKey", publishedKey)
	mapCentre.Put("signedOn", modConvert.ConvertBooleanToString(signedOn))
	Return mapCentre
End Sub

' Saves default customer information to file
private Sub SaveDefault As Boolean
	Clear
	Save
	Return True 'TODO Needs to check if Save() worked and return the correct value
End Sub

#End Region  Local Subroutines