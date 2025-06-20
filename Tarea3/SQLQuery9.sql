USE [controlPlanillas]
GO
/****** Object:  StoredProcedure [dbo].[sp_AsociarDeduccionEmpleado]    Script Date: 10/6/2025 22:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER   PROCEDURE [dbo].[sp_AsociarDeduccionEmpleado]
    @inIdEmpleado INT,
    @inIdTipoDeduccion INT,
    @inIdUsuario INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Verificar que el empleado existe y está activo
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Empleados] WHERE id = @inIdEmpleado AND Activo = 1)
        BEGIN
            SET @outResultCode = 50014;
            RETURN;
        END
        
        -- Verificar que el tipo de deducción existe
        IF NOT EXISTS (SELECT 1 FROM [dbo].[TiposDeDeduccion] WHERE id = @inIdTipoDeduccion)
        BEGIN
            SET @outResultCode = 50015;
            RETURN;
        END
        
        -- Verificar que no esté ya asociada
        IF EXISTS (SELECT 1 FROM [dbo].[DeduccionXEmpleado] 
                  WHERE idEmpleado = @inIdEmpleado AND idTipoDeDeduccion = @inIdTipoDeduccion)
        BEGIN
            SET @outResultCode = 50016;
            RETURN;
        END
        
        -- Asociar deducción al empleado
        INSERT INTO [dbo].[DeduccionXEmpleado] (
            idTipoDeDeduccion,
            idEmpleado
        )
        VALUES (
            @inIdTipoDeduccion,
            @inIdEmpleado
        );
        
        -- Registrar evento
        INSERT INTO [dbo].[Eventos] (
            idUsuario,
            idTipoEvento,
            fecha
        )
        VALUES (
            @inIdUsuario,
            (SELECT id FROM [dbo].[TiposdeEvento] WHERE Nombre = 'Asociar deducción'),
            GETDATE()
        );
        
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        SET @outResultCode = 50017;
        
        INSERT INTO [dbo].[Eventos] (
            idUsuario,
            idTipoEvento,
            fecha
        )
        VALUES (
            @inIdUsuario,
            (SELECT id FROM [dbo].[TiposdeEvento] WHERE Nombre = 'Error en SP'),
            GETDATE()
        );
        
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en sp_AsociarDeduccionEmpleado: %s', 16, 1, @ErrorMsg);
    END CATCH;
    
    SET NOCOUNT OFF;
END;
