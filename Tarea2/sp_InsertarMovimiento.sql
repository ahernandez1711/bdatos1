USE [test]
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarMovimiento]    Script Date: 24/4/2025 19:03:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_InsertarMovimiento]
    @inValorDocumentoIdentidad VARCHAR(16),
    @inIdTipoMovimiento INT,
    @inMonto MONEY,
    @inPostByUserId INT,
    @inPostInIP VARCHAR(64),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idEmpleado INT;
    DECLARE @saldoActual MONEY;
    DECLARE @nuevoSaldo MONEY;
    DECLARE @tipoAccion VARCHAR(128);
    DECLARE @idTipoEvento INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Obtener empleado y saldo
        SELECT 
            @idEmpleado = E.id,
            @saldoActual = E.SaldoVacaciones
        FROM [dbo].[Empleado] E
        WHERE E.ValorDocumentoIdentidad = @inValorDocumentoIdentidad AND E.EsActivo = 1;

        IF @idEmpleado IS NULL
        BEGIN
            SET @outResultCode = 50006;
            ROLLBACK;
            RETURN;
        END

        -- Obtener tipo de movimiento
        SELECT @tipoAccion = TipoAccion
        FROM [dbo].[TipoMovimiento]
        WHERE id = @inIdTipoMovimiento;

        IF @tipoAccion IS NULL
        BEGIN
            SET @outResultCode = 50011;
            ROLLBACK;
            RETURN;
        END

        -- Calcular nuevo saldo
        IF @tipoAccion = 'Credito'
            SET @nuevoSaldo = @saldoActual + @inMonto;
        ELSE IF @tipoAccion = 'Debito'
        BEGIN
            IF @saldoActual - @inMonto < 0
            BEGIN
                SET @outResultCode = 50011;
                ROLLBACK;
                RETURN;
            END
            SET @nuevoSaldo = @saldoActual - @inMonto;
        END

        -- Insertar movimiento
        INSERT INTO [dbo].[Movimiento] (
            idEmpleado,
            idTipoMovimiento,
            Fecha,
            Monto,
            NuevoSaldo,
            idPostByUser,
            PostInIP,
            PostTime
        )
        VALUES (
            @idEmpleado,
            @inIdTipoMovimiento,
            GETDATE(),
            @inMonto,
            @nuevoSaldo,
            @inPostByUserId,
            @inPostInIP,
            GETDATE()
        );

        -- Actualizar saldo
        UPDATE [dbo].[Empleado]
        SET SaldoVacaciones = @nuevoSaldo
        WHERE id = @idEmpleado;

        -- Registrar en bitácora
        SELECT @idTipoEvento = id FROM [dbo].[TipoEvento] WHERE Nombre = 'Insertar movimiento exitoso';

        INSERT INTO [dbo].[BitacoraEvento] (
            idTipoEvento,
            Descripcion,
            idPostByUser,
            PostInIP,
            PostTime
        )
        VALUES (
            @idTipoEvento,
            CONCAT('Movimiento registrado para DocID: ', @inValorDocumentoIdentidad, 
                   ', Monto: ', @inMonto, ', Nuevo Saldo: ', @nuevoSaldo),
            @inPostByUserId,
            @inPostInIP,
            GETDATE()
        );

        COMMIT;

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;

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

