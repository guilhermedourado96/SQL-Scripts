CREATE FUNCTION fn_cortaString( @TEXT varchar(8000), @COLUMN tinyint, @SEPARATOR char(1)) RETURNS varchar(8000)  AS

-- RECORTA SUBSTRING QUE ESTIVER ENTRE O DELIMITADOR INFORMADO DA OCORRÊNCIA INFORMADA ATÉ A OCORRÊNCIA ANTERIOR (OCOR-1)
-- SINTAXE: fn_cortaString([nome_da_coluna],[num_da_ocorrência],[delimitador])
BEGIN
       DECLARE @POS_START  int = 1  
       DECLARE @POS_END    int = CHARINDEX(@SEPARATOR, @TEXT, @POS_START)  
  
       WHILE (@COLUMN >1 AND @POS_END> 0)  
         BEGIN  
             SET @POS_START = @POS_END + 1  
             SET @POS_END = CHARINDEX(@SEPARATOR, @TEXT, @POS_START)  
             SET @COLUMN = @COLUMN - 1  
         END   
  
       IF @COLUMN > 1  SET @POS_START = LEN(@TEXT) + 1  
       IF @POS_END = 0 SET @POS_END = LEN(@TEXT) + 1   
  
       RETURN SUBSTRING (@TEXT, @POS_START, @POS_END - @POS_START)  
END  