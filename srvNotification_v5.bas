B4A=true
Group=Services
ModulesStructureVersion=1
Type=Service
Version=8.3
@EndOfDesignText@
'
' Service which handles the displaying of notifications.
'

#Region  Documentation
	'
	' Name......: srvNotification 
	' Release...: 5
	' Date......: 22/10/19
	'
	' History
	' Date......: 10/07/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking Code taken from
	'   Main module see  https://www.b4x.com/android/forum/threads/nb6-notifications-builder-class-2018.91819/
	'
	' Date......: 13/08/18
	' Release...: 2
	' Overview..: Changes to pSimple_Notification() to support improved notification handling.
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Changed the parameters of pSimple_Notification() so that the title and content are passed as a string array (keeping
	' 				the number of parameters down to two, the most handled by the CallSub methods), and added new 'notificationID'
	'		Mod: Changes to pSimple_Notification() so that it returns the notification object that it creates
	'		Mod: Removed some obsolete commented-out code, and tidied up the module
	'
	' Date......: 30/08/18
	' Release...: 3
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Change in Service_Start() to prevent initial test toast message being shown
	'
	' Date......: 16/01/19
	' Release...: 4
	' Overview..: Changes made to use the new icon.
	' Amendee...: D Hathway
	' Details...: 	Mod: Private variable "smiley" renamed to "notifyIcon", and change in Service_Create() to use the new icon file.
	'
	' Date......: 22/10/19
	' Release...: 5
	' Overview..: Support for X-platform.
	' Amendee...: D Morris
	' Details...: Mod: Rename subs.
	'
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region

#Region  Service Attributes
	#StartAtBoot: False
#End Region  Service Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals

	' Local variables
	Private notifyIcon As Bitmap ' The icon which will be shown in the notification bar when a notification is raised

End Sub

Sub Service_Create
	notifyIcon = LoadBitmapResize(File.DirAssets, "IconSilhouette.png", 24dip, 24dip, False)
End Sub

Sub Service_Start (StartingIntent As Intent)
	' See https://www.b4x.com/android/forum/threads/nb6-notifications-builder-class-2018.91819/
	If StartingIntent.IsInitialized Then
		Dim cs As CSBuilder
		cs.Initialize.Bold.Size(20).Append($"Action: ${StartingIntent.Action}"$).PopAll
		Log(cs)
	End If
End Sub

Sub Service_Destroy
	' Currently nothing
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Currently none

#End Region  Event Handlers

#Region  Public Subroutines

' Builds and raises a simple notification with the specified title, content, tag, and notification ID number.
' The title, string, and tag should be passed as a string array with this index order: 0 = title, 1 = content, 2 = tag.
Public Sub pSimple_Notification(titleContentTag() As String, notificationID As Int) As Notification
	Dim rtnNotification As Notification
	
	Dim nb6Obj As NB6
	nb6Obj.Initialize("default", Application.LabelName, "DEFAULT").AutoCancel(True).SmallIcon(notifyIcon)
	rtnNotification = nb6Obj.Build(titleContentTag(0), titleContentTag(1), titleContentTag(2), aTaskSelect)
	rtnNotification.Notify(notificationID)
	
	Return rtnNotification
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Currently none

#End Region  Local Subroutines
