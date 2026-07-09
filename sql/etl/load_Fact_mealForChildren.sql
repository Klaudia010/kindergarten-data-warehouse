USE PrzedszkoleDW;
GO

-- Drop the view if it exists
IF OBJECT_ID('vETLFMealForChildren') IS NOT NULL 
    DROP VIEW vETLFMealForChildren;
GO

-- Create a staging view
CREATE VIEW vETLFMealForChildren
AS
SELECT
    C_DW.ID_Children AS ID_Children,
    EM.EatenMealNo AS EatenMealNo
FROM Przedszkole.dbo.Children AS C_SRC
JOIN PrzedszkoleDW.dbo.Children AS C_DW
    ON C_SRC.Pesel = C_DW.Pesel
JOIN PrzedszkoleDW.dbo.[Group] AS G_DW
    ON C_SRC.GroupName = G_DW.GroupName  -- Map child's group to DW Group
JOIN PrzedszkoleDW.dbo.EatenMeal AS EM
    ON EM.ID_GroupName = G_DW.ID_GroupName; -- Only meals eaten by their group
GO

-- Merge into MealForChild fact table
MERGE INTO PrzedszkoleDW.dbo.MealForChild AS TT
USING vETLFMealForChildren AS ST
    ON TT.ID_Children = ST.ID_Children
    AND TT.EatenMealNo = ST.EatenMealNo
WHEN NOT MATCHED THEN
    INSERT (
        ID_Children,
        EatenMealNo
    )
    VALUES (
        ST.ID_Children,
        ST.EatenMealNo
    );
GO

-- Drop the temporary view
DROP VIEW vETLFMealForChildren;
GO
