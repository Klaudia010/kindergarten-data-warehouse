USE PrzedszkoleDW;
GO

-- 1. Drop the view if it exists
IF OBJECT_ID('vETLFMealWithTeacher') IS NOT NULL DROP VIEW vETLFMealWithTeacher;
GO

-- 2. Create the view to map Teachers Meals based on DW IDs
CREATE VIEW vETLFMealWithTeacher
AS
SELECT --DISTINCT
    T_DW.ID_Teacher AS ID_Teacher,
    EM.EatenMealNo AS EatenMealNo
FROM Przedszkole.dbo.Teacher AS T_SRC
JOIN PrzedszkoleDW.dbo.Teacher AS T_DW
    ON T_SRC.Pesel = T_DW.Pesel
JOIN PrzedszkoleDW.dbo.[Group] AS G_DW
    ON T_SRC.GroupName = G_DW.GroupName   -- Map Teacher to DW Group
JOIN PrzedszkoleDW.dbo.EatenMeal AS EM
    ON G_DW.ID_GroupName = EM.ID_GroupName -- Meal must match the DW Group ID
GO

-- 3. Merge into MealWithTeacher fact table
MERGE INTO PrzedszkoleDW.dbo.MealWithTeacher AS TT
USING vETLFMealWithTeacher AS ST
    ON TT.ID_Teacher = ST.ID_Teacher
    AND TT.EatenMealNo = ST.EatenMealNo
WHEN NOT MATCHED THEN
    INSERT (
        ID_Teacher,
        EatenMealNo
    )
    VALUES (
        ST.ID_Teacher,
        ST.EatenMealNo
    );
GO

-- 4. Drop the temporary view
DROP VIEW vETLFMealWithTeacher;
GO
