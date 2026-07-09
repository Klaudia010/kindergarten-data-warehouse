use PrzedszkoleDW
go

-- Fill DimDates Lookup Table
-- Step a: Declare variables use in processing
Declare @StartDate date; 
Declare @EndDate date;

-- Step b:  Fill the variable with values for the range of years needed
SELECT @StartDate = '2015-01-01', @EndDate = '2035-12-31';

-- Step c:  Use a while loop to add dates to the table
Declare @DateInProcess datetime = @StartDate;

While @DateInProcess <= @EndDate
	Begin
	--Add a row into the date dimension table for this date
		Insert Into [dbo].[Date] 
		( [Date]
		, [Year]
		, [Month]
		)
		Values ( 
		  @DateInProcess -- [Date]
		  ,DATEPART(Year,@DateInProcess) -- [Year]
		  ,DATENAME(MONTH, @DateInProcess) -- [Month]
		);  
		-- Add a day and loop again
		Set @DateInProcess = DateAdd(d, 1, @DateInProcess);
	End
go

