USE PrzedszkoleDW
GO

If (object_id('vETLDimMealTypeData') is not null) Drop View vETLDimMealTypeData;
go
CREATE VIEW vETLDimMealTypeData
AS
SELECT DISTINCT
	[MealType]
FROM [Przedszkole].dbo.[MealRecipe];
go

MERGE INTO PrzedszkoleDW.dbo.MealType as MT
USING vETLDimMealTypeData as ST
ON MT.MealType = ST.MealType
	WHEN Not Matched
	THEN
	INSERT Values (
		ST.MealType 

);

Drop View vETLDimMealTypeData;