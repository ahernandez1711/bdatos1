USE [test]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_EliminarEmpleado]
    @inIdEmpleado INT,
    @inConfirmacion BIT, -- 1 = sí, 0 = no
    @inPostByUserId INT,
    @inPostIP VARCHAR(64),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idTipoEvento INT;
    DECLARE @docID VARCHAR(16), @nombre VARCHAR(64), @idPuesto INT, @saldo MONEY;

    BEGIN TRY
        -- Verifica que el empleado exista y esté activo
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Empleado] WHERE id = @inIdEmpleado AND EsActivo = 1)
        BEGIN
            SET @outResultCode = 50006; -- Empleado no existe o ya fue eliminado
            RETURN;
        END

        -- Obtiene datos para bitácora
        SELECT 
            @docID = ValorDocumentoIdentidad,
            @nombre = Nombre,
            @idPuesto = idPuesto,
            @saldo = SaldoVacaciones
        FROM [dbo].[Empleado]
        WHERE id = @inIdEmpleado;

        IF @inConfirmacion = 0
        BEGIN
            -- Registra intento sin confirmación
            SELECT @idTipoEvento = id FROM [dbo].[TipoEvento] WHERE Nombre = 'Intento de borrado';

            INSERT INTO [dbo].[BitacoraEvento] (
                idTipoEvento,
                Descripcion,
                idPostByUser,
                PostInIP,
                PostTime
            )
            VALUES (
                @idTipoEvento,
                CONCAT('Intento de eliminar empleado: ', @docID, ', ', @nombre, ', Puesto: ', @idPuesto, ', Saldo: ', @saldo),
                @inPostByUserId,
                @inPostIP,
                GETDATE()
            );

            SET @outResultCode = 0;
            RETURN;
        END

        -- Elimina lógicamente el empleado
        UPDATE [dbo].[Empleado]
        SET EsActivo = 0
        WHERE id = @inIdEmpleado;

        -- Registra borrado exitoso
        SELECT @idTipoEvento = id FROM [dbo].[TipoEvento] WHERE Nombre = 'Borrado exitoso';

        INSERT INTO [dbo].[BitacoraEvento] (
            idTipoEvento,
            Descripcion,
            idPostByUser,
            PostInIP,
            PostTime
        )
        VALUES (
            @idTipoEvento,
            CONCAT('Empleado eliminado: ', @docID, ', ', @nombre, ', Puesto: ', @idPuesto, ', Saldo: ', @saldo),
            @inPostByUserId,
            @inPostIP,
            GETDATE()
        );

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        SET @outResultCode = 50008;

        INSERT INTO [dbo].[DBError] (
            UserName,
            Number,
            State,
            Severity,
            Line,
            [Procedure],
            Message,
            DateTime
        )
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );
    END CATCH;

    SET NOCOUNT OFF;
END;
