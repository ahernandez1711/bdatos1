USE [test]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetEmpleados]    Script Date: 23-Mar-25 7:06:54 PM ******/
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
		FROM [dbo].[Empleado] AS tab;
		--ORDER BY tablaNombre DESC, descomentar si se quiere ordenar el SELECT; 
		
		SET @outResultCode = 0; --despliege de codigo para el return
		RETURN @outResultCode;
	END TRY
	BEGIN CATCH
		SET @outResultCode = 50005; --prueba de Catch
		RETURN @outResultCode;
	END CATCH
	SET NOCOUNT OFF
END
