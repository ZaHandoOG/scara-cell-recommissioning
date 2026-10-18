# 🤖 Proyecto: Rehabilitación y Recomisionamiento de la Celda SCARA de Manufactura Médica

**Asignatura:** Proyectos VII (Modelo D+i - Semestre AD26)
**Institución:** Universidad Modelo - Ingeniería Mecatrónica
**Alumno / Residente:** Ángel Gabriel Pérez Ongay (Ejecutor Único)

## 📌 Resumen del Proyecto
Este repositorio contiene la reingeniería inversa, los diagramas físicos (eléctricos y neumáticos), los diseños CAD (impresión 3D) y la arquitectura de software en SPEL+ (Epson RC+ 7.0) para el recomisionamiento de una celda robótica SCARA. 

Debido a restricciones de acceso físico a planta, la validación preliminar de las rutinas operativas (Pick and Place, Paletizado, Casos Límite OnErr) se está ejecutando en el banco de pruebas universitario utilizando el manipulador **Epson LS-401S con controlador RC90**.

## 👥 Equipo y Trazabilidad (Full-Stack Mechatronics Engineer)
Al ser un proyecto de residencia individual, todas las tareas técnicas y de gestión recaen en un ejecutor único, cubriendo los siguientes roles:
- **Project Manager:** Gestión de entregables y versiones.
- **Ing. Eléctrico/Neumático:** Diagramas de botonera física y válvula 5/2.
- **Ing. Mecánico:** Modelado e impresión 3D de nidos, pallets y adaptador de gripper.
- **Ing. de Control/Robótica:** Programación en SPEL+ (Rutinas y Homing), manejo de I/O y control de excepciones (Casos Límite).

## 📂 Índice del Repositorio
- `01_Hardware_y_Planos/`: Diagramas eléctricos (botonera) y neumáticos (válvula 5/2 monoestable).
- `02_Mecanica_CAD_y_FEA/`: Archivos STL del adaptador del gripper, piezas circulares y pallets.
- `03_Software_y_Control/`: Código fuente principal (Main.prg) en SPEL+ y rutinas modulares.
- `04_Simulaciones_v0_a_v3/`: Entornos de simulación offline Epson RC+.
- `05_Pruebas_y_Datos_Crudos/`: Evidencias fotográficas y métricas en el banco de pruebas universitario.
- `06_Documentacion_y_Manuales/`: Documentos de Puntos de Control (PC) y reportes.

---
*Repositorio gestionado bajo el estándar metodológico CDIO y PMBOK.*