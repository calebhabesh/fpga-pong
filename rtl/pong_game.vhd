library ieee;
use ieee.std_logic_1164.all;

entity pong_game is
  port(clk, reset, tick : in std_logic;
       controls : in std_logic_vector(3 downto 0);
       p1_y, p2_y : out natural range 40 to 360;
       ball_x : out natural range 0 to 630;
       ball_y : out natural range 40 to 430);
end;
architecture rtl of pong_game is
  signal left_y : natural range 40 to 360 := 360;
  signal right_y : natural range 40 to 360 := 60;
  signal bx : natural range 0 to 630 := 310;
  signal by : natural range 40 to 430 := 230;
  signal dx, dy : integer range -1 to 1 := 1;
begin
  process(clk)
    variable nx, ny, vx, vy : integer;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        left_y <= 360; right_y <= 60;
        bx <= 310; by <= 230; dx <= 1; dy <= 1;
      elsif tick = '1' then
        if controls(1) = '0' then
          if controls(0) = '1' and left_y > 40 then left_y <= left_y - 1;
          elsif controls(0) = '0' and left_y < 360 then left_y <= left_y + 1; end if;
        end if;
        if controls(3) = '0' then
          if controls(2) = '1' and right_y > 40 then right_y <= right_y - 1;
          elsif controls(2) = '0' and right_y < 360 then right_y <= right_y + 1; end if;
        end if;
        vx := dx; vy := dy;
        if by <= 40 then vy := 1;
        elsif by >= 430 then vy := -1; end if;
        -- Direction guard avoids repeated reversal while overlapping a paddle.
        if vx = -1 and bx <= 60 and bx >= 50 and by < left_y + 80 and by + 10 > left_y then
          vx := 1;
        elsif vx = 1 and bx + 10 >= 580 and bx < 590 and by < right_y + 80 and by + 10 > right_y then
          vx := -1;
        elsif vx = -1 and bx = 40 and (by < 160 or by + 10 > 320) then
          vx := 1;
        elsif vx = 1 and bx = 590 and (by < 160 or by + 10 > 320) then
          vx := -1;
        end if;
        nx := bx + vx; ny := by + vy;
        if nx < 0 or nx > 630 then
          bx <= 300; by <= 220; dx <= 1; dy <= 1;
        else
          bx <= nx; by <= ny; dx <= vx; dy <= vy;
        end if;
      end if;
    end if;
  end process;
  p1_y <= left_y; p2_y <= right_y; ball_x <= bx; ball_y <= by;
end;
