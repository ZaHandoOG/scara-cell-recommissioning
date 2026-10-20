'======================================================================
' AFILADO — Secuencia independiente
'======================================================================
' El robot toma la pieza, la lleva contra la lijadora de banda, la
' presiona contra la lija, gira la herramienta una vuelta completa en
' una dirección y luego regresa el mismo giro en dirección opuesta.
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
' Esta secuencia NO requiere I/O nueva: el giro se hace con JTran sobre
' la articulación 4 (eje U/muñeca), no con una salida física.
'
' Puntos a enseñar antes de ejecutar:
'   AfiladoPick       Punto donde se toma la pieza para esta prueba
'   AfiladoPos        Posición justo encima de la banda, antes de bajar
'   AfiladoContacto   Posición con la pieza en contacto contra la lija
'
' *** VERIFICAR ANTES DE EJECUTAR EN EL ROBOT FÍSICO ***
' JTran 4, 360 gira la articulación 4 (U) 360° de forma RELATIVA a la
' posición actual. Esto requiere que el rango de movimiento (Range) de
' esa articulación permita un recorrido de 360° sin exceder sus límites
' de software; si el rango configurado es menor (algo común en varios
' SCARA de 4 ejes por defecto), esta instrucción arrojará un error de
' límite de recorrido. Confirmar el rango del eje U en la configuración
' del robot (o con la función Range) antes de la primera prueba física.
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
			AfiladoCycle
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
			AfiladoCycle
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

Function AfiladoCycle
	OnErr GoTo eHandler

	' 1) Toma la pieza
	Jump AfiladoPick
	On GripOn
	Wait .1

	' 2) Va a la posición de trabajo y baja hasta el contacto con la lija
	Jump AfiladoPos
	Jump AfiladoContacto

	' 3) Gira la herramienta una vuelta completa y regresa
	JTran 4, 360
	Wait .1
	JTran 4, -360
	Wait .1

	' 4) Se retira de la lija
	Jump AfiladoPos
	Jump Park
	Exit Function

eHandler:
	Print "Error", Err, " en función ", Erf$, ", línea ", Erl, ": ", ErrMsg$(Err)
	Off ReadyLed
	Off InCycle
	On ErrorLight
	Quit All
Fend
