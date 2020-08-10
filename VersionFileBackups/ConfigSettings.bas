B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=8.28
@EndOfDesignText@
'
' This activity allows the user to modify the app's settings
'

#Region  Documentation
	'
	' Name......: ConfigSettings
	' Release...: 9-
	' Date......: 29/07/19
	'
	' History
	' Date......: 06/07/18
	' Release...: 1
	' Created by: D Hathway
	' Details...: First release to support version tracking
	'
	' Date......: 19/07/18
	' Release...: 2
	' Overview..: Support for streamlined sign-on
	' Amendee...: D Morris
	' Details...:  Mod: Checkbox added to form to control use of streamlined sign-on.
	'
	' Date......: 30/08/18
	' Release...: 3
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Change in form layout to ensure the checkbox added in the above update is displayed properly
	'
	' Date......: 10/10/18
	' Release...: 4
	' Overview..: Changes to prevent the ability to sign-on using Unique Customer Number or Daily ID Number.
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Changes to the layout file and associated code to remove the 'allow UCN' and 'enable streamline' views
	'
	' Date......: 28/01/19
	' Release...: 5
	' Overview..: Changes to allow the app to determine when it is no longer connected.
	' Amendee...: D Hathway
	' Details...:  Mod: Change in Activity_Pause() to kill this activity if the phone becomes disconnected from the server
	'
	' Date......: 04/06/19
	' Release...: 6
	' Overview..: Support for HTTP communications
	' Amendee...: D Morris
	' Details...: Added: Support for chkHttpEnable with handler support.
		'
	' Date......: 05/06/19
	' Release...: 7
	' Overview..: Support for Web Only communications setting.
	' Amendee...: D Morris
	' Details...: Mod: chkHttpEnable changed to chkWebOnlyComms.
	'			     : lDisplayCurrentSettings() now updates chkWebOnlyComms.
	'				 : btnAccept_Click() restored.
		'
	' Date......: 20/06/19
	' Release...: 8
	' Overview..: Support for New Web Startup option
	' Amendee...: D Morris
	' Details...:  Mod: frmconfigSettings new version.
		'
	' Date......: 04/07/19
	' Release...: 9
	' Overview..: Option control notification operation 
	' Amendee...: D Morris
	' Details...: Added: chkAllFcmNotification with support.
		'
	' Date......: 
	' Release...: 
	' Overview..: References to settings.newWebStartup removed.
	' Amendee...: D Morris
	' Details...: Mod: lDisplayCurrentSettings() and lSaveAllSettings().
	'			  Form: chkNewWebStartup removed.
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
End Sub

Sub Globals

	' Local variables
	Private mClosingActivity As Boolean ' Whether the activity will be fully finished (killed) the next time it disappears.
	
	' View declarations
	Private btnAccept As Button ' Button which saves the entered settings and closes the activity.
	Private btnCancel As Button ' Button which closes the activity without saving any changes to settings.
	Private chkAllFcmNotification As CheckBox	' Check box got control FCM message behaviour
'	Private chkNewWebStartup As CheckBox		' Check box to enable New Web Startup operation.
	Private chkWebOnlyComms As CheckBox			' Check box to enable web only communications.	
	Private edtConnectionTimeout As EditText 	' Textbox which determines the 'Connection timeout' settings value.
	Private edtReconnectTimeout As EditText 	' Textbox which determines the 'Reconnect timeout' settings value.
	Private edtServerCheckInterval As EditText 	' Textbox which determines the 'Server check interval' settings value.
	Private edtServerCheckTimeout As EditText 	' Textbox which determines the 'Server check timeout' settings value.
	Private edtWifiHysteresis As EditText 		' Textbox which determines the 'Wifi hysteresis' settings value.
	Private edtWifiLowThreshold As EditText 	' Textbox which determines the 'Low wifi threshold' settings value.
	

End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmconfigsettings")
	lDisplayCurrentSettings
End Sub

Sub Activity_Resume
	' Currently nothing
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If mClosingActivity Or Starter.DisconnectedCloseActivities Then Activity.Finish
End Sub

Sub Activity_Keypress(KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then mClosingActivity = True
	Return False ' Allow the event to continue
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Accept button.
Private Sub btnAccept_Click
	lSaveAllSettings
	lCloseActivity
End Sub

' Handles the Click event of the Cancel button.
Private Sub btnCancel_Click
	lCloseActivity
End Sub



#End Region  Event Handlers

#Region  Public Subroutines

	' Currently none

#End Region  Public Subroutines

#Region  Local Subroutines

' Fully closes (kills) this activity, returning to the Task Select activity.
Private Sub lCloseActivity
	mClosingActivity = True
	StartActivity(TaskSelect)
End Sub

' Displays the current app settings on the activity's views.
Private Sub lDisplayCurrentSettings
	chkAllFcmNotification.Checked = Starter.settings.allFcmNotification
'	chkNewWebStartup.Checked = Starter.settings.newWebStartup
	chkWebOnlyComms.Checked = Starter.settings.webOnlyComms	
	
	edtConnectionTimeout.Text = Starter.settings.connectionTimeout
	edtReconnectTimeout.Text = Starter.settings.reconnectTimeout
	edtServerCheckInterval.Text = Starter.settings.serverCheckInterval
	edtServerCheckTimeout.Text = Starter.settings.serverCheckTimeout

	edtWifiHysteresis.Text = Starter.settings.wifiHysteresis
	edtWifiLowThreshold.Text = Starter.settings.wifiLowThreshold
End Sub

' Saves all the values displayed by the views, and then saves the settings to disk.
Private Sub lSaveAllSettings
	If IsNumber(edtConnectionTimeout.Text.Trim) Then Starter.settings.connectionTimeout = edtConnectionTimeout.Text.Trim
	If IsNumber(edtReconnectTimeout.Text.Trim) Then Starter.settings.reconnectTimeout =edtReconnectTimeout.Text.Trim
	If IsNumber(edtServerCheckInterval.Text.Trim) Then Starter.settings.serverCheckInterval = edtServerCheckInterval.Text.Trim
	If IsNumber(edtServerCheckTimeout.Text.Trim) Then Starter.settings.serverCheckTimeout = edtServerCheckTimeout.Text.Trim
	Starter.settings.allFcmNotification = chkAllFcmNotification.Checked
	Starter.settings.webOnlyComms = chkWebOnlyComms.Checked
'	Starter.settings.newWebStartup = chkNewWebStartup.Checked
	If IsNumber(edtWifiHysteresis.Text.Trim) Then Starter.settings.wifiHysteresis = edtWifiHysteresis.Text.Trim
	If IsNumber(edtWifiLowThreshold.Text.Trim) Then Starter.settings.wifiLowThreshold = edtWifiLowThreshold.Text.Trim
	Starter.settings.pSaveSettings
End Sub

#End Region  Local Subroutines
