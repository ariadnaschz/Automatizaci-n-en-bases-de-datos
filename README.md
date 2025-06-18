# Automatización de Procesos en Bases de Datos – Northwind (Azure SQL)

En este repositorio se detallan los procedimientos almacenados desarrollados para la automatización de procesos internos en la base de datos Northwind de Azure SQL. Cada procedimiento ha sido diseñado para aportar lógica empresarial real, optimizado para su ejecución y documentado exhaustivamente. Se ha puesto especial énfasis en el manejo de errores y el uso de transacciones donde ha sido pertinente para asegurar la atomicidad e integridad de los datos.

🔗 [DataSet Northwind](https://learn.microsoft.com/es-es/dotnet/framework/data/adonet/sql/linq/downloading-sample-databases#get-the-northwind-sample-database-for-sql-server)
---

## 📁 Contenido del Proyecto
- crear_tabla_EmployeeBonuses.sql: script para crear la tabla auxiliar.
- crear_tipo_OrderDetailType.sql: script para crear el tipo de tabla (TVP).
- procedimiento_RegistrarNuevoPedido.sql: script del procedimiento con validaciones y transacciones.
- procedimiento_ActualizarEstadoPedido.sql: script del segundo procedimiento con control de envíos.
- Actividad_automatización_en_bases_de_datos.pdf: informe más detallado del proyecto (ncluye los scripts de pruebas exitosas y fallidas).

---

## 📌 Objetivos

- Automatizar la creación y actualización de pedidos.
- Garantizar la integridad y coherencia de los datos mediante validaciones.
- Implementar lógica de negocio realista y manejo de errores robusto.
- Aplicar transacciones SQL para asegurar operaciones atómicas.
- Realizar pruebas unitarias controladas.

---

## 🗃️ Estructura del proyecto

### Tablas adicionales

- **EmployeeBonuses**: Almacena bonificaciones calculadas a empleados según la cantidad de pedidos gestionados. Incluye validaciones de integridad y restricciones únicas.

### Tipos de tabla definidos

- **OrderDetailType**: TVP utilizado para enviar múltiples detalles de productos a los procedimientos almacenados.

---

## ⚙️ Procedimientos Almacenados

### 1. `RegistrarNuevoPedido`

Automatiza la inserción de un nuevo pedido en la tabla `Orders` y sus productos asociados en `Order Details`, asegurando:
- Validación de existencia de `CustomerID`, `EmployeeID` y `ShipVia`.
- Verificación de stock disponible por producto.
- Actualización del inventario.
- Uso de transacciones y control de errores.

#### Parámetros principales:
- Información del cliente y envío.
- TVP `@OrderDetailsTVP` con productos, cantidad, precio y descuento.

---

### 2. `ActualizarEstadoPedido`

Permite actualizar la fecha de envío (`ShippedDate`) y transportista (`ShipVia`) de un pedido, bajo las siguientes restricciones:
- Solo se permite si el pedido **no ha sido enviado aún**.
- El `ShipVia` debe ser válido.
- La nueva fecha de envío no puede ser anterior a la fecha del pedido.

---

## ✅ Pruebas realizadas

Se diseñaron y ejecutaron **múltiples casos de prueba**, incluyendo:
- Registro exitoso de pedido con stock suficiente.
- Control de errores por:
  - Stock insuficiente.
  - Pedido ya enviado.
  - Identificadores inexistentes.
  - Fecha de envío inválida.

Cada prueba incluye validación de resultados antes y después de la ejecución del procedimiento, asegurando consistencia en la base de datos.

## 🧰 Tecnologías utilizadas

- **SQL Server Management Studio (SSMS)**
- **Azure SQL Database**
- **Transact-SQL (T-SQL)**
- **Control de errores con TRY...CATCH**
- **Validaciones personalizadas con THROW**
  
## 📌 Créditos

Este proyecto fue desarrollado como parte de una actividad de la materia de "Bases de datos" en la Universidad Tecnológica de Bolivar.



