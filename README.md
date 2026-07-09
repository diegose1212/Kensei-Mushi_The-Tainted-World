# Kensei-Mushi: The Corrupted World

### Descripción

**Kensei-Mushi: The Corrupted World** es un juego de acción en 3D desarrollado en **Godot 4**, ambientado en un mundo corrompido donde el jugador encarna a un samurái que debe enfrentarse a poderosos jefes enemigos. El combate se basa en el tiempo, los reflejos y la habilidad para bloquear y contraatacar.



### Controles

| Acción         | Tecla            |
|----------------|------------------|
| Mover          | W A S D          |
| Atacar         | Espacio          |
| Cubrirse       | Q                |


###  Mecánicas de juego

- **Movimiento en 3D** libre por el escenario usando `CharacterBody3D` y `move_and_slide()`.
- **Sistema de ataque** con área de colisión (`Area3D`) que detecta al jefe y le aplica daño.
- **Sistema de cobertura**: mantén presionada la tecla **Q** para cubrirte. Mientras te cubres, el daño recibido se reduce un **80%**.
- **Barra de vida** para el jugador y el jefe, que se actualiza en tiempo real durante el combate.
- **Jefe con IA básica**: detecta la distancia al jugador y ataca automáticamente cuando está lo suficientemente cerca, con un intervalo	de tiempo entre golpes.
- **Sistema de muerte**: cuando la vida llega a cero, el personaje o el jefe son eliminados.

---

### Estructura del proyecto


res://
├── mundos/
│   └── mundo_1.tscn          # Escena principal del juego
├── personajes/
│   ├── jugador1.tscn          # Escena del jugador
│   ├── jugador_1.gd           # Script del jugador
│   ├── boss_1.tscn            # Escena del jefe
│   └── boss_1.gd              # Script del jefe
├── barra_vida/
│   ├── barra_vida_jugador.tscn
│   ├── barra_vida_jugador.gd
│   └── barra_vida_boss.gd
└── MaquinaDeEstados/          # Lógica de estados del jefe


---

###  Tecnologías utilizadas

- **Motor:** Godot Engine 4.x
- **Lenguaje:** GDScript
- **Versión estable:** 4.6.3.stable

---

### Cómo ejecutar el proyecto

1. Clona este repositorio:

   git clone https://github.com/Julian-Sanabria-0/kensei-mushi.git
   git clone https://github.com/diegose1212/kensei-mushi.git
  
2. Abre **Godot Engine 4** y selecciona **Importar Proyecto**.
3. Navega hasta la carpeta del repositorio y abre el archivo `project.godot`.
4. Presiona **F5** o el botón ▶ para ejecutar el juego.



### Equipo de desarrollo

Proyecto desarrollado en colaboración como parte de un proceso de aprendizaje de desarrollo de videojuegos con Godot 4.



### Estado del proyecto

 **En desarrollo** — El proyecto se encuentra en una etapa activa de desarrollo. Las mecánicas base de combate están implementadas y funcionales.

**Pendiente / próximas funciones:**
-  Animación de cobertura del jugador
-  Más jefes y escenarios
-  Menú principal
-  Sistema de puntuación
-  Efectos de sonido y música
-  Atuendos desbloqueables
-  Personajes seleccionables
