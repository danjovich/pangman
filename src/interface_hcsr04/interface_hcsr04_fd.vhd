--------------------------------------------------------------------
-- Arquivo   : interface_hcsr04_fd.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : fluxo de dados para o circuito interface_hcsr04
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                      Descricao
--     17/09/2023  1.0     Daniel Carvalho e Italo Lui  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04_fd is
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
end entity interface_hcsr04_fd;

architecture arch of interface_hcsr04_fd is

  component gerador_pulso is
    generic (
      largura : integer := 25
    );
    port (
      clock  : in std_logic;
      reset  : in std_logic;
      gera   : in std_logic;
      para   : in std_logic;
      pulso  : out std_logic;
      pronto : out std_logic
    );
  end component;

  component registrador_n is
    generic (
      constant N : integer := 8
    );
    port (
      clock  : in std_logic;
      clear  : in std_logic;
      enable : in std_logic;
      D      : in std_logic_vector (N - 1 downto 0);
      Q      : out std_logic_vector (N - 1 downto 0)
    );
  end component;

  component contador_cm is
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
  end component;

  signal s_digitos : std_logic_vector(11 downto 0);

begin

  gerador_trigger : gerador_pulso
  generic map(
    largura => 500
    -- largura => 1 -- (TEST_ONLY)
  )
  port map(
    clock  => clock,
    reset  => zera,
    gera   => gera,
    para   => '0',
    pulso  => trigger,
    pronto => open
  );

  registrador_12 : registrador_n
  generic map(
    N => 12
  )
  port map(
    clock  => clock,
    clear  => zera,
    enable => registra,
    D      => s_digitos,
    Q      => medida
  );

  cm : contador_cm
  port map(
    clock   => clock,
    reset   => zera,
    pulso   => pulso,
    digito0 => s_digitos(3 downto 0),
    digito1 => s_digitos(7 downto 4),
    digito2 => s_digitos(11 downto 8),
    fim     => open,
    pronto  => fim_medida
  );

end architecture arch;