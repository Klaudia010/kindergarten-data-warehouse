USE PrzedszkoleDW;
GO

-- Create temporary table to hold CSV data
CREATE TABLE #TempIngredientData (
    [Date] DATE,
    [Type] VARCHAR(20),
    [Name] VARCHAR(20),
    [Amount] DECIMAL(10,2),
    [Price] INT
);

-- Load CSV data into temporary table
BULK INSERT #TempIngredientData
FROM 'path/to/modified_Order_list.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- Merge after SELECT DISTINCT to avoid duplicates
MERGE INTO PrzedszkoleDW.dbo.Ingredient AS I
USING (
    SELECT DISTINCT Name, Type
    FROM #TempIngredientData
) AS T
ON I.Name COLLATE Latin1_General_CI_AS = T.Name COLLATE Latin1_General_CI_AS
WHEN MATCHED THEN
    UPDATE SET I.Type = T.Type
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Name, Type)
    VALUES (T.Name, T.Type);

-- Drop temporary table
DROP TABLE #TempIngredientData;
GO
