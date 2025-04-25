USE [test]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ActualizarEmpleado]
    @inIdEmpleado INT,
    @inNuevoValorDocumentoIdentidad VARCHAR(16),
    @inNuevoNombre VARCHAR(64),
    @inNuevoIdPuesto INT,
    @inPostIP VARCHAR(64),
    @inPostByUserId INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idTipoEvento INT;

    BEGIN TRY
        -- Valida que exista el empleado
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Empleado] WHERE id = @inIdEmpleado AND EsActivo = 1)
        BEGIN
            SET @outResultCode = 50006; -- Empleado no existe
            RETURN;
        END

        -- Valida nombre alfabÈtico
        IF @inNuevoNombre LIKE '%[^A-Za-z¡…Õ”⁄·ÈÌÛ˙—Ò ]%'
        BEGIN
            SET @outResultCode = 50009;
            RETURN;
        END

        -- Valida documento numÈrico
        IF @inNuevoValorDocumentoIdentidad LIKE '%[^0-9]%'
        BEGIN
            SET @outResultCode = 50010;
            RETURN;
        END

        -- Valida que no haya otro empleado con el mismo nombre
        IF EXISTS (
            SELECT 1 FROM [dbo].[Empleado]
            WHERE Nombre = @inNuevoNombre AND id <> @inIdEmpleado
        )
        BEGIN
            SET @outResultCode = 50007; -- Nombre duplicado
            RETURN;
        END

        -- Valida que no haya otro empleado con el mismo documento
        IF EXISTS (
            SELECT 1 FROM [dbo].[Empleado]
            WHERE ValorDocumentoIdentidad = @inNuevoValorDocumentoIdentidad AND id <> @inIdEmpleado
        )
        BEGIN
            SET @outResultCode = 50006; -- Documento duplicado
            RETURN;
        END

        -- Obtiene valores actuales para bit·cora
        DECLARE @docAnterior VARCHAR(16), @nombreAnterior VARCHAR(64), @idPuestoAnterior INT, @saldo MONEY;

        SELECT 
            @docAnterior = ValorDocumentoIdentidad,
            @nombreAnterior = Nombre,
            @idPuestoAnterior = idPuesto,
            @saldo = SaldoVacaciones
        FROM [dbo].[Empleado]
        WHERE id = @inIdEmpleado;

        -- Actualiza datos
        UPDATE [dbo].[Empleado]
        SET 
            ValorDocumentoIdentidad = @inNuevoValorDocumentoIdentidad,
            Nombre = @inNuevoNombre,
            idPuesto = @inNuevoIdPuesto
        WHERE id = @inIdEmpleado;

        -- Registra evento en bit·cora
        SELECT @idTipoEvento = id FROM [dbo].[TipoEvento] WHERE Nombre = 'Update exitoso';

        INSERT INTO [dbo].[BitacoraEvento] (
            idTipoEvento,
            Descripcion,
            idPostByUser,
            PostInIP,
            PostTime
        )
        VALUES (
            @idTipoEvento,
            CONCAT(
                'Empleado actualizado: de [', @docAnterior, ', ', @nombreAnterior, ', Puesto ', @idPuestoAnterior,
                '] a [', @inNuevoValorDocumentoIdentidad, ', ', @inNuevoNombre, ', Puesto ', @inNuevoIdPuesto,
                ']. Saldo actual: ', @saldo
            ),
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
