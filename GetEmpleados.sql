USE [test]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetEmpleados]    Script Date: 22-Mar-25 7:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sp_GetEmpleados]
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @outResultCode AS INT; -- declarar codigo de salida
	BEGIN TRY

		SELECT id AS tablaID --declaracion de select
		, Nombre AS tablaNombre
		, Salario AS tablaSalario 
		FROM [dbo].[Empleado] AS tab; --declaracion y alias de variables y tabla

		SET @outResultCode = 0; --despliege de codigo para el return (0 si no hay problemas)
		RETURN @outResultCode;
	END TRY
	BEGIN CATCH
		SET @outResultCode = 50005; --prueba de Catch
		RETURN @outResultCode;
	END CATCH
	SET NOCOUNT OFF
END
