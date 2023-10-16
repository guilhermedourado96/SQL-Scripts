/* 
-> ESTA PROCEDURE CAPTURA DADOS DA COTAÇÃO DO EURO E ARMAZENA EM UMA TABELA TEMPORÁRIA (ALTERAR POSTERIORMENTE);
--	É NECESSÁRIO QUE O NÍVEL DE COMPATIBILIDADE DO BANCO SEJA NO MÍNIMO 140. PODE VERIFICAR USANDO O COMANDO "SELECT compatibility_level FROM SYS.databases";
--	COMANDO DE COMPATIBILIDADE: ALTER DATABASE [NOME_DO_SEU_BANCO] SET COMPATIBILITY_LEVEL = 140;
--	TAMBÉM É NECESSÁRIO QUE AS PROCEDURES DO OLE AUTOMATION SEJAM HABILITADAS;
--> SITE PARA VALIDAR JSON HTTP://JSONVIEWER.STACK.HU/

========================= HABLITAR ANTES DE EXECUTAR ===============================
GO
SP_CONFIGURE 'SHOW ADVANCED OPTIONS', 1;
GO
RECONFIGURE;
GO
SP_CONFIGURE 'OLE AUTOMATION PROCEDURES', 1;
GO
RECONFIGURE;
GO
====================================================================================

*/
--ALTER PROCEDURE [dbo].[sp_cotacaoMoedas] as 

DECLARE 
	@INTTOKEN INT,
	@VCHURL AS VARCHAR(MAX),
	@VCHJSON AS VARCHAR(8000),
	@VCHJSON_VALUE AS VARCHAR(MAX)

	SET @VCHURL = 'HTTPS://ECONOMIA.AWESOMEAPI.COM.BR/JSON/LAST/EUR-BRL'

	/*
	"CODE"			- RETORNA SIGLA DA MOEDA ORIGINAL
	"CODEIN"		- RETORNA SIGLA DA MOEDA OBJETIVO  
	"NAME"			- RETORNA NOME DA MOEDA ORIGINAL E MOEDA OBJETIVO
	"HIGH"			- RETORNA MÁXIMA DA MOEDA
	"LOW"			- RETORNA MÍNIMA DA MOEDA
	"VARBID"		- RETORNA VARIAÇÃO
	"PCTCHANGE"		- RETORNA PORCENTAGEM DE VARIAÇÃO
	"BID"			- RETORNA VALOR DE COMPRA DA MOEDA
	"ASK"			- RETORNA VALOR DE VENDA DA MOEDA
	"TIMESTAMP"		- RETORNA O TIMESTAMP DA DATA
	"CREATE_DATE"	- RETORNA DATA DE CRIAÇÃO 
	*/


	EXEC SP_OACREATE 'MSXML2.XMLHTTP', @INTTOKEN OUT;
	/*CHAMADA PARA MÉTODO OPEN*/
	EXEC SP_OAMETHOD @INTTOKEN, 'OPEN', NULL, 'GET', @VCHURL, 'FALSE';
	/*CHAMADA PARA MÉTODO SEND*/
	EXEC SP_OAMETHOD @INTTOKEN, 'SEND';
	/*CHAMADA PARA MÉTODO RESPONSE TEXT*/
	EXEC SP_OAMETHOD @INTTOKEN, 'RESPONSETEXT', @VCHJSON OUTPUT;
	
	
	IF (ISJSON(@VCHJSON) = 1)
		BEGIN
			SET @VCHJSON_VALUE = (SELECT [VALUE] FROM OPENJSON(@VCHJSON))

			IF OBJECT_ID('TBCOTACAO_MOEDAS') IS NULL 
				BEGIN
					CREATE TABLE TBCOTACAO_MOEDAS(DATA_INCLUSAO_REGISTRO	SMALLDATETIME,
												  DATA_COTACAO			SMALLDATETIME,
												  CONVERSAO				VARCHAR(50),
												  VALOR_BRL				DECIMAL(5,2))

				END


			BEGIN	
				SET DATEFORMAT ymd;
				
				INSERT INTO TBCOTACAO_MOEDAS VALUES (CONVERT(SMALLDATETIME,GETDATE()),
												   (SELECT TOP 1 convert(smalldatetime,[value]) FROM OPENJSON(@vchJSON_value) WHERE [key] = 'create_date'),
												   (SELECT TOP 1 [value] FROM OPENJSON(@vchJSON_value) WHERE [key] = 'name'),
												   (SELECT TOP 1 [value] FROM OPENJSON(@vchJSON_value) WHERE [key] = 'ask'))
			
			END	
		END
	ELSE 
		BEGIN
			PRINT 'NÃO É JSON!'
		END

	EXEC SP_OADESTROY @INTTOKEN;

	SELECT * FROM TBCOTACAO_MOEDAS
	
GO


