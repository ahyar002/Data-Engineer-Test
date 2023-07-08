
--- 1. Create script to create table for each object

CREATE TABLE Employee (
    Id INTEGER PRIMARY KEY IDENTITY(1,1),
    EmployeeId NVARCHAR(10) NOT NULL UNIQUE,
    FullName NVARCHAR(100) NOT NULL,
    BirthDate DATE NOT NULL,
    Address NVARCHAR(500)
);


CREATE TABLE PositionHistory (
    Id INTEGER PRIMARY KEY IDENTITY(1,1),
    PosId NVARCHAR(10) NOT NULL,
    PosTitle NVARCHAR(100) NOT NULL,
    EmployeeId NVARCHAR(10) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);

-- 2. Create insert script to inserting data into each table

INSERT INTO Employee(EmployeeId, FullName, BirthDate, Address)
VALUES
    ('10105001', 'Ali Anton', '1982-08-19', 'Jakarta Utara'),
    ('10105002', 'Rara Siva', '1982-01-01', 'Mandalika'),
    ('10105003', 'Rini Aini', '1982-02-20', 'Sumbawa Besar'),
    ('10105004', 'Budi', '1982-02-22', 'Mataram Kota');


INSERT INTO PositionHistory (PosId, PosTitle, EmployeeId, StartDate, EndDate)
VALUES
    ('50000', 'IT Manager', '10105001', '2022-01-01', '2022-02-28'),
    ('50001', 'IT Sr. Manager', '10105001', '2022-03-01', '2022-12-31'),
    ('50002', 'Programmer Analyst', '10105002', '2022-01-01', '2022-02-28'),
    ('50003', 'Sr. Programmer Analyst', '10105002', '2022-03-01', '2022-12-31'),
    ('50004', 'IT Admin', '10105003', '2022-01-01', '2022-02-28'),
    ('50005', 'IT Secretary', '10105003', '2022-03-01', '2022-12-31');


-- 3. Create query to display all employee (EmployeeId, FullName, BirthDate, Address) data with their
--current position information (PosId, PosTitle, EmployeeId, StartDate, EndDate).

WITH temp_table AS (
    SELECT t1.EmployeeId, FullName, BirthDate, Address, PosId, PosTitle, StartDate, EndDate, 
	DENSE_RANK() OVER (PARTITION BY FullName ORDER BY StartDate DESC) AS ranking
    FROM Employee t1
    JOIN PositionHistory t2 ON t1.EmployeeId = t2.EmployeeId
)
SELECT EmployeeId, FullName, BirthDate, Address, PosId, PosTitle, StartDate, EndDate
FROM temp_table
WHERE ranking = 1;
