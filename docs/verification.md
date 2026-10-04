# Verification, 2026-10-04

GHDL 5.1.1 mcode, Ubuntu 24.04 container, Linux x86-64 host.
`bash scripts/check-docker.sh` passes; exact image digest is pinned in the script
and GitHub Actions. The retained log is in `evidence/verification-2026-10-04.log`.

The archived source fails `tb_pong`: the RGB process listens only to video-active
changes and therefore produces **zero** white pixels on a line expecting **600**.
The refreshed renderer includes every combinational dependency in its sensitivity
list, and that same test passes. This catches a simulation/synthesis discrepancy
without a subjective screenshot comparison.

`tb_video` verifies all 420,000 pixel positions of one frame and the first pixel
of the next, measures the 40 ns DAC period, checks 96×525 horizontal-sync samples
and 2×800 vertical-sync samples, and confirms black RGB during blanking. It tests
known border, ball and paddle coordinates and writes `build/frame.ppm` directly
from the RGB outputs. The PNG in `docs/assets/` is a lossless encoding of that PPM.
The capture uses an enlarged motion divider so the game remains still during a frame.

`tb_game` verifies enable gating, paddle saturation/pause, reset and trajectories
that exercise paddle bounce, vertical/side-wall bounce and goal reset. The top-level
simulation exercises the video/game integration, while the game test accelerates
motion through its existing tick input.

GHDL synthesis elaboration succeeds, with warnings that its backend ignores ISE's
`ASYNC_REG` annotation. No FPGA resource usage, Fmax, timing closure, new bitstream
or fresh hardware run is established. The 2024 resource counts describe the archived
source only; its unconstrained timing report cannot substantiate a maximum clock.
