library ieee;
use ieee.std_logic_1164.all;

entity sensor_control is
    port (
        echo : in std_logic;
        async_reset : in std_logic;
        clk : in std_logic;
        result : out std_logic;
        trigger : out std_logic
    );
end sensor_control;

architecture behavioral of sensor_control is
	signal counter: integer range 0 to 511 := 0;
	
begin
	process (clk, async_reset) is
	begin
		if rising_edge(clk) then
			if counter >= 511 then
				counter <= 0;
			else
				counter <= counter + 1;
			end if;
		
			if counter = 438 or counter = 439 then
				result <= not echo;
			else
				result <= '0';
			end if;
		
			if counter = 0 or counter = 1 then
				trigger <= not echo;
			else
				result <= '0';
			end if;
		end if;
		
		if async_reset = '1' then
			counter <= 0;
		end if;
		
	end process;
		
end behavioral;

library ieee;
use ieee.std_logic_1164.all;

entity traffic_control is
    port (
        hr_sensor_echo : in std_logic;
        pc_sensor_echo : in std_logic;
        clk : in std_logic;
        hr_sensor_trigger : out std_logic;
        pc_sensor_trigger : out std_logic;
        mr_green : out std_logic;
        mr_yellow : out std_logic;
        mr_red : out std_logic;
        pc_green : out std_logic;
        pc_yellow : out std_logic;
        pc_red : out std_logic
    );
end traffic_control;

architecture behavioral of traffic_control is
	component sensor_control
	port (
        echo : in std_logic;
        async_reset : in std_logic;
        clk : in std_logic;
        result : out std_logic;
        trigger : out std_logic
   );
	end component;
	
	signal hr_sensor_out, pc_sensor_out: std_logic;
	signal mr_2s: integer range 0 to 100000 := 0;
	signal mr_20s: integer range 0 to 1000000 := 0;
	signal pc_20ms: integer range 0 to 1000 := 0;
	signal pc_2s: integer range 0 to 100000 := 0;
	signal pc_20s: integer range 0 to 1000000 := 0;
	signal pc_state: integer range 0 to 3 := 0;
	signal mr_state: integer range 0 to 2 := 0;
	signal det_people: boolean := false;
	
begin
	pc_s: sensor_control port map (
					pc_sensor_echo => echo,
					clk => clk,
					pc_sensor_out => result,
					pc_sensor_trigger => trigger);
					
	hr_s: sensor_control port map (
					hr_sensor_echo => echo,
					clk => clk,
					hr_sensor_out => result,
					hr_sensor_trigger => trigger);
	
	process (clk)
	begin
		if rising_edge(clk) then
			case pc_state is
				when 0 =>
					if pc_sensor_out = '1' then
						mr_state <= 1;
						det_people <= true;
					end if;
					
				when 1 =>
					pc_20ms <= pc_20ms + 1;
					pc_20s <= pc_20s + 1 when pc_20s < 1000000 else 1000000;
					
					if pc_sensor_out = '1' then
						det_people <= true;
					end if;
					
					if hr_sensor_out = '1' then
						mr_state <= 0;
					end if;
					
					if pc_20ms >= 1000 then
						if det_people = true then
							det_people <= false;
						else
							pc_state <= 0;
						end if;
						
						pc_20ms <= 0;
					end if;
					
					if pc_20s >= 1000000 and mr_state = 2 then
						pc_state <= 2;
						pc_20s <= 0;
					end if;
					
				when 2 =>
					pc_20s <= pc_20s + 1;
					
					if hr_sensor_out = '1' then
						pc_state <= 3;
						pc_20s <= 0;
					end if;
					
					if pc_20s >= 1000000 then
						pc_state <= 3;
						pc_20s <= 0;
					end if;
					
				when 3 =>
					pc_2s <= pc_2s + 1;
					
					if pc_2s >= 100000 then
						pc_state <= 0;
						pc_2s <= 0;
					end if;
						
			end case;
			
			case mr_state is
				when 0 =>
					if hr_sensor_out = '1' then
						mr_state <= 1;
					end if;
				
				when 1 =>
					mr_2s <= mr_2s + 1;
					
					if mr_2s >= 100000 then
						mr_state <= 2;
						mr_2s <= 0;
					end if;
				
				when 2 =>
					mr_20s <= mr_20s + 1 when mr_20s < 1000000 else 1000000;
					
					if mr_20s >= 1000000 and (pc_state = 0 or pc_state = 1) then
						mr_state <= 0;
						mr_20s <= 0;
					end if;
				
			end case;
			
		end if;
		
		mr_green <= '1' when mr_state = 0 else '0';
		mr_yellow <= '1' when mr_state = 1 else '0';
		mr_red <= '1' when mr_state = 2 else '0';
		
		pc_red <= '1' when pc_state = 0 or pc_state = 1 else '0';
		pc_green <= '1' when pc_state = 2 else '0';
		pc_yellow <= '1' when pc_state = 3 else '0';
		
	end process;
	
end behavioral;
