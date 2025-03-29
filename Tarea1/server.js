const express = require("express");
const mssql = require("mssql");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json()); // Para procesar JSON en las solicitudes POST

// Configura la conexión a la BD
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

// Esta función conecta con el sql
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
        const result = await pool.request().execute("sp_GetEmpleados");
        //Usar Aliases de la base de datos
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
            return res.status(400).json({ mensaje: "Faltan datos" });
        }

        const pool = await getConnection();
        const request = pool.request();
        request.input("inNombre", mssql.VarChar(64), Nombre);
        request.input("inSalario", mssql.Money, Salario);

        // Ejecuta el procedimiento almacenado y obtiene el código de resultado
        const result = await request.execute("sp_InsertEmpleado");
        const outResultCode = result.returnValue;

        if (outResultCode === 0) {
            res.status(201).json({ mensaje: "Empleado insertado correctamente", codigo: outResultCode });
        } else if (outResultCode === 50001) {
            res.status(400).json({ mensaje: "Nombre de empleado ya existe", codigo: outResultCode });
        } else {
            res.status(500).json({ mensaje: "Error al insertar empleado", codigo: outResultCode });
        }
    } catch (error) {
        console.error("Error al insertar empleado:", error);
        res.status(500).json({ mensaje: "Error al insertar empleado", codigo: 50005 });
    }
});

// Inicia el servidor en el puerto 3000
app.listen(3000, () => {
    console.log("Servidor corriendo en http://localhost:3000");
});

//cd "C:\Carpetas de escritorio\TEC\BDD1\Tarea1"
//node server.js

