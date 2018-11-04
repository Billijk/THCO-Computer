library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart is
    Port ( clk : in  STD_LOGIC; 
           rst : in  STD_LOGIC; 
           send_data : in  STD_LOGIC_VECTOR (7 downto 0);
           data_ready : in  STD_LOGIC;
           send_data_complete : out STD_LOGIC;
           receive_data_complete : out STD_LOGIC;
           tbre : in  STD_LOGIC;
           tsre : in  STD_LOGIC;
           receive_data : out  STD_LOGIC_VECTOR (7 downto 0);
           en1 : in STD_LOGIC;
           en2 : in STD_LOGIC;
           en3 : in STD_LOGIC;
           ram1oe : out  STD_LOGIC;
           ram1we : out  STD_LOGIC;
           ram1en : out  STD_LOGIC;
           rdn : out  STD_LOGIC;
           wrn : out  STD_LOGIC;
           ram1data : inout  STD_LOGIC_VECTOR (7 downto 0));
end uart;

architecture Behavioral of uart is
type big_state_machine is (read_uart, write_uart); 
type read_state_machine is (r1, r2, r3);
type write_state_machine is (w0, w1, w2, w3, w4, w5);
signal big_state : big_state_machine;
signal read_state : read_state_machine;
signal write_state : write_state_machine;

begin

receive_data_complete <= data_ready;
ram1data <= send_data when en1 = '1' else "ZZZZZZZZ";

process(rst, clk, en1, en2) is
begin
    if rst = '0' then
        send_data_complete <= '1';
        ram1en <= '1';
        ram1oe <= '1';
        ram1we <= '1';
        if en1 = '0' then
            big_state <= read_uart;
            read_state <= r1;
        elsif en1 = '1' then
            big_state <= write_uart;
            write_state <= w0;
        end if;
    elsif falling_edge(clk) and en2 = '1' then
        if en1 = '1' then
            big_state <= write_uart;
            if big_state = read_uart then
                write_state <= w0;
            end if;
        end if;
        if big_state = read_uart then
            case read_state is
                when r1 =>
                    rdn <= '1';
                    read_state <= r2;
                when r2 =>
                    if data_ready = '1' and en3 = '1' then
                        rdn <= '0';
                        read_state <= r3;
                    elsif data_ready = '0' then
                        read_state <= r1;
                    end if;
                when r3 =>
                    receive_data <= ram1data;
                    read_state <= r1;
            end case;
        elsif big_state = write_uart then 
            case write_state is
                when w0 =>
                    wrn <= '1';
                    write_state <= w1;
                    send_data_complete <= '0';
                when w1 =>
                    wrn <= '0';
                    write_state <= w2;
                when w2 =>
                    wrn <= '1';
                    write_state <= w3;
                when w3 =>
                    if tbre = '1' then
                        write_state <= w4;
                    end if;
                when w4 =>
                    if tsre = '1' then 
                        big_state <= read_uart;
                        read_state <= r1;
                        send_data_complete <= '1';
                    end if;
                when w5 => null;
            end case;
        end if;
    end if;
end process;
end Behavioral;

