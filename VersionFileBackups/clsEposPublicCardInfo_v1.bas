B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
'
' Class to handle Public Card information.
'
#Region  Documentation
	'
	' Name......: clsEposPublicCardInfo
	' Release...: 1
	' Date......: 20/01/21
	'
	' History
	' Date......: 20/01/21
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
#End Region  Documentation

#Region  Mandatory Subroutines & Data

Sub Class_Globals
''' <summary>
''' The card expiry date.
''' </summary>
''' <remarks>Format "MM/YY".</remarks>
Public expiryDate As String

''' <summary>
''' The last4 digits of the card number.
''' </summary>
Public last4Digits As String
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize


End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines