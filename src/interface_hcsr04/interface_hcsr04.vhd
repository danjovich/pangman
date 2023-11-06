--------------------------------------------------------------------
-- Arquivo   : interface_hcsr04.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : circuito de interface com o sensor HCSR04
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                      Descricao
--     17/09/2023  1.0     Daniel Carvalho e Italo Lui  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04 is
  port (
    clock     : in std_logic;
    reset     : in std_logic;
    medir     : in std_logic;
    echo      : in std_logic;
    trigger   : out std_logic;
    medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
    pronto    : out std_logic;
    db_reset  : out std_logic;
    db_medir  : out std_logic;
    db_estado : out std_logic_vector(3 downto 0) -- estado da UC
  );
end entity interface_hcsr04;

architecture arch of interface_hcsr04 is

  component interface_hcsr04_fd is
    port (
      clock      : in std_logic;
      zera       : in std_logic;
      gera       : in std_logic;
      registra   : in std_logic;
      pulso      : in std_logic;
      fim_medida : out std_logic;
      trigger    : out std_logic;
      medida     : out std_logic_vector(11 downto 0) -- 3 digitos BCD
    );
  end component;

  component interface_hcsr04_uc is
    port (
      clock      : in std_logic;
      reset      : in std_logic;
      medir      : in std_logic;
      echo       : in std_logic;
      fim_medida : in std_logic;
      zera       : out std_logic;
      gera       : out std_logic;
      registra   : out std_logic;
      pronto     : out std_logic;
      db_estado  : out std_logic_vector(3 downto 0)
    );
  end component;
  signal s_zera, s_gera, s_registra, s_fim_medida : std_logic;

begin
  FD : interface_hcsr04_fd
  port map(
    clock      => clock,
    zera       => s_zera,
    gera       => s_gera,
    registra   => s_registra,
    pulso      => echo,
    fim_medida => s_fim_medida,
    trigger    => trigger,
    medida     => medida
  );

  UC : interface_hcsr04_uc
  port map(
    clock      => clock,
    reset      => reset,
    medir      => medir,
    echo       => echo,
    fim_medida => s_fim_medida,
    zera       => s_zera,
    gera       => s_gera,
    registra   => s_registra,
    pronto     => pronto,
    db_estado  => db_estado
  );

  -- debug
  db_reset <= reset;
  db_medir <= medir;

end architecture arch;