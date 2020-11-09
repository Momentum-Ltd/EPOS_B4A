B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=8.28
@EndOfDesignText@
'
' This class contains the app settings.
'

#Region  Documentation
	'
	' Name......: clsConfigSettings
	' Release...: 18
	' Date......: 05/10/20
	'
	' History
	' Date......: 06/07/18
	' Release...: 1
	' Created by: D Hathway
	' Details...: First release to support version tracking
	'
	' History v2 - 8 see v9.
	'          9 - 17 see v17
	'
	' Date......: 04/07/19
	' Release...: 9
	' Overview..: Option to control FCM notification behaviour also now able to save default settings.
	' Amendee...: D Morris
	' Details...: Added: allFcmNotification, pSaveDefaults.
	'
	' Date......: 05/07/19
	' Release...: 10
	' Overview..: Default selection is now Web operation.
	' Amendee...: D Morris.
	' Details...: Mod: Defaults changed to select web operation. 
	'
	' Date......: 30/07/19
	' Release...: 11
	' Overview..: Support for newWebStartup flag removed.
	' Amendee...: D Morris
	' Details...: Mod: lLoadDefaults(), pLoadSettings() and pSaveSettings() newWebStartup removed. 
	'
	' Date......: 11/08/19
	' Release...: 12
	' Overview..: Changes to support x-platform operation.
	' Amendee...: D Morris
	' Details...:  Mod: To overcome IOS problems with read/write booleans- webOnlyComms and allFcmNotification
	'						 are stored as strings.
	'
	' Date......: 14/08/19
	' Release...: 13
	' Overview..: Names changes to methods - bring in-line with IOS version.
	' Amendee...: D Morris
	' Details...:    Mod: prefix 'p' adn 'l' dropped from sub names.
	'			  Bugfix: enableStreamLineSignon is now handled correctly fixed LoadSettings() and SaveSettings().
	'				 Mod: enableStreamLineSignon is now always set true (redundant).
		'
	' Date......: 17/11/19
	' Release...: 14
	' Overview..: Support for test mode setting.
	' Amendee...: D Morris
	' Details...:  Added: Element testMode plus supported code.
	'
	' Date......: 01/12/19
	' Release...: 15
	' Overview..: Bugfix: #0216 - restore default settings if settings file corrupted.
	' Amendee...: D Morris
	' Details...:  Mod: LoadSettings() - try/catch added.
	'
	' Date......: 11/06/20
	' Release...: 16
	' Overview..: Improved checks on Server and internet.
	' Amendee...: D Morris
	' Details...:  Mod: Support for Server API URL.
	'
	' Date......: 02/07/20
	' Release...: 17
	' Overview..: Bufix: allowEntryOfUCN now saved as boolean value.
	' Amendee...: D Morris
	' Details...:  Bugfix: LoadSettings(). SaveSettings().
	'
	' Date......: 05/10/20
	' Release...: 18
	' Overview..: Add: Support for test centrs and search parameters.
	' Amendee...: D Morris.
	' Details...: Added: Support for maxCentres, searchRadius, showTestCentres and unitKm.
	'			    Mod: LoadDefaults() now public.
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
	
	' Local constants
	' X-platform related.
	Private xui As XUI		'Ignore
	
	' Settings for Web/newWeb/wifi
'	Private Const DFT_NEWWEBSTARTUP As Boolean = True
	Private Const DFT_WEB_ONLY_COMMS As Boolean = True	
	
	' other settings
	Private const DFT_ALL_FCM_NOTIVICATION As Boolean = False
	Private Const DFT_ALLOW_UCN As Boolean = False
	Private Const DFT_CONNECTION_TIMEOUT As Int = 10
	Private Const DFT_RECONNECT_TIMEOUT As Int = 5
	Private Const DFT_SERVER_CHECK_INTERVAL As Int = 30
	Private Const DFT_SERVER_CHECK_TIMEOUT As Int = 5
	Private Const DFT_SERVER_API_URL As String = "https://www.superord.co.uk/api" ' modEposWeb.URL_WEB_SERVER_1_API' don't work!!!
	Private Const DFT_STREAMLINE_SIGNON As Boolean = True
	Private Const DFT_TESTMODE As Boolean = False
	Private Const DFT_WIFI_HYSTERESIS As Int = 10
	Private Const DFT_WIFI_LOW_THRESHOLD As Int = 30
	' New values 
	Private Const DFT_MAX_CENTRES As Int = 20
	Private Const DFT_SEARCH_RADIUS As Int = 250
	Private Const DFT_SHOW_TEST_CENTRES As Boolean = False
	Private Const DFT_UNIT_KM As Boolean = False ' Miles selected
	
	
	Private const MAPKEY_ALL_FCM_NOTIFICATION As String = "allFcnNotification"
	Private Const MAPKEY_ALLOW_UCN As String = "allowEntryOfUCN"
	Private Const MAPKEY_CONNECTION_TIMEOUT As String = "connectionTimeout"
	Private Const MAPKEY_RECONNECT_TIMEOUT As String = "reconnectTimeout"
	Private Const MAPKEY_SERVER_API_URL As String = "serverApiUrl"	
	Private Const MAPKEY_SERVER_CHECK_INTERVAL As String = "serverCheckInterval"
	Private Const MAPKEY_SERVER_CHECK_TIMEOUT As String = "serverCheckTimeout"
	Private Const MAPKEY_STREAMLINE_SIGNON As String = "enableStreamLineSignon"
	Private Const MAPKEY_TESTMODE As String = "testMode"
	Private Const MAPKEY_WEB_ONLY_COMMS As String = "webOnlyComms"	
	Private Const MAPKEY_WIFI_HYSTERESIS As String = "wifiHysteresis"
	Private Const MAPKEY_WIFI_LOW_THRESHOLD As String = "wifiLowThreshold"
	' New values
	Private Const MAPKEY_MAX_CENTRES As String = "maxCentres"
	Private Const MAPKEY_SEARCH_RADIUS As String = "seachRadius"
	Private Const MAPKEY_SHOW_TEST_CENTRES As String = "showTestCentres"
	Private Const MAPKEY_UNIT_KM As String = "unitKm"
	
	
	Private Const SETTINGS_FILENAME As String = "ConfigSettings.map"
	
	' Public variables
	Public allFcmNotification As Boolean 	' When set all FCM message raise notification
	Public allowEntryOfUCN As Boolean 		' Whether the user can enter their Unique Customer Number when connecting (otherwise, Daily ID)
	Public connectionTimeout As Int 		' The length of time (in seconds) before timeout, when first connecting to the server
	Public enableStreamLineSignon As Boolean ' Whether to use the streamlined sign-on operation (this is currently redundant)
	Public reconnectTimeout As Int 			' The length of time (in seconds) before timeout, when automatically reconnecting to the server
	Public serverApiUrl As String 			' Server API URL	
	Public serverCheckInterval As Int 		' The length of time (in seconds) between automatic checks if the server is online
	Public serverCheckTimeout As Int 		' The length of time (in seconds) before timeout, when checking if the server is online

	Public testMode As Boolean				' Selects phone's test mode.
	Public webOnlyComms As Boolean 			' All communications via the Web Server.	
	Public wifiHysteresis As Int 			' The additional percentage to be added to the Low Threshold warning, to act as hysteresis
	Public wifiLowThreshold As Int 			' The Wifi connection percentage at which to register a Low Wifi warning
	
	' New Values
	Public maxCentres As Int				' Maximum number of centres displayed in a search.
	Public searchRadius As Int				' Search radius (km/miles).
	Public showTestCentres As Boolean		' When set test Centres are shown in search results.
	Public unitKm As Boolean				' When set units are shown in km.
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

' Initializes the app settings object, setting all its members to their default values.
Public Sub Initialize
	LoadDefaults	' Set up values to their defaults
End Sub

' Load default settings.
public Sub LoadDefaults
	allFcmNotification = DFT_ALL_FCM_NOTIVICATION
	allowEntryOfUCN = DFT_ALLOW_UCN
	connectionTimeout = DFT_CONNECTION_TIMEOUT
	enableStreamLineSignon = DFT_STREAMLINE_SIGNON
	reconnectTimeout = DFT_RECONNECT_TIMEOUT
	serverApiUrl = DFT_SERVER_API_URL
	serverCheckInterval = DFT_SERVER_CHECK_INTERVAL
	serverCheckTimeout = DFT_SERVER_CHECK_TIMEOUT
	testMode = DFT_TESTMODE
	wifiHysteresis = DFT_WIFI_HYSTERESIS
	wifiLowThreshold = DFT_WIFI_LOW_THRESHOLD
	webOnlyComms = DFT_WEB_ONLY_COMMS
	
	' New values
	maxCentres = DFT_MAX_CENTRES
	searchRadius = DFT_SEARCH_RADIUS
	showTestCentres = DFT_SHOW_TEST_CENTRES
	unitKm = DFT_UNIT_KM
End Sub

' Loads the app settings from their file.
' If any or all of the settings cannot be read, they will be assigned their default values.
Public Sub LoadSettings
	Try
#if B4A
		If File.Exists(File.DirInternal, SETTINGS_FILENAME) Then
			Dim mapConfig As Map = File.ReadMap(File.DirInternal, SETTINGS_FILENAME)
#else ' B4I
		If File.Exists(File.DirLibrary, SETTINGS_FILENAME) Then
			Dim mapConfig As Map = File.ReadMap(File.DirLibrary, SETTINGS_FILENAME)
#End If
			allFcmNotification = ReadBooleanStrgValue(mapConfig.GetDefault(MAPKEY_ALL_FCM_NOTIFICATION, WriteBooleanStrgValue(DFT_ALL_FCM_NOTIVICATION)))
			allowEntryOfUCN = ReadBooleanStrgValue(mapConfig.GetDefault(MAPKEY_ALLOW_UCN, WriteBooleanStrgValue(DFT_ALLOW_UCN)))
			connectionTimeout = mapConfig.GetDefault(MAPKEY_CONNECTION_TIMEOUT, DFT_CONNECTION_TIMEOUT)
			enableStreamLineSignon = ReadBooleanStrgValue( mapConfig.GetDefault(MAPKEY_STREAMLINE_SIGNON,WriteBooleanStrgValue( DFT_STREAMLINE_SIGNON)))
			reconnectTimeout = mapConfig.GetDefault(MAPKEY_RECONNECT_TIMEOUT, DFT_RECONNECT_TIMEOUT)
			serverApiUrl = mapConfig.GetDefault(MAPKEY_SERVER_API_URL, DFT_SERVER_API_URL)			
			serverCheckInterval = mapConfig.GetDefault(MAPKEY_SERVER_CHECK_INTERVAL, DFT_SERVER_CHECK_INTERVAL)
			serverCheckTimeout = mapConfig.GetDefault(MAPKEY_SERVER_CHECK_TIMEOUT, DFT_SERVER_CHECK_TIMEOUT)

			testMode = ReadBooleanStrgValue(mapConfig.GetDefault(MAPKEY_TESTMODE, WriteBooleanStrgValue( DFT_TESTMODE)))
			webOnlyComms = ReadBooleanStrgValue(mapConfig.GetDefault(MAPKEY_WEB_ONLY_COMMS, WriteBooleanStrgValue(DFT_WEB_ONLY_COMMS)))
			wifiHysteresis = mapConfig.GetDefault(MAPKEY_WIFI_HYSTERESIS, DFT_WIFI_HYSTERESIS)
			wifiLowThreshold = mapConfig.GetDefault(MAPKEY_WIFI_LOW_THRESHOLD, DFT_WIFI_LOW_THRESHOLD)
			
			enableStreamLineSignon = DFT_STREAMLINE_SIGNON	' Now always true (redundant)
			
			' New values
			maxCentres = mapConfig.GetDefault(MAPKEY_MAX_CENTRES, DFT_MAX_CENTRES)
			searchRadius = mapConfig.GetDefault(MAPKEY_SEARCH_RADIUS, DFT_SEARCH_RADIUS)
			showTestCentres = ReadBooleanStrgValue(mapConfig.GetDefault(MAPKEY_SHOW_TEST_CENTRES, WriteBooleanStrgValue(DFT_SHOW_TEST_CENTRES)))
			unitKm = ReadBooleanStrgValue(mapConfig.GetDefault(MAPKEY_UNIT_KM, WriteBooleanStrgValue(DFT_UNIT_KM)))
		End If		
	Catch
		Log(LastException)
#if B4A
		CallSubDelayed3(Starter, "LogReport", modEposApp.ERROR_LIST_FILENAME, "Problem with Settings file:" & CRLF & SETTINGS_FILENAME )
#else ' B4I
		' Starter.LogReport(Starter, "LogReport", modEposApp.ERROR_LIST_FILENAME, "Problem with Settings file:" & CRLF & SETTINGS_FILENAME )
#end if
		SaveDefaults		
		xui.MsgboxAsync("This device has be reset to its default settings.", "Settings file corrupted")
		Wait for msgbox_result (result As Int)	
	End Try
End Sub

' Save default settings to file
Public Sub SaveDefaults
	LoadDefaults
	SaveSettings
End Sub

' Saves the app settings to their file.
Public Sub SaveSettings
	Dim mapConfig As Map : mapConfig.Initialize
	mapConfig.Put(MAPKEY_ALL_FCM_NOTIFICATION, WriteBooleanStrgValue(allFcmNotification))
	mapConfig.Put(MAPKEY_ALLOW_UCN, WriteBooleanStrgValue(allowEntryOfUCN))
	mapConfig.Put(MAPKEY_CONNECTION_TIMEOUT, connectionTimeout)
	mapConfig.Put(MAPKEY_STREAMLINE_SIGNON, WriteBooleanStrgValue(enableStreamLineSignon))
	mapConfig.Put(MAPKEY_RECONNECT_TIMEOUT, reconnectTimeout)
	mapConfig.Put(MAPKEY_SERVER_API_URL, serverApiUrl)
	mapConfig.Put(MAPKEY_SERVER_CHECK_INTERVAL, serverCheckInterval)
	mapConfig.Put(MAPKEY_SERVER_CHECK_TIMEOUT, serverCheckTimeout)
	mapConfig.Put(MAPKEY_TESTMODE, WriteBooleanStrgValue(testMode))
	mapConfig.Put(MAPKEY_WEB_ONLY_COMMS, WriteBooleanStrgValue(webOnlyComms))
	mapConfig.Put(MAPKEY_WIFI_HYSTERESIS, wifiHysteresis)
	mapConfig.Put(MAPKEY_WIFI_LOW_THRESHOLD, wifiLowThreshold)
	
	' New values
	mapConfig.Put(MAPKEY_MAX_CENTRES, maxCentres)
	mapConfig.Put(MAPKEY_SEARCH_RADIUS, searchRadius)
	mapConfig.Put(MAPKEY_SHOW_TEST_CENTRES, WriteBooleanStrgValue(showTestCentres))
	mapConfig.Put(MAPKEY_UNIT_KM, WriteBooleanStrgValue(unitKm))
#if B4A
	File.WriteMap(File.DirInternal, SETTINGS_FILENAME, mapConfig)
#Else
	File.WriteMap(File.DirLibrary, SETTINGS_FILENAME, mapConfig)
#End If
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines



' Convert a map boolean string to boolean value.
private Sub ReadBooleanStrgValue(booleanStrg As String) As Boolean
	Dim boolValue As Boolean = False
	If booleanStrg = "t" Then
		boolValue = True
	End If
	Return boolValue
End Sub

' Convert a boolean value to map boolean string.
private Sub WriteBooleanStrgValue(boolValue As Boolean) As String
	Dim booleanStrg As String = "f"
	If boolValue Then
		booleanStrg = "t"
	End If
	Return booleanStrg
End Sub

#End Region  Local Subroutines
