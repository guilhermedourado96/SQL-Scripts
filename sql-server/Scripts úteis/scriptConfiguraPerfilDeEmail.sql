-----------------------------------------------------------------------------------------
-- HABILITA O ENVIO DE E-MAIL NO SERVIDOR
-----------------------------------------------------------------------------------------
sp_configure 'show advanced options', 1;
GO
RECONFIGURE
GO
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO
-----------------------------------------------------------------------------------------
-- CRIA UMA CONTA DE ENVIO DE E-MAIL NO BANCO DE DADOS
-----------------------------------------------------------------------------------------
DECLARE
    @Account_Name SYSNAME = 'Nome da conta',	-- ALTERAR PARA NOME DA CONTA DE EMAIL A SER UTILIZADA
    @Profile_Name SYSNAME = 'Nome do Perfil'		-- MUDAR PARA NOME DO PERFIL DE EMAIL A SER UTILIZADO
IF ((SELECT COUNT(*) FROM msdb.dbo.sysmail_account WHERE name = @Account_Name) > 0)
    EXEC msdb.dbo.sysmail_delete_account_sp @account_name = @Account_Name
 
 
EXEC msdb.dbo.sysmail_add_account_sp
    @account_name = @Account_Name,
    @description = 'Descrição da conta',							-- INSERIR DESCRIÇÃO DA CONTA DBMAIL, 
    @email_address = '',											-- INSERIR ENDEREÇO DE EMAIL A SER UTILIZADO
    @replyto_address = '',											-- INSERIR EMAIL DE REPLICAÇÃO
    @display_name = 'Importações Actyon',							-- INSERIR NOME EXIBIDO PARA A CONTA DE EMAIL
    @mailserver_name = 'smtp.seu_email.com.br',						-- INSERIR SERVIDOR DE MAIL A SER UTILIZADO PELA CONTA DE EMAIL
    @mailserver_type = 'SMTP',										-- INSERIR PROTOCOLO DE ENVIO DE EMAIL
    @port = '587',													-- INSERIR A PORTA UTILIZADA PELO PROTOCOLO SMTP 
    @username = '',													-- INSERIR ENDEREÇO DE EMAIL A SER UTILIZADO
    @password = '',													-- INSERIR SENHA DO ENDEREÇO DE EMAIL A SER UTILIZADO
    @enable_ssl = 0,												-- DESABILITA O USO DO SSL
    @use_default_credentials = 0									-- DESABILITA USO DAS CREDENCIAIS PADRÃO
 
 
 
-----------------------------------------------------------------------------------------
-- CRIA O PERFIL DE E-MAIL
-----------------------------------------------------------------------------------------
 
IF ((SELECT COUNT(*) FROM msdb.dbo.sysmail_profile WHERE name = @Profile_Name) > 0)
    EXEC msdb.dbo.sysmail_delete_profile_sp @profile_name = @Profile_Name
 
 
 
EXEC msdb.dbo.sysmail_add_profile_sp
    @profile_name = @Profile_Name,
    @description = 'Descrição do perfil de email' ;
 
 
-----------------------------------------------------------------------------------------
-- ADICIONA A CONTA AO PERFIL CRIADO
-----------------------------------------------------------------------------------------
 
DECLARE 
    @profile_id INT = (SELECT profile_id FROM msdb.dbo.sysmail_profile WHERE name = @Profile_Name), 
    @account_id INT = (SELECT account_id FROM msdb.dbo.sysmail_account WHERE name = @Account_Name)
    
IF ((SELECT COUNT(*) FROM msdb.dbo.sysmail_profileaccount WHERE account_id = @account_id AND profile_id = @profile_id) > 0)
    EXEC msdb.dbo.sysmail_delete_profileaccount_sp @profile_name = @Profile_Name, @account_name = @Account_Name
 
EXEC msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @Profile_Name,
    @account_name = @Account_Name,
    @sequence_number = 1;
-----------------------------------------------------------------------------------------
-- LIBERA ACESSO NO PERFIL CRIADO PARA TODOS OS USUÁRIOS
-----------------------------------------------------------------------------------------
IF ((SELECT COUNT(*) FROM msdb.dbo.sysmail_principalprofile WHERE profile_id = @profile_id) > 0)
    EXEC msdb.dbo.sysmail_delete_principalprofile_sp @profile_name = @Profile_Name
 
EXEC msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = @Profile_Name,
    @principal_name = 'public', -- AQUI VOCÊ PODE DAR ACESSO SOMENTE PARA UM USUÁRIO ESPECÍFICO, SE PREFERIR
    @is_default = 0;
 
-----------------------------------------------------------------------------------------
-- DEFINE O TAMANHO MÁXIMO POR ANEXO 
-----------------------------------------------------------------------------------------
EXEC msdb.dbo.sysmail_configure_sp 'MaxFileSize', '200000000';
