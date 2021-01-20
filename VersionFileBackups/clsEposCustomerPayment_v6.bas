B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' Class to handle EPOS customer payments.
'
#Region  Documentation
	'
	' Name......: clsEposCustomerPayment.
	' Release...: 6
	' Date......: 20/01/21
	'
	' History
	' Date......: 03/09/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 05/09/19
	' Release...: 2
	' Overview..: Now support status when serializing.
	' Amendee...: D Morris. 
	' Details...: Mod: XmlSerialize() code changed.
		'
	' Date......: 22/10/19
	' Release...: 3
	' Overview..: Bugfix XmlSerialize B4I not working correctly.
	' Amendee...: D Morris
	' Details...: Bugfix: XmlSerialize() fix on B4I code. 
	'
	' Date......: 01/12/19
	' Release...: 4
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: centreId - definitions, XmlDeserialize() and XmlSerialize().
	'	
    ' Date......: 31/05/20
    ' Release...: 5
    ' Overview..: Bugfix: #0421 - Placing new orders when previous orders cancelled.
    ' Amendee...: D Morris
    ' Details...: Added: orderId.
	'				Mod: XmlDeserialize() and XmlSerialize() support for orderId.
	'		
	' Date......: 20/01/21
	' Release...: 6
	' Overview..: Bugfix: #0464 - Save card option now works correctly.
	' Amendee...: D Morris.
	' Details...: Added: publicCardInfo, billPayment, noSave and paymentId.
    '               Mod: Constructors to support publicCardInfo.
	'			    Mod: XmlDeserialize() and XmlSerialize() support for new elemnts.
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
	''' Indicates if bill or order is to be paid
	''' </summary>
	''' <remarks> false indicates a Order is to be paid.</remarks>
	Public billPayment As Boolean
	
	''' <summary>The centre identifier</summary>
	Public centreId As Int

	''' <summary>
	''' The customer identifier.
	''' </summary>
	Public customerId As Int

	''' <summary>Now obsolete - Remove ASAP - The order identifier.</summary>
	''' <remarks>This is a option element - if applicable it is indicates the order this
	''' payment relates to. If not required it should either be removed, negative or = 0.</remarks>
	Public orderId As Int
	
	''' <summary>
	''' Don't save card.
	''' </summary>
	Public noSave As Boolean

	''' <summary>
	''' Payment identifier
	''' </summary>
	Public paymentId As Int
	
	''' <summary>
	''' The public card information
	''' </summary>
	''' <remarks>Only valid if new card token provided.</remarks>
	Public publicCardInfo As clsEposPublicCardInfo
	
	''' <summary>
	''' The payment/operation (bidirectional) flag.
	''' </summary>
	Public status As Int
	
	''' <summary>
	''' Container for Token information (Used to pass a new customer card token).
	''' </summary>
	''' <remarks>If token = "" use stored token otherwise a new token.</remarks>
	Public token As String

	''' <summary>
	''' The total value for that customer ( = 0 indicates only the token is being passed).
	''' </summary>
	Public total As Float
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	publicCardInfo.Initialize
End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
Public Sub XmlDeserialize(xmlString As String) As clsEposCustomerPayment
	Dim localRetObject As clsEposCustomerPayment : localRetObject.Initialize ' Local working copy of object
	Dim xm As Xml2Map : xm.Initialize
	Dim parsedData As Map = xm.Parse(xmlString)
	Dim customerPaymentResult As Map = parsedData.Get("clsEposCustomerPayment")
	If customerPaymentResult.IsInitialized Then ' Protection against receiving the wrong class
		localRetObject.billPayment = modConvert.ConvertStringToBoolean(customerPaymentResult.GetDefault("billPayment", False))
		localRetObject.centreId = customerPaymentResult.GetDefault("centreId", 0)
		localRetObject.customerId = customerPaymentResult.GetDefault("customerId", 0)
		localRetObject.orderId = customerPaymentResult.GetDefault("orderId", 0)
		localRetObject.Status = modConvert.ConvertPaymentStatusToInt(customerPaymentResult.GetDefault("status", ""))
		localRetObject.noSave = modConvert.ConvertStringToBoolean(customerPaymentResult.GetDefault("noSave", ""))
		localRetObject.paymentId = customerPaymentResult.GetDefault("paymentId", 0)
		Dim cardInfoMap As Map = customerPaymentResult.Get("clsEposPublicCardInfo")
		If cardInfoMap Is Map Then
			localRetObject.publicCardInfo.expiryDate = cardInfoMap.GetDefault("expiryDate", "")
			localRetObject.publicCardInfo.last4Digits = cardInfoMap.GetDefault("last4Digits", "")
		End If		
		localRetObject.Token = customerPaymentResult.GetDefault("token", "")
		localRetObject.total = customerPaymentResult.GetDefault("total", 0)
	End If
	Return localRetObject
End Sub

' Returns an XML string containing the data contained in this class.
Public Sub XmlSerialize() As String
	Dim x As XMLBuilder
	
	x = x.create("clsEposCustomerPayment").attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
			.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("billPayment").text(modConvert.ConvertBooleanToString(billPayment)).up
	x = x.element("centreId").text(centreId).up
	x = x.element("customerId").text(customerId).up
	x = x.element("orderId").text(orderId).up
	x = x.element("noSave").text(noSave).up
	x = x.element("paymentId").text(paymentId).up
	x = x.element("status").text(modConvert.ConvertPaymentStatusIntToString(status)).up	
	x = x.element("token").text(token).up
	x = x.element("total").text(total).up
	x = x.element("publicCardInfo")
	x = x.element("expiryDate").text(publicCardInfo.expiryDate).up. _
					element("last4Digits").text(publicCardInfo.last4Digits).up.up		
#if B4A	'TODO need to investigate why different code required for B4A and B4I  
	Dim props As Map : props.Initialize ' TODO Not sure using 'Map' is necessary - investigate
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else ' B4I code taken from original version for B4I
	' DH - NOTE: The following line ensures the class's closing tag is included - strangely, it's not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsEposCustomerPayment>"
	Return xmlString
#End If

End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines