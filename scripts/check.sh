#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
cd build
ghdl -a --std=08 ../rtl/vga_timing.vhd ../rtl/pong_game.vhd ../rtl/pong.vhd ../tests/tb_pong.vhd ../tests/tb_video.vhd ../tests/tb_game.vhd
for test in tb_pong tb_video tb_game; do
  ghdl -r --std=08 "$test" --assert-level=error
done
ghdl --synth --std=08 pong > pong-netlist.vhd
echo 'PASS: GHDL synthesis elaboration (not FPGA placement or timing closure)'
