USE PrzedszkoleDW;
GO

-- STEP 1: Drop staging table if it exists
IF OBJECT_ID('dbo.StgIngredientPrice') IS NOT NULL
    DROP TABLE dbo.StgIngredientPrice;
GO

-- STEP 2: Create staging table
CREATE TABLE dbo.StgIngredientPrice (
    [Date] DATE,
    [Type] VARCHAR(20),
    [Name] VARCHAR(20),
    [Amount] DECIMAL(10, 2),
    [PricePerUnit] INT
);
GO

-- STEP 3: Bulk load CSV data into staging table
BULK INSERT dbo.StgIngredientPrice
FROM 'path/to/modified_Order_list.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2  -- Skip header
);
GO

-- STEP 4: Merge data into EatenMeal fact table
MERGE INTO EatenMeal AS Target
USING (
    SELECT 
        D.ID_Date,
        G.ID_GroupName,
        MT.ID_MealType,
        MR_DW.ID_MealRecipe,
        MC.MealsPrepared,
        MC.MealsGiven,
        MC.Leftovers,

        -- Cost of leftovers
        ISNULL(SUM(SIP.PricePerUnit * IA.Amount * MC.Leftovers * 0.001), 0) AS MealLoss,

        -- Total cost of meals prepared
        ISNULL(SUM(SIP.PricePerUnit * IA.Amount * MC.MealsPrepared * 0.001), 0) AS GroupMealPrice

    FROM Przedszkole.dbo.MealConsumption AS MC
    JOIN Przedszkole.dbo.[Group] AS G_SRC
        ON MC.GroupName = G_SRC.GroupName

    JOIN Przedszkole.dbo.MealSchedule AS MS
        ON MC.Date = MS.Date AND MC.MealType = MS.MealType

    JOIN Przedszkole.dbo.MealRecipe AS MR_SRC
        ON MS.ID = MR_SRC.ID

    JOIN Przedszkole.dbo.IngredientAmount AS IA
        ON MR_SRC.ID = IA.ID 

    JOIN Przedszkole.dbo.Ingredient AS I_SRC
        ON IA.Name = I_SRC.Name

    -- Deduplicate to get latest price per ingredient
    LEFT JOIN (
        SELECT Name, PricePerUnit
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY Name ORDER BY [Date] DESC) AS rn			--assign numbers, within each group of the same Name, to rows by Date most recent rn=1
            FROM dbo.StgIngredientPrice
        ) AS RankedPrices
        WHERE rn = 1		--take only the most recent price
    ) AS SIP
        ON SIP.Name = I_SRC.Name

    -- Map to DW dimension tables
    JOIN PrzedszkoleDW.dbo.[Date] AS D
        ON MC.Date = D.Date

    JOIN PrzedszkoleDW.dbo.MealType AS MT
        ON MC.MealType = MT.MealType

    JOIN PrzedszkoleDW.dbo.[Group] AS G
        ON G_SRC.GroupName = G.GroupName

    JOIN PrzedszkoleDW.dbo.MealRecipe AS MR_DW
        ON MR_SRC.Name = MR_DW.Name

    GROUP BY 
        D.ID_Date,
        G.ID_GroupName,
        MT.ID_MealType,
        MR_DW.ID_MealRecipe,
        MC.MealsPrepared,
        MC.MealsGiven,
        MC.Leftovers
) AS Source

-- Insert only if no matching record
ON Target.ID_Date = Source.ID_Date
   AND Target.ID_GroupName = Source.ID_GroupName
   AND Target.ID_MealType = Source.ID_MealType
   AND Target.ID_MealRecipe = Source.ID_MealRecipe

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        ID_Date,
        ID_GroupName,
        ID_MealType,
        ID_MealRecipe,
        MealPrepared,
        MealGiven,
        Leftovers,
        MealLoss,
        GroupMealPrice
    )
    VALUES (
        Source.ID_Date,
        Source.ID_GroupName,
        Source.ID_MealType,
        Source.ID_MealRecipe,
        Source.MealsPrepared,
        Source.MealsGiven,
        Source.Leftovers,
        Source.MealLoss,
        Source.GroupMealPrice
    );
GO

-- STEP 5: Drop staging table after merge
DROP TABLE dbo.StgIngredientPrice;
GO
