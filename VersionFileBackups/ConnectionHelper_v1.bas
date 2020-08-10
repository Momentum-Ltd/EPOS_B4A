B4A=true
Group=Default Group
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

' Generate a generic message for order status
' NOTE xmlStr must be type clsOrderStatusRec
'  Duplicated code see Starter.lNotify()
public Sub pOrderStatusGeneric(xmlStr As String) As String
	Dim responseObj As clsOrderStatusRec
	responseObj.Initialize
	responseObj = responseObj.pXmlDeserialize(xmlStr) ' TODO - need to determine if the deserialisation was successful
	Dim message As String
'	If responseObj.status <> ModConvert.statusInactive Then
	message = "Your order: " & responseObj.orderId  & CRLF '" is " & ModConvert.ConvertStatusToString(responseObj.status) & CRLF
	If responseObj.deliverTo <> "0" Then
		message = message & "For delivery to Table: " & responseObj.deliverTo & CRLF
	Else
		message = message & "For collection" & CRLF
	End If
	Select  responseObj.status
		Case  ModConvert.statusReady
			If responseObj.deliverTo <> "0" Then
				message = message & CRLF & "Order is been delivered NOW!"
			Else
				message = message & CRLF & "Please collection you order NOW!"
			End If
		Case ModConvert.statusCollected
			If responseObj.deliverTo <> "0" Then
				message = message & CRLF & "Order has been delivered!"
			Else
				message = message & CRLF & "Order has been collected!"
			End If
		Case ModConvert.statusInprogress
			message = message & CRLF & "Your order is been preparing."
		Case ModConvert.statusWaiting
			message = message & CRLF & "Your order is in the queued."
		Case Else
			message = message & CRLF & "Your order is " &  ModConvert.ConvertStatusToString(responseObj.status)
	End Select
'	Else	' Inactive (indicates not order available).
'		message = "No order placed"
'	End If

	Return message
End Sub
#End Region

#Region Local Subroutines

#End Region



