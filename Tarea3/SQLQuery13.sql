USE [controlPlanillas]
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarEmpleadosConFiltro]    Script Date: 10/6/2025 22:51:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_ListarEmpleadosConFiltro]
    @inFiltro VARCHAR(64),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @outResultCode = 50008; -- Error inesperado por defecto

    BEGIN TRY
        -- Si el filtro está vacío, listar todos los empleados activos
        IF LTRIM(RTRIM(@inFiltro)) = ''
        BEGIN
            SELECT 
                E.Id,
                E.Nombre,
                E.ValorDocumento,
                P.Nombre AS Puesto,
                D.Nombre AS Departamento
            FROM 
                dbo.Empleados E
            INNER JOIN 
                dbo.Puestos P ON E.IdPuesto = P.Id
            INNER JOIN 
                dbo.Departamentos D ON E.IdDepartamento = D.Id
            WHERE 
                E.Activo = 1
            ORDER BY 
                E.Nombre ASC;

            SET @outResultCode = 0; -- Éxito
            RETURN;
        END

        -- Si el filtro es numérico, buscar por documento
        IF PATINDEX('%[^0-9]%', @inFiltro) = 0
        BEGIN
            SELECT 
                E.Id,
                E.Nombre,
                E.ValorDocumento,
                P.Nombre AS Puesto,
                D.Nombre AS Departamento
            FROM 
                dbo.Empleados E
            INNER JOIN 
                dbo.Puestos P ON E.IdPuesto = P.Id
            INNER JOIN 
                dbo.Departamentos D ON E.IdDepartamento = D.Id
            WHERE 
                E.Activo = 1 
                AND E.ValorDocumento LIKE CONCAT('%', @inFiltro, '%')
            ORDER BY 
                E.Nombre ASC;

            SET @outResultCode = 0;
            RETURN;
        END

        -- Si el filtro contiene letras, buscar por nombre
        SELECT 
            E.Id,
            E.Nombre,
            E.ValorDocumento,
            P.Nombre AS Puesto,
            D.Nombre AS Departamento
        FROM 
            dbo.Empleados E
        INNER JOIN 
            dbo.Puestos P ON E.IdPuesto = P.Id
        INNER JOIN 
            dbo.Departamentos D ON E.IdDepartamento = D.Id
        WHERE 
            E.Activo = 1 
            AND E.Nombre LIKE CONCAT('%', @inFiltro, '%')
        ORDER BY 
            E.Nombre ASC;

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        SET @outResultCode = 50008;
        
        -- Registrar error en bitácora
        INSERT INTO dbo.Eventos (
            idUsuario, 
            idTipoEvento, 
            fecha, 
            descripcion
        )
        VALUES (
            0, -- Usuario sistema
            (SELECT Id FROM dbo.Tiposdefvento WHERE Nombre = 'Error'), 
            GETDATE(), 
            CONCAT('Error en sp_ListarEmpleadosConFiltro: ', ERROR_MESSAGE())
        );
    END CATCH;

    SET NOCOUNT OFF;
END;