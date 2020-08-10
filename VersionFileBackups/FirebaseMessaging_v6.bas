B4A=true
Group=Services
ModulesStructureVersion=1
Type=Service
Version=9.01
@EndOfDesignText@
'
' Service which handles Firebase Messaging
'  Taken from B4A tutorial on Firebase tutorial
' https://www.b4x.com/android/forum/threads/firebasenotifications-push-messages-firebase-cloud-messaging-fcm.67716/
'
#Region  Documentation
	'
	' Name......: FirebaseMessaging 
	' Release...: 6
	' Date......: 16/05/20
	'
	' History
	' Date......: 04/06/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 13/06/19
	' Release...: 2
	' Overview..: Investigate Firebase exception when 1st installed.
	' Amendee...: D Morris
	' Details...:  Mod: Service_Create() - early reference to token removed.
	'			   Mod: public mMyFireBaseToken removed. 
	'			 Added: Public GetFcmToken.
	'
	' Date......: 04/07/19
	' Release...: 3
	' Overview..: Option to not raise App notification when firebase message arrives.
	' Amendee...: D Morris
	' Details...: Mod: Code added to fm_MessageArrived() to only raise notications if a message is received.
	'
	' Date......: 22/10/19
	' Release...: 4
	' Overview..: Support for X-platform.
	' Amendee...: D Morris
	' Details...: Mod: Rename subs.
			'
	' Date......: 21/03/20
	' Release...: 5
	' Overview..: #315 Issue removed B4A compiler warnings. 
	' Amendee...: D Morris
	' Details...:  Mod: GetFcmToken() msgbox() shows a testmessage instead.
	'
	' Date......: 16/05/20
	' Release...: 6
	' Overview..: Issue #0409 - Message notification sound twice.
	' Amendee...: D Morris
	' Details...:  Mod: fm_MessageArrived() code to raise notification when message received removed.
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
	' TODO Need to insert code in fm_TokenRefreshed().
	'
#End Region

#Region  Service Attributes 
	#StartAtBoot: False
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

	Private fm As FirebaseMessaging
	' Added
	Public mMyFirebaseToken As String
End Sub

Sub Service_Create
	fm.Initialize("fm")
'	mMyFirebaseToken = fm.Token
'	Log("My firebase token: " & mMyFirebaseToken)
	
'	SubscribeToTopics ' Just in case (I think)
''	
'	mMyFirebaseToken = fm.Token
'	Log("My firebase 2nd token: " & mMyFirebaseToken)
End Sub

Sub Service_Start (StartingIntent As Intent)
	If StartingIntent.IsInitialized Then 
		fm.HandleIntent(StartingIntent)
	End If
	Sleep(0)
	Service.StopAutomaticForeground 'remove if not using B4A v8+.
End Sub

Sub Service_Destroy

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Event raised when FCM message arrives.
Sub fm_MessageArrived (Message As RemoteMessage)
	Log("Message arrived")
	Log($"Message data: ${Message.GetData}"$)
	
	' Only raise notification if it is a message.
'	Dim msgText As String = Message.GetData.Get("Message")
'	If Starter.settings.allFcmNotification Or  msgText.StartsWith(modEposApp.EPOS_MESSAGE) Then
	If Starter.settings.allFcmNotification Then
		Dim n As Notification
		n.Initialize
		n.Icon = "icon"
		n.SetInfo(Message.GetData.Get("title"), Message.GetData.Get("body"), aTaskSelect)
		n.Notify(1)
	End If
	'	ToastMessageShow(Message.GetData.Get("Message"), True)
	
	' Always pass FCM communications to the system for processing.
	CallSub2(Starter, "pProcessInputStrg", Message.GetData.Get("Message"))		

End Sub

' Event raised when token changes (can happen at anytime).
Sub fm_TokenRefreshed(newToken As String)
	' Code required to update customer info on the Web Server.
	ToastMessageShow("FCM Token changed now = " & newToken, True)
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Subscribes to a FCM topic.
Public Sub SubscribeToTopics
	fm.SubscribeToTopic("general") 'you can subscribe to more topics
' Removed to investigate if this throws the exception after first installation.
'	If fm.Token = "" Then
'		Msgbox("FCM = null - close app and restart", "FCM Error")
'	End If
'	mMyFirebaseToken = fm.Token
'	Log("My firebase token: " & mMyFirebaseToken)
End Sub

' Gets the FCM token - returned as string.
'  NOTE: for some reason including MsgboxAsync() and return ResumableSub has problems. 
Public Sub GetFcmToken As String 
'	Dim fcmToken As String = fm.Token
'	If fcmToken = "" Then
''		MsgboxAsync("FCM = null - close app and restart", "FCM Error")
''		Wait For msgbox_result()
'	End If
	Dim firebaseToken As String = fm.Token
	Log("My firebase token: " & firebaseToken)
	If firebaseToken = "" Then
		ToastMessageShow("FCM = null - close app and restart", True)
	End If
	Return firebaseToken
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines


#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region



