USE [test]
GO

/****** Object:  StoredProcedure [dbo].[sp_InsertEmpleado]    Script Date: 17-Mar-25 3:30:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_InsertEmpleado](
	@Nombre varchar(64),
	@Salario money /* Usamos variables dadas para esta ejecuccion del stored procedure */
)
AS 
BEGIN
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT 1 from dbo.Empleado where Nombre = @Nombre) /*Si no existe un empleado con el mismo nombre proporcionado por la variable de entrada @Nombre se agrega */
		BEGIN
			INSERT INTO dbo.Empleado(Nombre, Salario) /*Insertamos en el campo Nombre y Salario nuestros valores de Nombre y Salario proporcionados*/
			VALUES (@Nombre, @Salario)
			COMMIT /*Guardamos el cambio*/ 
		END

	IF(@@TRANCOUNT>0) 
	/*Verificacion 
	de errores: En el caso de que tengamos un empleado ya dentro de la DB con el mismo nombre, no tenemos una salida dentro del IF anterior que tenga un ELSE. Sin embargo, es una transacción pendiente, asi que si nuestras transacciones no estan en 0 
	(en este caso), le hacemos
	rollback para revertir el cambio. Luego tiramos el mensaje de error.
	Los parametros de RAISEERROR son el mensaje al usuario, la severidad y el estado. En este caso la severidad es de 16 en un rango de 11-20 para errores (0-10 es para warnings) y el estado es 1. Abortamos la transaccion.*/
	BEGIN
		ROLLBACK
		RAISERROR('Error al introducir empleado', 16,1);
	END
END
GO


