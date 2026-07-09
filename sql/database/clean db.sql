use Przedszkole;

DELETE FROM MealConsumption;
DBCC CHECKIDENT ('MealConsumption', RESEED, 0);

DELETE FROM MealSchedule;
DELETE FROM IngredientAmount;
DELETE FROM Children;
DELETE FROM Teacher;
DELETE FROM Ingredient;
DELETE FROM MealRecipe;
DBCC CHECKIDENT ('MealRecipe', RESEED, 0);

DELETE FROM [Group];
