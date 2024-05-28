CREATE DATABASE Campeonato_Amador

--CRIACAO DAS TABELAS
CREATE TABLE EQUIPE
(
	ID_EQUIPE INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	NOME VARCHAR(50) NOT NULL,
	APELIDO VARCHAR(50) NOT NULL,
	DATA_CRIACAO DATE NOT NULL,
	PONTOS INT
);

CREATE TABLE JOGO
(
	ID_PARTIDA INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	DATA_JOGO DATE NOT NULL,
	TOTAL_GOLS_TIME_M INT NOT NULL,
	TOTAL_GOLS_TIME_V INT NOT NULL,
	RESULTADO VARCHAR(50),
	ID_TIME_MANDANTE INT NOT NULL,
	ID_TIME_VISITANTE INT NOT NULL,
	FOREIGN KEY (ID_TIME_MANDANTE) REFERENCES EQUIPE (ID_EQUIPE),
	FOREIGN KEY (ID_TIME_VISITANTE) REFERENCES EQUIPE (ID_EQUIPE)
);

--TRIGGER
CREATE TRIGGER TGR_RESULTADO_JOGO
ON JOGO
AFTER INSERT
AS
BEGIN
	DECLARE
	@RESULTADO_JOGO VARCHAR(100),
	@ID_PARTIDA INT,
	@GOLS_TIME_M INT,
	@GOLS_TIME_V INT,
	@ID_TIME_M INT,
	@ID_TIME_V INT,
	@PONTOS_TIME_M INT,
	@PONTOS_TIME_V INT

	SELECT @RESULTADO_JOGO =  RESULTADO, @ID_PARTIDA = ID_PARTIDA, @GOLS_TIME_M = TOTAL_GOLS_TIME_M, @GOLS_TIME_V = TOTAL_GOLS_TIME_V, @ID_TIME_M = ID_TIME_MANDANTE, @ID_TIME_V = ID_TIME_VISITANTE FROM INSERTED
	SELECT @PONTOS_TIME_M = PONTOS FROM EQUIPE WHERE ID_EQUIPE = @ID_TIME_M
	SELECT @PONTOS_TIME_V = PONTOS FROM EQUIPE WHERE ID_EQUIPE = @ID_TIME_V

	IF @GOLS_TIME_M > @GOLS_TIME_V
	BEGIN
		SET @PONTOS_TIME_M = 3
		SET @PONTOS_TIME_V = 0
		SET @RESULTADO_JOGO = 'O time Mandante venceu!'
		UPDATE JOGO
		SET RESULTADO = @RESULTADO_JOGO
		WHERE @ID_PARTIDA = ID_PARTIDA
		UPDATE EQUIPE
		SET PONTOS = PONTOS + @PONTOS_TIME_M
		WHERE ID_EQUIPE = @ID_TIME_M
		UPDATE EQUIPE
		SET PONTOS = PONTOS + @PONTOS_TIME_V
		WHERE ID_EQUIPE = @ID_TIME_V
		PRINT('O resultado do jogo e os pontos dos times foram atualizados!')
	END
	ELSE
	BEGIN
		IF @GOLS_TIME_V > @GOLS_TIME_M
		BEGIN
			SET @PONTOS_TIME_V = 5
			SET @PONTOS_TIME_M = 0
			SET @RESULTADO_JOGO = 'O time Visitante venceu!'
			UPDATE JOGO
			SET RESULTADO = @RESULTADO_JOGO
			WHERE ID_PARTIDA = @ID_PARTIDA
			UPDATE EQUIPE
			SET PONTOS = PONTOS + @PONTOS_TIME_M
			WHERE ID_EQUIPE = @ID_TIME_M
			UPDATE EQUIPE
			SET PONTOS = PONTOS + @PONTOS_TIME_V
			WHERE ID_EQUIPE = @ID_TIME_V
			PRINT('O resultado do jogo e os pontos dos times foram atualizados!')
		END
		ELSE
		BEGIN
			SET @PONTOS_TIME_M = 1
			SET @PONTOS_TIME_V = 1
			SET @RESULTADO_JOGO = 'Empate!'
			UPDATE JOGO
			SET RESULTADO = @RESULTADO_JOGO
			WHERE ID_PARTIDA = @ID_PARTIDA
			UPDATE EQUIPE
			SET PONTOS = PONTOS + @PONTOS_TIME_M
			WHERE ID_EQUIPE = @ID_TIME_M
			UPDATE EQUIPE
			SET PONTOS = PONTOS + @PONTOS_TIME_V
			WHERE ID_EQUIPE = @ID_TIME_V;
		END
	END
END
GO

--STORAGE PROCEDURE
USE Campeonato_Amador
GO

CREATE PROCEDURE SP_Classificar_Times
AS
BEGIN
SELECT * FROM EQUIPE
ORDER BY PONTOS DESC
END