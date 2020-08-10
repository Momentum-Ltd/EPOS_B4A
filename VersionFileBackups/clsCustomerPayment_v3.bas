B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Class to hold information about customer payments
'
#Region  Documentation
	'
	' Name......: clsCustomerPayment
	' Release...: 3
	' Date......: 17/02/18
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 17/02/18
	' Release...: 2
	' Amendee...: D Morris
	' Details...: Mod: Documentation changes (no code changed)
		'
	' Date......: 03/09/19
	' Release...: 3
	' Overview..: Obsolete - replaced with clsEposCustomerPayment
	' Amendee...: D Morris
	' Details...: Mod: Remove from project.
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
	Public customerId As Int
	Public total As Float
End Sub
#End Region

#Region  Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

public Sub pXmlSerialize(paymentDetails As clsCustomerPayment) As String
	Dim x As XMLBuilder
	
	x = x.create("clsCustomerPayment") _
		.attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
		.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("customerId").text(paymentDetails.customerId).up()
	x = x.element("total").text(paymentDetails.total)
	Dim props As Map	' TODO Not sure using 'Map' is necessary - needs investigation
	props.Initialize
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
End Sub

#End Region

#Region Local Subroutines

#End Region
