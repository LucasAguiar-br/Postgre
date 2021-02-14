--  Primeira função

CREATE FUNCTION PRIMEIRA_FUNCAO() RETURNS INTEGER AS '
	SELECT (5 - 3) * 2;
' LANGUAGE SQL;

-- BUSCANDO A FUNCAO
SELECT PRIMEIRA_FUNCAO();

-- RENOMEAR SELECT
SELECT PRIMEIRA_FUNCAO() AS NUMERO;

-- Recebendo parâmetros

-> 'Informando o valor dentro dos paranteses, o campo fica restrito, como por exemplo integer, que só ira aceitar valores inteiros'
CREATE FUNCTION SOMADOIS(NUMERO_1 INTEGER, NUMERO_2 INTEGER) RETURNS INTEGER AS ' 
	SELECT NUMERO_1 + NUMERO_2;	
' LANGUAGE SQL;

--INFORMAR OS VALORES DA FUNÇÃO, PARA EXECUTA-LÁ.
SELECT SOMADOIS(2,5)

-- SE NÃO DEFINIMOS OS CAMPOS DENTRO DO PARANTESES, PODEMOS DEFINIR DENTRO DA FUNÇÃO OS CAMPOS
CREATE FUNCTION SOMADOIS(INTEGER, INTEGER) RETURNS INTEGER AS ' 
	SELECT $1 + $2;	
' LANGUAGE SQL;

--EXCLUIR FUNCTION
DROP FUNCTION SOMADOIS;

--Detalhes sobre funções
-- DEMONSTRANDO UM ERRO DENTRO DA FUNCTION

CREATE TABLE A(NOME VARCHAR(255) NOT NULL);
CREATE FUNCTION CRIA_A(NOME VARCHAR) RETURNS VARCHAR AS '
	INSERT INTO A(NOME) VALUES (CRIA_A.NOME);
	SELECT NOME;
' LANGUAGE SQL;

-- O ÚLTIMO VALOR DA FUNÇÃO, PRECISAR RETORNAR ALGUM VALOR.

-- QUANDO TESTAR FUNÇÕES, NÃO É NECESSÁRIO REALIZAR O DROP, APENSAR USAR O COMANDO REPLACE

CREATE OR REPLACE FUNCTION CRIA_A(NOME VARCHAR) RETURNS VARCHAR AS '
	INSERT INTO A(NOME) VALUES (CRIA_A.NOME);
	SELECT NOME;
' LANGUAGE SQL;

SELECT CRIA_A('LUCAS SILVA');

-- SE QUISER APENSAR INSERIR O VALOR, SEM RETORNAR, BASTA ALTERAR DEPOIS DO RETURNS E COLOCAR "VOID";

--INSERIR VALOR, DIRETO DO INSERT, DENTRO DA FUNCTION
--PODEMOS TROCAR AS ASPAS, POR A NOTAÇÃO DE DÓLAR
CREATE OR REPLACE FUNCTION CRIA_A(NOME VARCHAR) RETURNS VARCHAR AS $$
	INSERT INTO A(NOME) VALUES ('PATRICIA');
	SELECT NOME;
$$ LANGUAGE SQL;


-- Parâmetros compostos

CREATE TABLE INSTRUTOR(
	ID SERIAL PRIMARY KEY,
	NOME VARCHAR(255) NOT NULL,
	SALARIO DECIMAL(10,2)
);

INSERT INTO INSTRUTOR (NOME, SALARIO) VALUES ('Lucas Silva', 5000);

-- O CAMPO INSTRUTOR DENTRO DO PARENTESES, É A TABELA COMO PARAMETRO, COM ISSO, DENTRO DO SELECT CONSEGUIMOS ACESSAR O CAMPO SALARIO DA MESMA
CREATE FUNCTION DOBRO_SALARIO (INSTRUTOR) RETURNS DECIMAL AS $$
	SELECT $1.salario * 2 as dobro;	
$$ LANGUAGE SQL;


SELECT NOME, DOBRO_SALARIO(INSTRUTOR.*) FROM INSTRUTOR;

-- Retorno composto

-- NESSE CASO, CRIAMOS UMA FUNÇÃO QUE DEVOLVE UM ITEM DE UMA TABELA, MAS OS TIPOS PRECISAM EXISTIR.
CREATE FUNCTION CRIA_INSTUTOR_FALSO() RETURNS INSTRUTOR AS $$ 
	SELECT 22, 'NOME FALSO', 222::DECIMAL;
$$ LANGUAGE SQL;


SELECT CRIA_INSTUTOR_FALSO();
SELECT * FROM CRIA_INSTUTOR_FALSO();


-- Retornando conjuntos
INSERT INTO INSTRUTOR (NOME, SALARIO) VALUES ('INSTRUTOR2', 2000);
INSERT INTO INSTRUTOR (NOME, SALARIO) VALUES ('INSTRUTOR3', 4000);
INSERT INTO INSTRUTOR (NOME, SALARIO) VALUES ('INSTRUTOR4', 1500);
INSERT INTO INSTRUTOR (NOME, SALARIO) VALUES ('INSTRUTOR5', 10000);
INSERT INTO INSTRUTOR (NOME, SALARIO) VALUES ('INSTRUTOR6', 3800);
INSERT INTO INSTRUTOR (NOME, SALARIO) VALUES ('INSTRUTOR7', 2800);

-- O SETOF, SERVE PARA TRAZERMOS UM CONJUTO DE VALORES
CREATE FUNCTION INSTRUTOR_BEM_PAGO (VALOR_SALARIO DECIMAL)RETURNS  SETOF  INSTRUTOR  AS $$ 
	SELECT * FROM INSTRUTOR WHERE SALARIO > VALOR_SALARIO;
$$ LANGUAGE SQL;


SELECT * FROM  INSTRUTOR_BEM_PAGO(2000);

-- Parâmetros de saída

CREATE FUNCTION SOMA_E_PRODUTO (NUMERO_1 INTEGER, NUMERO_2 INTEGER, OUT SOMA INTEGER, OUT PRODUTO INTEGER) AS $$ 
	SELECT NUMERO_2 + NUMERO_2 AS SOMA, NUMERO_1 * NUMERO_2 AS PRODUTO;
$$ LANGUAGE SQL; 


SELECT * FROM SOMA_E_PRODUTO(3,3);

DROP FUNCTION INSTRUTOR_BEM_PAGO
CREATE FUNCTION INSTRUTOR_BEM_PAGO (VALOR_SALARIO DECIMAL, OUT NOME VARCHAR, OUT SALARIO INTEGER)RETURNS SETOF RECORD AS $$ 
	SELECT NOME, SALARIO FROM INSTRUTOR WHERE SALARIO > VALOR_SALARIO;
$$ LANGUAGE SQL;


-- PostgreSQL e PLs
 -- Estrutura de PLpgSQL
 -- UTILIZANDO O PLPGSQL, PRECISAMOS DEFINIR UM BLOCO DE CÓDIGOS.
 CREATE OR REPLACE FUNCTION PRIMEIRA_PL() RETURNS INTEGER AS $$ 
 	BEGIN
	-- PODEMOS TER VÁRIOS COMANDO SQL
	RETURN 1;
	-- MAS PRECISAMOS DE UM RETURN
	END	
 $$ LANGUAGE PLPGSQL;
 
  SELECT FROM PRIMEIRA_PL();
 
 
 --Declarações de variáveis
 -- Declarar a variável antes do begin
 -- PODEMOS TER VÁRIOS COMANDO SQL
 -- MAS PRECISAMOS DE UM RETURN
  CREATE OR REPLACE FUNCTION PRIMEIRA_PL() RETURNS INTEGER AS $$ 
 	DECLARE
		PRIMEIRA_VARIAVEL INTEGER DEFAULT 3;
	BEGIN
	PRIMEIRA_VARIAVEL := PRIMEIRA_VARIAVEL  * 2;
	RETURN PRIMEIRA_VARIAVEL;
	END	
 $$ LANGUAGE PLPGSQL;
 
 SELECT PRIMEIRA_PL();
-- QUANDO DEFINIMOS O NO DECLARE, E É UM VALOR FIXO, PODEMOS USAR O DEFAUTL, NO CORPO, UTILIZAMOS O :=, COMO BOA PRÁTICA.

-- Blocos
 
 CREATE OR REPLACE FUNCTION PRIMEIRA_PL() RETURNS INTEGER AS $$ 
 	DECLARE
		PRIMEIRA_VARIAVEL INTEGER DEFAULT 3;
	BEGIN
	PRIMEIRA_VARIAVEL := PRIMEIRA_VARIAVEL  * 2;
		BEGIN PRIMEIRA_VARIAVEL := 7;
		END;
	RETURN PRIMEIRA_VARIAVEL;
	END	
 $$ LANGUAGE PLPGSQL;
 
 SELECT PRIMEIRA_PL();
 
 
 -- Retornos em PLs
 
CREATE OR REPLACE FUNCTION CRIA_INSTRUTOR_FALSO() RETURNS INSTRUTOR AS $$ 
	BEGIN
	RETURN ROW (22, 'NOME FALSO', 200::DECIMAL)::INSTRUTOR;
	END;
$$ LANGUAGE PLPGSQL;

-- OUTRO MODO DE RETORNO


CREATE OR REPLACE FUNCTION CRIA_INSTRUTOR_FALSO() RETURNS INSTRUTOR AS $$ 
	DECLARE RETORNO INSTRUTOR;
	BEGIN
	SELECT 22, 'NOME FALSO', 200::DECIMAL INTO RETORNO;
	RETURN RETORNO;
	END;
$$ LANGUAGE PLPGSQL;

DROP FUNCTION INSTRUTOR_BEM_PAGO;
CREATE FUNCTION INSTRUTOR_BEM_PAGO (VALOR_SALARIO DECIMAL) RETURNS SETOF INSTRUTOR AS $$ 
	BEGIN
	RETURN QUERY SELECT * FROM INSTRUTOR WHERE SALARIO > VALOR_SALARIO;
	END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM  INSTRUTOR_BEM_PAGO(500);

-- If - Else

CREATE FUNCTION SALARIO_OK(INSTRUTOR INSTRUTOR) RETURNS VARCHAR AS $$ 
	BEGIN
		IF INSTRUTOR.SALARIO > 4000 THEN
			RETURN 'SALARIO OK';
		ELSE 
			RETURN 'SALARIO PODE AUMENTAR';
			END IF;
	END;
$$ LANGUAGE PLPGSQL;

SELECT NOME, SALARIO_OK(INSTRUTOR) FROM INSTRUTOR;


-- ElseIf
	
CREATE OR REPLACE FUNCTION SALARIO_OK(INSTRUTOR INSTRUTOR) RETURNS VARCHAR AS $$ 
	BEGIN
		IF INSTRUTOR.SALARIO > 4000 THEN
			RETURN 'SALARIO OK';
			ELSEIF INSTRUTOR.SALARIO = 4000 THEN
				RETURN 'SALARIO PODE AUEMNTAR';
				ELSE
				RETURN 'SALARIO DEFASADO';
		END IF;
	END;
$$ LANGUAGE PLPGSQL;

SELECT NOME, SALARIO_OK(INSTRUTOR) FROM INSTRUTOR;




-- Case When

CREATE OR REPLACE FUNCTION SALARIO_OK(INSTRUTOR INSTRUTOR) RETURNS VARCHAR AS $$ 
	BEGIN
		CASE 
			WHEN INSTRUTOR.SALARIO = 2000 THEN
				RETURN 'SALARIO BAIXO';
			WHEN INSTRUTOR.SALARIO = 4000 THEN
				RETURN 'SALARIO OK';
			ELSE
				RETURN 'SALARIO ÓTIMO';
		END CASE;
	END;
$$ LANGUAGE PLPGSQL;

SELECT NOME, SALARIO_OK(INSTRUTOR) FROM INSTRUTOR;

 -- OUTRO MODO 
 
 
CREATE OR REPLACE FUNCTION SALARIO_OK(INSTRUTOR INSTRUTOR) RETURNS VARCHAR AS $$ 
	BEGIN
		CASE INSTRUTOR.SALARIO
			WHEN  2000 THEN
				RETURN 'SALARIO BAIXO';
			WHEN  4000 THEN
				RETURN 'SALARIO OK';
			ELSE
				RETURN 'SALARIO ÓTIMO';
		END CASE;
	END;
$$ LANGUAGE PLPGSQL;

SELECT NOME, SALARIO_OK(INSTRUTOR) FROM INSTRUTOR;


