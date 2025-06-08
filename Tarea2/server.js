// ================================
// Importaciones y Configuración
// ================================

const express = require('express');
const mssql = require('mssql');
const cors = require('cors');
const app = express();
const { getConnection } = require('./conexion');

app.use(cors());
app.use(express.json());

// ================================
// Rutas - Login
// ================================

// Ruta para hacer login
app.post("/login", async (req, res) => {
    try {
        const { usuario, contrasena } = req.body;

        if (!usuario || !contrasena) {
            return res.status(400).json({ mensaje: "Faltan datos" });
        }

        const pool = await getConnection();
        const request = pool.request();
        request.input("inUsername", mssql.VarChar(64), usuario);
        request.input("inPass", mssql.VarChar(128), contrasena);
        request.input("inIP", mssql.VarChar(64), req.ip || '127.0.0.1');
        request.output("outResultCode", mssql.Int);
        request.output("outUserId", mssql.Int);

        const result = await request.execute("sp_Login");

        const outResultCode = result.output.outResultCode;
        const outUserId = result.output.outUserId;

        console.log("Resultado de ingresar:", outResultCode);

        if (outResultCode === 0) {
            res.status(200).json({ 
                mensaje: "Login exitoso", 
                codigo: 0, 
                userId: outUserId 
            });
        } else if (outResultCode === 50013) {
            res.status(403).json({ 
                mensaje: "Su cuenta ha sido bloqueada. Debe esperar 10 minutos para volver a intentarlo.", 
                codigo: 50013 
            });
        } else {
            res.status(401).json({ 
                mensaje: "Usuario o contraseña incorrectos.", 
                codigo: outResultCode 
            });
        }
    } catch (error) {
        console.error("Error en login:", error);
        res.status(500).json({ mensaje: "Error interno en login" });
    }
});


// ================================
// Rutas - Empleados
// ================================

// Listar empleados con filtro
app.get('/empleados', async (req, res) => {
    try {
        const { filtro = '' } = req.query;
        const pool = await getConnection();

        const result = await pool.request()
            .input("inFiltro", mssql.VarChar(64), filtro)
            .execute("sp_ListarEmpleadosConFiltro");

        res.status(200).json(result.recordset);
    } catch (error) {
        console.error("Error al listar empleados:", error);
        res.status(500).json({ mensaje: "Error al listar empleados", codigo: 500 });
    }
});

// Obtener detalles de un empleado específico
app.get("/empleados/:id", async (req, res) => {
    try {
        const { id } = req.params;

        const pool = await getConnection();
        const result = await pool.request()
            .input("inIdEmpleado", mssql.Int, id)
            .execute("sp_ConsultarEmpleado");

        if (result.recordset.length === 0) {
            return res.status(404).json({ mensaje: "Empleado no encontrado" });
        }

        res.status(200).json(result.recordset[0]);
    } catch (error) {
        console.error("Error obteniendo empleado:", error);
        res.status(500).json({ mensaje: "Error interno del servidor" });
    }
});



// Insertar un nuevo empleado
app.post("/empleados", async (req, res) => {
    try {
        const { Nombre, ValorDocumentoIdentidad, IdPuesto } = req.body;

        if (!Nombre || !ValorDocumentoIdentidad || !IdPuesto) {
            return res.status(400).json({ mensaje: "Faltan datos para el empleado" });
        }

        const pool = await getConnection();
        const request = pool.request();
        request.input("inValorDocumentoIdentidad", mssql.VarChar(16), ValorDocumentoIdentidad);
        request.input("inNombre", mssql.VarChar(64), Nombre);
        request.input("inIdPuesto", mssql.Int, IdPuesto);
        request.input("inPostIP", mssql.VarChar(64), req.ip || '127.0.0.1');
        request.input("inPostByUserId", mssql.Int, 1);
        request.output("outResultCode", mssql.Int);

        const result = await request.execute("sp_InsertarEmpleado");

        const outResultCode = result.output.outResultCode;

        if (outResultCode === 0) {
            res.status(200).json({ mensaje: "Empleado insertado correctamente", codigo: 0 });
        } else {
            res.status(400).json({ mensaje: "Error al insertar empleado", codigo: outResultCode });
        }
    } catch (error) {
        console.error("Error al insertar empleado:", error);
        res.status(500).json({ mensaje: "Error al insertar empleado" });
    }
});

// Actualizar empleado
app.put("/empleados/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { ValorDocumentoIdentidad, Nombre, IdPuesto } = req.body;

        if (!ValorDocumentoIdentidad || !Nombre || !IdPuesto) {
            return res.status(400).json({ mensaje: "Faltan datos para actualizar" });
        }

        const pool = await getConnection();
        const result = await pool.request()
            .input("inIdEmpleado", mssql.Int, id)
            .input("inNuevoValorDocumentoIdentidad", mssql.VarChar(16), ValorDocumentoIdentidad)
            .input("inNuevoNombre", mssql.VarChar(64), Nombre)
            .input("inNuevoIdPuesto", mssql.Int, IdPuesto)
            .input("inPostIP", mssql.VarChar(64), req.ip || '127.0.0.1')
            .input("inPostByUserId", mssql.Int, 1)
            .output("outResultCode", mssql.Int)
            .execute("sp_ActualizarEmpleado");

        const outResultCode = result.output.outResultCode;
        console.log("Resultado actualizar empleado:", outResultCode);

        if (outResultCode === 0) {
            res.status(200).json({ mensaje: "Empleado actualizado correctamente", codigo: 0 });
        } else {
            res.status(400).json({ mensaje: "Error al actualizar empleado", codigo: outResultCode });
        }
    } catch (error) {
        console.error("Error al actualizar empleado:", error);
        res.status(500).json({ mensaje: "Error al actualizar empleado" });
    }
});

// Eliminar empleado
app.delete("/empleados/:id", async (req, res) => {
    try {
        const { id } = req.params;

        const pool = await getConnection();
        const result = await pool.request()
            .input("inIdEmpleado", mssql.Int, id)
            .input("inConfirmacion", mssql.Bit, 1) // Confirmamción
            .input("inPostIP", mssql.VarChar(64), req.ip || '127.0.0.1')
            .input("inPostByUserId", mssql.Int, 1) // usuario de prueba
            .output("outResultCode", mssql.Int)
            .execute("sp_EliminarEmpleado");

        const outResultCode = result.output.outResultCode;
        console.log("Resultado eliminar empleado:", outResultCode);

        if (outResultCode === 0) {
            res.status(200).json({ mensaje: "Empleado eliminado correctamente", codigo: 0 });
        } else {
            res.status(400).json({ mensaje: "Error al eliminar empleado", codigo: outResultCode });
        }
    } catch (error) {
        console.error("Error al eliminar empleado:", error);
        res.status(500).json({ mensaje: "Error al eliminar empleado" });
    }
});


// ================================
// Rutas - Movimientos
// ================================

// Listar movimientos de un empleado
app.get("/movimientos/:id", async (req, res) => {
    try {
        const { id } = req.params;

        const pool = await getConnection();
        const result = await pool.request()
            .input("inIdEmpleado", mssql.Int, id)
            .execute("sp_ListarMovimientosPorEmpleado");

        res.status(200).json(result.recordset);
    } catch (error) {
        console.error("Error al listar movimientos:", error);
        res.status(500).json({ mensaje: "Error al listar movimientos" });
    }
});

// Insertar movimiento
app.post('/movimientos', async (req, res) => {
    try {
        const { EmpleadoId, TipoMovimiento, Monto } = req.body;

        if (!EmpleadoId || !TipoMovimiento || !Monto) {
            return res.status(400).json({ mensaje: "Faltan datos para movimiento", codigo: 400 });
        }

        const pool = await getConnection();

        // Buscar el ValorDocumentoIdentidad
        const empleadoResult = await pool.request()
            .input("inIdEmpleado", mssql.Int, EmpleadoId)
            .execute("sp_ConsultarEmpleado");

        const empleado = empleadoResult.recordset[0];

        if (!empleado || !empleado.ValorDocumentoIdentidad) {
            return res.status(404).json({ mensaje: "Empleado no encontrado", codigo: 404 });
        }

        const documentoIdentidad = empleado.ValorDocumentoIdentidad;

        const request = pool.request();
        request.input("inValorDocumentoIdentidad", mssql.VarChar(16), documentoIdentidad);
        request.input("inIdTipoMovimiento", mssql.Int, parseInt(TipoMovimiento));
        request.input("inMonto", mssql.Money, parseFloat(Monto));
        request.input("inPostByUserId", mssql.Int, 1); // Id de quien inserta
        request.input("inPostInIP", mssql.VarChar(64), req.ip || '127.0.0.1');
        request.output("outResultCode", mssql.Int);

        const result = await request.execute("sp_InsertarMovimiento");

        const outResultCode = result.output?.outResultCode ?? 50008;

        console.log("Resultado insertar movimiento:", outResultCode);

        if (outResultCode === 0) {
            return res.status(200).json({ mensaje: "Movimiento insertado correctamente", codigo: 0 });
        } else {
            return res.status(400).json({ mensaje: "Error al insertar movimiento", codigo: outResultCode });
        }

    } catch (error) {
        console.error("Error interno al insertar movimiento:", error);
        return res.status(500).json({ mensaje: "Error interno al insertar movimiento", codigo: 500 });
    }
});


// ================================
// Inicio del servidor
// ================================

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
});



// ================================
// Con esto se corre el server, en mi compu
// ================================

//cd "C:\Carpetas de escritorio\TEC\BDD1\Tarea1"
//node server.js

