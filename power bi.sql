#2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
SELECT CustomerId, EstimatedSalary, `Bank DOJ`
FROM Bank_Churn
WHERE MONTH(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) IN (10, 11, 12)
ORDER BY EstimatedSalary DESC
LIMIT 5;

#3.	Calculate the average number of products used by customers who have a credit card. (SQL)
SELECT AVG(NumOfProducts) AS AvgProductsUsed
FROM Bank_Churn
WHERE HasCrCard = 1;



#5.	Compare the average credit score of customers who have exited and those who remain. (SQL)
SELECT 
    Exited,
    AVG(CreditScore) AS AvgCreditScore
FROM Bank_Churn
GROUP BY Exited;

#6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
SELECT 
    GenderID,
    AVG(EstimatedSalary) AS AvgEstimatedSalary,
    SUM(IsActiveMember) AS ActiveAccounts,
    COUNT(*) AS TotalCustomers,
    (SUM(IsActiveMember) * 100.0 / COUNT(*)) AS ActiveRate
FROM Bank_Churn
GROUP BY GenderID
ORDER BY AvgEstimatedSalary DESC;


#7.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
SELECT 
    CASE 
        WHEN CreditScore < 500 THEN 'Low'
        WHEN CreditScore BETWEEN 500 AND 699 THEN 'Medium'
        ELSE 'High'
    END AS CreditScoreSegment,
    COUNT(*) AS TotalCustomers,
    SUM(Exited) AS ExitedCustomers,
    (SUM(Exited) * 100.0 / COUNT(*)) AS ExitRate
FROM Bank_Churn
GROUP BY CreditScoreSegment
ORDER BY ExitRate DESC
LIMIT 1;

#10.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.
SELECT 
    YEAR(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) AS JoinYear,
    MONTH(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) AS JoinMonth,
    COUNT(*) AS TotalCustomers
FROM Bank_Churn
WHERE `Bank DOJ` IS NOT NULL AND `Bank DOJ` != ''
GROUP BY JoinYear, JoinMonth
ORDER BY JoinYear, JoinMonth;

#11.	Analyse the relationship between the number of products and the account balance for customers who have exited.
SELECT 
    NumOfProducts, 
    AVG(Balance) AS AvgBalance, 
    MIN(Balance) AS MinBalance, 
    MAX(Balance) AS MaxBalance,
    COUNT(*) AS ExitedCount
FROM Bank_Churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

#14.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)
WITH GenderAvgIncome AS (
    SELECT 
        `GeographyID`, 
        `GenderID`, 
        AVG(`EstimatedSalary`) AS AvgIncome
    FROM `Bank_Churn`
    GROUP BY `GeographyID`, `GenderID`
)
SELECT 
    `GeographyID`, 
    `GenderID`, 
    `AvgIncome`,
    RANK() OVER (PARTITION BY `GeographyID` ORDER BY `AvgIncome` DESC) AS IncomeRank
FROM GenderAvgIncome;

#15.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '50+'
    END AS AgeBracket,
    AVG(Tenure) AS AvgTenure
FROM Bank_Churn
WHERE Exited = 1
GROUP BY AgeBracket
ORDER BY AgeBracket;

#18.	Rank each bucket of credit score as per the number of customers who have churned the bank
WITH CreditScoreBuckets AS (
    SELECT 
        CASE 
            WHEN CreditScore BETWEEN 300 AND 499 THEN '300-499'
            WHEN CreditScore BETWEEN 500 AND 699 THEN '500-699'
            WHEN CreditScore BETWEEN 700 AND 899 THEN '700-899'
            ELSE '900+'
        END AS CreditScoreBucket,
        COUNT(*) AS ChurnedCustomers
    FROM Bank_Churn
    WHERE Exited = 1
    GROUP BY CreditScoreBucket
)
SELECT 
    CreditScoreBucket, 
    ChurnedCustomers,
    RANK() OVER (ORDER BY ChurnedCustomers DESC) AS RankByChurn
FROM CreditScoreBuckets;


#19.	According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser than average number of credit cards per bucket.
WITH AgeBuckets AS (
    SELECT 
        CASE 
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 31 AND 50 THEN '31-50'
            ELSE '50+'
        END AS AgeBucket,
        COUNT(*) AS CreditCardHolders
    FROM Bank_Churn
    WHERE HasCrCard = 1
    GROUP BY 
        CASE 
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 31 AND 50 THEN '31-50'
            ELSE '50+'
        END
),
AvgCreditCards AS (
    SELECT AVG(CreditCardHolders) AS AvgCards FROM AgeBuckets
)
SELECT A.AgeBucket, A.CreditCardHolders
FROM AgeBuckets A, AvgCreditCards AC
WHERE A.CreditCardHolders < AC.AvgCards;

#20.	 Rank the Locations as per the number of people who have churned the bank and average balance of the customers.
SELECT 
    GeographyID, 
    COUNT(*) AS ChurnedCustomers,
    AVG(Balance) AS AvgBalance,
    RANK() OVER (ORDER BY COUNT(*) DESC, AVG(Balance) DESC) AS LocationRank
FROM Bank_Churn
WHERE Exited = 1
GROUP BY GeographyID;

#21.	As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.

SELECT 
    CustomerID, 
    Name, 
    CONCAT(CustomerID, '_', Name) AS CustomerKey
FROM CustomerInfo;

#22.	Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
SELECT 
    CustomerId,
    Exited,
    CASE 
        WHEN Exited = 1 THEN 'Churned'
        ELSE 'Active'
    END AS ExitCategory
FROM Bank_Churn;

#24.	Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
SELECT 
    c.CustomerID, 
    c.Name AS LastName, 
    CASE 
        WHEN b.IsActiveMember = 1 THEN 'Active' 
        ELSE 'Inactive' 
    END AS ActiveStatus
FROM CustomerInfo c
JOIN Bank_Churn b ON c.CustomerID = b.CustomerId
WHERE c.Name LIKE '%on';

#25.	Can you observe any data disrupency in the Customer’s data? As a hint it’s present in the IsActiveMember and Exited columns. One more point to consider is that the data in the Exited Column is absolutely correct and accurate.
SELECT CustomerID, IsActiveMember, Exited 
FROM Bank_Churn
WHERE (IsActiveMember = 1 AND Exited = 1)  
   OR (IsActiveMember = 0 AND Exited = 0); 


#Subjective Question:


#8.	Are 'Tenure', 'NumOfProducts', 'IsActiveMember', and 'EstimatedSalary' important for predicting if a customer will leave the bank?

SELECT 
    GeographyID, 
    COUNT(CustomerID) AS num_of_customers, 
    AVG(Balance) AS avg_balance
FROM Bank_Churn
GROUP BY GeographyID;

# 13. In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?
Alter table bank_churn
Change Column HasCrCard Has_creditcard int;


