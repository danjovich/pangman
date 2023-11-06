-----------------Laboratorio Digital-------------------------------------------
-- Arquivo   : controle_servo_3.vhd
-- Projeto   : Experiencia 5 - Sistema de Sonar
-------------------------------------------------------------------------------
-- Descricao : 
--             codigo VHDL para controle de um servomotor
-------------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                       Descricao
--     05/09/2023  1.0     Daniel Carvalho e Italo Lui  criacao
--     24/08/2022  1.1     Daniel Carvalho e Italo Lui  refatoracao para sonar
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is
    port (
        clock      : in std_logic;
        reset      : in std_logic;
        posicao    : in std_logic_vector(2 downto 0);
        pwm        : out std_logic;
        db_reset   : out std_logic;
        db_pwm     : out std_logic;
        db_posicao : out std_logic_vector(2 downto 0)
    );
end entity controle_servo_3;

architecture rtl of controle_servo_3 is
    component circuito_pwm is
        generic (
            conf_periodo : integer := 1250; -- periodo do sinal pwm [1250 => f=4KHz (25us)]
            largura_000  : integer := 0;    -- largura do pulso p/ 000 [0 => 0]
            largura_001  : integer := 50;   -- largura do pulso p/ 001 [50 => 1us]
            largura_010  : integer := 500;  -- largura do pulso p/ 010 [500 => 10us]
            largura_011  : integer := 1000; -- largura do pulso p/ 011 [1000 => 20us]
            largura_100  : integer := 2000; -- largura do pulso p/ 100 [2000 => 40us]
            largura_101  : integer := 4000; -- largura do pulso p/ 101 [4000 => 80us]
            largura_110  : integer := 8000; -- largura do pulso p/ 110 [8000 => 160us]
            largura_111  : integer := 16000 -- largura do pulso p/ 111 [16000 => 320us]
        );
        port (
            clock   : in std_logic;
            reset   : in std_logic;
            largura : in std_logic_vector(2 downto 0);
            pwm     : out std_logic
        );
    end component;

    signal s_pwm : std_logic;

begin

    pwm_interno : circuito_pwm
    generic map(
        conf_periodo => 1e6,
        -- conf_periodo => 110001, -- para simulacao do servo!
        largura_000  => 35000,
        largura_001  => 45700,
        largura_010  => 56450,
        largura_011  => 67150,
        largura_100  => 77850,
        largura_101  => 88550,
        largura_110  => 99300,
        largura_111  => 110000
    )
    port map(
        clock   => clock,
        reset   => reset,
        largura => posicao,
        pwm     => s_pwm
    );

    db_reset   <= reset;
    db_posicao <= posicao;
    db_pwm     <= s_pwm;
    pwm        <= s_pwm;

end architecture rtl;