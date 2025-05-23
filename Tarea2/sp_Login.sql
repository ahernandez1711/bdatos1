USE [test]
GO
/****** Object:  StoredProcedure [dbo].[sp_Login]    Script Date: 23/4/2025 18:09:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_Login]
    @inUsername VARCHAR(64)
    , @inPassword VARCHAR(128)
    , @inIP VARCHAR(64)
    , @outResultCode INT OUTPUT
    , @outUserId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @loginAttempts AS INT;
    DECLARE @isDisabled AS BIT = 0;
    DECLARE @idTipoEvento AS INT;
    DECLARE @idUsuario AS INT;
    
    BEGIN TRY
        -- Obtener ID de usuario si existe
        SELECT @idUsuario = U.id
        FROM [dbo].[Usuario] AS U
        WHERE U.Username = @inUsername;
        
        -- Verificar intentos fallidos recientes
        SELECT @loginAttempts = COUNT(*) 
        FROM [dbo].[BitacoraEvento] AS BE
        INNER JOIN [dbo].[TipoEvento] AS TE ON BE.idTipoEvento = TE.id
        WHERE BE.idPostByUser = @idUsuario
        AND TE.Nombre = 'Login No Exitoso'
        AND BE.PostTime > DATEADD(MINUTE, -30, GETDATE());
        
        -- Validar si está deshabilitado por intentos
        IF @loginAttempts >= 5
        BEGIN
            SET @outResultCode = 50003; -- Login deshabilitado
            SET @isDisabled = 1;
            
            -- Registrar evento de login deshabilitado
            SET @idTipoEvento = (
                SELECT id 
                FROM [dbo].[TipoEvento] 
                WHERE Nombre = 'Login deshabilitado'
            );
            
            INSERT INTO [dbo].[BitacoraEvento] (
                idTipoEvento
                , idPostByUser
                , PostInIP
            )
            VALUES (
                @idTipoEvento
                , @idUsuario
                , @inIP
            );
            
            RETURN;
        END;
        
        -- Verificar credenciales
        IF EXISTS (
            SELECT 1 
            FROM [dbo].[Usuario] AS U
            WHERE U.Username = @inUsername 
            AND U.Password = @inPassword
        )
        BEGIN
            SET @outUserId = @idUsuario;
            
            -- Registrar login exitoso
            SET @idTipoEvento = (
                SELECT id 
                FROM [dbo].[TipoEvento] 
                WHERE Nombre = 'Login Exitoso'
            );
            
            INSERT INTO [dbo].[BitacoraEvento] (
                idTipoEvento
                , idPostByUser
                , PostInIP
            )
            VALUES (
                @idTipoEvento
                , @outUserId
                , @inIP
            );
            
            SET @outResultCode = 0; -- Éxito
            RETURN;
        END
        ELSE
        BEGIN
            -- Determinar tipo de error
            IF @idUsuario IS NULL
                SET @outResultCode = 50001; -- Username no existe
            ELSE
                SET @outResultCode = 50002; -- Password incorrecto
                
            -- Registrar login fallido
            SET @idTipoEvento = (
                SELECT id 
                FROM [dbo].[TipoEvento] 
                WHERE Nombre = 'Login No Exitoso'
            );
            
            INSERT INTO [dbo].[BitacoraEvento] (
                idTipoEvento
                , Descripcion
                , idPostByUser
                , PostInIP
            )
            VALUES (
                @idTipoEvento
                , CONCAT('Intento #', ISNULL(@loginAttempts, 0) + 1)
                , @idUsuario
                , @inIP
            );
            
            RETURN;
        END;
    END TRY
    BEGIN CATCH
        INSERT INTO [dbo].[DBError] (
            UserName
            , Number
            , State
            , Severity
            , Line
            , [Procedure]
            , Message
            , DateTime
        )
        VALUES (
            SUSER_SNAME()
            , ERROR_NUMBER()
            , ERROR_STATE()
            , ERROR_SEVERITY()
            , ERROR_LINE()
            , ERROR_PROCEDURE()
            , ERROR_MESSAGE()
            , GETDATE()
        );
        
        SET @outResultCode = 50005; -- Error en BD
        RETURN;
    END CATCH;
    
    SET NOCOUNT OFF;
END
