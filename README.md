# CandyNDS: Desarrollo de un juego tipo Candy Crush para Nintendo DS

**CandyNDS** es un proyecto académico completo que adapta la experiencia de un juego tipo Candy Crush a la consola Nintendo DS (NDS), combinando lógica de juego y representación gráfica animada. Este proyecto busca explotar al máximo las capacidades de hardware de la NDS para ofrecer una experiencia inmersiva.

---

## Características principales

### Dinámica de juego:
- **Tablero interactivo**: Una matriz con casillas que pueden contener:
  - Elementos básicos que se combinan en secuencias para ser eliminados.
  - Gelatinas simples y dobles con comportamientos especiales.
  - Bloques sólidos y huecos que afectan la caída de elementos.
- **Progresión de niveles**:
  - Supera objetivos como eliminar gelatinas o alcanzar puntuaciones específicas.
  - Gestiona movimientos limitados y aprovecha sugerencias de combinaciones.

### Gráficos y animaciones:
- **Elementos visuales**:
  - Sprites detallados para los componentes del juego.
  - Fondos dinámicos con patrones ajedrezados y una imagen estática.
- **Efectos animados**:
  - Movimiento fluido de piezas.
  - Escalado dinámico para sugerencias de movimientos.
  - Animación de gelatinas y desplazamiento del fondo general.

### Implementación técnica:
- **Lógica y gráficos**:
  - Desarrollo modular en C y ensamblador (ARM v5).
  - Rutinas optimizadas para gestionar el juego, sprites y animaciones.
- **Gestión del proyecto**:
  - Integración de funcionalidades en un sistema cohesivo.
  - Control de versiones para manejar la colaboración y las iteraciones del desarrollo.

---

## Organización del proyecto

### Estructura general:
El repositorio incluye una organización clara de ficheros que manejan la lógica del juego, configuraciones, gráficos y rutinas de animación. Algunos ejemplos destacados son:
- **Lógica del juego**:
  - `candy1_init.s`, `candy1_secu.s`, `candy1_move.s`: Rutinas fundamentales para la gestión del tablero.
- **Gráficos y animaciones**:
  - `RSI_timer*.s`: Control de animaciones de sprites, escalado y fondo.
  - `candy2_graf.c`, `candy2_main.c`: Inicialización y control gráfico.
- **Configuración y soporte**:
  - `candy2_conf.s`: Configuración de niveles y elementos gráficos.
  - `Sprites_sopo.s`, `candy2_sopo.c`: Gestión de sprites y soporte.

---

## Objetivo

El proyecto **CandyNDS** ofrece una experiencia integral de desarrollo para sistemas embebidos, abarcando desde lógica básica hasta gráficos avanzados y animaciones. Está diseñado como un desafío técnico y creativo que maximiza las capacidades de la Nintendo DS.

--- 

¿Así está mejor ajustado? 😊
