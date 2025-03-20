
SET NOCOUNT ON
SELECT id AS NumID
, Nombre AS nombreEmpleado
, Salario  AS salarioEmpleado
FROM dbo.Empleado
/* ORDER BY (REVERSE(SUBSTRING(REVERSE(Nombre), 0, CHARINDEX(' ', REVERSE(Nombre)))));*/

/*prueba de ordenar por apellido arriba, abajo es con nombre*/
ORDER BY nombreEmpleado DESC ; /*o con ASC se puede probar*/
SET NOCOUNT OFF