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
	' Release...: 6
	' Date......: 03/02/21
	'
	' History
	' Date......: 26/01/20
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
	' Date......: 03/01/21
	' Release...: 3
	' Overview..: Bugfix: Radius values shown without commas.
	'			  Mod: Now uses Starter.latestLocation.
	' Amendee...: D Morris.
	' Details...: Mod: UpdateDisplay().
	'			  Mod: Old commented out code removed.
	'
	' Date......: 27/01/21
	' Release...: 4
	' Overview..: Bugfix: #0576 - Setting screen not hiding keyboard when return pressed.
	' Amendee...: D Morris
	' Details...:   Mod: uses clsKeyboardHelper to handle keyboard. 
	'					
	' Date......: 30/01/21
	' Release...: 5
	' Overview..: Maintenance fix to support new names.
	' Amendee...: D Morris
	' Details...: Mod: kbHelper_HideKeyboard(), DisplayCurrentSettings(). 
	'			  Mod: InitializeLocals() - New call to clsKeyboardHelper.SetupTextAndKeyboard().
	'
	' Date......: 03/02/21
	' Release...: 6
	' Overview..: General maintenance.
	' Amendee...: D Morris
	' Details...: Mod: Old commented code removed.
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
	Private xui As XUI							'ignore
	
	' Constants
	Private Const MAX_CENTRES As Int = 99		' Maximum centres to display setting.
	Private Const MAX_RADIUS As Int = 9999		' Maximum search radius setting.
	Private Const MIN_CENTRES As Int = 5		' Minimum centres to display setting.
	Private Const MIN_RADIUS As Int = 2			' Minimum search radius setting (km).
	
	' Activity view declarations
	Private btnDefault As SwiftButton			' Load default settings button.
	
	Private edtMaxCentres As B4XFloatTextField	' Maximum centres displayed in searches.
	Private edtRadius As B4XFloatTextField		' Search radius setting.
	
	Private pnlEnterDetails As Panel			' Panel for entering details.	
		
	Private swAllFcmNotifications As B4XSwitch	' Switch to raise a notify for all FCM messages.
	Private swShowTestCentres As B4XSwitch		' Switch to enable show test centres.	
	Private swTestMode As B4XSwitch				' Switch to enable/disable Test mode.
	Private swUnitsKm As B4XSwitch				' Switch to select units.
	
	Private swServer2 As B4XSwitch				' Select server (unchecked = Server1).
	
	' Misc objects	
	Public dialog As B4XDialog					' Dialog enter number for permission to change settings (public so it can be accessed by the parent form).
	Private kbHelper As clsKeyboardHelper		' Keyboard helper	
#if B4A	
	Private saveParent As Activity				' Storage for the parent activity.
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
Private Sub btnDefault_Click
	Starter.settings.LoadDefaults
	UpdateDisplay
End Sub

' Handle Max Centres enter button.
Private Sub edtMaxCentres_EnterPressed
	Log("Max Centres Return")
	Starter.settings.maxCentres = modEposApp.CheckNumberRange(edtMaxCentres.Text, MAX_CENTRES, MIN_CENTRES, modEposApp.DFT_MAX_CENTRES)
	edtMaxCentres.Text = Starter.settings.maxCentres	' Ensure screen text updated with latest value
End Sub
'
' Handle Max Centres enter button.
Private Sub edtRadius_EnterPressed
	Log("Max Centres Return")
	Starter.settings.searchRadius = ProcessSearchRadius(edtRadius.Text)
	edtRadius.text = GetRadiusText ' Ensure screen text updated with latest value
End Sub

#if b4i 
' Hide the keyboard
Public Sub kbHelper_HideKeyboard
	xChangeSettings.HideKeyboard
End Sub
#End If

' Handle units switch
Private Sub swUnitsKm_ValueChanged (Value As Boolean)
	Starter.settings.unitKm = Value
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
	Wait For (dialog.ShowTemplate(input, "OK", "", "CANCEL")) Complete (Result As Int) ' Request access code.
	' See code snippets in https://www.b4x.com/android/forum/threads/b4x-xui-views-cross-platform-views-and-dialogs.100836/#content
	dialog.Close(xui.DialogResponse_Cancel)  ' Important - need to close it.
	If Not(Result = xui.DialogResponse_Positive And input.Text = Starter.myData.customer.customerId) Then ' Access code correct.
#if B4A
		saveParent.Finish
#else ' B4i
		' See https://www.b4x.com/android/forum/threads/call-back-button-programmatically.113242/#post-709683
		Main.NavControl.RemoveCurrentPage
	Else
		xChangeSettings.ShowBackbutton
#End If
	End If
End Sub

#if B4i
' Moves up the panel when necessary.
Public Sub MoveUpEnterPanel(oskHeight As Float)
	kbHelper.MoveUpEnterDetailsPanel(oskHeight)
End Sub
#End If

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If dialog.IsInitialized Then
		' See code snippets in https://www.b4x.com/android/forum/threads/b4x-xui-views-cross-platform-views-and-dialogs.100836/#content
		dialog.Close(xui.DialogResponse_Cancel)  ' Important - need to close it.		
	End If

End Sub

#if B4i
' Handle resize event
Public Sub Resize
	kbHelper.Resize
End Sub
#End If

' Saves all the values displayed to file.
Public Sub SaveAllSettings
	Starter.settings.maxCentres = modEposApp.CheckNumberRange(edtMaxCentres.Text, MAX_CENTRES, MIN_CENTRES, modEposApp.DFT_MAX_CENTRES) 
	Starter.settings.searchRadius = ProcessSearchRadius(edtRadius.Text)
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

' Handle request to diplay the customer's ID (also centreID and if signed on)
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
	Dim fcmToken As String = CallSub(FirebaseMessaging, "GetFcmToken")	' TODO This need to be resummable.
#else ' B4I
	wait for (Main.GetFirebaseToken()) complete (fcmToken As String)
#End If
	xui.MsgboxAsync(fcmToken, "FCM Token")
	wait for Msgbox_Result(result As Int)
End Sub

' Show location
Public Sub ShowLocation
	Dim locationString As String
	locationString = "LAT:" & Starter.latestLocation.Latitude & CRLF & "LONG:" & Starter.latestLocation.Longitude
	xui.MsgboxAsync(locationString, "Location")
	wait for MsgBox_result(tempResult As Int)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Gets the stored Radius text and displays it as km or miles.
Private Sub GetRadiusText As String
	Dim radiusStrg As String = Starter.settings.searchRadius	
	If Starter.settings.unitKm = False Then ' Display as miles?
		radiusStrg = NumberFormat2(Round(modConvert.ConvertKmToMiles(radiusStrg)), 1, 0, 0, False)
	End If
	Return radiusStrg
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	kbHelper.Initialize(Me, "kbHelper", pnlEnterDetails)
#if b4i	
	kbHelper.AddViewToKeyboard(edtMaxCentres)
	kbHelper.AddViewToKeyboard(edtRadius)
#End If
	kbHelper.SetupBackcolourAndBorder(edtMaxCentres)
	kbHelper.SetupBackcolourAndBorder(edtRadius)
	Dim enterPanelTextField() As B4XFloatTextField = Array As B4XFloatTextField(edtMaxCentres, edtRadius)
	kbHelper.SetupTextAndKeyboard(enterPanelTextField)
End Sub

' Process the Search radius setting.
' Return processed value as int.
Private Sub ProcessSearchRadius(numberStrg As String) As Int
	Dim searchRadius As Int = modEposApp.CheckNumberRange(numberStrg, MAX_RADIUS, MIN_RADIUS, modEposApp.DFT_SEARCH_RADIUS)
	If Starter.settings.unitKm = False Then ' If miles entered convert to km.
		searchRadius = Round(modConvert.ConvertMilesToKm(searchRadius))
	End If
	Return searchRadius
End Sub

' Update display
'  Distances are displayed in km/miles according to the unitsKm value.
Private Sub UpdateDisplay()
	edtMaxCentres.Text = Starter.settings.maxCentres
	swAllFcmNotifications.Value = Starter.settings.allFcmNotification
	swShowTestCentres.Value = Starter.settings.showTestCentres
	swTestMode.Value = Starter.settings.testMode
	swUnitsKm.Value = Starter.settings.unitKm
	edtRadius.text = GetRadiusText
	If Starter.server.GetServerNumber = 2 Then
		swServer2.Value = True
	Else
		swServer2.Value = False
	End If
End Sub

#End Region  Local Subroutines


