USE [controlPlanillas]
GO
/****** Object:  StoredProcedure [dbo].[sp_EliminarEmpleado]    Script Date: 12/6/2025 22:44:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_EliminarEmpleado]
    @inIdEmpleado INT,
    @inConfirmacion BIT, -- 1 = sí, 0 = no
    @inIdUsuario INT,    -- Usuario que realiza la acción
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @outResultCode = 50008; -- Error inesperado por defecto

    DECLARE @docID VARCHAR(50), @nombre VARCHAR(50), @idPuesto INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación 1: ¿Existe el empleado y está activo?
        IF NOT EXISTS (SELECT 1 FROM dbo.Empleados WHERE Id = @inIdEmpleado AND Activo = 1)
        BEGIN
            SET @outResultCode = 50006; -- Empleado no existe o ya fue eliminado
            ROLLBACK;
            RETURN;
        END

        -- Validación 2: ¿Tiene registros asociados? (Opcional, según requisitos)
        IF EXISTS (SELECT 1 FROM dbo.Jornadas WHERE idEmpleado = @inIdEmpleado)
        BEGIN
            SET @outResultCode = 50020; -- Empleado tiene jornadas asignadas
            ROLLBACK;
            RETURN;
        END

        -- Obtener datos para bitácora
        SELECT 
            @docID = ValorDocumento,
            @nombre = Nombre,
            @idPuesto = NombrePuesto
        FROM dbo.Empleados
        WHERE Id = @inIdEmpleado;

        -- Caso: Eliminación sin confirmación
        IF @inConfirmacion = 0
        BEGIN
            INSERT INTO dbo.Eventos (
                idUsuario,
                idTipoEvento,
                fecha,
                descripcion
            )
            VALUES (
                @inIdUsuario,
                (SELECT Id FROM dbo.Tiposdefvento WHERE Nombre = 'Intento de borrado'),
                GETDATE(),
                CONCAT('Intento de eliminar empleado: ', @docID, ' - ', @nombre, ' (Puesto: ', @idPuesto, ')')
            );

            SET @outResultCode = 0; -- Éxito (solo registro en bitácora)
            COMMIT;
            RETURN;
        END

        -- Eliminación lógica
        UPDATE dbo.Empleados
        SET Activo = 0
        WHERE Id = @inIdEmpleado;

        -- Registrar eliminación exitosa
        INSERT INTO dbo.Eventos (
            idUsuario,
            idTipoEvento,
            fecha,
            descripcion
        )
        VALUES (
            @inIdUsuario,
            (SELECT Id FROM dbo.Tiposdefvento WHERE Nombre = 'Borrado exitoso'),
            GETDATE(),
            CONCAT('Empleado eliminado: ', @docID, ' - ', @nombre, ' (Puesto: ', @idPuesto, ')')
        );

        SET @outResultCode = 0; -- Éxito
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SET @outResultCode = 50008; -- Error inesperado

        -- Registrar error
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
            CONCAT('Error en sp_EliminarEmpleado: ', ERROR_MESSAGE())
        );
    END CATCH;

    SET NOCOUNT OFF;
END;