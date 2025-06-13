const express = require('express');
const mssql = require('mssql');
const cors = require('cors');
const app = express();
const { getConnection } = require('./conexion');
const { procesarSimulacion } = require('./simulador');

app.use(cors());
app.use(express.json());


// ========= Rutas de simulacion
app.post('/api/simulacion', async (req, res) => {
    try {
        await procesarSimulacion();
        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ========== RUTAS DE AUTENTICACIÓN ==========
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
        request.output("outTipoUsuario", mssql.Int); // 1=Admin, 2=Empleado

        const result = await request.execute("sp_Login");

        const outResultCode = result.output.outResultCode;
        const outUserId = result.output.outUserId;
        const outTipoUsuario = result.output.outTipoUsuario;

        if (outResultCode === 0) {
            res.status(200).json({ 
                mensaje: "Login exitoso", 
                codigo: 0, 
                userId: outUserId,
                tipoUsuario: outTipoUsuario
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

// ========== RUTAS DE ADMINISTRADOR ==========
// Listar empleados con filtro
app.get('/admin/empleados', async (req, res) => {
    try {
        const { filtro = '' } = req.query;
        const pool = await getConnection();

        const result = await pool.request()
            .input("inFiltro", mssql.VarChar(64), filtro)
            .execute("sp_ListarEmpleadosConFiltro");

        res.status(200).json(result.recordset);
    } catch (error) {
        console.error("Error al listar empleados:", error);
        res.status(500).json({ mensaje: "Error al listar empleados" });
    }
});

// CRUD Empleados
app.post('/admin/empleados', async (req, res) => {
    try {
        const { Nombre, ValorDocumentoIdentidad, IdPuesto } = req.body;
        const pool = await getConnection();
        
        const result = await pool.request()
            .input("inNombre", mssql.VarChar(64), Nombre)
            .input("inValorDocumentoIdentidad", mssql.VarChar(16), ValorDocumentoIdentidad)
            .input("inIdPuesto", mssql.Int, IdPuesto)
            .input("inPostIP", mssql.VarChar(64), req.ip)
            .input("inPostByUserId", mssql.Int, req.user?.userId || 1)
            .output("outResultCode", mssql.Int)
            .execute("sp_InsertarEmpleado");

        if (result.output.outResultCode === 0) {
            res.status(201).json({ mensaje: "Empleado creado" });
        } else {
            res.status(400).json({ mensaje: "Error al crear empleado" });
        }
    } catch (error) {
        console.error("Error al crear empleado:", error);
        res.status(500).json({ mensaje: "Error al crear empleado" });
    }
});

// ========== RUTAS DE EMPLEADO ==========
// Obtener planilla semanal
app.get('/empleado/planilla-semanal/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const pool = await getConnection();

        const result = await pool.request()
            .input("inIdEmpleado", mssql.Int, id)
            .execute("sp_ObtenerPlanillaSemanal");

        res.status(200).json(result.recordset);
    } catch (error) {
        console.error("Error al obtener planilla:", error);
        res.status(500).json({ mensaje: "Error al obtener planilla" });
    }
});

// ========== INICIAR SERVIDOR ==========
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});