-----------------------------------------------------------------------
-- Arquivo   : pangman.vhd
-- Projeto   : pangman
-----------------------------------------------------------------------
-- Descricao : circuito do pangman da experiência 5
-----------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                      Descricao
--     08/10/2023  1.0     Daniel Carvalho e Italo Lui  versao inicial
--     14/10/2023  1.1     Daniel Carvalho e Italo Lui  mais sinais db
-----------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pangman is
  port (
    clock            : in std_logic;
    reset            : in std_logic;
    ligar            : in std_logic;
    echo             : in std_logic;
    dado_serial      : in std_logic;
    trigger          : out std_logic;
    pwm              : out std_logic;
    saida_serial     : out std_logic;
    fim_posicao      : out std_logic;
    db_saida_serial  : out std_logic;
    db_pwm           : out std_logic;
    db_trigger       : out std_logic;
    db_echo          : out std_logic;
    db_modo          : out std_logic;
    db_posicao       : out std_logic_vector(2 downto 0);
    db_estado        : out std_logic_vector(6 downto 0);
    db_estado_sensor : out std_logic_vector(6 downto 0);
    db_estado_tx     : out std_logic_vector(6 downto 0);
    db_timeout : out std_logic
    );
end entity pangman;

architecture arch of pangman is
  component pangman_fd is
    port (
      clock              : in std_logic;
      echo               : in std_logic;
      zera               : in std_logic;
      medir              : in std_logic;
      transmite          : in std_logic;
      conta_transmissoes : in std_logic;
      conta_posicao      : in std_logic;
      zera_2_seg         : in std_logic;
      dado_serial        : in std_logic;
      zera_1_seg         : in std_logic;
      conta_1_seg         : in std_logic;
      zera_servo         : in std_logic;
      fim_servo          : out std_logic;
      fim_1_seg          : out std_logic;
      modo               : out std_logic;
      fim_2_seg          : out std_logic;
      fim_medida         : out std_logic;
      fim_transmissao    : out std_logic;
      fim_transmissoes   : out std_logic;
      trigger            : out std_logic;
      saida_serial       : out std_logic;
      pwm                : out std_logic;
      db_saida_serial    : out std_logic;
      db_pwm             : out std_logic;
      db_trigger         : out std_logic;
      db_echo            : out std_logic;
      db_posicao         : out std_logic_vector(2 downto 0);
      db_estado_sensor   : out std_logic_vector(3 downto 0);
      db_estado_tx       : out std_logic_vector(3 downto 0)
    );
  end component pangman_fd;

  component pangman_uc is
    port (
      reset              : in std_logic;
      clock              : in std_logic;
      ligar              : in std_logic;
      mudar_servo        : in std_logic;
      fim_servo          : in std_logic;
      fim_1_seg          : in std_logic;
      fim_2_seg          : in std_logic;
      fim_medida         : in std_logic;
      fim_transmissao    : in std_logic;
      fim_transmissoes   : in std_logic;
      modo               : in std_logic;
      conta_1_seg         : out std_logic;
      zera_1_seg         : out std_logic;
      zera               : out std_logic;
      zera_2_seg         : out std_logic;
      zera_servo         : out std_logic;
      mensurar           : out std_logic;
      transmite          : out std_logic;
      conta_transmissoes : out std_logic;
      conta_posicao      : out std_logic;
      db_estado          : out std_logic_vector(3 downto 0)
    );
  end component;

  component hexa7seg is
    port (
      hexa : in std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
    );
  end component;

  signal s_zera, s_medir, s_transmite, s_conta_transmissoes, s_conta_posicao, s_zera_2_seg, s_fim_2_seg, s_fim_medida, s_fim_transmissao, s_fim_transmissoes, s_modo, s_fim_1_seg, s_zera_1_seg, s_fim_servo, s_zera_servo, s_conta_1_seg : std_logic;
  signal s_db_estado, s_db_estado_sensor, s_db_estado_tx                                                                                                                                                                   : std_logic_vector(3 downto 0);
begin

  FD : pangman_fd
  port map(
    clock              => clock,
    echo               => echo,
    zera               => s_zera,
    medir              => s_medir,
    transmite          => s_transmite,
    conta_transmissoes => s_conta_transmissoes,
    conta_posicao      => s_conta_posicao,
    zera_2_seg         => s_zera_2_seg,
    dado_serial        => dado_serial,
    modo               => s_modo,
    zera_servo         => s_zera_servo,
    fim_servo          => s_fim_servo,
    conta_1_seg => s_conta_1_seg,
    fim_1_seg          => s_fim_1_seg,
    zera_1_seg         => s_zera_1_seg,
    fim_2_seg          => s_fim_2_seg,
    fim_medida         => s_fim_medida,
    fim_transmissao    => s_fim_transmissao,
    fim_transmissoes   => s_fim_transmissoes,
    trigger            => trigger,
    saida_serial       => saida_serial,
    pwm                => pwm,
    db_saida_serial    => db_saida_serial,
    db_pwm             => db_pwm,
    db_trigger         => db_trigger,
    db_echo            => db_echo,
    db_posicao         => db_posicao,
    db_estado_sensor   => s_db_estado_sensor,
    db_estado_tx       => s_db_estado_tx
  );

  UC : pangman_uc
  port map(
    reset              => reset,
    clock              => clock,
    ligar              => ligar,
    mudar_servo        => s_fim_2_seg,
    fim_servo          => s_fim_servo,
    fim_medida         => s_fim_medida,
    fim_transmissao    => s_fim_transmissao,
    fim_transmissoes   => s_fim_transmissoes,
    zera_1_seg         => s_zera_1_seg,
    conta_1_seg => s_conta_1_seg,
    fim_1_seg          => s_fim_1_seg,
    fim_2_seg          => s_fim_2_seg,
    modo               => s_modo,
    zera               => s_zera,
    zera_2_seg         => s_zera_2_seg,
    mensurar           => s_medir,
    transmite          => s_transmite,
    conta_transmissoes => s_conta_transmissoes,
    conta_posicao      => s_conta_posicao,
    zera_servo         => s_zera_servo,
    db_estado          => s_db_estado
  );

  fim_posicao <= s_fim_transmissoes;

  db_estado_7_seg : hexa7seg
  port map(
    hexa => s_db_estado,
    sseg => db_estado
  );

  db_estado_sensor_7_seg : hexa7seg
  port map(
    hexa => s_db_estado_sensor,
    sseg => db_estado_sensor
  );

  db_estado_tx_7_seg : hexa7seg
  port map(
    hexa => s_db_estado_tx,
    sseg => db_estado_tx
  );

  db_modo <= s_modo;
  db_timeout <= s_fim_1_seg;

end architecture arch;