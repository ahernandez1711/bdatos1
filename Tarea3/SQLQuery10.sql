USE [controlPlanillas]
GO
/****** Object:  StoredProcedure [dbo].[sp_CierreSemanalPlanilla]    Script Date: 10/6/2025 22:51:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[sp_CierreSemanalPlanilla]
    @inFechaCierre DATE, -- Debe ser un jueves
    @inIdUsuario INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @FechaInicioSemana DATE = DATEADD(DAY, -6, @inFechaCierre);
    DECLARE @EsUltimaSemanaMes BIT = 0;
    
    BEGIN TRY
        -- Verificar que la fecha de cierre es jueves
        IF DATEPART(WEEKDAY, @inFechaCierre) <> 5 -- 5 = Jueves
        BEGIN
            SET @outResultCode = 50002;
            RETURN;
        END
        
        -- Determinar si es la última semana del mes
        DECLARE @SiguienteJueves DATE = DATEADD(DAY, 7, @inFechaCierre);
        IF MONTH(@SiguienteJueves) <> MONTH(@inFechaCierre)
            SET @EsUltimaSemanaMes = 1;
        
        -- Tabla temporal para almacenar resultados intermedios
        CREATE TABLE #ResultadosPlanilla (
            EmpleadoId INT,
            SalarioBruto FLOAT,
            TipoDeduccionId INT,
            NombreDeduccion VARCHAR(50),
            MontoDeduccion FLOAT,
            EsPorcentual BIT
        );
        
        -- 1. Calcular salario bruto para cada empleado
        INSERT INTO #ResultadosPlanilla (EmpleadoId, SalarioBruto)
        SELECT 
            e.id,
            ISNULL(SUM(m.monto), 0)
        FROM 
            [dbo].[Empleados] e
        LEFT JOIN 
            [dbo].[Movimientos] m ON e.id = m.idEmpleado
        LEFT JOIN 
            [dbo].[TiposDeMovimiento] tm ON m.idTiposDeMovimiento = tm.id
        WHERE 
            e.Activo = 1
            AND m.fecha BETWEEN @FechaInicioSemana AND @inFechaCierre
            AND tm.Nombre IN ('Horas Ordinarias', 'Horas Extra Normales', 'Horas Extra Dobles')
        GROUP BY 
            e.id;
        
        -- 2. Calcular deducciones para cada empleado
        UPDATE rp
        SET 
            TipoDeduccionId = de.idTipoDeDeduccion,
            NombreDeduccion = td.Nombre,
            MontoDeduccion = CASE 
                WHEN td.Porcentual = 'Si' THEN rp.SalarioBruto * td.Valor
                ELSE td.Valor / CASE WHEN @EsUltimaSemanaMes = 1 THEN 4.0 ELSE 4.0 END
            END,
            EsPorcentual = CASE WHEN td.Porcentual = 'Si' THEN 1 ELSE 0 END
        FROM 
            #ResultadosPlanilla rp
        INNER JOIN 
            [dbo].[DeduccionXEmpleado] de ON rp.EmpleadoId = de.idEmpleado
        INNER JOIN 
            [dbo].[TiposDeDeduccion] td ON de.idTipoDeDeduccion = td.id
        WHERE 
            rp.TipoDeduccionId IS NULL;
        
        -- 3. Insertar movimientos de deducciones
        INSERT INTO [dbo].[Movimientos] (
            idEmpleado,
            idTiposDeMovimiento,
            fecha,
            monto
        )
        SELECT 
            rp.EmpleadoId,
            CASE 
                WHEN rp.EsPorcentual = 1 THEN 
                    (SELECT id FROM [dbo].[TiposDeMovimiento] WHERE Nombre = 'Deducción Porcentual')
                ELSE
                    (SELECT id FROM [dbo].[TiposDeMovimiento] WHERE Nombre = 'Deducción Fija')
            END,
            GETDATE(),
            rp.MontoDeduccion
        FROM 
            #ResultadosPlanilla rp
        WHERE 
            rp.TipoDeduccionId IS NOT NULL;
        
        -- Registrar evento de cierre
        INSERT INTO [dbo].[Eventos] (
            idUsuario,
            idTipoEvento,
            fecha
        )
        VALUES (
            @inIdUsuario,
            (SELECT id FROM [dbo].[TiposdeEvento] WHERE Nombre = 'Cierre semanal'),
            GETDATE()
        );
        
        DROP TABLE #ResultadosPlanilla;
        
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#ResultadosPlanilla') IS NOT NULL
            DROP TABLE #ResultadosPlanilla;
        
        SET @outResultCode = 50003;
        
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
        RAISERROR('Error en sp_CierreSemanalPlanilla: %s', 16, 1, @ErrorMsg);
    END CATCH;
    
    SET NOCOUNT OFF;
END;
