library ieee;
use ieee.std_logic_1164.all;
use std.env.all;
entity tb_game is end;
architecture test of tb_game is
  signal clk : std_logic := '0';
  signal reset, tick : std_logic := '0';
  signal controls : std_logic_vector(3 downto 0) := "1010";
  signal p1, p2 : natural range 40 to 360;
  signal bx : natural range 0 to 630;
  signal by : natural range 40 to 430;
begin
  clk <= not clk after 5 ns;
  dut: entity work.pong_game port map(clk, reset, tick, controls, p1, p2, bx, by);
  process
    variable old_x, old_y, prior_dx, new_dx : integer;
    variable wall_bounce, paddle_bounce, goal_reset, vertical_bounce : boolean := false;
    procedure step is
    begin
      wait until falling_edge(clk); tick <= '1';
      wait until rising_edge(clk); wait for 1 ns;
    end;
  begin
    wait for 31 ns;
    assert bx = 310 and by = 230 report "Movement occurred without tick" severity failure;
    step;
    assert bx = 311 and by = 231 and p1 = 360 and p2 = 60 report "Initial motion or pause controls incorrect" severity failure;
    controls <= "0101"; -- both paddles upward
    for i in 1 to 400 loop step; end loop;
    assert p1 = 40 and p2 = 40 report "Paddle upper clamp failed" severity failure;
    controls <= "0000";
    for i in 1 to 400 loop step; end loop;
    assert p1 = 360 and p2 = 360 report "Paddle lower clamp failed" severity failure;
    controls <= "1010";
    for i in 1 to 40 loop step; end loop;
    assert p1 = 360 and p2 = 360 report "Paused paddles moved" severity failure;
    reset <= '1'; step; reset <= '0';
    assert bx = 310 and by = 230 and p1 = 360 and p2 = 60 report "Reset failed" severity failure;
    -- Follow the ball with the right paddle; the left paddle remains paused.
    prior_dx := 1;
    for i in 1 to 10000 loop
      if i = 2000 then
        reset <= '1'; step; reset <= '0'; prior_dx := 1;
      end if;
      if i < 2000 then
        if p2 + 40 > by then controls <= "0110"; else controls <= "0010"; end if;
      else controls <= "1010"; end if;
      old_x := bx; old_y := by; step;
      new_dx := integer(bx) - old_x;
      if new_dx = -1 and prior_dx = 1 then
        if old_x = 570 then paddle_bounce := true;
        elsif old_x = 590 then wall_bounce := true; end if;
      elsif new_dx = 1 and prior_dx = -1 then
        if old_x = 60 then paddle_bounce := true;
        elsif old_x = 40 then wall_bounce := true; end if;
      end if;
      if old_y = 40 and by = 41 then vertical_bounce := true; end if;
      if old_x = 0 or old_x = 630 then
        if bx = 300 and by = 220 then goal_reset := true; end if;
      end if;
      if new_dx = 1 or new_dx = -1 then prior_dx := new_dx; end if;
    end loop;
    assert paddle_bounce report "Right-paddle collision not exercised" severity failure;
    assert wall_bounce report "Side-wall collision not exercised" severity failure;
    assert vertical_bounce report "Vertical-wall collision not exercised" severity failure;
    assert goal_reset report "Goal/reset not exercised" severity failure;
    report "PASS: motion enable, paddle bounds/pause, reset, paddle/wall collisions and goal reset";
    finish;
  end process;
end;
