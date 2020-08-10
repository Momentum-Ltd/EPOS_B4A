B4A=true
Group=Templates
ModulesStructureVersion=1
Type=Service
Version=7.8
@EndOfDesignText@
'
' This is a template for Services
'

#Region  Documentation
	'
	' Name......: 
	' Release...: -
	' Date......: --/--/19
	'
	' History
	' Date......: --/--/19
	' Release...: 1
	' Created by: 
	' Details...: First release to support version tracking
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
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Service_Create

End Sub

Sub Service_Start (StartingIntent As Intent)
	' DM added to template on 10/7/18 See https://www.b4x.com/android/forum/threads/automatic-foreground-mode.90546/
	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
End Sub

Sub Service_Destroy

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines
