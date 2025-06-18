CREATE OR ALTER PROCEDURE dbo.RegistrarNuevoPedido
    -- Parámetros para la tabla Orders
    @CustomerID NCHAR(5),
    @EmployeeID INT,
    @OrderDate DATETIME,
    @RequiredDate DATETIME,
    @ShippedDate DATETIME = NULL,
    @ShipVia INT,
    @Freight MONEY = 0,
    @ShipName NVARCHAR(40),
    @ShipAddress NVARCHAR(60),
    @ShipCity NVARCHAR(15),
    @ShipRegion NVARCHAR(15) = NULL,
    @ShipPostalCode NVARCHAR(10) = NULL,
    @ShipCountry NVARCHAR(15),
    -- Parámetro de tipo tabla para los detalles del pedido
    @OrderDetailsTVP OrderDetailType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewOrderID INT;
    DECLARE @CurrentProductID INT;
    DECLARE @CurrentQuantity SMALLINT;
    DECLARE @StockAvailable SMALLINT;
    DECLARE @ProductName NVARCHAR(40);
    DECLARE @ErrorMessage NVARCHAR(2048); -- Variable para construir mensajes de error

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Validar existencia de CustomerID, EmployeeID y ShipperID
        IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerID = @CustomerID)
        BEGIN
            SET @ErrorMessage = FORMATMESSAGE('El CustomerID proporcionado ''%s'' no existe.', @CustomerID);
            THROW 50001, @ErrorMessage, 1;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.Employees WHERE EmployeeID = @EmployeeID)
        BEGIN
            SET @ErrorMessage = FORMATMESSAGE('El EmployeeID proporcionado ''%d'' no existe.', @EmployeeID);
            THROW 50002, @ErrorMessage, 1;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.Shippers WHERE ShipperID = @ShipVia)
        BEGIN
            SET @ErrorMessage = FORMATMESSAGE('El ShipVia (ShipperID) proporcionado ''%d'' no existe.', @ShipVia);
            THROW 50003, @ErrorMessage, 1;
        END

        -- 2. Validar stock para cada producto en el TVP
        DECLARE product_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT ProductID, Quantity FROM @OrderDetailsTVP;

        OPEN product_cursor;
        FETCH NEXT FROM product_cursor INTO @CurrentProductID, @CurrentQuantity;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT
                @StockAvailable = p.UnitsInStock,
                @ProductName = p.ProductName
            FROM dbo.Products p
            WHERE p.ProductID = @CurrentProductID;

            IF @StockAvailable IS NULL -- Significa que el ProductID no se encontró en la tabla Products
            BEGIN
                CLOSE product_cursor;
                DEALLOCATE product_cursor;
                SET @ErrorMessage = FORMATMESSAGE('El producto ID %d especificado en los detalles del pedido no existe en la tabla Products.', @CurrentProductID);
                THROW 50004, @ErrorMessage, 1;
            END

            IF @StockAvailable < @CurrentQuantity
            BEGIN
                CLOSE product_cursor;
                DEALLOCATE product_cursor;
                SET @ErrorMessage = FORMATMESSAGE('Stock insuficiente para el producto "%s" (ID: %d). Solicitado: %d, Disponible: %d.', @ProductName, @CurrentProductID, @CurrentQuantity, @StockAvailable);
                THROW 50005, @ErrorMessage, 1;
            END

            FETCH NEXT FROM product_cursor INTO @CurrentProductID, @CurrentQuantity;
        END

        CLOSE product_cursor;
        DEALLOCATE product_cursor;

        -- 3. Insertar en la tabla Orders
        INSERT INTO dbo.Orders (
            CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate,
            ShipVia, Freight, ShipName, ShipAddress, ShipCity,
            ShipRegion, ShipPostalCode, ShipCountry
        )
        VALUES (
            @CustomerID, @EmployeeID, @OrderDate, @RequiredDate, @ShippedDate,
            @ShipVia, @Freight, @ShipName, @ShipAddress, @ShipCity,
            @ShipRegion, @ShipPostalCode, @ShipCountry
        );

        SET @NewOrderID = SCOPE_IDENTITY();

        -- 4. Insertar en la tabla Order Details y actualizar stock
        INSERT INTO dbo.[Order Details] (
            OrderID, ProductID, UnitPrice, Quantity, Discount
        )
        SELECT
            @NewOrderID,
            tvp.ProductID,
            tvp.UnitPrice,
            tvp.Quantity,
            tvp.Discount
        FROM @OrderDetailsTVP tvp;

        UPDATE p
        SET p.UnitsInStock = p.UnitsInStock - od.Quantity
        FROM dbo.Products p
        INNER JOIN @OrderDetailsTVP od ON p.ProductID = od.ProductID;

        COMMIT TRANSACTION;

        SELECT @NewOrderID AS NewOrderID;
        PRINT 'Pedido ' + CAST(@NewOrderID AS VARCHAR(10)) + ' registrado exitosamente.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Relanzar el error. El mensaje ya fue formateado si provino de un THROW nuestro.
        -- Si es un error del sistema, se relanzará tal cual.
        THROW;
        -- RETURN; -- No es estrictamente necesario después de THROW si es la última instrucción en CATCH
    END CATCH
END
GO