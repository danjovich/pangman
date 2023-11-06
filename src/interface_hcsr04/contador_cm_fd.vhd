--------------------------------------------------------------------
-- Arquivo   : contador_cm_fd.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : fluxo de dados para o circuito contador_cm
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                      Descricao
--     17/09/2023  1.0     Daniel Carvalho e Italo Lui  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm_fd is
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
end entity contador_cm_fd;

architecture arch of contador_cm_fd is

  component contador_bcd_3digitos is
    port (
      clock   : in std_logic;
      zera    : in std_logic;
      conta   : in std_logic;
      digito0 : out std_logic_vector(3 downto 0);
      digito1 : out std_logic_vector(3 downto 0);
      digito2 : out std_logic_vector(3 downto 0);
      fim     : out std_logic
    );
  end component;

  component contador_m is
    generic (
      constant M : integer := 50;
      constant N : integer := 6
    );
    port (
      clock : in std_logic;
      zera  : in std_logic;
      conta : in std_logic;
      Q     : out std_logic_vector (N - 1 downto 0);
      fim   : out std_logic;
      meio  : out std_logic
    );
  end component;

begin

  contador_bcd : contador_bcd_3digitos
  port map(
    clock   => clock,
    zera    => zera_bcd,
    conta   => conta_bcd,
    digito0 => digito0,
    digito1 => digito1,
    digito2 => digito2,
    fim     => fim
  );

  REG1 : contador_m
  generic map(
    M => 2941,
    N => 12
  )
  port map(
    clock => clock,
    zera  => zera_tick,
    conta => conta_tick,
    Q     => open,
    fim   => open,
    meio  => tick
  );

end architecture arch;