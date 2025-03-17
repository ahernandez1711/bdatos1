USE [test]
GO

/****** Object:  StoredProcedure [dbo].[sp_getEmpleados]    Script Date: 17-Mar-25 3:31:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_getEmpleados]
AS
BEGIN
	SELECT id, Nombre, Salario FROM Empleado
END
GO


