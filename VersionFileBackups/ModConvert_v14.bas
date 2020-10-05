B4A=true
Group=Modules
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'
' This module contains conversion subroutines used commonly throughout the application.
'

#Region  Documentation
	'
	' Name......: ModConvert
	' Release...: 14
	' Date......: 05/10/20   
	'
	' History
	' 	Version v1 = 9 see version ModConvert_v9.
	'
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on arenaRemote.ModConvert (V1)
	'
	'
	' Date......: 07/08/19
	' Release...: 9
	' Overview..: Improved reporting of status to customers.
	' Amendee...: D Morris.
	' Details...: Mod: status const values update in-line with VB.net modEposApp.enuOrderStatus.
	'			  Mod: ConvertStatusToUserString() new parameter used to modify the message.
	'	
	' Date......: 03/09/19
	' Release...: 10
	' Overview..: Support for payment status.
	' Amendee...: D Morris
	' Details...: Added: Payment status constants, ConvertPaymentStatusToInt() and 	ConvertPaymentStatusIntToString().	
		'
	' Date......: 05/09/19
	' Release...: 11
	' Overview..: Support save card.
	' Amendee...: D Morris
	' Details...: Added: payStatusSaveCard.
	'			    Mod: ConvertPaymentStatusIntToString() and ConvertPaymentStatusToInt().
		'
	' Date......: 22/10/19
	' Release...: 12
	' Overview..: Query B4I exception thrown by select statement - All select statements now have else condition. 
	' Amendee...: D Morris
	' Details...: Mod: ConvertColourToStringLower(), ConvertPaymentStatusIntToString(), ConvertNumberToOrdinalString()
	'					ConvertPaymentStatusToInt(), ConvertStringToColour(), ConvertStatusToString(), ConvertStatusToUserString(),
	'					ConvertStringToStatus().
	'
	' Date......: 13/05/20
	' Release...: 13
	' Overview..: Bugfix: #0404 - no response to Message or Update Epos commands.
	' Amendee...: D Morris.
	' Details...: Added: ConvertMessageStatusIntToString(), ConvertMessageStatusToInt().
	'
	' Date......: 05/10/20
	' Release...: 14
	' Overview..: Support for km/miles conversions.
	' Amendee...: D Morris.
	' Details...: Added CVT_KM_TO_MILES and CVT_MILES_TO_KM
	'					ConvertKmToMiles() and ConvertMilesToKm().
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
	
	' Status value values (must correspond to VB.net modEposApp.enuOrderStatus).
	Public Const statusUnknown As Int = 0,  statusInactive As Int = 1, statusWaitingForPayment As Int = 2
	Public const statusWaiting As Int = 3, statusInprogress As Int = 4, statusReady As Int = 5
	Public Const statusCollected As Int = 6,  statusDeleted As Int = 7
	
	' Payment status values (must correspond to vb.net values - see clsCardOperation.)
	Public Const payStatusUnknown As Int = 0, payStatusFailed As Int = 1, payStatusPending As Int = 2
	Public Const payStatusSucceeded As Int = 3, payStatusCancelled As Int = 4, payrequestRetry As Int = 5
	Public Const payStatusCardNotAccepted As Int = 6, payStatusCreateCardAccProblem As Int = 7, payStatusCardProblem As Int = 8
	Public Const payStatusSaveCard As Int = 9
	
	' Conversion constants for km/miles
	Public Const CVT_KM_TO_MILES As Float = 0.62137119
	Public Const CVT_MILES_TO_KM As Float = 1.609344
	
	Type intByRef(value As Int)
		
End Sub

#End Region

#Region  Public Subroutines

' Returns the "true" or "false" depending on value
' DM Why does  .tostring not work here or could it be me?
Public Sub ConvertBooleanToString(value As Boolean) As String
	Dim booleanStrg As String
	If value = True Then
		booleanStrg = "true"
	Else
		booleanStrg = "false"
	End If
	Return booleanStrg
End Sub

' Returns the lower-case string equivalent to the specified colour code (i.e. surrogate phaser colour).
' If the colour code can't be resolved as one of the surrogate phaser colours, then "unknown" will be returned.  
Public Sub ConvertColourToStringLower(colourCode As Int) As String
	Dim rtnColourString As String
		
	Select colourCode
		Case Colors.Red ' Surrogate value for Red phaser colour
			rtnColourString = "red"
		Case Colors.Green ' Surrogate value for Green phaser colour
			rtnColourString = "green"
		Case Colors.Blue ' Surrogate value for Blue phaser colour
			rtnColourString = "blue"
		Case Colors.Cyan ' Surrogate value for Cyan phaser colour
			rtnColourString = "cyan"
		Case Colors.Magenta ' Surrogate value for Magenta phaser colour
			rtnColourString = "magenta"
		Case Colors.Yellow ' Surrogate value for Orange phaser colour
			rtnColourString = "orange"
		Case Else
			rtnColourString = "unknown"
	End Select
	
	Return rtnColourString
End Sub

' Converts the specified Daily ID Number into its equivalent Customer Number, which is assigned to the specified field.
' Returns true if the Daily ID has a valid checksum <i>and</i> is valid for this day; otherwise, returns false.
Public Sub ConvertDailyIdToCustomerNumber(dailyIdNumber As String, customerNumber As intByRef) As Boolean
	Dim dailyIdValid As Boolean = False

    ' Check whether the Daily ID has the correct number of characters (prevents exceptions in the next step)
    If dailyIdNumber.Length = 5 Then

        ' Separate the digits into the individual number characters
        Dim firstCustomerDigit As Int = dailyIdNumber.SubString2(0,1)
        Dim checksumDigit As Int = dailyIdNumber.SubString2(1,2)
        Dim secondCustomerDigit As Int = dailyIdNumber.SubString2(2,3)
        Dim dateDigit As Int = dailyIdNumber.SubString2(3,4)
        Dim thirdCustomerDigit As Int = dailyIdNumber.SubString(4)

        ' Check whether the checksum is valid
		Dim localChecksumStr As String = (firstCustomerDigit + secondCustomerDigit + dateDigit + thirdCustomerDigit)
		Dim localChecksumDigit As Int = localChecksumStr.SubString(localChecksumStr.Length - 1)
        If checksumDigit = localChecksumDigit Then

            ' Check whether the date digit is valid for today
			Dim now As Long = DateTime.Now
			Dim localDateStr As String = lGetDigitSum(DateTime.GetDayOfMonth(now)) + lGetDigitSum(DateTime.GetMonth(now)) + _
										 lGetDigitSum(DateTime.GetYear(now))
			Dim localDateDigit As Int = localDateStr.SubString(localDateStr.Length -1)
            If dateDigit = localDateDigit Then

                ' Get the Customer Number (the Daily ID Number is a valid construction by this point)
                dailyIdValid = True
                Dim customerDigit1 As Int = lSubtractWraparound(firstCustomerDigit, DateTime.GetDayOfMonth(now))
				Dim customerDigit2 As Int = lSubtractWraparound(secondCustomerDigit, DateTime.GetMonth(now))
				Dim customerDigit3 As Int = lSubtractWraparound(thirdCustomerDigit, DateTime.GetYear(now))
                customerNumber.value = customerDigit1 & customerDigit2 & customerDigit3
            End If
        End If
    End If

    Return dailyIdValid
End Sub

' Convert km to miles.
Public Sub ConvertKmToMiles(kmDistance As Float) As Float
	Return kmDistance * CVT_KM_TO_MILES
End Sub

' Convert EPSO message status enum (sent by Server) to int message status value.
Public Sub ConvertMessageStatusToInt(value As String) As Int
	Dim messageStatusInt As Int
	Select Case value
		Case "received"
			messageStatusInt = 1
		Case "displayed"
			messageStatusInt = 2
		Case Else
			messageStatusInt = 0 ' Default "unknown"
	End Select
	Return messageStatusInt
End Sub

' Convert EPSO message status int to enu string (for sending to the Server).
Public Sub ConvertMessageStatusIntToString(messageStatusInt As Int) As String
	Dim messageStatus As String
	Select Case messageStatusInt
		Case 1
			messageStatus = "received"
		Case 2
			messageStatus = "displayed"
		Case Else
			messageStatus = "unknown"' Default 
	End Select
	Return messageStatus
End Sub

' Convert miles to km
Public Sub ConvertMilesToKm(milesDistance As Float) As Float
	Return milesDistance * CVT_MILES_TO_KM
End Sub

' Convert payment status int to enum string (for sending to the Server).
Public Sub ConvertPaymentStatusIntToString(paymentStatusInt As Int) As String
	Dim paymentStatusString As String
	Select paymentStatusInt
		Case 1
			paymentStatusString = "failed"
		Case 2
			paymentStatusString = "pending"
		Case 3
			paymentStatusString = "succeeded"
		Case 4
			paymentStatusString = "cancelled"
		Case 5
			paymentStatusString = "requestRetry"
		Case 6 
			paymentStatusString = "cardNotAccepted"
		Case 7
			paymentStatusString = "createCardAccProblem"
		Case 8
			paymentStatusString = "cardProblem"
		Case 9
			paymentStatusString = "saveCard"
		Case Else
			paymentStatusString = "unknown"
	End Select
	Return paymentStatusString
End Sub

' Returns the specified integer as its equivalent ordinal string (e.g. 1 returns "1st", 2 returns "2nd", etc).
Public Sub ConvertNumberToOrdinalString(inputNumber As Int) As String
	Dim rtnOrdinalString As String = inputNumber & "th"
	
	Dim inputNumberStr As String = inputNumber ' Explicit conversion to string
	Dim lastDigit As String = inputNumberStr.SubString(inputNumberStr.Length - 1)
	
	If Not(inputNumber > 10 And inputNumber < 14) And Not(inputNumber < -10 And inputNumber > -14) Then
		Select Case lastDigit
			Case "1"
				rtnOrdinalString = inputNumber & "st"
			Case "2"
				rtnOrdinalString = inputNumber & "nd"
			Case "3"
				rtnOrdinalString = inputNumber & "rd"
			Case Else
				rtnOrdinalString = inputNumber & "th"
		End Select		
	End If
	
	Return rtnOrdinalString
End Sub

' Convert a payment enum (sent by Server) to int payment status value.
public Sub ConvertPaymentStatusToInt(value As String) As Int
	Dim paymentStatusInt As Int 
	Select Case value
		Case "failed"
			paymentStatusInt = 1
		Case "pending"
			paymentStatusInt = 2
		Case "succeeded"
			paymentStatusInt = 3
		Case "cancelled"
			paymentStatusInt = 4
		Case "requestRetry"
			paymentStatusInt = 5
		Case "cardNotAccepted"
			paymentStatusInt = 6
		Case "createCardAccProblem"
			paymentStatusInt = 7
		Case "cardProblem" 
			paymentStatusInt = 8
		Case "saveCard"
			paymentStatusInt = 9
		Case Else
			paymentStatusInt = 0 ' Default "unknown"
	End Select
	Return paymentStatusInt
End Sub

' Returns the boolean equivalent to the specified string.
' If the string can't be parsed, False will be returned.
Public Sub ConvertStringToBoolean(value As String) As Boolean
	Dim rtnValue As Boolean = False
	If value.ToLowerCase = "true" Then 
		rtnValue = True
	End If
	Return rtnValue
End Sub

' Returns the colour code (i.e. surrogate phaser colour) equivalent to the specified string.
' If the string can't be parsed, then DarkGray (surrogate for Unknown phaser colour) will be returned. 
Public Sub ConvertStringToColour(colourStrg As String) As Int
	Dim rtnColourCode As Int
		
	Select colourStrg.ToLowerCase
		Case "red"
			rtnColourCode = Colors.Red ' Surrogate value for Red phaser colour
		Case "green"
			rtnColourCode = Colors.Green ' Surrogate value for Green phaser colour
		Case "blue"
			rtnColourCode = Colors.Blue ' Surrogate value for Blue phaser colour
		Case "cyan"
			rtnColourCode = Colors.Cyan ' Surrogate value for Cyan phaser colour
		Case "magenta"
			rtnColourCode = Colors.Magenta ' Surrogate value for Magenta phaser colour
		Case "orange"
			rtnColourCode = Colors.Yellow ' Surrogate value for Orange phaser colour
		Case Else
			rtnColourCode = Colors.DarkGray ' Initialise to surrogate value for Unknown phaser colour
	End Select
	
	Return rtnColourCode
End Sub

' Convert this app's status codes to status strings used by the Server.
public Sub ConvertStatusToString(statusCode As Int) As String
	Dim rtnStatus As String
	
	Select statusCode
		Case statusWaiting
			rtnStatus = "waiting"
		Case statusInprogress 
			rtnStatus = "inprogress"
		Case statusReady
			rtnStatus = "ready"
		Case statusCollected
			rtnStatus = "collected"
		Case statusWaitingForPayment
			rtnStatus = "waitingForPayment"
		Case Else
			rtnStatus  = "unknown"
	End Select
	Return rtnStatus
End Sub

' Convert this app's status codes to strings suitable for use in messages displayed to the user.
' Status code - usually from Web Server in a EPOS message (corresponds to VB.net modEposApp.enuOrderStatus).
' forDelivery - set order is for delivery/ reset for collection.
public Sub ConvertStatusToUserString(statusCode As Int, forDelivery As Boolean) As String
	Dim rtnStatus As String = "Unknown"
	
	Select statusCode
		Case statusWaiting
			rtnStatus = "Waiting in Queue"
		Case statusInprogress 
			rtnStatus = "Being Processed"
		Case statusReady
			If forDelivery Then
				rtnStatus = "Being Delivered"			
			Else	
				rtnStatus = "Ready for collection"
			End If
		Case statusCollected
			If forDelivery Then
				rtnStatus = "Delivered"				
			Else
				rtnStatus = "Collected"
			End If
		Case statusWaitingForPayment
			rtnStatus = "Requires Payment"
		Case Else
			rtnStatus = "Unknown"
	End Select
	Return rtnStatus
End Sub

' Convert status string (sent from Server) to internal status flags 
Public Sub ConvertStringToStatus(statusString As String) As Int
	Dim rtnStatus As Int 
	
	Select statusString
		Case "waiting"
			rtnStatus = statusWaiting
		Case "inprogress"
			rtnStatus = statusInprogress
		Case "ready"
			rtnStatus = statusReady
		Case "collected"
			rtnStatus = statusCollected
		Case "waitingForPayment"
			rtnStatus = statusWaitingForPayment
		Case Else
			rtnStatus = statusUnknown
	End Select
	Return rtnStatus
End Sub

#End Region

#Region Local Subroutines
	
' Returns the sum of the digits of the specified integer (e.g. 456 would give 15).
Private Sub lGetDigitSum(inputInt As Int) As Int
	Dim inputStr As String = inputInt

	Dim digitSum As Int = 0
	For charIndex = 0 To (inputStr.Length - 1)
		Dim digit As Int = inputStr.SubString2(charIndex, charIndex + 1)
		digitSum = digitSum + digit
	Next

	Return digitSum
End Sub
	
' Returns the last digit of the result of subtracting the specified subtractor from the specified starting number,
' wrapping around if necessary (i.e. preventing the result being negative by adding enough 10s to make the starting 
' number higher than the subtractor - so 3 minus 5 would give 8 rather than -2).
' <b>Note:</b> this method only works for positive integers.
Private Sub lSubtractWraparound(startingInt As Int, intToSubtract As Int) As Int
	Dim subtractorStr As String = intToSubtract
	Dim subtractorLastDigit As Int = subtractorStr.SubString(subtractorStr.Length - 1)
	Dim resultStr As String = (startingInt + 10) - subtractorLastDigit
	Dim resultLastDigit As Int = resultStr.SubString(resultStr.Length - 1)
	Return resultLastDigit
End Sub

#End Region
