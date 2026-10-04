library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity tb_pong is end;
architecture test of tb_pong is
  signal clk : std_logic := '0';
  signal h, v, dac : std_logic;
  signal r, g, b : std_logic_vector(7 downto 0);
begin
  clk <= not clk after 10 ns;
  dut: entity work.pong port map(clk, '0', '1', '0', '1', h, v, dac, r, g, b);
  process
    variable white_pixels : natural := 0;
  begin
    -- Count a line through the top white border. Rendering must respond to X.
    for pixel in 0 to 800 * 21 - 1 loop
      wait until rising_edge(dac);
      wait for 1 ns;
      if pixel >= 800 * 20 then
        if r = x"ff" and g = x"ff" and b = x"ff" then
          white_pixels := white_pixels + 1;
        end if;
      end if;
    end loop;
    assert white_pixels = 600 report "RGB did not follow pixel coordinates: expected 600 white border pixels, got " & natural'image(white_pixels) severity failure;
    report "PASS: combinational RGB changes across a scanline";
    finish;
  end process;
end;
