B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
'
' class for handling notifications
'
#Region  Documentation
	'
	' Name......: clsNotifications
	' Release...: 5
	' Date......: 20/05/20
	'
	' History
	' Date......: 02/04/20
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 06/04/20
	' Release...: 2
	' Overview..: Issue: #0315 (ongoing) compiler warnings removed. 
	' Amendee...: D Morris
	' Details...:  Mod: PlayRingtone() only included for B4A.
	'
	' Date......: 26/04/20
	' Release...: 3
	' Overview..: Calling pSendMessage changed.
	' Amendee...: D Morris
	' Details...:  Mod: SendStatusAckn().
	'
	' Date......: 09/05/20
	' Release...: 4
	' Overview..: Bugfix: Missing message notifications.
	' Amendee...: D Morris
	' Details...:   Mod: ShowMessageNotificationMsgBox() - Wait for added.
	'
	' Date......: 20/05/20
	' Release...: 5
	' Overview..: Mod: Previous stored message/status test is cleared when displayed.
	' Amendee...: D Morris
	' Details...:  Mod: ShowMessageNotificationMsgBox() and ShowStatusNotificationMsgBox() code to clear text moved.
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
	Private xui As XUI						'ignore (to remove warning)
	' Local variables
#if B4A
	Private alertCustomerVibrate As PhoneVibrate
	Private rm As RingtoneManager
#else ' B4I

#end if
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub


' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	' Make the notification sound and vibration, if required
#if B4A	
	If soundAndVibrate Then
		alertCustomerVibrate.Vibrate(500)
		PlayRingtone(rm.GetDefault(rm.TYPE_NOTIFICATION))
	End If
	
	' Show the message box
	xui.Msgbox2Async(Starter.PrevMessage, "New message(s)", "OK", "", "", Null)
	
	Starter.PrevMessage = "" ' Clear the most recent message, as it is checked in multiple places
	
	Wait For Msgbox_Result (Result As Int) ' Wait until it has been deliberately dismissed by the user
	' Clear out previous notification data
	Starter.NotificationMessage.Cancel(modEposApp.NOTIFY_MESSAGE_ID) ' Should be cancelled automatically, but just in case
'	Starter.PrevMessage = "" ' Clear the most recent message, as it is checked in multiple places
#else ' B4I
	' TODO Code required.
#end if

End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	' Make the notification sound and vibration, if required
#if B4A	
	If soundAndVibrate Then
		alertCustomerVibrate.Vibrate(500)
		PlayRingtone(rm.GetDefault(rm.TYPE_NOTIFICATION))
	End If
	
	' Show the message box and send acknowledgement once it has been dismissed
	xui.Msgbox2Async(Starter.prevstatus(1), Starter.PrevStatus(0), "OK", "", "", Null)
	
	Starter.PrevStatus = Array As String("","") ' Clear the most recent order status
	
	Wait For Msgbox_Result (Result As Int) ' Wait until it has been deliberately dismissed by the user
	SendStatusAckn(Starter.PrevStatusRec)
		' Clear out previous notification data
	Starter.NotificationStatus.Cancel(modEposApp.NOTIFY_STATUS_ID) ' Usually cancelled automatically, but just in case
'	Starter.PrevStatus = Array As String("","") ' Clear the most recent order status, as it is checked in multiple places
			
#else ' B4I
	' TODO Code required see above.
#end if

End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

#if B4A
' See https://www.b4x.com/android/forum/threads/default-message-sound.56476/
Private Sub PlayRingtone(url As String)
' #if B4A
	Dim jo As JavaObject
	jo.InitializeStatic("android.media.RingtoneManager")
	Dim jo2 As JavaObject
	jo2.InitializeContext
	Dim u As Uri
	u.Parse(url)
	jo.RunMethodJO("getRingtone", Array(jo2, u)).RunMethod("play", Null)
'#else ' B4I
	'TODO Code required.
' #end if
End Sub
#end if

#if B4A
' Sends a message to the Server acknowledging the specified status notification.
Private Sub SendStatusAckn(statusRec As clsEposOrderStatus)
	Dim msg As String = modEposApp.EPOS_ORDERSTATUS & statusRec.XmlSerialize
	CallSub2(Starter, "pSendMessage", msg)
End Sub
#end if

#End Region  Local Subroutines