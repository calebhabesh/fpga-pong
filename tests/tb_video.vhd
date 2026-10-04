library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.all;
entity tb_video is end;
architecture test of tb_video is
  signal clk : std_logic := '0';
  signal h, v, dac : std_logic;
  signal r, g, b : std_logic_vector(7 downto 0);
begin
  clk <= not clk after 10 ns;
  dut: entity work.pong generic map(MOTION_CYCLES => 50000000)
    port map(clk, '0', '1', '0', '1', h, v, dac, r, g, b);
  process
    file frame : text open write_mode is "frame.ppm";
    variable l : line;
    variable active_pixels, horizontal_low, vertical_low : natural := 0;
    variable previous_edge : time := 0 ns;
  begin
    write(l, string'("P3")); writeline(frame, l);
    write(l, string'("640 480")); writeline(frame, l);
    write(l, string'("255")); writeline(frame, l);
    for y in 0 to 524 loop
      for x in 0 to 799 loop
        wait until rising_edge(dac); wait for 1 ns;
        if previous_edge /= 0 ns then
          assert now - previous_edge = 40 ns report "Incorrect pixel clock period" severity failure;
        end if;
        previous_edge := now;
        if x >= 656 and x < 752 then
          assert h = '0' report "Horizontal sync pulse mismatch" severity failure;
          horizontal_low := horizontal_low + 1;
        else assert h = '1' report "Horizontal sync porch mismatch" severity failure; end if;
        if y = 490 or y = 491 then
          assert v = '0' report "Vertical sync pulse mismatch" severity failure;
          vertical_low := vertical_low + 1;
        else assert v = '1' report "Vertical sync porch mismatch" severity failure; end if;
        if x < 640 and y < 480 then
          active_pixels := active_pixels + 1;
          write(l, to_integer(unsigned(r))); write(l, string'(" "));
          write(l, to_integer(unsigned(g))); write(l, string'(" "));
          write(l, to_integer(unsigned(b))); writeline(frame, l);
        else
          assert r = x"00" and g = x"00" and b = x"00" report "RGB must be black during blanking" severity failure;
        end if;
        if x = 25 and y = 25 then
          assert r = x"ff" and g = x"ff" and b = x"ff" report "White border missing" severity failure;
        elsif x = 55 and y = 365 then
          assert r = x"00" and g = x"00" and b = x"ff" report "Blue paddle missing" severity failure;
        elsif x = 585 and y = 65 then
          assert r = x"ff" and g = x"00" and b = x"ff" report "Magenta paddle missing" severity failure;
        elsif x = 315 and y = 235 then
          assert r = x"ff" and g = x"ff" and b = x"00" report "Yellow ball missing" severity failure;
        end if;
      end loop;
    end loop;
    assert active_pixels = 307200 and horizontal_low = 96 * 525 and vertical_low = 2 * 800 severity failure;
    wait until rising_edge(dac); wait for 1 ns;
    assert h = '1' and v = '1' and g = x"ff" report "Frame did not wrap to pixel (0,0)" severity failure;
    report "PASS: 800x525 frame, 640x480 active pixels, sync widths, porches, blanking, colors and 40 ns DAC period";
    file_close(frame); finish;
  end process;
end;
