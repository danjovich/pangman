------------------------------------------------------------------
-- Arquivo   : rx_serial_7O1_fd.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 2 
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             
--     10/09/2023  1.0     Daniel J. Carvalho e Italo R. Lui 
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_7O1_fd is
    port (
        clock       : in std_logic;
        reset       : in std_logic;
        zera        : in std_logic;
        conta       : in std_logic;
        carrega     : in std_logic;
        limpa       : in std_logic;
        desloca     : in std_logic;
        registra    : in std_logic;
        dado_serial : in std_logic;
        saida_ascii : out std_logic_vector(6 downto 0);
        paridade    : out std_logic;
        paridade_ok : out std_logic;
        fim         : out std_logic
    );
end entity;

architecture rx_serial_7O1_fd_arch of rx_serial_7O1_fd is

    component deslocador_n
        generic (
            constant N : integer
        );
        port (
            clock          : in std_logic;
            reset          : in std_logic;
            carrega        : in std_logic;
            desloca        : in std_logic;
            entrada_serial : in std_logic;
            dados          : in std_logic_vector(N - 1 downto 0);
            saida          : out std_logic_vector(N - 1 downto 0)
        );
    end component;

    component contador_m
        generic (
            constant M : integer;
            constant N : integer
        );
        port (
            clock : in std_logic;
            zera  : in std_logic;
            conta : in std_logic;
            Q     : out std_logic_vector(N - 1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component;

    signal s_paridade, s_paridade_esperada : std_logic;
    signal s_dados, s_entrada, s_saida     : std_logic_vector(10 downto 0);
    signal s_saida_ascii                   : std_logic_vector(6 downto 0);

begin

    s_dados <= "11111111111";
    U1 : deslocador_n
    generic map(
        N => 11
    )
    port map(
        clock          => clock,
        reset          => reset,
        carrega        => carrega,
        desloca        => desloca,
        entrada_serial => dado_serial,
        dados          => s_dados,
        saida          => s_saida
    );

    U2 : contador_m
    generic map(
        M => 12, -- 115200 bauds
        N => 4
    )
    port map(
        clock => clock,
        zera  => zera,
        conta => conta,
        Q     => open,
        fim   => fim,
        meio  => open
    );

    s_saida_ascii       <= s_saida(7 downto 1);
    s_paridade          <= s_saida(8);
    s_paridade_esperada <= not (s_saida_ascii(0) xor s_saida_ascii(1)
        xor s_saida_ascii(2) xor s_saida_ascii(3)
        xor s_saida_ascii(4) xor s_saida_ascii(5)
        xor s_saida_ascii(6));

    paridade_ok <= '1' when s_paridade = s_paridade_esperada else
        '0';
        paridade <= s_paridade;
    saida_ascii <= s_saida_ascii;

end architecture;