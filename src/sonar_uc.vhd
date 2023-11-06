------------------------------------------------------------------------
-- Arquivo   : sonar_uc.vhd
-- Projeto   : Experiencia 5 - Sistema de Sonar
------------------------------------------------------------------------
-- Descricao : unidade de controle do sistema de sonar da experiência 5
------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                      Descricao
--     08/10/2023  1.0     Daniel Carvalho e Italo Lui  versao inicial
------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_uc is
  port (
    reset              : in std_logic;
    clock              : in std_logic;
    ligar              : in std_logic;
    fim_2_seg          : in std_logic;
    fim_medida         : in std_logic;
    fim_transmissao    : in std_logic;
    fim_transmissoes   : in std_logic;
    zera               : out std_logic;
    zera_2_seg         : out std_logic;
    mensurar           : out std_logic;
    transmite          : out std_logic;
    conta_transmissoes : out std_logic;
    conta_posicao      : out std_logic;
    db_estado          : out std_logic_vector(3 downto 0)
  );
end entity sonar_uc;

architecture uc of sonar_uc is
  type tipo_estado is (
    inicial,
    preparacao,
    aguarda,
    medida,
    transmissao,
    espera_transmissao,
    proxima_transmissao,
    mudar_posicao,
    final
  );
  signal Eatual, Eprox : tipo_estado;
begin

  -- estado
  process (reset, clock)
  begin
    if reset = '1' or ligar = '0' then
      Eatual <= inicial;
    elsif clock'event and clock = '1' then
      Eatual <= Eprox;
    end if;
  end process;

  -- logica de proximo estado
  process (ligar, fim_2_seg, fim_medida, fim_transmissao, Eatual)
  begin
    case Eatual is
      when inicial =>
        if ligar = '1' then
          Eprox <= preparacao;
        else
          Eprox <= inicial;
        end if;

      when preparacao => Eprox <= aguarda;

      when aguarda =>
        if fim_2_seg = '1' then
          Eprox <= medida;
        else
          Eprox <= aguarda;
        end if;

      when medida =>
        if fim_medida = '1' then
          Eprox <= transmissao;
        else
          Eprox <= medida;
        end if;

      when transmissao => Eprox <= espera_transmissao;

      when espera_transmissao =>
        if fim_transmissao = '1' then
          Eprox <= proxima_transmissao;
        else
          Eprox <= espera_transmissao;
        end if;

      when proxima_transmissao =>
        if ligar = '1' then
          if fim_transmissoes = '1' then
            Eprox <= mudar_posicao;
          else
            Eprox <= transmissao;
          end if;
        else
          Eprox <= final;
        end if;

      when mudar_posicao => Eprox <= aguarda;

      when final => Eprox <= inicial;

      when others => Eprox <= inicial;
    end case;
  end process;

  -- saidas de controle
  with Eatual select
    --      zera <= '1' when inicial | preparacao, '0' when others;
    zera <= '1' when preparacao, '0' when others;
  with Eatual select
    zera_2_seg <= '1' when preparacao, '0' when others;
  with Eatual select
    mensurar <= '1' when medida, '0' when others;
  with Eatual select
    transmite <= '1' when transmissao, '0' when others;
  with Eatual select
    conta_transmissoes <= '1' when proxima_transmissao, '0' when others;
  with Eatual select
    conta_posicao <= '1' when mudar_posicao, '0' when others;

  with Eatual select
    db_estado <=
    "0000" when inicial,
    "0001" when preparacao,
    "0010" when aguarda,
    "0011" when medida,
    "0100" when transmissao,
    "0101" when espera_transmissao,
    "0110" when mudar_posicao,
    "1111" when final,
    "1110" when others;

end architecture uc;