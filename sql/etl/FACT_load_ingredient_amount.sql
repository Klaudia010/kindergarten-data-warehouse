USE PrzedszkoleDW;
GO

IF OBJECT_ID('vETLFIngredientAmount') IS NOT NULL DROP VIEW vETLFIngredientAmount;
GO

CREATE VIEW vETLFIngredientAmount AS
WITH RecipeSignatures AS (
    SELECT
        mr.Name AS MealName,
        mr.ID AS RecipeID,
        STRING_AGG(CAST(ia.Name AS NVARCHAR) + ':' + CAST(ia.Amount AS NVARCHAR), ',') 
            WITHIN GROUP (ORDER BY ia.Name, ia.Amount) AS IngredientSignature
    FROM Przedszkole.dbo.MealRecipe AS mr
    JOIN Przedszkole.dbo.IngredientAmount AS ia
        ON mr.ID = ia.ID
    GROUP BY mr.Name, mr.ID
),
VersionedRecipes AS (
    SELECT 
        RecipeID,
        MealName,
        IngredientSignature,
        'v' + CAST(ROW_NUMBER() OVER (PARTITION BY MealName ORDER BY IngredientSignature) AS VARCHAR) AS Version
    FROM RecipeSignatures
)
SELECT
    ia.Name AS IngredientName,
    ia.Amount,
    vr.MealName,
    vr.Version
FROM Przedszkole.dbo.IngredientAmount AS ia
JOIN Przedszkole.dbo.MealRecipe AS mr ON ia.ID = mr.ID
JOIN VersionedRecipes AS vr ON mr.ID = vr.RecipeID;
GO

MERGE INTO PrzedszkoleDW.dbo.IngredientAmount AS Target
USING (
    SELECT 
        i.ID_Ingredient,
        mr.ID_MealRecipe,
        v.Amount
    FROM vETLFIngredientAmount AS v
    JOIN PrzedszkoleDW.dbo.Ingredient AS i
        ON v.IngredientName = i.Name
    JOIN PrzedszkoleDW.dbo.MealRecipe AS mr
        ON v.MealName = mr.Name AND v.Version = mr.Version
) AS Source
ON Target.ID_Ingredient = Source.ID_Ingredient AND Target.ID_MealRecipe = Source.ID_MealRecipe
WHEN NOT MATCHED THEN
    INSERT (ID_Ingredient, ID_MealRecipe)
    VALUES (Source.ID_Ingredient, Source.ID_MealRecipe);
GO

DROP VIEW vETLFIngredientAmount;
GO
