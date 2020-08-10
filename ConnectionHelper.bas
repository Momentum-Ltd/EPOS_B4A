B4A=true
Group=Modules
ModulesStructureVersion=1
Type=StaticCode
Version=7.8
@EndOfDesignText@
'
' Code Module ConnectionHelper
'Subs in this code module will be accessible from all modules.
'
#Region  Documentation
	'
	' Name......: ConnectionHelper
	' Release...: 1
	' Date......: 18/02/18
	'
	' History
	' Date......: 18/02/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 	
	'

	'
#End Region

#Region  Mandatory Subroutines & Data
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub
#end Region

#Region  Public Subroutines

public Sub pCheckSocketOperation() As Int
	Dim wifi As MLwifi
	Dim wifiSignal As Int = wifi.WifiSignalPct
	
	Return wifiSignal
End Sub

#End Region

#Region Local Subroutines

#End Region



