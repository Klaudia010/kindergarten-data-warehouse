-- Create the Przedszkole data warehouse
CREATE DATABASE PrzedszkoleDW COLLATE Latin1_General_CI_AS;
GO

USE PrzedszkoleDW;
GO

-- DIMENSION TABLES

-- Ingredient
CREATE TABLE Ingredient (
    ID_Ingredient INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(20) NOT NULL,
    Type VARCHAR(20) CHECK (Type IN ('dairy', 'meat', 'fruit', 'vegetable', 'side/other'))
);

-- MealRecipe
CREATE TABLE MealRecipe (
    ID_MealRecipe INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(30) NOT NULL,
    Version VARCHAR(10) NOT NULL
);

-- Group (renamed to avoid reserved keyword)
CREATE TABLE [Group] (
    ID_GroupName INT PRIMARY KEY IDENTITY(1,1),
    GroupName VARCHAR(20) NOT NULL,
    Age VARCHAR(10) CHECK (Age IN ('3-4yr', '4-5yr', '5-6yr'))
);

-- MealType
CREATE TABLE MealType (
    ID_MealType INT PRIMARY KEY IDENTITY(1,1),
    MealType VARCHAR(20) CHECK (MealType IN ('breakfast', 'lunch', 'snack', 'dinner'))
);

-- Date
CREATE TABLE [Date](
    ID_Date INT PRIMARY KEY IDENTITY(1,1),
    Date DATE NOT NULL,
    Year INT CHECK (Year BETWEEN 2000 AND 2100),
    Month VARCHAR(10) CHECK (Month IN (
        'January','February','March','April','May','June',
        'July','August','September','October','November','December'
    ))
);

-- Teacher (SCD2)
CREATE TABLE Teacher (
    ID_Teacher INT PRIMARY KEY IDENTITY(1,1),
    Pesel CHAR(11) NOT NULL,
    FullName VARCHAR(60) NOT NULL,
    Qualification VARCHAR(100),
    Date_first_qualification DATE,
    Date_new_qualification DATE,
	GroupName VARCHAR(20) NOT NULL
);

-- Children
CREATE TABLE Children (
    ID_Children INT PRIMARY KEY IDENTITY(1,1),
    Pesel CHAR(11) NOT NULL,
    FullName VARCHAR(60) NOT NULL,
    Age VARCHAR(10) CHECK (Age IN ('3yr', '4yr', '5yr', '6yr')),
    Allergies VARCHAR(3) CHECK (Allergies IN ('yes', 'no')),
    SpecialNeeds VARCHAR(3) CHECK (SpecialNeeds IN ('yes', 'no')),
	GroupName VARCHAR(20) NOT NULL
);

-- FACT TABLES

-- EatenMeal (Fact Table)
CREATE TABLE EatenMeal (
    EatenMealNo INT PRIMARY KEY IDENTITY(1,1),
    ID_Date INT NOT NULL,
    ID_GroupName INT NOT NULL,
    ID_MealType INT NOT NULL,
    ID_MealRecipe INT NOT NULL,
    MealPrepared INT NOT NULL,
    MealGiven INT NOT NULL,
    Leftovers INT NOT NULL,
    MealLoss DECIMAL(10, 2),
    GroupMealPrice DECIMAL(10, 2),
    FOREIGN KEY (ID_Date) REFERENCES [Date](ID_Date),
    FOREIGN KEY (ID_GroupName) REFERENCES [Group](ID_GroupName),
    FOREIGN KEY (ID_MealType) REFERENCES MealType(ID_MealType),
    FOREIGN KEY (ID_MealRecipe) REFERENCES MealRecipe(ID_MealRecipe)
);

-- IngredientAmount (Fact Table)
CREATE TABLE IngredientAmount (
    ID_Ingredient INT NOT NULL,
    ID_MealRecipe INT NOT NULL,
	PRIMARY KEY (ID_Ingredient, ID_MealRecipe), 
    FOREIGN KEY (ID_Ingredient) REFERENCES Ingredient(ID_Ingredient),
    FOREIGN KEY (ID_MealRecipe) REFERENCES MealRecipe(ID_MealRecipe)
);

-- MealForChild (Fact Table)
CREATE TABLE MealForChild (
    ID_Children INT NOT NULL,
    EatenMealNo INT NOT NULL,
	PRIMARY KEY (EatenMealNo, ID_Children), 
    FOREIGN KEY (ID_Children) REFERENCES Children(ID_Children),
    FOREIGN KEY (EatenMealNo) REFERENCES EatenMeal(EatenMealNo)
);

-- MealWithTeacher (Fact Table)
CREATE TABLE MealWithTeacher (
    ID_Teacher INT NOT NULL,
    EatenMealNo INT NOT NULL,
	PRIMARY KEY (EatenMealNo, ID_Teacher),
    FOREIGN KEY (ID_Teacher) REFERENCES Teacher(ID_Teacher),
    FOREIGN KEY (EatenMealNo) REFERENCES EatenMeal(EatenMealNo)
);
