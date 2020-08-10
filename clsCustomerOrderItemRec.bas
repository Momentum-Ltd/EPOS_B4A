B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Class to provide information about an item in a Customer's Order 
'
#Region  Documentation
	'
	' Name......: clsCustomersOrderItemRec
	' Release...: 2
	' Date......: 25/05/18
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 25/05/18
	' Release...: 2
	' Overview..: Renamed class to more appropriate name.
	' Amendee...: D Morris
	' Details...: Rename from clsCustomerOrderTableRec to clsCustomerOrderItemRec
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region
#Region  Mandatory Subroutines & Data
Sub Class_Globals
	Public priceId As Int	' The price ID of the order item.
	Public qty As Float		' The quantity of this kind of item in the order.
End Sub
#End Region

#Region Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub
#End Region


#Region Local Subroutines

#End Region
