USE [controlPlanillas]
GO
/****** Object:  StoredProcedure [dbo].[sp_ActualizarEmpleado]    Script Date: 12/6/2025 22:44:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_ActualizarEmpleado]
    @inIdEmpleado INT,
    @inNuevoNombre VARCHAR(50),
    @inNuevoIdTipoDocumento INT,
    @inNuevoValorDocumento VARCHAR(50),
    @inNuevoFechaNacimiento DATE,
    @inNuevoIdDepartamento INT,
    @inNuevoIdPuesto INT,
    @inIdUsuario INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @outResultCode = 50008; -- Error inesperado por defecto

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación 1:
        IF NOT EXISTS (SELECT 1 FROM dbo.Empleados WHERE Id = @inIdEmpleado AND Activo = 1)
        BEGIN
            SET @outResultCode = 50006; -- Empleado no existe o inactivo
            ROLLBACK;
            RETURN;
        END

        -- Validación 2: 
        IF NOT EXISTS (SELECT 1 FROM dbo.TiposdeDocumentodeldentidad WHERE Id = @inNuevoIdTipoDocumento)
        BEGIN
            SET @outResultCode = 50006; -- Reutilizado para "Tipo documento no existe"
            ROLLBACK;
            RETURN;
        END

        -- Validación 3:
        IF NOT EXISTS (SELECT 1 FROM dbo.Puestos WHERE Id = @inNuevoIdPuesto)
        BEGIN
            SET @outResultCode = 50016; -- Tipo jornada no existe (reutilizado para puesto)
            ROLLBACK;
            RETURN;
        END

        -- Validación 4:
        IF NOT EXISTS (SELECT 1 FROM dbo.Departamentos WHERE Id = @inNuevoIdDepartamento)
        BEGIN
            SET @outResultCode = 50006; -- Reutilizado para "Departamento no existe"
            ROLLBACK;
            RETURN;
        END

        -- Validación 5: 
        IF EXISTS (
            SELECT 1 FROM dbo.Empleados 
            WHERE ValorDocumento = @inNuevoValorDocumento 
            AND Id <> @inIdEmpleado
        )
        BEGIN
            SET @outResultCode = 50019; -- Deducción ya asociada (reutilizado para documento)
            ROLLBACK;
            RETURN;
        END

        -- Obtener valores actuales para bitácora
        DECLARE @docAnterior VARCHAR(50), @nombreAnterior VARCHAR(50), @puestoAnterior INT, @deptoAnterior INT;

        SELECT 
            @docAnterior = ValorDocumento,
            @nombreAnterior = Nombre,
            @puestoAnterior = NombrePuesto,
            @deptoAnterior = IdDepartamento
        FROM dbo.Empleados
        WHERE Id = @inIdEmpleado;

        -- Actualizar empleado
        UPDATE dbo.Empleados
        SET 
            Nombre = @inNuevoNombre,
            IdTipoDocumento = @inNuevoIdTipoDocumento,
            ValorDocumento = @inNuevoValorDocumento,
            FechaNacimiento = @inNuevoFechaNacimiento,
            IdDepartamento = @inNuevoIdDepartamento,
            NombrePuesto = @inNuevoIdPuesto
        WHERE Id = @inIdEmpleado;

        -- Registrar en bitácora
        INSERT INTO dbo.Eventos (
            idUsuario, 
            idTipoEvento, 
            fecha, 
            descripcion
        )
        VALUES (
            @inIdUsuario,
            (SELECT Id FROM dbo.Tiposdefvento WHERE Nombre = 'Actualización empleado'),
            GETDATE(),
            CONCAT(
                'Actualización empleado ID ', @inIdEmpleado, 
                '. Cambios: [Doc: ', @docAnterior, ' → ', @inNuevoValorDocumento, 
                '], [Nombre: ', @nombreAnterior, ' → ', @inNuevoNombre, 
                '], [Puesto: ', @puestoAnterior, ' → ', @inNuevoIdPuesto, 
                '], [Depto: ', @deptoAnterior, ' → ', @inNuevoIdDepartamento, ']'
            )
        );

        SET @outResultCode = 0; -- Éxito
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SET @outResultCode = 50008; -- Error inesperado

        -- Registrar error en bitácora
        INSERT INTO dbo.Eventos (
            idUsuario, 
            idTipoEvento, 
            fecha, 
            descripcion
        )
        VALUES (
            @inIdUsuario,
            (SELECT Id FROM dbo.Tiposdefvento WHERE Nombre = 'Error'),
            GETDATE(),
            CONCAT('Error en sp_ActualizarEmpleado: ', ERROR_MESSAGE())
        );
    END CATCH;

    SET NOCOUNT OFF;
END;