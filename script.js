async function cargarEmpleados() {
    try {
        let respuesta = await fetch("http://localhost:3000/empleados");
        let empleados = await respuesta.json();
        let tabla = document.getElementById("tabla-empleados").getElementsByTagName("tbody")[0];

        tabla.innerHTML = ""; // Limpiar antes de llenarla

        empleados.forEach(emp => {
            let fila = tabla.insertRow();
            //console.log(emp);
            fila.insertCell(0).textContent = emp.tablaID;
            fila.insertCell(1).textContent = emp.tablaNombre;
            fila.insertCell(2).textContent = emp.tablaSalario;
        });
    } catch (error) {
        console.error("Error al cargar empleados:", error);
    }
}

async function insertarEmpleado() {
    let nombre = document.getElementById("nombre").value.trim();
    let salario = document.getElementById("salario").value.trim();
    let errorNombre = document.getElementById("error-nombre");
    let errorSalario = document.getElementById("error-salario");

    errorNombre.textContent = "";
    errorSalario.textContent = "";

    try {
        let respuesta = await fetch("http://localhost:3000/empleados", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ Nombre: nombre, Salario: salario })
        });

        let resultado = await respuesta.json();

        if (resultado.codigo === 0) {
            alert("Empleado agregado con éxito");
            window.location.href = "index.html"; // Regresar y refrescar tabla
        } else if (resultado.codigo === 50001) {
            alert("Nombre de empleado ya existe");
        } else {
            alert("Error al insertar empleado");
        }
    } catch (error) {
        console.error("Error al insertar empleado:", error);
        alert("Error al insertar empleado");
    }
}
