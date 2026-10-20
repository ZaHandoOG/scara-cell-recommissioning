'======================================================================
' AJUSTE — Secuencia independiente
'======================================================================
' Toma la pieza, la deja en el eje rotatorio (posición A), espera a que
' el eje gire, la vuelve a tomar, y la deja en la base de ajuste de
' altura: abre pinza, baja un poco, y vuelve a cerrar pinza.
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
'   Output GiraEje      Comanda el giro del eje rotatorio
'   Input  EjeGirado    Confirma que el eje terminó de girar
'
' Puntos a enseñar antes de ejecutar:
'   AjustePick      Punto donde se toma la pieza para esta prueba
'   EjeRotativo     Posición A, sobre el eje rotatorio
'   AjusteBase      Base de ajuste de altura
'
' Parámetro editable:
'   AJUSTE_BAJA     Distancia (mm) que baja la pinza para el ajuste fino
'======================================================================

#define AJUSTE_BAJA 5

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
	' Tarea en segundo plano (task 2): vigila el botón de Stop en todo
	' momento e interrumpe la tarea principal (task 1) sin importar en
	' qué instrucción se encuentre, incluyendo un Jump en curso.
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
			AjusteCycle
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
			AjusteCycle
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

Function AjusteCycle
	OnErr GoTo eHandler

	' 1) Toma la pieza del punto de origen
	Jump AjustePick
	On GripOn
	Wait .1

	' 2) La lleva al eje rotatorio (posición A) y la deja
	Jump EjeRotativo
	Off GripOn
	Wait .1

	' 3) Comanda el giro del eje y espera su confirmación
	On GiraEje
	Wait Sw(EjeGirado) = On
	Off GiraEje

	' 4) Vuelve a tomar la pieza ya girada
	Jump EjeRotativo
	On GripOn
	Wait .1

	' 5) La lleva a la base de ajuste de altura
	Jump AjusteBase
	Off GripOn                 ' abre la pinza para soltar sobre la base
	Wait .1
	Go Here :Z(-AJUSTE_BAJA)   ' baja un poco (movimiento local, sin arco)
	Wait .1
	On GripOn                  ' vuelve a cerrar la pinza en la nueva altura
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
