B4A=true
Group=Services
ModulesStructureVersion=1
Type=Service
Version=7.8
@EndOfDesignText@
#Region  Documentation
	'
	' Name......: TestStartAt
	' Release...: 5
	' Date......: 10/02/21   
	'
	' History
	' Date......: 17/02/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 30/07/18
	' Release...: 2
	' Overview..: Maintenance update
	' Amendee...: D Morris
	' Details...: Mod: 	Public lph As PhoneWakeState commented out.
	'
	' Date......: 07/08/19
	' Release...: 3
	' Overview..: Support for myData.
	' Amendee...: D Morris
	' Details...: Mod: support for myData Service_Start()
	'
	' Date......: 26/04/20
	' Release...: 4
	' Overview..: Calling pSendMessage changed.
	' Amendee...: D Morris
	' Details...:  Mod: Service_Start().
	'             		
	' Date......: 10/02/21
	' Release...: 5
	' Overview..: Maintenance fix.
	' Amendee...: D Morris
	' Details...: Mod: 'p' dropped from call to Starter.SendMessage().
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region ' Documentation

#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

#Region  Mandatory Subroutines & Data
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

'	Private  wifiNew As MLwifi
	Private stopCalled As Boolean
'	Public lph As PhoneWakeState
End Sub

Sub Service_Create

End Sub

Sub Service_Start (StartingIntent As Intent)
'	lph.PartialLock
	If stopCalled = False Then
		DateTime.DateFormat = "HH:mm:ss"
		Dim message As String =  modEposApp.EPOS_PING & " From Customer #" & _ 
								Starter.myData.customer.customerIdStr & _
								"  Time:" & DateTime.Date(DateTime.Now)
		CallSub2(Starter, "SendMessage", message )
		StartServiceAtExact(Me, DateTime.Now + 5 *1000, True)
	Else
		stopCalled = False		
	End If
'	lph.ReleasePartialLock
End Sub

Sub Service_Destroy
	stopCalled = True
End Sub
#end Region


#Region  Event Handlers

#end Region

#Region  Public Subroutines

#End Region

#Region  Local Subroutines

' See https://www.b4x.com/android/forum/threads/default-message-sound.56476/
'private Sub lPlayRingtone(url As String)
'	Dim jo As JavaObject
'	jo.InitializeStatic("android.media.RingtoneManager")
'	Dim jo2 As JavaObject
'	jo2.InitializeContext
'	Dim u As Uri
'	u.Parse(url)
'	jo.RunMethodJO("getRingtone", Array(jo2, u)).RunMethod("play", Null)
'End Sub

#end Region
