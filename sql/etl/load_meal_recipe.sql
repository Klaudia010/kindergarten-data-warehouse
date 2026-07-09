USE PrzedszkoleDW;
GO

-- 1. Drop existing view if it exists
IF OBJECT_ID('vETLDimMealRecipeData') IS NOT NULL DROP VIEW vETLDimMealRecipeData;
GO

-- 2. Create new staging view with versioning based on ingredient composition
CREATE VIEW vETLDimMealRecipeData AS
WITH RecipeSignatures AS (
    SELECT
        mr.Name AS MealName,
        mr.ID AS RecipeID,
        STRING_AGG(CAST(ia.Name AS NVARCHAR) + ':' + CAST(ia.Amount AS NVARCHAR), ',')  --Carrot:100, Potato:150
            WITHIN GROUP (ORDER BY ia.Name, ia.Amount) AS IngredientSignature
    FROM Przedszkole.dbo.MealRecipe AS mr
    JOIN Przedszkole.dbo.IngredientAmount AS ia
        ON mr.ID = ia.ID
    GROUP BY mr.Name, mr.ID
),
VersionedRecipes AS (
    SELECT 
        MealName,
        IngredientSignature,
        'v' + CAST(ROW_NUMBER() OVER (PARTITION BY MealName ORDER BY IngredientSignature) AS VARCHAR) AS Version   --Within each MealName, it assigns version numbers (v1, v2, …) to each unique ingredient signature.
    FROM RecipeSignatures
)
SELECT DISTINCT MealName, Version
FROM VersionedRecipes;
GO

-- 3. Merge new versions into DW
MERGE INTO PrzedszkoleDW.dbo.MealRecipe AS Target
USING vETLDimMealRecipeData AS Source
ON Target.Name = Source.MealName AND Target.Version = Source.Version
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Name, Version)
    VALUES (Source.MealName, Source.Version);
GO

-- 4. Drop staging view
DROP VIEW vETLDimMealRecipeData;
GO
