-- Create the Przedszkole database
CREATE DATABASE Przedszkole COLLATE Latin1_General_CI_AS;
GO

USE Przedszkole
GO

-- MealRecipe table
CREATE TABLE MealRecipe (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL,
    Allergens VARCHAR(6) NULL CHECK (Allergens IS NULL OR Allergens IN ('Milk', 'Egg', 'Peanut', 'Wheat', 'Soy')),
    MealType VARCHAR(50) CHECK (MealType IN ('breakfast', 'snack', 'lunch', 'dinner'))
);
GO

-- MealSchedule table to store Date and MealType
CREATE TABLE MealSchedule (
    Date DATE NOT NULL CHECK (Date <= GETDATE()),
    MealType VARCHAR(50) CHECK (MealType IN ('breakfast', 'snack', 'lunch', 'dinner')),
    PRIMARY KEY (Date, MealType),
	ID INT NOT NULL,    -- REF to MealRecipe
    FOREIGN KEY (ID) REFERENCES MealRecipe(ID)
);
GO

-- Group table with GroupName as the primary key and CurrentCapacity
CREATE TABLE [Group] (
    GroupName VARCHAR(255) PRIMARY KEY CHECK (GroupName IN ('Group_3yr', 'Group_4yr', 'Group_5yr')),
    CurrentCapacity INT NOT NULL CHECK (CurrentCapacity >= 0)
);
GO

-- MealConsumption table referencing Group and MealSchedule
CREATE TABLE MealConsumption (
	ID INT PRIMARY KEY IDENTITY(1,1),
    MealsPrepared INT NOT NULL CHECK (MealsPrepared >= 0),
    MealsGiven INT NOT NULL CHECK (MealsGiven >= 0),
    Leftovers INT NOT NULL CHECK (Leftovers >= 0),
    GroupName VARCHAR(255) NOT NULL,  -- REF to Group
    Date DATE NOT NULL,               -- REF to MealSchedule
    MealType VARCHAR(50) NOT NULL,    -- REF to MealSchedule
    FOREIGN KEY (GroupName) REFERENCES [Group](GroupName) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Date, MealType) REFERENCES MealSchedule(Date, MealType) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Ingredient table
CREATE TABLE Ingredient (
    Name VARCHAR(255) PRIMARY KEY
);
GO

-- IngredientAmount table with REF to MealRecipe and Ingredient
CREATE TABLE IngredientAmount (
    Amount INT NOT NULL CHECK (Amount >= 0),
    Unit VARCHAR(50) NOT NULL CHECK (Unit IN ('grams', 'millilitres')),
    ID INT,                             -- REF to MealRecipe
    Name VARCHAR(255),                  -- REF to Ingredient
    PRIMARY KEY (ID, Name),
    FOREIGN KEY (ID) REFERENCES MealRecipe(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Name) REFERENCES Ingredient(Name) ON DELETE CASCADE ON UPDATE CASCADE
);
GO



-- Children table with GroupName as REF to Group
CREATE TABLE Children (
    Pesel CHAR(11) PRIMARY KEY CHECK (Pesel LIKE '[0-9]%' AND LEN(Pesel) = 11),
    FullName VARCHAR(255) NOT NULL CHECK (FullName LIKE '[A-Z][a-z- ]%'),
    DateOfBirth DATE NOT NULL CHECK (DateOfBirth <= GETDATE()),
    Allergies VARCHAR(50) NULL CHECK (Allergies IS NULL OR Allergies IN ('Milk', 'Egg', 'Peanut', 'Wheat', 'Soy')),
    SpecialNeeds VARCHAR(255) CHECK (SpecialNeeds IN ('Yes', 'No')),
    ParentContact CHAR(9) NOT NULL CHECK ((ParentContact LIKE '[0-9]%') AND LEN(ParentContact) = 9),
    GroupName VARCHAR(255) NOT NULL,  -- REF to Group
    FOREIGN KEY (GroupName) REFERENCES [Group](GroupName) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Teacher table with GroupName as REF to Group
CREATE TABLE Teacher (
    Pesel CHAR(11) PRIMARY KEY CHECK (Pesel LIKE '[0-9]%' AND LEN(Pesel) = 11),
    FullName VARCHAR(255) NOT NULL CHECK (FullName LIKE '[A-Z][a-z- ]%'),
    Qualification VARCHAR(255) NOT NULL, 
    ContactInfo CHAR(9) NOT NULL CHECK ((ContactInfo LIKE '[0-9]%') AND LEN(ContactInfo) = 9),
    GroupName VARCHAR(255) NOT NULL,  -- REF to Group
    FOREIGN KEY (GroupName) REFERENCES [Group](GroupName) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
