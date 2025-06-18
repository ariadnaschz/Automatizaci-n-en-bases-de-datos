IF TYPE_ID(N'OrderDetailType') IS NULL
BEGIN
    CREATE TYPE OrderDetailType AS TABLE (
        ProductID INT NOT NULL,
        UnitPrice MONEY NOT NULL,
        Quantity SMALLINT NOT NULL,
        Discount REAL NOT NULL CHECK (Discount >= 0 AND Discount <= 1)
    );
    PRINT 'Tipo de tabla OrderDetailType creado exitosamente.';
END
ELSE
    PRINT 'Tipo de tabla OrderDetailType ya existe.';
GO
