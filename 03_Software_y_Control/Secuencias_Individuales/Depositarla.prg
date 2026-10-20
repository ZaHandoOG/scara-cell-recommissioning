'======================================================================
' DEPOSITARLA — Secuencia independiente
'======================================================================
' Pick and place simple: el robot toma la pieza y la deja en un lugar
' específico.
'
' E/S física (IOLabel) ya establecida en el proyecto:
'   Input  StartCycle   Botón de ciclo continuo (NA)
'   Input  UniqB        Botón de ciclo único (NA)
'   Input  StopB        Botón de paro (NA) -> Sw(StopB) = On al presionarlo
'   Output ReadyLed     Indicador de listo
'   Output InCycle      Indicador de ciclo en ejecución
'   Output ErrorLight   Indicador de error/paro
'   Output GripOn       Control de la pinza
'
' Puntos a enseñar antes de ejecutar:
'   DepositarlaPick    Punto donde se toma la pieza para esta prueba
'   DepositarlaLugar   Lugar específico donde se deposita la pieza
'======================================================================

Global Boolean gStopRequested

Function Main
	gStopRequested = False
	Initialize
	Xqt 2, StopMonitor
	MainLoop
Fend

Function Initialize
	OnErr GoTo eHandler

	Robot 1
	Reset
	Off ErrorLight
	Off InCycle
	Off ReadyLed
	Off GripOn
	Motor On
	Speed 10
	Accel 20, 20
	Power Low
	Arm 0
	Tool 1
	Jump Park

	On ReadyLed
	Exit Function

eHandler:
	Print "Error", Err, " en función ", Erf$, ", línea ", Erl, ": ", ErrMsg$(Err)
	Off ReadyLed
	Off InCycle
	On ErrorLight
	Quit All
Fend

Function StopMonitor
	Do
		If Sw(StopB) = On Then
			gStopRequested = True
			Halt 1
			Wait Sw(StopB) = Off
		EndIf
	Loop
Fend

Function MainLoop
	Boolean bContinuous

	OnErr GoTo eHandler
	bContinuous = False

	Do
		If gStopRequested Then
			bContinuous = False
			Off InCycle
			On ReadyLed
			gStopRequested = False
			Resume 1
		EndIf

		If Sw(UniqB) = On And Sw(StopB) = Off Then
			Off ReadyLed
			On InCycle
			DepositarlaCycle
			Off InCycle
			On ReadyLed
			Wait Sw(UniqB) = Off
		EndIf

		If Sw(StartCycle) = On And Sw(StopB) = Off Then
			bContinuous = True
		EndIf

		If bContinuous And Sw(StopB) = Off Then
			Off ReadyLed
			On InCycle
			DepositarlaCycle
		ElseIf Sw(StopB) = On Then
			bContinuous = False
		EndIf
	Loop

eHandler:
	Print "Error", Err, " en función ", Erf$, ", línea ", Erl, ": ", ErrMsg$(Err)
	Off ReadyLed
	Off InCycle
	On ErrorLight
	Quit All
Fend

Function DepositarlaCycle
	OnErr GoTo eHandler

	Jump DepositarlaPick
	On GripOn
	Wait .1
	Jump DepositarlaLugar
	Off GripOn
	Wait .1
	Jump Park
	Exit Function

eHandler:
	Print "Error", Err, " en función ", Erf$, ", línea ", Erl, ": ", ErrMsg$(Err)
	Off ReadyLed
	Off InCycle
	On ErrorLight
	Quit All
Fend
