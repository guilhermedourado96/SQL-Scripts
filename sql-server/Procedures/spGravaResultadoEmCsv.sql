/*
1º- Antes de executar os comandos, verificar se as permissões do xp_cmdshell estão habilitadas e se a segurança do diretório do actyon está permitido para "TODOS"
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	EXEC sp_configure 'xp_cmdshell', 1;
	RECONFIGURE;
2º - Segue o significado de cada parâmetro do comando de criação do arquivo CSV.
	Parâmetro	<-> Significado
	---------------------------------
	-S			<-> nome do Servidor
	-d			<-> Nome do banco
	-E			<-> Definir como conexão confiável
	-Q			<-> Consulta em comando de linha com saída
	-o			<-> arquivo de saída
	-W			<-> Remove espaços do final
	-s			<-> Delimitador
	-h			<-> Header
3º - Esta procedure deve receber três parâmetros do sistema: diretorio, nome do arquivo e a consulta a ser utilizada.
Segue um exemplo de BLOCO DE TESTE. 
	DECLARE	@DIR		varchar(50)		= 'C:\Actyon\ARQUIVOS',
			@NOME_ARQ	VARCHAR(50)		= 'arquivo_teste',
			@query		varchar(100)	= 'select * from TBOPERADOR'

	EXEC SPGRAVARESULTADOEMCSV 'C:\ACTYON\ARQUIVOS\', 'ARQUIVO_TESTE', 'SELECT * FROM TBOPERADOR'
*/

ALTER PROCEDURE spGravaResultadoEmCsv @DIR VARCHAR(200), @NOME_ARQ VARCHAR(50), @QUERY NVARCHAR(MAX) AS
SET NOCOUNT ON;
-- CAPTURO A DATA DA CRIAÇÃO DO ARQUIVO
DECLARE @DATA VARCHAR(13) = FORMAT(GETDATE(), 'yyyyMMdd_HHmm'),
		@SAIDA BIT = 0,
		@RESULTADO VARCHAR(30)

-- AJUSTO OS PARÂMETROS PARA SEGUIR UM PADRÃO
SET @DIR = UPPER(@DIR)
SET @NOME_ARQ = UPPER(@NOME_ARQ)
SET @QUERY = CONCAT('SET NOCOUNT ON; ',@QUERY)

IF (@DIR IS NOT NULL AND @DIR <> '')
	BEGIN
		-- VERIFICO VIA CMDSHELL SE O DIRETÓRIO JÁ EXISTE OU NÃO
		DECLARE @QUERY_CMD VARCHAR(8000) = 'IF EXIST "' + @DIR + '" ( ECHO 1 ) ELSE ( ECHO 0 )'

		DECLARE @RETORNO TABLE (
		    LINHA INT IDENTITY(1, 1),
		    RESULTADO VARCHAR(MAX)
		)

		INSERT INTO @RETORNO
		EXEC MASTER.DBO.XP_CMDSHELL @COMMAND_STRING = @QUERY_CMD

		SELECT @SAIDA = RESULTADO FROM @RETORNO WHERE LINHA = 1
		-- CASO A SAÍDA SEJA "0" SIGNIFICA QUE O DIRETÓRIO NÃO EXISTE E DEVE SER CRIADO
		IF @SAIDA = 0
			BEGIN
				DECLARE @QUERY_CMD2 VARCHAR(8000) = 'mkdir "' + @DIR + '"'
				DECLARE @RETORNO2 TABLE (LINHA INT IDENTITY(1, 1),Resultado VARCHAR(MAX))
		
				INSERT INTO @RETORNO2 
				EXEC master.dbo.xp_cmdshell @command_string = @QUERY_CMD2

				SELECT @RESULTADO = Resultado FROM @RETORNO2 WHERE LINHA = 1
			END
	END

-- SE O RETORNO DA CRIAÇÃO DO DIRETÓRIO NÃO ACUSAR FALHAS, FICARÁ NULO, POR ISSO VERIFICO SE A VARIÁVEL É NULA PARA CONTINUAR
IF (@RESULTADO IS NULL)
	BEGIN
		SET @DIR = CONCAT(@DIR,'\',@NOME_ARQ,'_',@DATA,'.csv')
		DECLARE @cmd	NVARCHAR(2000) = 'sqlcmd -S '+@@SERVERNAME + ' -d '+DB_NAME()+ ' -E -s "," -W -Q "'+@QUERY+ '" -o "'+ @DIR+ '"'
		EXEC xp_cmdshell @cmd
	END
ELSE -- IMPRIMO O RESULTADO PARA EVIDENCIAR
	SELECT @RESULTADO





