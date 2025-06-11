const mssql = require('mssql');

const dbConfig = {
    user: "pruebasDB",
    password: "BD1g22025*",
    server: "172.235.134.93",
    database: "controlPlanillas",
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

async function getConnection() {
    try {
        const pool = await mssql.connect(dbConfig);
        return pool;
    } catch (error) {
        console.error('Error al conectar a la base de datos:', error);
        throw error;
    }
}

module.exports = { getConnection };