USE [controlPlanillas]
GO
/****** Object:  StoredProcedure [dbo].[sp_ConsultarPlanillaSemanal]    Script Date: 10/6/2025 22:51:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER   PROCEDURE [dbo].[sp_ConsultarPlanillaSemanal]
    @inIdEmpleado INT,
    @inFechaInicioSemana DATE,
    @outResultCode INT OUTPUT,
    @outSalarioBruto FLOAT OUTPUT,
    @outTotalDeducciones FLOAT OUTPUT,
    @outSalarioNeto FLOAT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Verificar que la fecha de inicio es viernes
        IF DATEPART(WEEKDAY, @inFechaInicioSemana) <> 6 -- 6 = Viernes
        BEGIN
            SET @outResultCode = 50011;
            RETURN;
        END
        
        DECLARE @FechaFinSemana DATE = DATEADD(DAY, 6, @inFechaInicioSemana);
        
        -- Obtener datos de la planilla semanal
        SELECT 
            @outSalarioBruto = pse.SalarioBruto,
            @outTotalDeducciones = pse.TotalDeducciones,
            @outSalarioNeto = pse.SalarioNeto
        FROM [dbo].[PlanillaSemXEmpleado] pse
        INNER JOIN [dbo].[SemanasPlanilla] sp ON pse.idSemanaPlanilla = sp.id
        WHERE pse.idEmpleado = @inIdEmpleado
        AND sp.fechaInicio = @inFechaInicioSemana
        AND sp.fechaFin = @FechaFinSemana;
        
        -- Si no se encontraron resultados
        IF @outSalarioBruto IS NULL
        BEGIN
            SET @outResultCode = 50012;
            RETURN;
        END
        
        -- Registrar evento de consulta
        INSERT INTO [dbo].[Eventos] (
            idUsuario,
            idTipoEvento,
            fecha
        )
        VALUES (
            @inIdEmpleado, -- Asumiendo que el idEmpleado es también idUsuario
            (SELECT id FROM [dbo].[TiposdeEvento] WHERE Nombre = 'Consulta planilla'),
            GETDATE()
        );
        
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        SET @outResultCode = 50013;
        
        INSERT INTO [dbo].[Eventos] (
            idUsuario,
            idTipoEvento,
            fecha
        )
        VALUES (
            @inIdEmpleado,
            (SELECT id FROM [dbo].[TiposdeEvento] WHERE Nombre = 'Error en SP'),
            GETDATE()
        );
        
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en sp_ConsultarPlanillaSemanal: %s', 16, 1, @ErrorMsg);
    END CATCH;
    
    SET NOCOUNT OFF;
END;
