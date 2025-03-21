USE [test]
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertEmpleado]    Script Date: 21-Mar-25 9:53:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_InsertEmpleado](
	 @inNombre VARCHAR(64)
	, @inSalario MONEY --Usamos variables dadas para esta ejecuccion del stored procedure
)
AS 
BEGIN 
	SET NOCOUNT ON
	DECLARE @outResultCode AS INT; --definicion 
	SET @outResultCode = 0;
	BEGIN TRY

			IF NOT EXISTS (SELECT 1 FROM [dbo].[Empleado] 
			WHERE Nombre = @inNombre) 
			--Si no existe un empleado con el mismo nombre proporcionado por la variable de entrada @Nombre se agrega 
			BEGIN
				INSERT INTO dbo.Empleado(
				Nombre
				, Salario
				) 
				VALUES (@inNombre
				, @inSalario
				)
				--Insertamos en el campo Nombre y Salario nuestros valores de Nombre y Salario proporcionados
	 
				RETURN @outResultCode;
			END 
			ELSE --En el caso de que ya exista tiramos un codigo para indicar que no ocurrio el insert. 
				SET @outResultCode = 50001; --
				RETURN @outResultCode;

	END TRY
	BEGIN CATCH

		--Verificacion de errores: En el caso de que tengamos un empleado ya dentro de la DB con el mismo nombre
		SET @outResultCode= 50005;
		RETURN @outResultCode;

	END CATCH
	SET NOCOUNT OFF
END
