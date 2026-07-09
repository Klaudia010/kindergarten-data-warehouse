USE PrzedszkoleDW;
GO

IF OBJECT_ID('vETLDimChildrenData') IS NOT NULL DROP VIEW vETLDimChildrenData;
GO

-- Create a staging VIEW
CREATE VIEW vETLDimChildrenData AS
SELECT DISTINCT
    [Pesel],
    [FullName],
    CASE 
        WHEN DATEDIFF(YEAR, [DateOfBirth], GETDATE()) = 3 THEN '3yr'
        WHEN DATEDIFF(YEAR, [DateOfBirth], GETDATE()) = 4 THEN '4yr'
        WHEN DATEDIFF(YEAR, [DateOfBirth], GETDATE()) = 5 THEN '5yr'
        WHEN DATEDIFF(YEAR, [DateOfBirth], GETDATE()) = 6 THEN '6yr'
        ELSE NULL -- Or 'Invalid' if preferred
    END AS [Age],
    CASE WHEN [Allergies] IS NOT NULL THEN 'yes' ELSE 'no' END AS [Allergies],
    CASE WHEN [SpecialNeeds] IS NOT NULL THEN 'yes' ELSE 'no' END AS [SpecialNeeds],
	[GroupName]
FROM Przedszkole.dbo.Children;
GO

-- Merge into DW Children table
MERGE INTO PrzedszkoleDW.dbo.Children AS TT
USING vETLDimChildrenData AS ST
ON TT.Pesel = ST.Pesel
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Pesel, FullName, Age, Allergies, SpecialNeeds, GroupName)
    VALUES (ST.Pesel, ST.FullName, ST.Age, ST.Allergies, ST.SpecialNeeds, ST.GroupName)
;
GO

-- Drop the staging view
DROP VIEW vETLDimChildrenData;
