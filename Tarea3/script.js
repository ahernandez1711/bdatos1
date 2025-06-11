// ========== FUNCIONES DE AUTENTICACIÓN ==========
async function login(event) {
    event.preventDefault();
    
    const usuario = document.getElementById("usuario").value.trim();
    const contrasena = document.getElementById("contrasena").value.trim();
    const tipoUsuario = document.getElementById("tipoUsuario").value;

    if (!usuario || !contrasena || !tipoUsuario) {
        alert("Todos los campos son obligatorios");
        return;
    }

    try {
        const respuesta = await fetch("http://localhost:3000/login", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ usuario, contrasena })
        });

        const resultado = await respuesta.json();

        if (resultado.codigo === 0) {
            sessionStorage.setItem("userId", resultado.userId);
            sessionStorage.setItem("tipoUsuario", resultado.tipoUsuario);
            
            if (resultado.tipoUsuario === 1) {
                window.location.href = "admin/dashboard.html";
            } else {
                window.location.href = "empleado/dashboard.html";
            }
        } else {
            alert("Error: " + resultado.mensaje);
        }
    } catch (error) {
        console.error("Error en login:", error);
        alert("Error al conectar con el servidor");
    }
}

// ========== FUNCIONES DE ADMINISTRADOR ==========
async function cargarEmpleados() {
    try {
        const filtro = document.getElementById("filtro")?.value || '';
        const respuesta = await fetch(`http://localhost:3000/admin/empleados?filtro=${encodeURIComponent(filtro)}`);
        const empleados = await respuesta.json();

        const tabla = document.getElementById("tabla-empleados").getElementsByTagName("tbody")[0];
        tabla.innerHTML = "";

        empleados.forEach(emp => {
            const fila = tabla.insertRow();
            fila.insertCell(0).textContent = emp.Nombre;
            fila.insertCell(1).textContent = emp.ValorDocumentoIdentidad;
            fila.insertCell(2).textContent = emp.NombrePuesto;
            
            const celdaAcciones = fila.insertCell(3);
            const btnVer = document.createElement("button");
            btnVer.textContent = "Ver";
            btnVer.onclick = () => window.location.href = `admin/empleados/ver.html?id=${emp.IdEmpleado}`;
            celdaAcciones.appendChild(btnVer);
        });
    } catch (error) {
        console.error("Error al cargar empleados:", error);
        alert("Error al cargar empleados");
    }
}

// ========== FUNCIONES DE EMPLEADO ==========
async function cargarPlanillaSemanal() {
    try {
        const userId = sessionStorage.getItem("userId");
        const respuesta = await fetch(`http://localhost:3000/empleado/planilla-semanal/${userId}`);
        const planillas = await respuesta.json();

        const tabla = document.getElementById("tabla-planillas").getElementsByTagName("tbody")[0];
        tabla.innerHTML = "";

        planillas.forEach(planilla => {
            const fila = tabla.insertRow();
            fila.insertCell(0).textContent = new Date(planilla.FechaInicio).toLocaleDateString();
            fila.insertCell(1).textContent = `₡${planilla.SalarioBruto.toFixed(2)}`;
            fila.insertCell(2).textContent = `₡${planilla.TotalDeducciones.toFixed(2)}`;
            fila.insertCell(3).textContent = `₡${planilla.SalarioNeto.toFixed(2)}`;
            fila.insertCell(4).textContent = planilla.HorasOrdinarias;
            fila.insertCell(5).textContent = planilla.HorasExtras;
            fila.insertCell(6).textContent = planilla.HorasDobles;
        });
    } catch (error) {
        console.error("Error al cargar planilla:", error);
        alert("Error al cargar planilla semanal");
    }
}

// ========== FUNCIONES GENERALES ==========
function cerrarSesion() {
    sessionStorage.clear();
    window.location.href = "../auth/login.html";
}

// Cargar datos al iniciar la página
if (document.getElementById("tabla-empleados")) {
    document.addEventListener("DOMContentLoaded", cargarEmpleados);
}

if (document.getElementById("tabla-planillas")) {
    document.addEventListener("DOMContentLoaded", cargarPlanillaSemanal);
}