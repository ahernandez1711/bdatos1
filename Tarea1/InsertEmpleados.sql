USE [test]
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertEmpleado]    Script Date: 23-Mar-25 4:11:20 PM ******/
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
	SET @outResultCode = 0; --Los SELECT comentados eran para probar que el codigo retornado es correcto 
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
				--SELECT 'Result Code' = @outResultCode; 
				RETURN @outResultCode;
			END 
			ELSE --En el caso de que ya exista tiramos un codigo para indicar que no ocurrio el insert. 
				SET @outResultCode = 50001; --
				--SELECT 'Result Code' = @outResultCode; 
				RETURN @outResultCode;

	END TRY
	BEGIN CATCH

		--Verificacion de errores del servidor propiamente
		SET @outResultCode= 50005;
		--SELECT 'Result Code' = @outResultCode;  
		RETURN @outResultCode;

	END CATCH
	SET NOCOUNT OFF
END
