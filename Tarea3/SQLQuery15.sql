USE [controlPlanillas]
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarEmpleado]    Script Date: 12/6/2025 22:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_InsertarEmpleado]
    @inNombre VARCHAR(50),
    @inIdTipoDocumento INT,
    @inValorDocumento VARCHAR(50),
    @inFechaNacimiento DATE,
    @inIdDepartamento INT,
    @inIdPuesto INT,
    @inIdUsuario INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @outResultCode = 50008; -- Error inesperado por defecto

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validaciones:
        -- 1. ¿Existe el tipo de documento?
        IF NOT EXISTS (SELECT 1 FROM dbo.TiposdeDocumentodeldentidad WHERE Id = @inIdTipoDocumento)
        BEGIN
            SET @outResultCode = 50006; -- Empleado no existe o inactivo 
            ROLLBACK;
            RETURN;
        END

        -- 2. ¿Existe el puesto?
        IF NOT EXISTS (SELECT 1 FROM dbo.Puestos WHERE Id = @inIdPuesto)
        BEGIN
            SET @outResultCode = 50016; -- Tipo jornada no existe 
            ROLLBACK;
            RETURN;
        END

        -- 3. ¿Documento duplicado?
        IF EXISTS (SELECT 1 FROM dbo.Empleados WHERE ValorDocumento = @inValorDocumento)
        BEGIN
            SET @outResultCode = 50019; -- Deducción ya asociada 
            ROLLBACK;
            RETURN;
        END

        -- Insertar empleado
        INSERT INTO dbo.Empleados (
            Nombre, 
            IdTipoDocumento, 
            ValorDocumento, 
            FechaNacimiento, 
            IdDepartamento, 
            NombrePuesto, 
            IdUsuario, 
            Activo
        ) VALUES (
            @inNombre, 
            @inIdTipoDocumento, 
            @inValorDocumento, 
            @inFechaNacimiento, 
            @inIdDepartamento, 
            @inIdPuesto, 
            @inIdUsuario, 
            1 -- Activo
        );

        -- Éxito: El trigger tr_AsignarDeduccionesObligatorias se ejecutará automáticamente
        SET @outResultCode = 0; 

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SET @outResultCode = 50008; -- Error inesperado

        -- Registrar error en bitácora 
        INSERT INTO dbo.Eventos (idUsuario, idTipoEvento, fecha, descripcion)
        VALUES (
            @inIdUsuario, 
            (SELECT Id FROM dbo.Tiposdefvento WHERE Nombre = 'Error'), 
            GETDATE(), 
            ERROR_MESSAGE()
        );
    END CATCH;
END;