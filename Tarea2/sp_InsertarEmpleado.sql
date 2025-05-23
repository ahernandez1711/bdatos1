USE [test]
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarEmpleado]    Script Date: 23/4/2025 21:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_InsertarEmpleado]
    @inValorDocumentoIdentidad VARCHAR(16),
    @inNombre VARCHAR(64),
    @inIdPuesto INT,
    @inPostIP VARCHAR(64),
    @inPostByUserId INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validaciones básicas
        IF @inNombre LIKE '%[^A-Za-zÁÉÍÓÚáéíóúÑñ ]%'
        BEGIN
            SET @outResultCode = 50009;
            RETURN;
        END

        IF @inValorDocumentoIdentidad LIKE '%[^0-9]%'
        BEGIN
            SET @outResultCode = 50010;
            RETURN;
        END

        -- Duplicados
        IF EXISTS (
            SELECT 1 FROM [dbo].[Empleado]
            WHERE ValorDocumentoIdentidad = @inValorDocumentoIdentidad
        )
        BEGIN
            SET @outResultCode = 50004;
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM [dbo].[Empleado]
            WHERE Nombre = @inNombre
        )
        BEGIN
            SET @outResultCode = 50005;
            RETURN;
        END

        -- Insertar empleado
        INSERT INTO [dbo].[Empleado] (
            idPuesto,
            ValorDocumentoIdentidad,
            Nombre,
            FechaContratacion,
            SaldoVacaciones,
            EsActivo
        )
        VALUES (
            @inIdPuesto,
            @inValorDocumentoIdentidad,
            @inNombre,
            GETDATE(),
            0,
            1
        );

        -- Bitácora
        DECLARE @idTipoEvento INT;
        SELECT @idTipoEvento = id FROM [dbo].[TipoEvento] WHERE Nombre = 'Insercion exitosa';

        INSERT INTO [dbo].[BitacoraEvento] (
            idTipoEvento,
            Descripcion,
            idPostByUser,
            PostInIP,
            PostTime
        )
        VALUES (
            @idTipoEvento,
            CONCAT('Empleado insertado: ', @inNombre, ', Doc: ', @inValorDocumentoIdentidad),
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
