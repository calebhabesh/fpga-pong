library ieee;
use ieee.std_logic_1164.all;

-- All registers use the 50 MHz input clock. The DAC clock is an output only.
entity vga_timing is
  port(clk : in std_logic;
       dac_clk, hsync, vsync, active : out std_logic;
       x : out natural range 0 to 799;
       y : out natural range 0 to 524);
end;
architecture rtl of vga_timing is
  signal phase : std_logic := '0';
  signal horizontal : natural range 0 to 799 := 0;
  signal vertical : natural range 0 to 524 := 0;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      phase <= not phase;
      -- Advance on the DAC falling phase; RGB settles before DAC rising.
      if phase = '1' then
        if horizontal = 799 then
          horizontal <= 0;
          if vertical = 524 then vertical <= 0;
          else vertical <= vertical + 1; end if;
        else horizontal <= horizontal + 1; end if;
      end if;
    end if;
  end process;
  dac_clk <= phase;
  x <= horizontal;
  y <= vertical;
  hsync <= '0' when horizontal >= 656 and horizontal < 752 else '1';
  vsync <= '0' when vertical >= 490 and vertical < 492 else '1';
  active <= '1' when horizontal < 640 and vertical < 480 else '0';
end;
