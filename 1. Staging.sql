USE master
GO

-- create staging database
CREATE DATABASE Staging

-- use staging database
GO
USE Staging
GO

-- create shcema to better distisnguish source data
CREATE SCHEMA emp
GO

CREATE SCHEMA hist
GO

CREATE SCHEMA train
GO

-- Create the staging table for Employee
CREATE TABLE emp.Staging_Employee (
    Id INTEGER,
    EmployeeId NVARCHAR(10),
    FullName NVARCHAR(100),
    BirthDate DATE,
    Address NVARCHAR(500)
);

-- Create the staging table for PositionHistory
CREATE TABLE hist.Staging_PositionHistory (
    Id INTEGER,
    PosId NVARCHAR(10),
    PosTitle NVARCHAR(100),
    EmployeeId NVARCHAR(10),
    StartDate DATE,
    EndDate DATE
);

-- Create the staging table for TrainingHistory
CREATE TABLE train.Staging_TrainingHistory (
    TrainingId INTEGER,
    EmployeeId NVARCHAR(10),
    TrainingName NVARCHAR(100),
    TrainingDate DATE,
    CompletionStatus NVARCHAR(50)
);


