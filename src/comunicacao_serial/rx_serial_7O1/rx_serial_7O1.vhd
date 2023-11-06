-------------------------------------------------------------------------------
-- Arquivo   : rx_serial_7O1.vhd
-- Projeto   : Experiencia 5 - Sistema de Sonar
-------------------------------------------------------------------------------
-- Descricao : circuito de recepcao serial
-------------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                        descricao
--     10/09/2023  1.0     Daniel Carvalho e Italo Lui  criacao
--     05/10/2023  1.1     Daniel Carvalho e Italo Lui  refatoracao para sonar
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_7O1 is
    port (
        clock             : in std_logic;
        reset             : in std_logic;
        dado_serial       : in std_logic;
        dado_recebido     : out std_logic_vector(6 downto 0);
        tem_dado          : out std_logic;
        paridade_recebida : out std_logic;
        pronto            : out std_logic;
        db_dado_serial    : out std_logic;
        db_estado         : out std_logic_vector(3 downto 0)
    );
end entity;

architecture estrutural of rx_serial_7O1 is

    component rx_serial_uc
        port (
            clock       : in std_logic;
            reset       : in std_logic;
            recebe_dado : in std_logic;
            dado        : in std_logic;
            tick        : in std_logic;
            fim         : in std_logic;
            zera        : out std_logic;
            limpa       : out std_logic;
            conta       : out std_logic;
            carrega     : out std_logic;
            desloca     : out std_logic;
            registra    : out std_logic;
            pronto      : out std_logic;
            tem_dado    : out std_logic;
            db_estado   : out std_logic_vector(3 downto 0)
        );
    end component;

    component rx_serial_7O1_fd
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

    component edge_detector
        port (
            clock     : in std_logic;
            signal_in : in std_logic;
            output    : out std_logic
        );
    end component;

    signal s_reset                                                                                  : std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim, s_limpa, s_registra, s_recebe_dado : std_logic;
    signal s_dado_serial, s_dado_serial_ed                                                          : std_logic;
    signal s_estado, s_hex2                                                                         : std_logic_vector(3 downto 0);
    signal s_saida_ascii                                                                            : std_logic_vector(6 downto 0);

begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset       <= reset;
    s_dado_serial <= dado_serial;

    s_recebe_dado <= not s_dado_serial;
    -- unidade de controle
    U1_UC : rx_serial_uc
    port map(
        clock       => clock,
        reset       => s_reset,
        recebe_dado => s_recebe_dado,
        dado        => s_dado_serial,
        tick        => s_tick,
        fim         => s_fim,
        zera        => s_zera,
        limpa       => s_limpa,
        conta       => s_conta,
        carrega     => s_carrega,
        desloca     => s_desloca,
        registra    => s_registra,
        pronto      => pronto,
        tem_dado    => tem_dado,
        db_estado   => s_estado
    );

    -- fluxo de dados
    U2_FD : rx_serial_7O1_fd
    port map(
        clock       => clock,
        reset       => s_reset,
        zera        => s_zera,
        conta       => s_conta,
        carrega     => s_carrega,
        limpa       => s_limpa,
        desloca     => s_desloca,
        registra    => s_registra,
        dado_serial => s_dado_serial,
        saida_ascii => s_saida_ascii,
        paridade    => paridade_recebida,
        paridade_ok => open,
        fim         => s_fim
    );

    -- gerador de tick
    -- fator de divisao para 115.200 bauds (434=50M/115200)
    U3_TICK : contador_m
    generic map(
        M => 434, -- 115200 bauds
        N => 13
    )
    port map(
        clock => clock,
        zera  => s_zera,
        conta => '1',
        Q     => open,
        fim   => open,
        meio  => s_tick
    );

    -- detetor de borda para tratar pulsos largos
    U4_ED : edge_detector
    port map(
        clock     => clock,
        signal_in => s_dado_serial,
        output    => s_dado_serial_ed
    );

    db_estado <= s_estado;
    dado_recebido <= s_saida_ascii;
end architecture;