library ieee;
use ieee.std_logic_1164.all;

-- Preserves the original board ports and four-switch control scheme.
entity pong is
  generic(MOTION_CYCLES : positive := 200002);
  port(clk, SW0, SW1, SW2, SW3 : in std_logic;
       H, V, DAC_CLK : out std_logic;
       Rout, Gout, Bout : out std_logic_vector(7 downto 0));
end;
architecture rtl of pong is
  signal x : natural range 0 to 799;
  signal y : natural range 0 to 524;
  signal active, tick : std_logic;
  signal p1, p2 : natural range 40 to 360;
  signal bx : natural range 0 to 630;
  signal by : natural range 40 to 430;
  signal divider : natural range 0 to MOTION_CYCLES - 1 := 0;
  signal switches_meta, switches_sync : std_logic_vector(3 downto 0) := (others => '0');
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of switches_meta, switches_sync : signal is "TRUE";
begin
  timing: entity work.vga_timing port map(clk, DAC_CLK, H, V, active, x, y);
  game: entity work.pong_game port map(clk, '0', tick, switches_sync, p1, p2, bx, by);
  tick <= '1' when divider = MOTION_CYCLES - 1 else '0';
  process(clk)
  begin
    if rising_edge(clk) then
      switches_meta <= SW3 & SW2 & SW1 & SW0;
      switches_sync <= switches_meta;
      if divider = MOTION_CYCLES - 1 then divider <= 0;
      else divider <= divider + 1; end if;
    end if;
  end process;
  -- Complete VHDL-93 sensitivity list also supports the historical ISE flow.
  process(active, x, y, p1, p2, bx, by)
  begin
    Rout <= (others => '0'); Gout <= (others => '0'); Bout <= (others => '0');
    if active = '1' then
      Gout <= (others => '1');
      if x >= 20 and x < 620 and y >= 20 and y < 460 then
        if y < 40 or y >= 440 or ((x < 40 or x >= 600) and (y < 160 or y >= 320)) then
          Rout <= (others => '1'); Bout <= (others => '1');
        elsif x >= bx and x < bx + 10 and y >= by and y < by + 10 then
          Rout <= (others => '1');
        elsif x >= 50 and x < 60 and y >= p1 and y < p1 + 80 then
          Gout <= (others => '0'); Bout <= (others => '1');
        elsif x >= 580 and x < 590 and y >= p2 and y < p2 + 80 then
          Rout <= (others => '1'); Gout <= (others => '0'); Bout <= (others => '1');
        elsif x >= 318 and x <= 322 and y >= 40 and y < 440 and y mod 64 < 32 then
          Gout <= (others => '0');
        end if;
      elsif x >= bx and x < bx + 10 and y >= by and y < by + 10 then
        Rout <= (others => '1'); Gout <= (others => '0');
      end if;
    end if;
  end process;
end;
