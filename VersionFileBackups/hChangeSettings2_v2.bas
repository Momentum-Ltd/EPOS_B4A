B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@

'
' This is a help class for the ChangeSettings Activity.
'
#Region  Documentation
	'
	' Name......: hChangeSettings2
	' Release...: 2
	' Date......: 15/12/20
	'
	' History
	' Date......: 05/10/20
	' Release...: 1
	' Created by: D Morris 
	' Details...: Based on hChangeSettings_v15.
	'
	' Date......: 15/02/20
	' Release...: 2
	' Overview..: Bugfix #0570 Crashes when search radius increased to > 999.
	' Amendee...: D Morris
	' Details...: Mode SaveAllSettings() code fixed.
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
	Private btnDefault As SwiftButton			' Load default settings button.
	
	Private edtMaxCentres As B4XView			' Maximum centres displayed in searches.
	Private edtRadus As B4XView					' Search radius setting.
		
	Private swAllFcmNotifications As B4XSwitch	' Switch to raise a notify for all FCM messages.
	Private swShowTestCentres As B4XSwitch		' Switch to enable show test centres.	
	Private swTestMode As B4XSwitch				' Switch to enable/disable Test mode.
	Private swUnitsKm As B4XSwitch				' Switch to select units.
	
	Private swServer2 As B4XSwitch				' Select server (unchecked = Server1).
	Public dialog As B4XDialog					' Dialog enter number for permission to change settings (public so it can be access by form).
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
	parent.LoadLayout("frmChangeSettings2")
	dialog.Initialize(parent)
	dialog.Title = "Input Code to change settings"
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handle Default button
Sub btnDefault_Click
	Starter.settings.LoadDefaults
	UpdateDisplay
End Sub

' Handle the select server switch
private Sub swServer2_ValueChanged (Value As Boolean)

End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Displays the current app settings on the activity's views.
public Sub DisplayCurrentSettings
	UpdateDisplay
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
	Else
		frmChangeSettings.ShowBackbutton
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
	If IsNumber(edtMaxCentres.Text.Trim) Then
		Starter.settings.maxCentres = edtMaxCentres.Text.Trim
	End If
	If IsNumber(edtRadus.Text.Trim) Then 
		Dim searchRadius As Double = edtRadus.Text.Trim
		If Starter.settings.unitKm = False Then ' If miles entered convert to km.
			searchRadius = modConvert.ConvertMilesToKm(searchRadius)
		End If
		Starter.settings.searchRadius = searchRadius
	End If
	Starter.settings.allFcmNotification = swAllFcmNotifications.Value
	Starter.settings.showTestCentres = swShowTestCentres.value
	Starter.settings.testMode = swTestMode.value
	Starter.settings.unitKm = swUnitsKm.Value

	If swServer2.Value = True Then		' Select server
		Starter.server.SelectServer(2)	' Server #2
	Else
		Starter.server.SelectServer(1)	' Server #1
	End If
	Starter.settings.SaveSettings
End Sub

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

' Update display
'  Distances are displayed in km/miles according to the unitsKm value.
Private Sub UpdateDisplay()
	edtMaxCentres.Text = Starter.settings.maxCentres
	swAllFcmNotifications.Value = Starter.settings.allFcmNotification
	swShowTestCentres.Value = Starter.settings.showTestCentres
	swTestMode.Value = Starter.settings.testMode
	swUnitsKm.Value = Starter.settings.unitKm
	If Starter.settings.unitKm = True Then ' Display as km?
		edtRadus.Text = Starter.settings.searchRadius		
	Else
		edtRadus.Text = NumberFormat(modConvert.ConvertKmToMiles(Starter.settings.searchRadius), 1, 0)
	End If
	If Starter.server.GetServerNumber = 2 Then
		swServer2.Value = True
	Else
		swServer2.Value = False
	End If
End Sub

#End Region  Local Subroutines

