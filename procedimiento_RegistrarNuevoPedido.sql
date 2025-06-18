-- ==========================================================================================
-- SP Nombre:       ActualizarEstadoPedido
-- Descripción:     Permite actualizar ShippedDate y ShipVia de un pedido, solo si
--                  el pedido no ha sido enviado previamente.
-- ==========================================================================================
CREATE OR ALTER PROCEDURE dbo.ActualizarEstadoPedido
    @OrderID INT,
    @NewShippedDate DATETIME,
    @NewShipVia INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(2048);
    DECLARE @CurrentShippedDate DATETIME;
    DECLARE @OrderDate DATETIME;

    BEGIN TRANSACTION;
    BEGIN TRY
        SELECT @CurrentShippedDate = o.ShippedDate, @OrderDate = o.OrderDate
        FROM dbo.Orders o WHERE o.OrderID = @OrderID;

        IF @OrderDate IS NULL
            THROW 50010, 'El pedido con OrderID %d no existe.', 1;

        IF @CurrentShippedDate IS NOT NULL
            THROW 50011, 'El pedido OrderID %d ya fue enviado y no puede ser modificado.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Shippers WHERE ShipperID = @NewShipVia)
            THROW 50012, 'El transportista (ShipVia) con ID %d no existe.', 1;
        
        IF @NewShippedDate IS NOT NULL AND @NewShippedDate < @OrderDate
            THROW 50013, 'La nueva fecha de envío no puede ser anterior a la fecha del pedido.', 1;

        UPDATE dbo.Orders
        SET ShippedDate = @NewShippedDate, ShipVia = @NewShipVia
        WHERE OrderID = @OrderID;

        IF @@ROWCOUNT = 0
            THROW 50014, 'No se pudo actualizar el pedido OrderID %d.', 1;

        PRINT 'Estado del pedido OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' actualizado.';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO