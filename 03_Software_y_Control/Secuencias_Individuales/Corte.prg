'======================================================================
' CORTE — Secuencia independiente
'======================================================================
' El robot toma la pieza, la coloca en el cilindro neumático de corte
' y la SOSTIENE mientras el cilindro avanza y corta. Al terminar, el
' cilindro retrocede y el robot se retira sin soltar la pieza (continúa
' sujeta hacia el siguiente proceso).
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
' E/S NUEVA que requiere esta secuencia (definir en el editor de
' IOLabel antes de ejecutar; no forma parte del mapa de I/O original):
'   Output CorteCilindro    Comanda el avance del cilindro de corte
'   Input  CilindroAvanzado Confirma cilindro avanzado (corte hecho)
'
'   Si el cilindro NO tiene sensores de fin de carrera, sustituir las
'   líneas "Wait Sw(...)" por una espera de tiempo fija (ej. Wait .5)
'   — se deja indicado en el código donde corresponde.
'
' Puntos a enseñar antes de ejecutar:
'   CortePick        Punto donde se toma la pieza para esta prueba
'   CorteFijacion    Posición de la pieza dentro/contra el cilindro
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
	Off CorteCilindro
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
			CorteCycle
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
			CorteCycle
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

Function CorteCycle
	OnErr GoTo eHandler

	' 1) Toma la pieza
	Jump CortePick
	On GripOn
	Wait .1

	' 2) La coloca en posición dentro del cilindro de corte
	'    (la pinza permanece cerrada: el robot sostiene la pieza
	'    durante todo el corte)
	Jump CorteFijacion

	' 3) Activa el cilindro neumático y espera a que corte
	On CorteCilindro
	Wait Sw(CilindroAvanzado) = On
	' Sin sensor de avance, sustituir la línea anterior por: Wait .5

	' 4) Retrocede el cilindro antes de retirar el brazo
	Off CorteCilindro
	Wait Sw(CilindroAvanzado) = Off
	' Sin sensor de retroceso, sustituir la línea anterior por: Wait .5

	' 5) El robot se retira; la pieza sigue sujeta para el siguiente proceso
	Jump Park
	Exit Function

eHandler:
	Print "Error", Err, " en función ", Erf$, ", línea ", Erl, ": ", ErrMsg$(Err)
	Off ReadyLed
	Off InCycle
	On ErrorLight
	Quit All
Fend
