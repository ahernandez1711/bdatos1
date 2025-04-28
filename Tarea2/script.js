// Función para login
async function login(event) {
    event.preventDefault(); // Evita que recargue la página

    let usuario = document.getElementById("usuario").value.trim();
    let contrasena = document.getElementById("contrasena").value.trim();

    console.log("Intentando login con:", usuario, contrasena);

    if (!usuario || !contrasena) {
        alert("Debe ingresar usuario y contraseña.");
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
            alert("Login exitoso");
            sessionStorage.setItem("userId", resultado.userId);
            window.location.href = "index.html";
        } else {
            alert("Login fallido: " + resultado.mensaje);
        }
    } catch (error) {
        console.error("Error en login:", error);
        alert("Error al intentar login.");
    }
}


// ================================
// Funciones de Empleados
// ================================

async function cargarEmpleados() {
    try {
        const filtro = document.getElementById("filtro")?.value.trim() || '';
        const respuesta = await fetch(`http://localhost:3000/empleados?filtro=${encodeURIComponent(filtro)}`);
        const empleados = await respuesta.json();

        const tabla = document.getElementById("tabla-empleados").getElementsByTagName("tbody")[0];
        tabla.innerHTML = "";

        empleados.forEach(emp => {
            let fila = tabla.insertRow();
            fila.insertCell(0).textContent = emp.Nombre;
            fila.insertCell(1).textContent = emp.ValorDocumentoIdentidad;
            let acciones = fila.insertCell(2);

            let botonVer = document.createElement("button");
            botonVer.textContent = "Ver Detalle";
            botonVer.onclick = function() {
                window.location.href = `empleado.html?id=${emp.id}`;
            };
            acciones.appendChild(botonVer);
        });
    } catch (error) {
        console.error("Error al cargar empleados:", error);
    }
}

async function cargarEmpleadoDetalle() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");

    if (!id) {
        alert("Empleado no especificado");
        window.location.href = "index.html";
        return;
    }

    try {
        const respuesta = await fetch(`http://localhost:3000/empleados/${id}`);
        const empleado = await respuesta.json();

        if (empleado) {
            document.getElementById("detalle-empleado").innerHTML = `
                <p><strong>Nombre:</strong> ${empleado.Nombre}</p>
                <p><strong>Documento Identidad:</strong> ${empleado.ValorDocumentoIdentidad}</p>
                <p><strong>Id Puesto:</strong> ${empleado.idPuesto}</p>
            `;
        } else {
            alert("Empleado no encontrado");
            window.location.href = "index.html";
        }
    } catch (error) {
        console.error("Error al cargar empleado:", error);
        alert("Error al cargar empleado");
        window.location.href = "index.html";
    }
}

function irEditar() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");
    window.location.href = `editar.html?id=${id}`;
}

async function eliminarEmpleado() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");

    if (!confirm("¿Está seguro que desea eliminar este empleado?")) {
        return;
    }

    try {
        const respuesta = await fetch(`http://localhost:3000/empleados/${id}`, { method: "DELETE" });
        const resultado = await respuesta.json();

        if (resultado.codigo === 0) {
            alert("Empleado eliminado correctamente");
            window.location.href = "index.html";
        } else {
            alert("Error al eliminar empleado");
        }
    } catch (error) {
        console.error("Error al eliminar empleado:", error);
    }
}

async function cargarEmpleadoPorId() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");

    try {
        const respuesta = await fetch(`http://localhost:3000/empleados/${id}`);
        const empleado = await respuesta.json();

        document.getElementById("nombre").value = empleado.Nombre;
        document.getElementById("documento").value = empleado.ValorDocumentoIdentidad;
        document.getElementById("idPuesto").value = empleado.idPuesto;

    } catch (error) {
        console.error("Error al cargar empleado para editar:", error);
    }
}

async function actualizarEmpleado() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");

    const nombre = document.getElementById("nombre").value.trim();
    const documento = document.getElementById("documento").value.trim();
    const idPuesto = document.getElementById("idPuesto").value.trim();

    try {
        const respuesta = await fetch(`http://localhost:3000/empleados/${id}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                Nombre: nombre,
                ValorDocumentoIdentidad: documento,
                IdPuesto: parseInt(idPuesto)
            })
        });

        const resultado = await respuesta.json();

        if (resultado.codigo === 0) {
            alert("Empleado actualizado correctamente");
            window.location.href = "index.html";
        } else {
            alert("Error al actualizar empleado");
        }
    } catch (error) {
        console.error("Error al actualizar empleado:", error);
    }
}

async function insertarEmpleado() {
    const nombre = document.getElementById("nombre").value.trim();
    const documento = document.getElementById("documento").value.trim();
    const idPuesto = document.getElementById("idPuesto").value.trim();

    try {
        const respuesta = await fetch("http://localhost:3000/empleados", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                Nombre: nombre,
                ValorDocumentoIdentidad: documento,
                IdPuesto: parseInt(idPuesto)
            })
        });

        const resultado = await respuesta.json();

        if (resultado.codigo === 0) {
            alert("Empleado insertado correctamente");
            window.location.href = "index.html";
        } else {
            alert("Error al insertar empleado");
        }
    } catch (error) {
        console.error("Error al insertar empleado:", error);
    }
}

// ================================
// Funciones de Movimientos
// ================================

function verMovimientos() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");
    window.location.href = `movimientos.html?id=${id}`;
}

async function cargarMovimientos() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");

    try {
        const respuesta = await fetch(`http://localhost:3000/movimientos/${id}`);
        const movimientos = await respuesta.json();

        const tabla = document.getElementById("tabla-movimientos").getElementsByTagName("tbody")[0];
        tabla.innerHTML = "";

        movimientos.forEach(mov => {
            let fila = tabla.insertRow();
            fila.insertCell(0).textContent = new Date(mov.Fecha).toLocaleDateString();
            fila.insertCell(1).textContent = mov.TipoMovimiento;
            fila.insertCell(2).textContent = mov.Monto;
            fila.insertCell(3).textContent = mov.NuevoSaldo;
            fila.insertCell(4).textContent = mov.RegistradoPor;
            fila.insertCell(5).textContent = mov.PostInIP;
            fila.insertCell(6).textContent = new Date(mov.PostTime).toLocaleString();
        });
    } catch (error) {
        console.error("Error al cargar movimientos:", error);
    }
}

function irInsertarMovimiento() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");
    window.location.href = `insertar_movimiento.html?id=${id}`;
}

async function insertarMovimiento() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");

    const tipoMovimiento = document.getElementById("tipoMovimiento").value.trim();
    const monto = document.getElementById("monto").value.trim();

    try {
        const respuesta = await fetch("http://localhost:3000/movimientos", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                EmpleadoId: parseInt(id),
                TipoMovimiento: tipoMovimiento,
                Monto: parseFloat(monto)
            })
        });

        const resultado = await respuesta.json();

        if (resultado.codigo === 0) {
            alert("Movimiento insertado correctamente");
            window.location.href = `movimientos.html?id=${id}`;
        } else {
            alert("Error al insertar movimiento");
        }
    } catch (error) {
        console.error("Error al insertar movimiento:", error);
    }
}

function volverAlListado() {
    window.location.href = "index.html";
}
