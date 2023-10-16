

select top 5 
	devedor_id, nome, cpf , 
	isnull((SELECT  tdf.fone + ', ' AS [text()]
			FROM tbdevedor_fone tdf
			WHERE tdf.Devedor_ID = D.devedor_ID
			FOR XML PATH ('')),'-') AS fones
from tbdevedor d