USE PrzedszkoleDW;
GO

IF OBJECT_ID('vETLDimGroupData') IS NOT NULL DROP VIEW vETLDimGroupData;
GO

-- Create a staging VIEW
CREATE VIEW vETLDimGroupData AS
SELECT DISTINCT
    [GroupName],
    CASE
        WHEN GroupName LIKE '%_3yr' THEN '3-4yr'
        WHEN GroupName LIKE '%_4yr' THEN '4-5yr'
        WHEN GroupName LIKE '%_5yr' THEN '5-6yr'
        WHEN GroupName LIKE '%_6yr' THEN '6-7yr'
    END AS [Age]
FROM Przedszkole.dbo.[Group];
GO

-- Merge into DW Group table
MERGE INTO PrzedszkoleDW.dbo.[Group] AS TT
USING vETLDimGroupData AS ST
ON TT.GroupName = ST.GroupName
WHEN NOT MATCHED BY TARGET THEN			--if doesnt exist in target (DW) than add
    INSERT (GroupName, Age)
    VALUES (ST.GroupName, ST.Age)
;
GO

-- Drop the staging view
DROP VIEW vETLDimGroupData;
