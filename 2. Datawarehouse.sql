USE master
GO

-- create datawarehouse database
CREATE DATABASE datawarehouse

-- use datawarehouse database
GO
USE datawarehouse
GO

-- create dim and fact table 
CREATE TABLE dbo.DimEmployee (
    EmployeeKey INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    EmployeeId NVARCHAR(10),
    FullName NVARCHAR(100),
    BirthDate DATE,
    Address NVARCHAR(500)
);


CREATE TABLE dbo.DimPosition (
    PositionKey INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    PosId NVARCHAR(10),
    PosTitle NVARCHAR(100),
	StartDate Date,
	EndDate Date
);

CREATE TABLE dbo.DimTraining (
    TrainingKey INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    TrainingName NVARCHAR(100),
	TrainingDate Date,
	CompletionStatus NVARCHAR(50)
);

CREATE TABLE dbo.DimDate (
    DateKey INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    DateValue DATE,
    Year INT,
    Month INT,
    Day INT,
    Weekday INT,
    MonthName NVARCHAR(20),
    DayOfWeekName NVARCHAR(20),
);

CREATE TABLE FactlessTable (
    FactlessTableKey INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    EmployeeKey INT,
    PositionKey INT,
    TrainingKey INT,
    FOREIGN KEY (EmployeeKey) REFERENCES DimEmployee(EmployeeKey),
    FOREIGN KEY (PositionKey) REFERENCES DimPosition(PositionKey),
    FOREIGN KEY (TrainingKey) REFERENCES DimTraining(TrainingKey)
);

end

/****** Object:  StoredProcedure [dbo].[Refresh_DimEmployee] *****/

CREATE PROCEDURE dbo.[Refresh_DimEmployee]
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO dbo.DimEmployee (EmployeeId, FullName, BirthDate, Address)
    SELECT e.EmployeeId, e.FullName, e.BirthDate, e.Address
    FROM [Staging].emp.Staging_Employee e
    LEFT JOIN dbo.DimEmployee de ON e.EmployeeId = de.EmployeeId
    WHERE de.EmployeeId IS NULL;

    UPDATE de
    SET de.FullName = e.FullName,
        de.BirthDate = e.BirthDate,
        de.Address = e.Address
    FROM dbo.DimEmployee de
    INNER JOIN [Staging].emp.Staging_Employee e ON e.EmployeeId = de.EmployeeId;

    SET NOCOUNT OFF
END;

/****** Object:  StoredProcedure [dbo].[Refresh_DimPosition] *****/

CREATE PROCEDURE [dbo].[Refresh_DimPosition]
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO dbo.DimPosition (PosId, PosTitle, StartDate, EndDate)
    SELECT p.PosId, p.PosTitle, p.StartDate, p.EndDate
    FROM [Staging].Staging_PositionHistory p
    LEFT JOIN dbo.DimPosition dp ON p.PosId = dp.PosId
    WHERE dp.PosId IS NULL;

    UPDATE dp
    SET dp.PosTitle = p.PosTitle,
        dp.StartDate = p.StartDate,
        dp.EndDate = p.EndDate
    FROM dbo.DimPosition dp
    INNER JOIN [Staging].Staging_PositionHistory p ON p.PosId = dp.PosId;

    SET NOCOUNT OFF
END;

/****** Object:  StoredProcedure [dbo].[Refresh_DimTraining] *****/

CREATE PROCEDURE [dbo].[Refresh_DimTraining]
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO dbo.DimTraining (TrainingName, TrainingDate, CompletionStatus)
    SELECT t.TrainingName, t.TrainingDate, t.CompletionStatus
    FROM [Staging].Staging_TrainingHistory t
    LEFT JOIN dbo.DimTraining dt ON t.TrainingName = dt.TrainingName
    WHERE dt.TrainingName IS NULL;

    UPDATE dt
    SET dt.TrainingDate = t.TrainingDate,
        dt.CompletionStatus = t.CompletionStatus
    FROM dbo.DimTraining dt
    INNER JOIN [Staging].Staging_TrainingHistory t ON t.TrainingName = dt.TrainingName;

    SET NOCOUNT OFF
END;

/****** Object:  StoredProcedure [dbo].[Refresh_DimDate] *****/
CREATE PROCEDURE [dbo].[Generate_DimDate]
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables to store the start and end dates
    DECLARE @StartDate DATE = '2022-01-01';
    DECLARE @EndDate DATE = '2122-12-31';

    -- Temporary table to hold the generated dates
    CREATE TABLE #TempDimDate (
        DateKey INT PRIMARY KEY IDENTITY(1, 1),
        DateValue DATE,
        [Year] INT,
        [Month] INT,
        [Day] INT,
        Weekday INT,
        MonthName NVARCHAR(20),
        DayOfWeekName NVARCHAR(20)
    );

    -- Generate dates and populate the temporary table
    WHILE @StartDate <= @EndDate
    BEGIN
        INSERT INTO #TempDimDate (DateValue, [Year], [Month], [Day], Weekday, MonthName, DayOfWeekName)
        SELECT
            @StartDate,
            YEAR(@StartDate),
            MONTH(@StartDate),
            DAY(@StartDate),
            DATEPART(WEEKDAY, @StartDate),
            DATENAME(MONTH, @StartDate),
            DATENAME(WEEKDAY, @StartDate);

        SET @StartDate = DATEADD(DAY, 1, @StartDate);
    END;

    -- Insert the generated dates into the DimDate table
    INSERT INTO dbo.DimDate (DateValue, [Year], [Month], [Day], Weekday, MonthName, DayOfWeekName)
    SELECT DateValue, [Year], [Month], [Day], Weekday, MonthName, DayOfWeekName
    FROM #TempDimDate;

    -- Clean up temporary table
    DROP TABLE #TempDimDate;

    SET NOCOUNT OFF;
END;


/****** Object:  StoredProcedure [dbo].[Refresh_FactlessTable] *****/
CREATE PROCEDURE [dbo].[Refresh_FactlessTable]
AS
BEGIN
    SET NOCOUNT ON;

    -- Update existing data in the FactlessTable
    UPDATE ft
    SET ft.EmployeeKey = de.EmployeeKey,
        ft.PositionKey = dp.PositionKey,
        ft.TrainingKey = dt.TrainingKey
		ft.DateKey = dd.DateKey;
    FROM FactlessTable ft
    LEFT JOIN dbo.DimEmployee de ON ft.EmployeeKey = de.EmployeeKey
    LEFT JOIN dbo.DimPosition dp ON ft.PositionKey = dp.PositionKey
    LEFT JOIN dbo.DimTraining dt ON ft.TrainingKey = dt.TrainingKey;
	LEFT JOIN dbo.DimDate dd ON ft.DareKey = dd.DateKey;
	WHERE
        de.EmployeeKey IS NULL
        AND dp.PositionKey IS NULL
        AND dt.TrainingKey IS NULL
		AND dd.DateKey IS NULL;

    SET NOCOUNT OFF;
END;
