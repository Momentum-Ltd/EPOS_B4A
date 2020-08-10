B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@

'
' This is a help class for the ChangeSettings Activity.
'
#Region  Documentation
	'
	' Name......: hChangeSettings
	' Release...: 13
	' Date......: 19/07/20
	'
	' History
	' Date......: 10/08/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: First release to support version tracking.
	'
	' Version 2 - 7 see v8.
	'
	' Date......: 26/04/20
	' Release...: 8
	' Overview..: Documentation changes (no code change)
	' Amendee...: D Morris
	' Details...: Mod: ShowCustomerId() code rearranged.
	'
	' Date......: 11/05/20
	' Release...: 9
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Added: OnClose().
	'
	' Date......: 31/05/20
	' Release...: 10
	' Overview..: General cleanup.
	' Amendee...: D Morris
	' Details...:  Removed: ClearAccount() obsolete.
	'
	' Date......: 09/06/20
	' Release...: 11
	' Overview..: Added: Work started to support a second Server.
	' Amendee...: D Morris.
	' Details...:  Added: swServer2 slide switch. 
	'
	' Date......: 02/07/20
	' Release...: 12
	' Overview..: Added: #0341 - Settings protection added. 
	' Amendee...: D Morris.
	' Details...:  Mod: Initialize(), DisplayCurrentSettings().
	'
	' Date......: 19/07/20
	' Release...: 14
	' Overview..: Bugfix: #0478 - Setting page crash.
	' Amendee...: D Morris
	' Details...:  Mod: DisplayCurrentSettings() code added to close dialog.
	'			   Mod: OnClose() close dialog code added (just in case the back button pressed).
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
	' X-platform related.
	Private xui As XUI			'ignore
	
	' Activity view declarations
#if B4A
	Private chkAllFcmNotification As B4XView	' Check box got control FCM message behaviour.

	Private chkTestMode As B4XView				' Check box to select phone test mode.
	Private chkWebOnlyComms As B4XView			' Check box to enable web only communications.
	Private edtConnectionTimeout As B4XView 	' Textbox which determines the 'Connection timeout' settings value.
	Private edtReconnectTimeout As B4XView 		' Textbox which determines the 'Reconnect timeout' settings value.
	Private edtServerCheckInterval As B4XView 	' Textbox which determines the 'Server check interval' settings value.
	Private edtServerCheckTimeout As B4XView 	' Textbox which determines the 'Server check timeout' settings value.
	Private edtWifiHysteresis As B4XView 		' Textbox which determines the 'Wifi hysteresis' settings value.
	Private edtWifiLowThreshold As B4XView 		' Textbox which determines the 'Low wifi threshold' settings value.
#Else
	Private swAllFcmNotification As Switch		' Switch to raise a notify for all FCM messages.
'	Private swNewWebStartup As Switch 			' Switch to enable/disable New Web Startup operation.
	Private swTestMode As Switch				' Switch to enable/disable Test mode.
	Private swWebOnlyComms As Switch 			' Switch to enable/disable Web only communications.
	Private txtConnectionTimeout As TextField 	' Textbox which determines the 'Connection timeout' settings value.
	Private txtReconnectTimeout As TextField 	' Textbox which determines the 'Reconnect timeout' settings value.
	Private txtServerCheckInterval As TextField ' Textbox which determines the 'Server check interval' settings value.
	Private txtServerCheckTimeout As TextField 	' Textbox which determines the 'Server check timeout' settings value.
	Private txtWifiHysteresis As TextField 		' Textbox which determines the 'Wifi hysteresis' settings value.
	Private txtWifiLowThreshold As TextField 	' Textbox which determines the 'Low wifi threshold' settings value.
#End If

	Private swServer2 As B4XSwitch				' Select server (unchecked = Server1).

'#if B4I
'	Private mHudObj As HUD 						' The HUD object used to display progress dialogs and toast messages.
'#End If


	Private dialog As B4XDialog					' Dialog enter number for permission to change settings.
#if B4A	
	Private saveParent As Activity
#end if

End Sub

'Initializes the object. You can add parameters to this method if needed.
#if B4A
Public Sub Initialize (parent As Activity)
	saveParent = parent	
#else ' B4I
public Sub Initialize(parent As B4XView)
#End If
	parent.LoadLayout("frmChangeSettings")
	dialog.Initialize(parent)
	dialog.Title = "Input Code to change settings"
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handle the select server switch
private Sub swServer2_ValueChanged (Value As Boolean)

End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Displays the current app settings on the activity's views.
public Sub DisplayCurrentSettings
#if B4A
	chkAllFcmNotification.Checked = Starter.settings.allFcmNotification
	chkWebOnlyComms.Checked = Starter.settings.webOnlyComms
	chkTestMode.Checked = Starter.settings.testMode
	edtConnectionTimeout.Text = Starter.settings.connectionTimeout
	edtReconnectTimeout.Text = Starter.settings.reconnectTimeout
	edtServerCheckInterval.Text = Starter.settings.serverCheckInterval
	edtServerCheckTimeout.Text = Starter.settings.serverCheckTimeout
	edtWifiHysteresis.Text = Starter.settings.wifiHysteresis
	edtWifiLowThreshold.Text = Starter.settings.wifiLowThreshold
#Else
	swAllFcmNotification.Value = Starter.settings.allFcmNotification
	swTestMode.Value = Starter.Settings.testMode
	swWebOnlyComms.value = Starter.settings.webOnlyComms
	txtConnectionTimeout.Text = Starter.settings.connectionTimeout
	txtReconnectTimeout.Text = Starter.settings.reconnectTimeout
	txtServerCheckInterval.Text = Starter.settings.serverCheckInterval
	txtServerCheckTimeout.Text = Starter.settings.serverCheckTimeout
	txtWifiHysteresis.Text = Starter.settings.wifiHysteresis
	txtWifiLowThreshold.Text = Starter.settings.wifiLowThreshold
#End If
	If Starter.server.GetServerNumber = 2 Then
		swServer2.Value = True
	Else
		swServer2.Value = False
	End If
	Dim input As B4XInputTemplate
	input.Initialize
	input.lblTitle.Text = "Number:"
	input.ConfigureForNumbers(False, False)
	Wait For (dialog.ShowTemplate(input, "OK", "", "CANCEL")) Complete (Result As Int)
	' See code snippets in https://www.b4x.com/android/forum/threads/b4x-xui-views-cross-platform-views-and-dialogs.100836/#content
	dialog.Close(xui.DialogResponse_Cancel)  ' Important - need to close it.
	If Not(Result = xui.DialogResponse_Positive And input.Text = Starter.myData.customer.customerId) Then ' Access code correct.
#if B4A
		saveParent.Finish
#else 
		' See https://www.b4x.com/android/forum/threads/call-back-button-programmatically.113242/#post-709683
		Main.NavControl.RemoveCurrentPage
#End If
	End If
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	' See code snippets in https://www.b4x.com/android/forum/threads/b4x-xui-views-cross-platform-views-and-dialogs.100836/#content
	dialog.Close(xui.DialogResponse_Cancel)  ' Important - need to close it.
End Sub

' Saves all the values displayed by the views, and then saves the settings to disk.
Public Sub SaveAllSettings
#if B4A
	If IsNumber(edtConnectionTimeout.Text.Trim) Then 
		Starter.settings.connectionTimeout = edtConnectionTimeout.Text.Trim
	End If
	If IsNumber(edtReconnectTimeout.Text.Trim) Then
		 Starter.settings.reconnectTimeout =edtReconnectTimeout.Text.Trim
	End If
	If IsNumber(edtServerCheckInterval.Text.Trim) Then 
		Starter.settings.serverCheckInterval = edtServerCheckInterval.Text.Trim
	End If
	If IsNumber(edtServerCheckTimeout.Text.Trim) Then 
		Starter.settings.serverCheckTimeout = edtServerCheckTimeout.Text.Trim
	End If
	Starter.settings.allFcmNotification = chkAllFcmNotification.Checked
	Starter.settings.testMode = chkTestMode.Checked
	Starter.settings.webOnlyComms = chkWebOnlyComms.Checked
	If IsNumber(edtWifiHysteresis.Text.Trim) Then 
		Starter.settings.wifiHysteresis = edtWifiHysteresis.Text.Trim
	End If
	If IsNumber(edtWifiLowThreshold.Text.Trim) Then 
		Starter.settings.wifiLowThreshold = edtWifiLowThreshold.Text.Trim
	End If
#Else
	If IsNumber(txtConnectionTimeout.Text.Trim) Then 
		Starter.settings.connectionTimeout = txtConnectionTimeout.Text.Trim
	End If
	If IsNumber(txtReconnectTimeout.Text.Trim) Then 
		Starter.settings.reconnectTimeout = txtReconnectTimeout.Text.Trim
	End If
	If IsNumber(txtServerCheckInterval.Text.Trim) Then
		 Starter.settings.serverCheckInterval = txtServerCheckInterval.Text.Trim
	End If
	If IsNumber(txtServerCheckTimeout.Text.Trim) Then
		 Starter.settings.serverCheckTimeout = txtServerCheckTimeout.Text.Trim
	End If
	Starter.settings.allFcmNotification = swAllFcmNotification.Value
	Starter.Settings.testMode = swTestMode.Value
	Starter.settings.webOnlyComms = swWebOnlyComms.value
	
'	Starter.settings.newWebStartup = swNewWebStartup.value
	If IsNumber(txtWifiHysteresis.Text.Trim) Then 
		Starter.settings.wifiHysteresis = txtWifiHysteresis.Text.Trim
	End If
	If IsNumber(txtWifiLowThreshold.Text.Trim) Then 
		Starter.settings.wifiLowThreshold = txtWifiLowThreshold.Text.Trim
	End If
#End If
	If swServer2.Value = True Then		' Select server
		Starter.server.SelectServer(2)	' Server #2
	Else
		Starter.server.SelectServer(1)	' Server #1
	End If
	Starter.settings.SaveSettings
End Sub

'' Report no changed maded to data.
'' Not ideal to use a toast message (but as this is usually called when the back button is pressed).
'Public Sub ReportNoChanges
'#if B4A
'	ToastMessageShow("Back button pressed" & CRLF & "No changes made.", True)
'#Else
'	mHudObj.ToastMessageShow("Back button pressed" & CRLF & "No changes made.", True)
'#End If
'End Sub

' Handle request to diplay the customer's ID (also centreID)
public Sub ShowCustomerId
	Dim signedOnStatus As String = "NO"
 	If Starter.myData.centre.signedOn Then
		signedOnStatus = "YES"
	End If
	xui.MsgboxAsync("  ID (inc rev):" & Starter.myData.customer.customerIdStr & CRLF & _
	 				"	  Centre ID:" & Starter.myData.centre.centreId & CRLF & _ 
	 				"  Signed-on To:" & signedOnStatus, "Customer ID information") 
	wait for Msgbox_Result(result As Int)
End Sub

' Handles request to display the FCM token
Public Sub ShowFcmToken
#if B4A
	' TODO This need to be resummable.
	Dim fcmToken As String = CallSub(FirebaseMessaging, "GetFcmToken")
#else ' B4I
	wait for (Main.GetFirebaseToken()) complete (fcmToken As String)
#End If
	xui.MsgboxAsync(fcmToken, "FCM Token")
	wait for Msgbox_Result(result As Int)
End Sub

' Show location
Public Sub ShowLocation
	Dim locationString As String
	locationString = "LAT:" & Starter.currentLocation.Latitude & CRLF & "LONG:" & Starter.currentLocation.Longitude
	xui.MsgboxAsync(locationString, "Location")
	wait for MsgBox_result(tempResult As Int)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Initialize the locals etc.
private Sub InitializeLocals
	' Currently no action.	
End Sub

#End Region  Local Subroutines
