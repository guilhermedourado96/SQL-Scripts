CREATE FUNCTION fn_cortaString( @TEXTO varchar(8000), @COLUNA tinyint, @SEPARADOR char(1)) RETURNS varchar(8000)  AS

-- RECORTA SUBSTRING QUE ESTIVER ENTRE O DELIMITADOR INFORMADO DA OCORRÊNCIA INFORMADA ATÉ A OCORRÊNCIA ANTERIOR (OCOR-1)
-- SINTAXE: fn_cortaString([nome_da_coluna],[num_da_ocorrência],[delimitador])
BEGIN
       DECLARE @POS_INICIAL  int = 1  
       DECLARE @POS_FINAL    int = CHARINDEX(@SEPARADOR, @TEXTO, @POS_INICIAL)  
  
       WHILE (@COLUNA>1 AND @POS_FINAL> 0)  
         BEGIN  
             SET @POS_INICIAL = @POS_FINAL + 1  
             SET @POS_FINAL = CHARINDEX(@SEPARADOR, @TEXTO, @POS_INICIAL)  
             SET @COLUNA = @COLUNA - 1  
         END   
  
       IF @COLUNA > 1  SET @POS_INICIAL = LEN(@TEXTO) + 1  
       IF @POS_FINAL = 0 SET @POS_FINAL = LEN(@TEXTO) + 1   
  
       RETURN SUBSTRING (@TEXTO, @POS_INICIAL, @POS_FINAL - @POS_INICIAL)  
END  
