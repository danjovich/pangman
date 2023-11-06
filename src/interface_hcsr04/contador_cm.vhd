--------------------------------------------------------------------
-- Arquivo   : contador_cm.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : contador de centimetros para o circuito interface_hcsr04
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                      Descricao
--     17/09/2023  1.0     Daniel Carvalho e Italo Lui  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm is
  port (
    clock   : in std_logic;
    reset   : in std_logic;
    pulso   : in std_logic;
    digito0 : out std_logic_vector(3 downto 0);
    digito1 : out std_logic_vector(3 downto 0);
    digito2 : out std_logic_vector(3 downto 0);
    fim     : out std_logic;
    pronto  : out std_logic
  );
end entity;

architecture arch of contador_cm is
  component contador_cm_fd is
    port (
      clock      : in std_logic;
      conta_bcd  : in std_logic;
      zera_bcd   : in std_logic;
      conta_tick : in std_logic;
      zera_tick  : in std_logic;
      digito0    : out std_logic_vector(3 downto 0);
      digito1    : out std_logic_vector(3 downto 0);
      digito2    : out std_logic_vector(3 downto 0);
      fim        : out std_logic;
      tick       : out std_logic
    );
  end component;

  component contador_cm_uc is
    port (
      clock      : in std_logic;
      reset      : in std_logic;
      tick       : in std_logic;
      pulso      : in std_logic;
      conta_bcd  : out std_logic;
      zera_bcd   : out std_logic;
      conta_tick : out std_logic;
      zera_tick  : out std_logic;
      pronto     : out std_logic
    );
  end component;

  -- component contador_bcd_3digitos is
  --   port (
  --     clock   : in std_logic;
  --     zera    : in std_logic;
  --     conta   : in std_logic;
  --     digito0 : out std_logic_vector(3 downto 0);
  --     digito1 : out std_logic_vector(3 downto 0);
  --     digito2 : out std_logic_vector(3 downto 0);
  --     fim     : out std_logic
  --   );
  -- end component;

  -- component contador_m is
  --   generic (
  --     constant M : integer := 50;
  --     constant N : integer := 6
  --   );
  --   port (
  --     clock : in std_logic;
  --     zera  : in std_logic;
  --     conta : in std_logic;
  --     Q     : out std_logic_vector (N - 1 downto 0);
  --     fim   : out std_logic;
  --     meio  : out std_logic
  --   );
  -- end component;

  -- signal s_tick : std_logic;
  signal s_conta_bcd, s_zera_bcd, s_conta_tick, s_zera_tick, s_tick : std_logic;

begin

  FD : contador_cm_fd
  port map(
    clock      => clock,
    conta_bcd  => s_conta_bcd,
    zera_bcd   => s_zera_bcd,
    conta_tick => s_conta_tick,
    zera_tick  => s_zera_tick,
    digito0    => digito0,
    digito1    => digito1,
    digito2    => digito2,
    fim        => fim,
    tick       => s_tick
  );

  UC : contador_cm_uc
  port map(
    clock      => clock,
    reset      => reset,
    tick       => s_tick,
    pulso      => pulso,
    conta_bcd  => s_conta_bcd,
    zera_bcd   => s_zera_bcd,
    conta_tick => s_conta_tick,
    zera_tick  => s_zera_tick,
    pronto     => pronto
  );

  -- contador_bcd : contador_bcd_3digitos
  -- port map(
  --   clock   => clock,
  --   zera    => reset,
  --   conta   => s_tick,
  --   digito0 => digito0,
  --   digito1 => digito1,
  --   digito2 => digito2,
  --   fim     => fim
  -- );

  -- REG1 : contador_m
  -- generic map(
  --   M => 2941,
  --   N => 12
  -- )
  -- port map(
  --   clock => clock,
  --   zera  => reset,
  --   conta => pulso,
  --   Q     => open,
  --   fim   => open,
  --   meio  => s_tick
  -- );
end architecture arch;