-- SUBMISSION BY: SOUPARNA MAITY
-- POWER BI PROJECT: BANK CRM ANALYSIS
-- TOOLS USED: POWER BI DESKTOP, MYSQL WORKBENCH, MS-OFFICE
-- BATCH: PROFESSIONAL CERTIFICATE COURSE IN DATA SCIENCE - MAY 2025

-- SCHEMA
USE BankChurnDB;

select * FROM activecustomer;
select * FROM creditcard;
select * FROM exitcustomer;
select * FROM gender;
select * FROM geography;
select * FROM CustomerInfo;
select * FROM bank_churn;

-- OBJECTIVE QUESTIONS

-- OBJECTIVE QUESTION 1 : What is the distribution of account balances across different regions?

Select
	g.GeographyLocation as Region,
    Round(Count(bc.Balance),2) as NumberOfCustomers,
    Round(SUM(bc.Balance),2) as TotalBalance,
    Round(AVG(bc.Balance),2) as AverageBalance
From bank_churn bc 
Inner Join customerinfo c on c.CustomerId = bc.CustomerId
Inner Join geography g on c.GeographyID = g.GeographyID
Group By g.GeographyLocation
Order By TotalBalance DESC;

-- OBJECTIVE QUESTION 2 : Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year.

WITH RankedSalaries AS (
    SELECT
        CustomerId,
        Surname,
        EstimatedSalary,
        Bank_DOJ,
        DENSE_RANK() OVER (ORDER BY EstimatedSalary DESC) AS SalaryRank
    FROM CustomerInfo
    WHERE MONTH(Bank_DOJ) IN (1, 2, 3)
)
SELECT * 
FROM RankedSalaries
WHERE SalaryRank <= 5
ORDER BY SalaryRank;

-- OBJECTIVE QUESTION 3 : Calculate the average number of products used by customers who have a credit card.

SELECT ROUND(AVG(NumOfProducts), 2) AS AverageNumberOfProducts
FROM Bank_Churn
WHERE HasCrCard = 1;

-- OBJECTIVE QUESTION 4 : Determine the churn rate by gender for the most recent year in the dataset

WITH RecentYearData AS (
    SELECT MAX(YEAR(Bank_DOJ)) AS MostRecentYear
    FROM CustomerInfo
),
GenderChurn AS (
    SELECT 
        g.GenderCategory AS Gender,
        COUNT(CASE WHEN b.Exited = 1 THEN 1 END) AS ChurnedCustomers,
        COUNT(*) AS TotalCustomers
    FROM Bank_Churn b
    JOIN CustomerInfo c ON b.CustomerId = c.CustomerId
    JOIN Gender g ON c.GenderID = g.GenderID
    JOIN RecentYearData r ON YEAR(c.Bank_DOJ) = r.MostRecentYear
    GROUP BY g.GenderCategory
)
SELECT 
    Gender,
    ChurnedCustomers,
    TotalCustomers,
    ROUND((ChurnedCustomers / TotalCustomers) * 100, 2) AS ChurnRate
FROM GenderChurn;

-- OBJECTIVE QUESTION 5 : Compare the average credit score of customers who have exited and those who remain. 

SELECT 
    e.ExitID,
    CASE
        WHEN e.ExitID = 0 THEN 'Retained'
        ELSE 'Exited'
    END AS LoyaltyStatus,
    ROUND(AVG(b.CreditScore), 0) AS AvgCreditScore
FROM ExitCustomer e
LEFT JOIN Bank_Churn b 
    ON e.ExitID = b.Exited
GROUP BY e.ExitID;

-- OBJECTIVE QUESTION 6 : Which gender has a higher average estimated salary, and how does it relate to the number of active accounts?

SELECT
    g.GenderCategory,
    ROUND(AVG(c.EstimatedSalary), 0) AS AvgEstimatedSalary,
    COUNT(a.ActiveID) AS CountOfActiveAccounts
FROM Gender g
INNER JOIN CustomerInfo c ON c.GenderID = g.GenderID
INNER JOIN Bank_Churn b ON b.CustomerId = c.CustomerId
INNER JOIN ActiveCustomer a ON b.IsActiveMember = a.ActiveID
GROUP BY g.GenderCategory
ORDER BY AvgEstimatedSalary DESC;

-- OBJECTIVE QUESTION 7 : Segment the customers based on their credit score and identify the segment with the highest exit rate.

SELECT  
    CASE  
        WHEN CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
        WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
        WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
        WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
    END AS CreditScoreSegment,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS ExitedCustomers,
    ROUND((SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100, 2) AS ExitRate
FROM Bank_Churn
GROUP BY CreditScoreSegment
ORDER BY ExitRate DESC;

-- OBJECTIVE QUESTION 8 : Find out which geographic region has the highest number of active customers with a tenure greater than 5 years.

SELECT 
    g.GeographyLocation,
    COUNT(*) AS NoOfActiveCustomers
FROM Geography g
INNER JOIN CustomerInfo c ON c.GeographyID = g.GeographyID
INNER JOIN Bank_Churn b ON b.CustomerId = c.CustomerId
WHERE b.IsActiveMember = 1
  AND b.Tenure > 5
GROUP BY g.GeographyLocation
ORDER BY NoOfActiveCustomers DESC;

-- OBJECTIVE QUESTION 9 : What is the impact of having a credit card on customer churn, based on the available data?

SELECT 
    CASE
        WHEN HasCrCard = 1 THEN 'Credit Card Holder'
        ELSE 'No Credit Card'
    END AS CreditCardStatus,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS ExitedCustomers,
    ROUND((SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100, 2) AS ChurnRate
FROM Bank_Churn
GROUP BY CreditCardStatus
ORDER BY ChurnRate DESC;

-- OBJECTIVE QUESTION 10 : For customers who have exited, what is the most common number of products they have used?

SELECT 
    NumOfProducts,
    COUNT(CustomerId) AS TotalCustomers
FROM Bank_Churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY TotalCustomers DESC;

-- OBJECTIVE QUESTION 11 : Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly)

-- Yearly trend
SELECT
    YEAR(Bank_DOJ) AS Year,
    COUNT(*) AS NewCustomers
FROM CustomerInfo
GROUP BY YEAR(Bank_DOJ)
ORDER BY Year;

-- Monthly trend
SELECT
    YEAR(Bank_DOJ) AS Year,
    MONTH(Bank_DOJ) AS Month,
    COUNT(*) AS NewCustomers
FROM CustomerInfo
GROUP BY YEAR(Bank_DOJ), MONTH(Bank_DOJ)
ORDER BY Year, Month;

-- OBJECTIVE QUESTION 12 : Analyze the relationship between the number of products and the account balance for customers who have exited

SELECT 
    NumOfProducts,
    COUNT(CustomerId) AS TotalCustomers,
    ROUND(SUM(Balance), 2) AS TotalBalance
FROM Bank_Churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY TotalBalance DESC;

-- OBJECTIVE QUESTION 13 : Identify any potential outliers in terms of balance among customers who have remained with the bank.
-- Calculate Q1, Q3, & IQR

SELECT COUNT(*) AS RetainedCustomers
FROM BankChurnDB.Bank_Churn
WHERE Exited = 0;
WITH ordered AS (
    SELECT 
        Balance,
        ROW_NUMBER() OVER (ORDER BY Balance) AS rn,
        COUNT(*) OVER() AS total_rows
    FROM Bank_Churn
    WHERE Exited = 0
),
quartiles AS (
    SELECT 
        MAX(CASE WHEN rn = CEIL(0.25 * total_rows) THEN Balance END) AS Q1,
        MAX(CASE WHEN rn = CEIL(0.75 * total_rows) THEN Balance END) AS Q3
    FROM ordered
)
SELECT 
    Q1, 
    Q3,
    (Q3 - Q1) AS IQR,
    (Q1 - 1.5 * (Q3 - Q1)) AS LowerBound,
    (Q3 + 1.5 * (Q3 - Q1)) AS UpperBound
FROM quartiles;
-- Identify Outlier Customers

WITH ordered AS (
    SELECT 
        CustomerId,
        Balance,
        ROW_NUMBER() OVER (ORDER BY Balance) AS rn,
        COUNT(*) OVER() AS total_rows
    FROM Bank_Churn
    WHERE Exited = 0
),
quartiles AS (
    SELECT 
        MAX(CASE WHEN rn = CEIL(0.25 * total_rows) THEN Balance END) AS Q1,
        MAX(CASE WHEN rn = CEIL(0.75 * total_rows) THEN Balance END) AS Q3
    FROM ordered
),
calc AS (
    SELECT
        o.CustomerId,
        o.Balance,
        q.Q1,
        q.Q3,
        (q.Q3 - q.Q1) AS IQR,
        (q.Q1 - 1.5 * (q.Q3 - q.Q1)) AS lower_bound,
        (q.Q3 + 1.5 * (q.Q3 - q.Q1)) AS upper_bound
    FROM ordered o CROSS JOIN quartiles q
)
SELECT 
    CustomerId,
    Balance
FROM calc
WHERE Balance < lower_bound 
   OR Balance > upper_bound
ORDER BY Balance DESC;

-- OBJECTIVE QUESTION 14  : How many different tables are given in the dataset, out of these tables which table only consists of categorical variables? 

-- The dataset consists of 7 tables. Out of these, the following 5 tables contain only categorical variables:

-- 1.	activecustomer
-- o	ActiveID (INT)
-- o	ActiveCategory (TEXT)

-- 2.	creditcard
-- o	CreditID (INT)
-- o	Category (TEXT)

-- 3.	exitcustomer
-- o	ExitID (INT)
-- o	ExitCategory (TEXT)

-- 4.	gender
-- o	GenderID (INT)
-- o	GenderCategory (TEXT)

-- 5.	geography
-- o	GeographyID (INT)
-- o	GeographyLocation (TEXT)


-- OBJECTIVE QUESTION 15 : Write a query to find out the gender-wise average income of males and females in each geography id. 
-- Also, rank the gender according to the average value. 

select * from customerinfo;
select * from Gender;
select * from Geography;

With cte1 as (
	Select 
		geo.GeographyLocation,
		g.GenderCategory,
		Round(Avg(c.EstimatedSalary),2) as AverageIncome
	from customerinfo c 
	inner join Gender g on c.GenderID = g.GenderID
	inner join Geography geo on c.GeographyID  = geo.GeographyID
	Group by geo.GeographyLocation, g.GenderCategory
)
Select 
	GeographyLocation,
    GenderCategory,
    AverageIncome,
    dense_rank() over (Partition by GenderCategory order by AverageIncome desc) as GenderRank
From cte1
Order by AverageIncome desc;

-- OBJECTIVE QUESTION 16 : Find out the average tenure of the people who have exited in each age bracket (18–30, 30–50, 50+)

SELECT 
    CASE 
        WHEN c.Age BETWEEN 18 AND 30 THEN '18–30'
        WHEN c.Age BETWEEN 31 AND 50 THEN '30–50'
        WHEN c.Age > 50 THEN '50+'
    END AS AgeBracket,
    ROUND(AVG(b.Tenure), 2) AS AvgTenure
FROM CustomerInfo c
INNER JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
WHERE b.Exited = 1 
GROUP BY AgeBracket
ORDER BY AgeBracket;

-- OBJECTIVE QUESTION 17 : Is there any direct correlation between salary and the balance of the customers? 
-- And is it different for people who have exited or not?. 

select * from customerinfo;
select * from bank_churn;
select * from exitcustomer;

-- (i): Salary and Balance of customers who have exited

SELECT 
    c.CustomerId,
    c.Surname AS CustomerName,
    c.EstimatedSalary AS CustomerSalary,
    b.Balance AS CustomerAccountBalance,
    e.ExitCategory
FROM CustomerInfo c 
INNER JOIN Bank_Churn b ON b.CustomerId = c.CustomerId
INNER JOIN ExitCustomer e ON e.ExitID = b.Exited
WHERE b.Exited = 1
ORDER BY CustomerAccountBalance DESC;

-- (ii): Salary and Balance of customers who are retained

SELECT 
    c.CustomerId,
    c.Surname AS CustomerName,
    c.EstimatedSalary AS CustomerSalary,
    b.Balance AS CustomerAccountBalance,
    e.ExitCategory
FROM CustomerInfo c 
INNER JOIN Bank_Churn b ON b.CustomerId = c.CustomerId
INNER JOIN ExitCustomer e ON e.ExitID = b.Exited
WHERE b.Exited = 0
ORDER BY CustomerAccountBalance DESC;

-- Correlation between Salary and Balance (overall)

SELECT 
    (SUM((c.EstimatedSalary - avg_s)*(b.Balance - avg_b)) /
    (SQRT(SUM(POW(c.EstimatedSalary - avg_s,2)) * SUM(POW(b.Balance - avg_b,2))))) AS Correlation
FROM CustomerInfo c
JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
CROSS JOIN (
    SELECT 
        AVG(c.EstimatedSalary) AS avg_s,
        AVG(b.Balance) AS avg_b
    FROM CustomerInfo c
    JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
) AS avgs;

-- OBJECTIVE QUESTION 18 : Is there any correlation between the salary and the credit score of customers?

SELECT 
    c.CustomerId,
    c.Surname AS CustomerName,
    c.EstimatedSalary AS CustomerSalary,
    b.CreditScore
FROM CustomerInfo c 
INNER JOIN Bank_Churn b ON b.CustomerId = c.CustomerId;

-- Calculate correlation between EstimatedSalary and CreditScore
SELECT 
    (SUM((c.EstimatedSalary - avg_s)*(b.CreditScore - avg_cs)) /
    (SQRT(SUM(POW(c.EstimatedSalary - avg_s,2)) * SUM(POW(b.CreditScore - avg_cs,2))))) AS Correlation
FROM CustomerInfo c
JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
CROSS JOIN (
    SELECT 
        AVG(c.EstimatedSalary) AS avg_s,
        AVG(b.CreditScore) AS avg_cs
    FROM CustomerInfo c
    JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
) AS avgs;

-- OBJECTIVE QUESTION 19 : Rank each bucket of credit score as per the number of customers who have churned.

WITH CreditScoreBuckets AS (
    SELECT 
        CASE
            WHEN b.CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
            WHEN b.CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
            WHEN b.CreditScore BETWEEN 670 AND 739 THEN 'Good'
            WHEN b.CreditScore BETWEEN 580 AND 669 THEN 'Fair'
            WHEN b.CreditScore BETWEEN 300 AND 579 THEN 'Poor'
        END AS CreditScoreBucket,
        COUNT(b.CustomerId) AS ChurnedCustomers
    FROM Bank_Churn b
    WHERE b.Exited = 1
    GROUP BY CreditScoreBucket
)
SELECT 
    CreditScoreBucket,
    ChurnedCustomers,
    DENSE_RANK() OVER (ORDER BY ChurnedCustomers DESC) AS ChurnRank
FROM CreditScoreBuckets
ORDER BY ChurnedCustomers DESC;

-- OBJECTIVE QUESTION 20 : According to the age buckets find the number of customers who have a credit card. 
-- Also retrieve those buckets that have lesser than average number of credit cards per bucket. 
select * from customerinfo;
select * from bank_churn;

-- (i): Number of customers who have a credit card per each Age Bucket

SELECT 
    CASE 
        WHEN c.Age BETWEEN 18 AND 30 THEN '18–30'
        WHEN c.Age BETWEEN 31 AND 50 THEN '31–50'
        ELSE '50+'
    END AS AgeBucket,
    COUNT(*) AS CreditCardCustomers
FROM CustomerInfo c
INNER JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
WHERE b.HasCrCard = 1
GROUP BY AgeBucket
ORDER BY AgeBucket;

-- (ii): Find age buckets below the average number of credit card holders

WITH AgeBuckets AS (
    SELECT 
        CASE 
            WHEN c.Age BETWEEN 18 AND 30 THEN '18–30'
            WHEN c.Age BETWEEN 31 AND 50 THEN '31–50'
            ELSE '50+'
        END AS AgeBucket,
        COUNT(*) AS CreditCardCustomers
    FROM CustomerInfo c
    INNER JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
    WHERE b.HasCrCard = 1
    GROUP BY AgeBucket
),
AvgCreditCards AS (
    SELECT AVG(CreditCardCustomers) AS AvgCreditCardsPerBucket
    FROM AgeBuckets
)
SELECT 
    ab.AgeBucket, 
    ab.CreditCardCustomers
FROM AgeBuckets ab
CROSS JOIN AvgCreditCards avg_cc
WHERE ab.CreditCardCustomers < avg_cc.AvgCreditCardsPerBucket
ORDER BY ab.CreditCardCustomers ASC;

-- OBJECTIVE QUESTION 21 :
-- Rank the Locations as per the number of people who have churned the bank and their average balance.

WITH LocationChurnData AS (
    SELECT 
        geo.GeographyID,
        geo.GeographyLocation,
        COUNT(b.CustomerID) AS ChurnedCustomers,
        ROUND(AVG(b.Balance), 2) AS AvgBalance
    FROM Bank_Churn b
    JOIN CustomerInfo c ON c.CustomerID = b.CustomerID
    JOIN Geography geo ON geo.GeographyID = c.GeographyID
    WHERE b.Exited = 1
    GROUP BY geo.GeographyID, geo.GeographyLocation
)
SELECT
    GeographyID,
    GeographyLocation,
    ChurnedCustomers,
    DENSE_RANK() OVER (ORDER BY ChurnedCustomers DESC) AS ChurnRank,
    AvgBalance,
    DENSE_RANK() OVER (ORDER BY AvgBalance DESC) AS BalanceRank
FROM LocationChurnData
ORDER BY ChurnedCustomers DESC, AvgBalance DESC;

-- OBJECTIVE QUESTION 22 : As we can see that the “CustomerInfo” table has the CustomerID and Surname, 
-- now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, 
-- come up with a column where the format is “CustomerID_Surname”. 
	
Select 
    CustomerID, 
    Surname,
    Concat(CustomerID, '_', Surname) As CustomerID_Surname
From customerinfo;

-- OBJECTIVE QUESTION 23 :
-- Retrieve ExitCategory from ExitCustomer table using subquery (no JOIN)

SELECT 
    b.CustomerId,
    b.CreditScore,
    b.Balance,
    b.Exited,
    (
        SELECT e.ExitCategory
        FROM ExitCustomer e
        WHERE e.ExitID = b.Exited
    ) AS ExitCategory
FROM Bank_Churn b
ORDER BY b.Balance DESC;

-- OBJECTIVE QUESTION 24 : Were there any missing values in the data, using which tool did you replace them and what are the ways to handle them? 

-- (i) Checking if Bank_Churn table has NULL values
SELECT 
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS Missing_CustomerID,
    SUM(CASE WHEN CreditScore IS NULL THEN 1 ELSE 0 END) AS Missing_CreditScore,
    SUM(CASE WHEN Tenure IS NULL THEN 1 ELSE 0 END) AS Missing_Tenure,
    SUM(CASE WHEN Balance IS NULL THEN 1 ELSE 0 END) AS Missing_Balance,
    SUM(CASE WHEN NumOfProducts IS NULL THEN 1 ELSE 0 END) AS Missing_NumOfProducts,
    SUM(CASE WHEN HasCrCard IS NULL THEN 1 ELSE 0 END) AS Missing_HasCrCard,
    SUM(CASE WHEN IsActiveMember IS NULL THEN 1 ELSE 0 END) AS Missing_IsActiveMember,
    SUM(CASE WHEN Exited IS NULL THEN 1 ELSE 0 END) AS Missing_Exited
FROM Bank_Churn;

-- (ii) Checking if CustomerInfo table has NULL values
SELECT 
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS Missing_CustomerID,
    SUM(CASE WHEN Surname IS NULL THEN 1 ELSE 0 END) AS Missing_Surname,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Missing_Age,
    SUM(CASE WHEN GenderID IS NULL THEN 1 ELSE 0 END) AS Missing_GenderID,
    SUM(CASE WHEN EstimatedSalary IS NULL THEN 1 ELSE 0 END) AS Missing_EstimatedSalary,
    SUM(CASE WHEN GeographyID IS NULL THEN 1 ELSE 0 END) AS Missing_GeographyID,
    SUM(CASE WHEN Bank_DOJ IS NULL THEN 1 ELSE 0 END) AS Missing_Bank_DOJ
FROM CustomerInfo;

-- OBJECTIVE QUESTION 25 :
-- Get Customer IDs, Last Names, and Active Status for customers whose surname ends with "on"

SELECT 
    c.CustomerId,
    c.Surname AS LastName,
    a.ActiveCategory
FROM CustomerInfo c
INNER JOIN Bank_Churn b ON c.CustomerId = b.CustomerId
INNER JOIN ActiveCustomer a ON a.ActiveID = b.IsActiveMember
WHERE c.Surname LIKE '%on'
ORDER BY c.Surname;

-- OBJECTIVE QUESTION 26 :
-- Check for data discrepancies between IsActiveMember and Exited columns

SELECT *
FROM Bank_Churn
WHERE IsActiveMember = 0     -- Inactive
  AND Exited = 0;            -- But still marked as "Not Exited"

-- Subjective QUESTIONS

-- SUBJECTIVE QUESTION 1 : What patterns can be observed in the spending habits of long-term customers compared to new customers, 
-- and what might these patterns suggest about customer loyalty? 
SELECT 
    CASE 
        WHEN b.Tenure > 3 THEN 'Long-Term'
        ELSE 'New'
    END AS CustomerType,
    Round(AVG(b.Balance),2) AS AvgBalance,
    COUNT(b.CustomerID) AS NumberOfCustomers,
    Round(AVG(b.NumOfProducts),2) AS AvgProducts,
    Round(AVG(b.CreditScore),2) AS AvgCreditScore
FROM bank_churn b
GROUP BY CustomerType
ORDER BY CustomerType DESC;

-- SUBJECTIVE QUESTION 2 : Which bank products or services are most commonly used together, and how might this influence cross-selling strategies?
    
WITH ProductUsage AS (
	SELECT 
		CustomerID, 
        NumOfProducts,
		CASE 
			WHEN NumOfProducts = 1 THEN 'SavingsAccount'
			WHEN NumOfProducts = 2 THEN 'SavingsAccount, CreditCard'
			WHEN NumOfProducts = 3 THEN 'SavingsAccount, CreditCard, Loan'
			WHEN NumOfProducts >= 4 THEN 'SavingsAccount, CreditCard, Loan, InvestmentAccount'
		END AS ProductCombination
	FROM bank_churn
),
CombinationAnalysis AS (
	SELECT 
		ProductCombination, 
		COUNT(CustomerID) AS CustomerCount
	FROM ProductUsage
	GROUP BY ProductCombination
)
SELECT 
	CustomerCount,
    ProductCombination,
    ROUND(CustomerCount/(SELECT COUNT(*) FROM bank_churn) * 100, 2) AS PercentageOfCustomers
FROM CombinationAnalysis;

-- SUBJECTIVE QUESTION 3 :
-- Correlation between geographic regions and churn/active customer behavior

SELECT 
    geo.GeographyLocation,
    COUNT(CASE WHEN b.Exited = 1 THEN 1 END) AS ChurnedCustomers,     -- customers who left
    COUNT(CASE WHEN b.IsActiveMember = 1 THEN 1 END) AS ActiveCustomers, -- active accounts
    COUNT(*) AS TotalCustomers,
    ROUND((COUNT(CASE WHEN b.Exited = 1 THEN 1 END) / COUNT(*)) * 100, 2) AS ChurnRate,
    ROUND((COUNT(CASE WHEN b.IsActiveMember = 1 THEN 1 END) / COUNT(*)) * 100, 2) AS ActiveRate
FROM Geography geo
JOIN CustomerInfo c ON geo.GeographyID = c.GeographyID
JOIN Bank_Churn b ON c.CustomerID = b.CustomerID
GROUP BY geo.GeographyLocation
ORDER BY ChurnRate DESC;

-- SUBJECTIVE QUESTION 4 :
-- Identify demographic segments that pose the highest financial risk to the bank

SELECT 
    g.GeographyLocation, 
    c.Surname, 
    c.Age, 
    c.EstimatedSalary, 
    bc.CreditScore, 
    bc.Tenure, 
    bc.Balance, 
    bc.NumOfProducts, 
    COUNT(DISTINCT bc.IsActiveMember) AS ActiveAccounts, 
    COUNT(CASE WHEN bc.Exited = 1 THEN 1 END) AS ChurnedCustomers,

    -- Identify high-risk customers based on credit score, balance, tenure, or region
    CASE 
        WHEN bc.CreditScore < 600 THEN 'High Risk: Low Credit Score'
        WHEN bc.Balance > (c.EstimatedSalary * 1.5) THEN 'High Risk: High Balance vs. Low Salary'
        WHEN bc.Tenure < 1 THEN 'High Risk: Short Tenure'
        WHEN g.GeographyLocation = 'Germany' THEN 'High Risk: High Churn Region'
        ELSE 'Low Risk'
    END AS RiskLevel,

    -- Regional churn rate
    ROUND((SUM(CASE WHEN bc.Exited = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS ChurnRate
FROM Geography g
JOIN CustomerInfo c ON g.GeographyID = c.GeographyID
JOIN Bank_Churn bc ON c.CustomerID = bc.CustomerID
GROUP BY g.GeographyLocation, c.CustomerID
HAVING RiskLevel LIKE 'High Risk%'
ORDER BY g.GeographyLocation, RiskLevel DESC;

-- SUBJECTIVE QUESTION 5 : How would you use the available data to model and predict the lifetime (tenure) value in the bank of different customer segments? 
-- Using available data to model and predict customer lifetime (tenure) value

SELECT 
    c.CustomerID,
    c.Age,
    c.EstimatedSalary,
    b.CreditScore,
    b.Tenure,
    b.Balance,
    b.NumOfProducts,
    cc.Category AS CreditCardCategory,
    a.ActiveCategory,
    e.ExitCategory,
    ROUND(DATEDIFF(CURDATE(), c.Bank_DOJ) / 365, 2) AS CurrentTenureYears
FROM CustomerInfo c
JOIN Geography geo ON c.GeographyID = geo.GeographyID
JOIN Bank_Churn b ON c.CustomerID = b.CustomerID
LEFT JOIN CreditCard cc ON b.HasCrCard = cc.CreditID          
LEFT JOIN ActiveCustomer a ON b.IsActiveMember = a.ActiveID
LEFT JOIN ExitCustomer e ON b.Exited = e.ExitID;               

-- SUBJECTIVE QUESTION 7 :
-- Identify common characteristics and trends among customers who have exited

SELECT 
    c.Age, 
    c.EstimatedSalary, 
    b.CreditScore, 
    b.Tenure, 
    b.Balance, 
    b.NumOfProducts, 
    COUNT(b.CustomerID) AS TotalExitedCustomers
FROM CustomerInfo c
JOIN Bank_Churn b ON c.CustomerID = b.CustomerID
JOIN Geography geo ON c.GeographyID = geo.GeographyID
LEFT JOIN ActiveCustomer a ON b.IsActiveMember = a.ActiveID
LEFT JOIN ExitCustomer e ON b.Exited = e.ExitID
WHERE b.Exited = 1
GROUP BY 
    c.Age, 
    c.EstimatedSalary, 
    b.CreditScore, 
    b.Tenure, 
    b.Balance, 
    b.NumOfProducts
ORDER BY TotalExitedCustomers DESC;

-- SUBJECTIVE QUES 8 Are 'Tenure', 'NumOfProducts', 'IsActiveMember', and 'EstimatedSalary' important for predicting if a customer will leave the bank?

-- Answered in Word File.

-- ----------------------------------------------------------------------------------------------------------------------------

-- SUBJECTIVE QUESTION 9 : Utilize SQL queries to segment customers based on demographics and account details. 
  
SELECT 
    c.CustomerID, 
    c.Age,
    b.CreditScore,
    b.Balance,
    b.Tenure,
    g.GenderCategory,
    geo.GeographyLocation,
    
    -- Segment by Age
    CASE 
        WHEN c.Age < 25 THEN 'Youth (Under 25)'
        WHEN c.Age BETWEEN 25 AND 35 THEN 'Young Adults (25-35)'
        WHEN c.Age BETWEEN 36 AND 50 THEN 'Middle Age (36-50)'
        ELSE 'Senior (Above 50)'
    END AS AgeGroup,

    -- Segment by Credit Score
    CASE 
        WHEN b.CreditScore < 500 THEN 'Poor Credit'
        WHEN b.CreditScore BETWEEN 500 AND 700 THEN 'Average Credit'
        ELSE 'Good Credit'
    END AS CreditScoreCategory,

    -- Segment by Balance
    CASE 
        WHEN b.Balance < 10000 THEN 'Low Balance'
        WHEN b.Balance BETWEEN 10000 AND 50000 THEN 'Medium Balance'
        ELSE 'High Balance'
    END AS BalanceCategory,

    -- Segment by Tenure
    CASE 
        WHEN b.Tenure < 2 THEN 'New Customer'
        WHEN b.Tenure BETWEEN 2 AND 5 THEN 'Moderate Customer'
        ELSE 'Loyal Customer'
    END AS TenureSegment,

    -- Segment by Credit Card Ownership
    CASE 
        WHEN b.HasCrCard = 1 THEN 'Credit Card Holder'
        ELSE 'Non-Credit Card Holder'
    END AS CreditCardSegment

FROM bank_churn b
JOIN customerinfo c ON c.CustomerID = b.CustomerID
JOIN gender g ON g.GenderID = c.GenderID
JOIN geography geo ON geo.GeographyID = c.GeographyID
ORDER BY AgeGroup, CreditScoreCategory;

-- ----------------------------------------------------------------------------------------------------------------------------

-- SUBJECTIVE QUESTION 10 : How can we create a conditional formatting setup to visually highlight customers at risk of 
-- churn and to evaluate the impact of credit card rewards on customer retention?

SELECT 
    c.CustomerID,
    c.Surname AS CustomerName,
    b.CreditScore,
    b.Balance,
    b.Tenure,
    b.NumOfProducts,
    b.HasCrCard,
    b.Exited,
    CASE 
        WHEN b.Exited = 1 THEN 'Churned'
        WHEN b.CreditScore < 600 OR b.Tenure < 2 OR b.Balance > 120000 OR b.HasCrCard = 0 THEN 'High Risk'
        WHEN b.CreditScore BETWEEN 600 AND 700 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS RiskLevel
FROM bank_churn b
JOIN customerinfo c ON c.CustomerID = b.CustomerID
ORDER BY RiskLevel DESC, b.CreditScore;

-- SUBJECTIVE QUESTION 12 : Create a dashboard incorporating all the KPIs and visualization-related metrics. 
-- Use a slicer in order to assist in selection in the dashboard. 

-- Created on PowerBi Desktop

-- ----------------------------------------------------------------------------------------------------------------------------

-- SUBJECTIVE QUESTION 13 : How would you approach this problem, if the objective and subjective questions weren't given?

-- Answered in word file

-- ----------------------------------------------------------------------------------------------------------------------------

-- SUBJECTIVE QUESTION 14 : In the “Bank_Churn” table how can you modify the name of the “CreditID” column to “Has_creditcard”?
ALTER TABLE bank_churn
CHANGE HasCrCard Has_creditcard INT;
Select * from bank_churn;


-- power bi

CREATE DATABASE IF NOT EXISTS analytics;
USE analytics;
CREATE TABLE analytics.customer_dim AS
SELECT
  c.CustomerId,
  c.Surname,
  c.Age,
  c.GenderID,
  g.GenderCategory,
  c.GeographyID,
  geo.GeographyLocation,
  c.EstimatedSalary,
  c.Bank_DOJ
FROM BankChurnDB.CustomerInfo c
LEFT JOIN BankChurnDB.Gender g ON c.GenderID = g.GenderID
LEFT JOIN BankChurnDB.Geography geo ON c.GeographyID = geo.GeographyID;
SELECT * FROM customer_dim;
-- 2
CREATE TABLE IF NOT EXISTS analytics.account_fact AS
SELECT
    b.CustomerId,
    b.CreditScore,
    b.Tenure,
    b.Balance,
    b.NumOfProducts,
    b.HasCrCard,
    b.IsActiveMember,
    b.Exited
FROM BankChurnDB.Bank_Churn b;
SELECT*FROM account_fact;
-- 3
CREATE TABLE IF NOT EXISTS active_dim AS
SELECT * FROM BankChurnDB.ActiveCustomer;
CREATE TABLE IF NOT EXISTS exit_dim AS
SELECT * FROM BankChurnDB.ExitCustomer;
CREATE TABLE IF NOT EXISTS creditcard_dim AS
SELECT * FROM BankChurnDB.CreditCard;
-- 4
CREATE TABLE IF NOT EXISTS calendar_dim AS
SELECT
    DATE(c.Bank_DOJ) AS date,
    YEAR(c.Bank_DOJ) AS year,
    MONTH(c.Bank_DOJ) AS month,
    MONTHNAME(c.Bank_DOJ) AS monthname
FROM BankChurnDB.CustomerInfo c;
SELECT * FROM calendar_dim;
-- 5
CREATE TABLE IF NOT EXISTS churn_by_geography AS
SELECT 
    geo.GeographyLocation,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
    ROUND(SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS ChurnRate,
    ROUND(AVG(b.Balance), 2) AS AvgBalance
FROM BankChurnDB.Bank_Churn b
JOIN BankChurnDB.CustomerInfo c 
    ON b.CustomerId = c.CustomerId
JOIN BankChurnDB.Geography geo 
    ON c.GeographyID = geo.GeographyID
GROUP BY geo.GeographyLocation;
SELECT * FROM churn_by_geography;
-- 6
CREATE TABLE IF NOT EXISTS churn_by_gender AS 
SELECT   
    g.GenderCategory,   
    COUNT(*) AS TotalCustomers,   
    SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,   
    ROUND(SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS ChurnRate 
FROM BankChurnDB.Bank_Churn b 
JOIN BankChurnDB.CustomerInfo c 
    ON b.CustomerId = c.CustomerId 
JOIN BankChurnDB.Gender g 
    ON c.GenderID = g.GenderID 
GROUP BY g.GenderCategory;
SELECT * FROM churn_by_gender;

SHOW TABLES FROM analytics;






