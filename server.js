const express = require("express");
const mssql = require("mssql");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json()); // Para procesar JSON en las solicitudes POST

// Configurar conexión a la BD
const bdconnection = {
    user: "pruebasDB",
    password: "BD1g22025*",
    server: "172.235.134.93",
    database: "test",
    options: {
        encrypt: false,
        trustServerCertificate: true,
    }
};

// Función para conectar con SQL Server
async function getConnection() {
    try {
        return await mssql.connect(bdconnection);
    } catch (error) {
        console.error("Error de conexión:", error);
    }
}

// Ruta para obtener la lista de empleados
app.get("/empleados", async (req, res) => {
    try {
        const pool = await getConnection();
        const result = await pool.request().query("SELECT id, Nombre, Salario FROM Empleado");
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send("Error al obtener empleados");
    }
});

// Ruta para insertar un empleado
app.post("/empleados", async (req, res) => {
    try {
        const { Nombre, Salario } = req.body;

        if (!Nombre || !Salario) {
            return res.status(400).send("Faltan datos");
        }

        const pool = await getConnection();
        await pool.request()
            .input("inNombre", mssql.VarChar(64), Nombre)
            .input("inSalario", mssql.Money, Salario)
            .execute("sp_InsertEmpleado"); // Ejecutamos el procedimiento almacenado

        res.status(201).send("Empleado insertado correctamente");
    } catch (error) {
        console.error("Error al insertar empleado:", error);
        res.status(500).send("Error al insertar empleado");
    }
});

// Iniciar el servidor en el puerto 3000
app.listen(3000, () => {
    console.log("Servidor corriendo en http://localhost:3000");
});

//cd "C:\Carpetas de escritorio\TEC\BDD1\Tarea1"
//node server.js

