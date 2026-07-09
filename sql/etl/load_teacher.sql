USE PrzedszkoleDW;
GO

IF OBJECT_ID('vETLDimTeacherData') IS NOT NULL DROP VIEW vETLDimTeacherData;
GO

CREATE VIEW vETLDimTeacherData AS
SELECT DISTINCT
    [Pesel],
    [FullName],
    [Qualification],
    [GroupName]
FROM Przedszkole.dbo.Teacher;
GO

-- 1. Expire old rows where qualification changed
UPDATE T
SET T.Date_new_qualification = GETDATE()
FROM PrzedszkoleDW.dbo.Teacher T
JOIN vETLDimTeacherData S
    ON T.Pesel = S.Pesel
WHERE T.Date_new_qualification IS NULL
  AND T.Qualification <> S.Qualification
  ;

-- 2. Insert new records for changed or new teachers
INSERT INTO PrzedszkoleDW.dbo.Teacher
    (Pesel, FullName, Qualification, Date_first_qualification, Date_new_qualification, GroupName)
SELECT 
    S.Pesel,
    S.FullName,
    S.Qualification,
    GETDATE(),       -- New version starts now
    NULL,            -- Open-ended, current
    S.GroupName
FROM vETLDimTeacherData S
LEFT JOIN PrzedszkoleDW.dbo.Teacher T
    ON T.Pesel = S.Pesel
   AND T.Qualification = S.Qualification
   AND T.FullName = S.FullName
   AND T.GroupName = S.GroupName
   AND T.Date_new_qualification IS NULL
WHERE T.Pesel IS NULL; -- Only insert if current version doesn't exist

-- 3. Drop the staging view
DROP VIEW vETLDimTeacherData;
GO
