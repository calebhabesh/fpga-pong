# Provenance

Student submission: Caleb Habesh, COE758 fall 2024, VGA video-game project.
`archive/pong.vhd` and `archive/constraints.ucf` were copied byte for byte from the
submitted project. [SHA-256 manifest](evidence/archive-sha256.txt).

The game follows a course assignment and the lab's VGA-controller/interface
guidance. The source names Caleb as engineer; no contribution-by-line audit against
all teaching examples is established. Describe this as a course project, not an
invented video standard or an independently designed FPGA/DAC board.

2026 work: separated video timing, game state and rendering; replaced internal
logic-derived clocks with clock enables; added input synchronizers and initialized
directions; corrected sync boundaries and RGB sensitivity; aligned side-wall
collision/rendering regions; added clock constraints and self-checking video/game
tests; captured a frame directly from RTL; added reproducible container checks and CI.

`docs/assets/board-demo-2024.webp` is the photograph from page 10 of the personal
final report. It was extracted without changing the scene, then encoded as WebP.
It is proof of historical board execution only. Reports containing student IDs and
assignment handouts are not published here. The original full report and bitstream
remain in the private school archive.

No blanket license is asserted over any course-derived material. Preserve the
course attribution when referencing this educational project.
