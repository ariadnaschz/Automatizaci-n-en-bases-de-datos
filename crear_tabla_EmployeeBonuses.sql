-- ==========================================================================================

-- Mejora el rendimiento y reduce el ruido en la salida de ejecución.
SET NOCOUNT ON;

-- Inicia un bloque TRY para el manejo de errores durante la creación de la tabla.
BEGIN TRY
 
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmployeeBonuses]') AND type in (N'U'))
    BEGIN
 
        PRINT 'Creando la tabla [dbo].[EmployeeBonuses]...';


        CREATE TABLE [dbo].[EmployeeBonuses](
           
            [BonusID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,    
            [EmployeeID] [int] NOT NULL,
            [BonusMonth] [int] NOT NULL,
            [BonusYear] [int] NOT NULL,
            [NumberOfOrdersManaged] [int] NOT NULL,
            [BonusAmount] [money] NOT NULL,
            [CalculationDate] [datetime] NULL DEFAULT (GETDATE()),
            CONSTRAINT FK_EmployeeBonuses_Employees FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employees]([EmployeeID]),

            CONSTRAINT CK_BonusMonth CHECK ([BonusMonth] BETWEEN 1 AND 12),

            CONSTRAINT UK_EmployeeBonus_MonthYear UNIQUE ([EmployeeID], [BonusMonth], [BonusYear])
        );

        PRINT 'Tabla [dbo].[EmployeeBonuses] creada exitosamente.';
    END
    ELSE
    BEGIN
        -- Mensaje informativo si la tabla ya existía y no se realizó ninguna acción de creación.
        PRINT 'La tabla [dbo].[EmployeeBonuses] ya existe. No se requieren acciones.';
    END
END TRY
-- Bloque CATCH para capturar cualquier error que ocurra durante la ejecución del bloque TRY.
BEGIN CATCH

    PRINT 'Ocurrió un error al intentar crear la tabla [dbo].[EmployeeBonuses].';
    PRINT 'Error Número: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Mensaje de Error: ' + ERROR_MESSAGE();
    PRINT 'Severidad del Error: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT 'Estado del Error: ' + CAST(ERROR_STATE() AS VARCHAR(10));
    PRINT 'Línea del Error: ' + CAST(ERROR_LINE() AS VARCHAR(10));


    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH

-- Restaura el comportamiento predeterminado de devolver mensajes de recuento de filas.
SET NOCOUNT OFF;
GO -- Final del lote de Transact-SQL.
