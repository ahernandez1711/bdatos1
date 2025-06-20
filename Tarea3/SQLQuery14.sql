USE [controlPlanillas]
GO
/****** Object:  StoredProcedure [dbo].[sp_ProcesarAsistencia]    Script Date: 10/6/2025 22:51:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[sp_ProcesarAsistencia]
    @inIdEmpleado INT,
    @inFecha DATE,
    @inHoraEntrada TIME,
    @inHoraSalida TIME,
    @inIdUsuario INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @EsDomingo BIT = CASE WHEN DATEPART(WEEKDAY, @inFecha) = 1 THEN 1 ELSE 0 END;
    DECLARE @EsFeriado BIT = 0;
    DECLARE @IdTipoJornada INT;
    DECLARE @HoraFinJornada TIME;
    DECLARE @SalarioXHora INT;
    DECLARE @HorasTrabajadas INT;
    DECLARE @HorasExtras INT;
    
    BEGIN TRY
        -- Verificar si es feriado
        SELECT @EsFeriado = 1 
        FROM [dbo].[Feriados] 
        WHERE CONVERT(DATE, [Fecha]) = @inFecha;
        
        -- Obtener jornada del empleado para esta fecha
        SELECT 
            @IdTipoJornada = j.[idTiposDeJornada],
            @HoraFinJornada = tj.[HoraFin]
        FROM [dbo].[Jornadas] j
        INNER JOIN [dbo].[TiposDeJornada] tj ON j.[idTiposDeJornada] = tj.[id]
        WHERE j.[idEmpleado] = @inIdEmpleado
        AND j.[fecha] = @inFecha;
        
        -- Obtener salario por hora del empleado
        SELECT @SalarioXHora = p.[SalarioXHora]
        FROM [dbo].[Empleados] e
        INNER JOIN [dbo].[Puestos] p ON e.[idPuesto] = p.[id]
        WHERE e.[id] = @inIdEmpleado;
        
        -- Calcular horas trabajadas
        SET @HorasTrabajadas = DATEDIFF(HOUR, @inHoraEntrada, @inHoraSalida);
        
        -- Insertar movimiento por horas ordinarias
        INSERT INTO [dbo].[Movimientos] (
            [idEmpleado],
            [idTiposDeMovimiento],
            [fecha],
            [monto]
        )
        VALUES (
            @inIdEmpleado,
            (SELECT [id] FROM [dbo].[TiposDeMovimiento] WHERE [Nombre] = 'Horas Ordinarias'),
            GETDATE(),
            @HorasTrabajadas * @SalarioXHora
        );
        
        -- Calcular horas extras
        IF @inHoraSalida > @HoraFinJornada
        BEGIN
            SET @HorasExtras = DATEDIFF(HOUR, @HoraFinJornada, @inHoraSalida);
            
            -- Determinar tipo de horas extras
            DECLARE @IdTipoMovimientoExtra INT;
            DECLARE @MultiplicadorExtra FLOAT;
            
            IF @EsDomingo = 1 OR @EsFeriado = 1
            BEGIN
                SET @IdTipoMovimientoExtra = (SELECT [id] FROM [dbo].[TiposDeMovimiento] WHERE [Nombre] = 'Horas Extra Dobles');
                SET @MultiplicadorExtra = 2.0;
            END
            ELSE
            BEGIN
                SET @IdTipoMovimientoExtra = (SELECT [id] FROM [dbo].[TiposDeMovimiento] WHERE [Nombre] = 'Horas Extra Normales');
                SET @MultiplicadorExtra = 1.5;
            END
            
            -- Insertar movimiento por horas extras
            INSERT INTO [dbo].[Movimientos] (
                [idEmpleado],
                [idTiposDeMovimiento],
                [fecha],
                [monto]
            )
            VALUES (
                @inIdEmpleado,
                @IdTipoMovimientoExtra,
                GETDATE(),
                @HorasExtras * @SalarioXHora * @MultiplicadorExtra
            );
        END
        
        -- Registrar evento
        INSERT INTO [dbo].[Eventos] (
            [idUsuario],
            [idTipoEvento],
            [fecha]
        )
        VALUES (
            @inIdUsuario,
            (SELECT [id] FROM [dbo].[TiposdeEvento] WHERE [Nombre] = 'Procesar asistencia'),
            GETDATE()
        );
        
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        SET @outResultCode = 50001;
        
        -- Registrar error
        INSERT INTO [dbo].[Eventos] (
            [idUsuario],
            [idTipoEvento],
            [fecha]
        )
        VALUES (
            @inIdUsuario,
            (SELECT [id] FROM [dbo].[TiposdeEvento] WHERE [Nombre] = 'Error en SP'),
            GETDATE()
        );
    END CATCH;
    
    SET NOCOUNT OFF;
END;
