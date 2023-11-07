-----------------------------------------------------------------------
-- Arquivo   : pangman_fd.vhd
-- Projeto   : Experiencia 5 - Sistema de Sonar
-----------------------------------------------------------------------
-- Descricao : fluxo de dados do sistema de sonar da experiência 5
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
use ieee.math_real.all;

entity pangman_fd is
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
end entity pangman_fd;

architecture fd of pangman_fd is
  component controle_servo_3 is
    port (
      clock      : in std_logic;
      reset      : in std_logic;
      posicao    : in std_logic_vector(2 downto 0);
      pwm        : out std_logic;
      db_reset   : out std_logic;
      db_pwm     : out std_logic;
      db_posicao : out std_logic_vector(2 downto 0)
    );
  end component;

  component interface_hcsr04 is
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
  end component interface_hcsr04;

  component tx_serial_7O1 is
    port (
      clock           : in std_logic;
      reset           : in std_logic;
      partida         : in std_logic;
      dados_ascii     : in std_logic_vector(6 downto 0);
      saida_serial    : out std_logic;
      pronto          : out std_logic;
      db_partida      : out std_logic;
      db_saida_serial : out std_logic;
      db_estado       : out std_logic_vector(3 downto 0)
    );
  end component;

  component contadorg_updown_m is
    generic (
      constant M : integer := 50 -- modulo do contador
    );
    port (
      clock   : in std_logic;
      zera_as : in std_logic;
      zera_s  : in std_logic;
      conta   : in std_logic;
      Q       : out std_logic_vector(natural(ceil(log2(real(M)))) - 1 downto 0);
      inicio  : out std_logic;
      fim     : out std_logic;
      meio    : out std_logic
    );
  end component;

  component rom_angulos_8x24 is
    port (
      endereco : in std_logic_vector(2 downto 0);
      saida    : out std_logic_vector(23 downto 0)
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
      Q     : out std_logic_vector(N - 1 downto 0);
      fim   : out std_logic;
      meio  : out std_logic
    );
  end component;

  component mux_8x1_n is
    generic (
      constant BITS : integer := 4
    );
    port (
      D0      : in std_logic_vector(BITS - 1 downto 0);
      D1      : in std_logic_vector(BITS - 1 downto 0);
      D2      : in std_logic_vector(BITS - 1 downto 0);
      D3      : in std_logic_vector(BITS - 1 downto 0);
      D4      : in std_logic_vector(BITS - 1 downto 0);
      D5      : in std_logic_vector(BITS - 1 downto 0);
      D6      : in std_logic_vector(BITS - 1 downto 0);
      D7      : in std_logic_vector(BITS - 1 downto 0);
      SEL     : in std_logic_vector(2 downto 0);
      MUX_OUT : out std_logic_vector(BITS - 1 downto 0)
    );
  end component;

  component rx_serial_7O1 is
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
  end component;

  signal s_trigger, s_pronto                           : std_logic;
  signal s_angulo                                      : std_logic_vector(23 downto 0);
  signal s_distancia                                   : std_logic_vector(11 downto 0);
  signal s_dados_ascii, s_comando                      : std_logic_vector(6 downto 0);
  signal s_centena_ang, s_dezena_ang, s_unidade_ang    : std_logic_vector(6 downto 0);
  signal s_centena_dist, s_dezena_dist, s_unidade_dist : std_logic_vector(6 downto 0);
  signal s_sel, s_posicao                              : std_logic_vector(2 downto 0);
begin

  process (s_pronto, s_comando, zera)
  begin
    if zera = '1' then
      modo <= '0';
    elsif s_pronto = '1' and s_comando = "1101001" then
      modo <= '1';
    elsif s_pronto = '1' and s_comando = "1110010" then
      modo <= '0';
    end if;
  end process;

  timer_2_seg : contador_m
  generic map(
--    M => 1e8, -- 2 s
	 M => 125e5, -- 0,25 s
  --  M => 1e4, -- 200 us para simulacao (TEST_ONLY)
    N => 27
  )
  port map(
    clock => clock,
    zera  => zera_2_seg,
    conta => '1',
    Q     => open,
    fim   => fim_2_seg,
    meio  => open
  );

  timer_1_seg : contador_m
  generic map(
    M => 5e7, -- 1 s
    -- M => 5e3, -- 100 us para simulacao
    N => 26
  )
  port map(
    clock => clock,
    zera  => zera_1_seg,
    conta => '1',
    Q     => open,
    fim   => fim_1_seg,
    meio  => open
  );

  medidor_distancia : interface_hcsr04
  port map(
    clock     => clock,
    reset     => zera,
    medir     => medir,
    echo      => echo,
    trigger   => s_trigger,
    medida    => s_distancia,
    pronto    => fim_medida,
    db_reset  => open,
    db_medir  => open,
    db_estado => db_estado_sensor
  );

  db_echo <= echo;

  trigger    <= s_trigger;
  db_trigger <= s_trigger;

  transmite_dados_sonar : tx_serial_7O1
  port map(
    clock           => clock,
    reset           => zera,
    partida         => transmite,
    dados_ascii     => s_dados_ascii,
    saida_serial    => saida_serial,
    pronto          => fim_transmissao,
    db_partida      => open,
    db_saida_serial => db_saida_serial,
    db_estado       => db_estado_tx
  );

  recebe_dados : rx_serial_7O1
  port map(
    clock             => clock,
    reset             => zera,
    dado_serial       => dado_serial,
    dado_recebido     => s_comando,
    tem_dado          => open,
    paridade_recebida => open,
    pronto            => s_pronto,
    db_dado_serial    => open,
    db_estado         => open
  );

  controle_servo : controle_servo_3
  port map(
    clock      => clock,
    reset      => zera,
    posicao    => s_posicao,
    pwm        => pwm,
    db_reset   => open,
    db_pwm     => db_pwm,
    db_posicao => db_posicao
  );

  contadorg_posicao_ang : contadorg_updown_m
  generic map(
    M => 8
  )
  port map(
    clock   => clock,
    zera_as => zera,
    zera_s  => zera,
    conta   => conta_posicao,
    Q       => s_posicao,
    inicio  => open,
    fim     => fim_servo,
    meio    => open
  );

  angulos : rom_angulos_8x24
  port map(
    endereco => s_posicao,
    saida    => s_angulo
  );

  -- angulo
  s_centena_ang <= s_angulo(22 downto 16);
  s_dezena_ang  <= s_angulo(14 downto 8);
  s_unidade_ang <= s_angulo(6 downto 0);

  -- distancia
  s_centena_dist <= "011" & s_distancia(11 downto 8);
  s_dezena_dist  <= "011" & s_distancia(7 downto 4);
  s_unidade_dist <= "011" & s_distancia(3 downto 0);

  conta_sel_transmissao : contador_m
  generic map(
    M => 8,
    N => 3
  )
  port map(
    clock => clock,
    zera  => zera,
    conta => conta_transmissoes,
    Q     => s_sel,
    fim   => fim_transmissoes,
    meio  => open
  );

  MUX : mux_8x1_n
  generic map(
    BITS => 7
  )
  port map(
    D0      => s_centena_ang,
    D1      => s_dezena_ang,
    D2      => s_unidade_ang,
    D3      => "0101100", -- ,
    D4      => s_centena_dist,
    D5      => s_dezena_dist,
    D6      => s_unidade_dist,
    D7      => "0100011", -- #
    SEL     => s_sel,
    MUX_OUT => s_dados_ascii
  );

end architecture fd;