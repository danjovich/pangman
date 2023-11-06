--------------------------------------------------------------------
-- Arquivo   : contador_cm_uc.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : unidade de controle para o circuito contador_cm
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                      Descricao
--     17/09/2023  1.0     Daniel Carvalho e Italo Lui  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm_uc is
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
end entity;
architecture arch of contador_cm_uc is
  type tipo_estado is (inicial, preparacao, espera_tick, conta_cm, final);
  signal Eatual, Eprox : tipo_estado;
begin

  -- estado
  process (reset, clock)
  begin
    if reset = '1' then
      Eatual <= inicial;
    elsif clock'event and clock = '1' then
      Eatual <= Eprox;
    end if;
  end process;

  -- logica de proximo estado
  process (tick, pulso, Eatual)
  begin
    case Eatual is
      when inicial => if pulso = '1' then
        Eprox <= preparacao;
      else Eprox <= inicial;
      end if;
      when preparacao => Eprox <= espera_tick;
      when espera_tick => if tick = '1' then
        Eprox <= conta_cm;
      elsif pulso = '0' then
        EProx <= final;
      else Eprox <= espera_tick;
      end if;
      when conta_cm => Eprox <= espera_tick;
      when final => if pulso = '1' then
        Eprox <= preparacao;
      else Eprox <= final;
      end if;
      when others => Eprox <= inicial;
    end case;
  end process;

  -- saidas de controle
  with Eatual select
    zera_bcd <= '1' when preparacao, '0' when others;
  with Eatual select
    zera_tick <= '1' when inicial | final, '0' when others;
  with Eatual select
    conta_bcd <= '1' when conta_cm, '0' when others;
  with Eatual select
    conta_tick <= '1' when preparacao | espera_tick | conta_cm, '0' when others;
  with Eatual select
    pronto <= '1' when final, '0' when others;

end architecture arch;