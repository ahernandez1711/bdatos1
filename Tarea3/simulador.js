const { parseString } = require('xml2js');
const fs = require('fs');
const { getConnection } = require('./conexion');
const mssql = require('mssql');

async function procesarSimulacion() {
    const pool = await getConnection();
    const xmlData = fs.readFileSync('operacion.xml', 'utf-8');
    
    // Parsear XML
    const { Operacion } = await new Promise((resolve, reject) => 
        parseString(xmlData, (err, result) => err ? reject(err) : resolve(result))
    );

    // Procesar cada fecha en orden cronológico
    for (const fechaOp of Operacion.FechaOperacion.sort((a, b) => 
        new Date(a.$.Fecha) - new Date(b.$.Fecha))) {
        
        const fecha = new Date(fechaOp.$.Fecha);
        console.log(` Procesando ${fecha.toLocaleDateString()}`);

        // 1. Nuevos empleados
        if (fechaOp.NuevosEmpleados) {
            for (const emp of fechaOp.NuevosEmpleados[0].NuevoEmpleado) {
                const empleado = emp.$;
                const request = pool.request()
                    .input('inNombre', mssql.NVarChar(50), empleado.Nombre)
                    .input('inIdTipoDocumento', mssql.Int, parseInt(empleado.IdTipoDocumento))
                    .input('inValorDocumento', mssql.NVarChar(50), empleado.ValorTipoDocumento)
                    .input('inFechaNacimiento', mssql.Date, new Date(empleado.FechaNacimiento))
                    .input('inIdDepartamento', mssql.Int, parseInt(empleado.IdDepartamento))
                    .input('inIdPuesto', mssql.Int, await obtenerIdPuesto(empleado.NombrePuesto, pool))
                    .input('inIdUsuario', mssql.Int, 1) // Usuario sistema
                    .output('outResultCode', mssql.Int);

                await request.execute('sp_InsertarEmpleado');
            }
        }

        // 2. Procesar asistencias
        if (fechaOp.MarcasAsistencia) {
            for (const asist of fechaOp.MarcasAsistencia[0].MarcaDeAsistencia) {
                const empleadoId = await obtenerIdEmpleado(asist.$.ValorTipoDocumento, pool);
                
                if (empleadoId) {
                    const request = pool.request()
                        .input('inIdEmpleado', mssql.Int, empleadoId)
                        .input('inFecha', mssql.Date, fecha)
                        .input('inHoraEntrada', mssql.Time, new Date(asist.$.HoraEntrada).toTimeString().substr(0, 8))
                        .input('inHoraSalida', mssql.Time, new Date(asist.$.HoraSalida).toTimeString().substr(0, 8))
                        .input('inIdUsuario', mssql.Int, 1)
                        .output('outResultCode', mssql.Int);

                    await request.execute('sp_ProcesarAsistencia');
                }
            }
        }

        // 3. Si es jueves: Cierre semanal y asignar jornadas
        if (fecha.getDay() === 4) { // Jueves
            const requestCierre = pool.request()
                .input('inFechaCierre', mssql.Date, fecha)
                .input('inIdUsuario', mssql.Int, 1)
                .output('outResultCode', mssql.Int);

            await requestCierre.execute('sp_CierreSemanalPlanilla');

            // Asignar jornadas para próxima semana
            if (fechaOp.JornadasProximaSemana) {
                const fechaViernes = new Date(fecha);
                fechaViernes.setDate(fecha.getDate() + 1); // Siguiente día (viernes)

                for (const jornada of fechaOp.JornadasProximaSemana[0].TipoJornadaProximaSemana) {
                    const empleadoId = await obtenerIdEmpleado(jornada.$.ValorTipoDocumento, pool);
                    
                    if (empleadoId) {
                        const requestJornada = pool.request()
                            .input('inIdEmpleado', mssql.Int, empleadoId)
                            .input('inIdTipoJornada', mssql.Int, parseInt(jornada.$.IdTipoJornada))
                            .input('inFechaInicio', mssql.Date, fechaViernes)
                            .input('inIdUsuario', mssql.Int, 1)
                            .output('outResultCode', mssql.Int);

                        await requestJornada.execute('sp_AsignarJornadaSemanal');
                    }
                }
            }
        }
    }
}

// Helper: Obtener ID de empleado por documento
async function obtenerIdEmpleado(valorDocumento, pool) {
    const result = await pool.request()
        .input('inValorDocumento', mssql.NVarChar(50), valorDocumento)
        .query('SELECT id FROM Empleados WHERE ValorDocumento = @inValorDocumento AND Activo = 1');
    
    return result.recordset[0]?.id;
}

// Helper: Obtener ID de puesto por nombre
async function obtenerIdPuesto(nombrePuesto, pool) {
    const result = await pool.request()
        .input('inNombrePuesto', mssql.NVarChar(100), nombrePuesto)
        .query('SELECT id FROM Puestos WHERE Nombre = @inNombrePuesto');
    
    return result.recordset[0]?.id;
}

// Ejecutar simulador
procesarSimulacion().catch(console.error);