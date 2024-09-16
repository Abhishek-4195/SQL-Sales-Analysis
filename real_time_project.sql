create database Project;
use project;

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID VARCHAR(10),
    ProductID VARCHAR(10),
    Quantity INT,
    TotalOrderValue DECIMAL(10, 2)
);

INSERT INTO Orders VALUES
(1001, '2024-01-10', 'C001', 'P001', 3, 150.00),
(1002, '2024-01-11', 'C002', 'P002', 2, 200.00),
(1003, '2024-01-12', 'C003', 'P003', 1, 300.00),
(1004, '2024-01-13', 'C001', 'P004', 5, 500.00),
(1005, '2024-01-14', 'C004', 'P005', 10, 1000.00);

CREATE TABLE Products (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(50),
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    Price DECIMAL(10, 2)
);

INSERT INTO Products VALUES
('P001', 'Laptop', 'Electronics', 'Computers', 50.00),
('P002', 'Smartphone', 'Electronics', 'Mobile', 100.00),
('P003', 'Tablet', 'Electronics', 'Computers', 300.00),
('P004', 'Headphones', 'Accessories', 'Audio', 100.00),
('P005', 'Smartwatch', 'Electronics', 'Wearables', 100.00);

CREATE TABLE Customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Region VARCHAR(50),
    Age INT,
    Gender VARCHAR(10)
);

INSERT INTO Customers VALUES
('C001', 'John', 'Doe', 'North', 35, 'Male'),
('C002', 'Jane', 'Smith', 'South', 28, 'Female'),
('C003', 'Alice', 'Johnson', 'East', 40, 'Female'),
('C004', 'Bob', 'Lee', 'West', 50, 'Male');

CREATE TABLE Inventory (
    ProductID VARCHAR(10) PRIMARY KEY,
    StockLevel INT,
    ReorderThreshold INT
);

INSERT INTO Inventory VALUES
('P001', 20, 5),
('P002', 10, 3),
('P003', 15, 4),
('P004', 5, 2),
('P005', 25, 10);

CREATE TABLE SalesChannels (
    ChannelID INT PRIMARY KEY,
    ChannelName VARCHAR(50),
    Sales DECIMAL(10, 2)
);

INSERT INTO SalesChannels VALUES
(1, 'Online', 2000),
(2, 'In-Store', 3000),
(3, 'Phone', 1000);



-- Write SELECT queries to view sample records from each table.--

select *from orders limit 2 offset 1;

-- Explore the relationships between tables using JOIN statements.--
-- Calculate total sales and number of orders per product, category, and subcategory.--

select p.Category,p.subcategory,count(o.quantity) as total_QTY,sum(o.totalordervalue) as total_sales
from orders o
left join products p
on o.ProductID=p.productid
group by p.Category,p.SubCategory;

-- Identify top-performing products by sales and quantity sold.--

select p.productname as Product, o.quantity as Total_QTY,(o.quantity*o.totalordervalue) as Total_sales
from orders o
left join products p
on o.ProductID=p.productid
order by total_sales desc;

-- Analyze sales performance by region and sales channel.--

select concat(c.firstname," ",c.lastname) as Full_name, c.region as Region, p.productname as Product, sum(o.quantity) as Total_QTY,sum(o.quantity*o.totalordervalue) as Total_sales
from customers c
left join orders o
on c.customerid=o.customerid
left join products p
on o.ProductID=p.productid
group by region, Full_name, product
order by total_sales desc;

-- Calculate total spend and number of orders per customer.--

select c.CustomerID, concat(c.firstname," ",c.lastname) as Full_name, sum(o.quantity) as NO_of_Orders,sum(o.totalordervalue) as Total_Spends
from customers c
left join orders o
on c.customerid=o.customerid
left join products p
on o.ProductID=p.productid
group by c.CustomerID
order by total_spends desc;

-- Identify high-value customers --

select c.CustomerID, concat(c.firstname," ",c.lastname) as Full_name,
sum(o.quantity) as NO_of_Orders, sum(totalordervalue) as Total_Spends
from customers c left join orders o on c.customerid=o.customerid
left join products p on o.ProductID=p.productid
group by c.CustomerID
order by total_spends desc limit 2;

-- Segment customers by region, frequency of purchase, and average order value.--

select c.CustomerID , c.region, count(o.orderid) as Order_freq, round(avg(totalordervalue),2) as Avg_Order_value
from customers c
left join orders o
on c.customerid=o.customerid
group by c.CustomerID, c.region
order by Order_freq desc;

-- Analyze monthly or quarterly sales trends for each product category.--

select o.productid as Product_ID, date_format(o.orderdate, '%m-%y') as Order_Month, Sum(o.totalordervalue) as Monthly_Revenue
from orders o
group by o.productid, Order_Month
order by Monthly_Revenue desc;

-- Calculate the current stock levels for each product.--

select i.productid as Product_ID ,p.productname as Product_name, i.stocklevel-sum(o.quantity) as Current_stock
from inventory i
left join orders o on i.ProductID=o.ProductID
left join products p on i.ProductID=p.ProductID
group by i.ProductID,p.ProductName
order by i.ProductID;

-- Identify products that are frequently out of stock.--

select i.productid as Product_ID ,p.productname as Product_name, count(*) as Out_of_stock
from inventory i
left join orders o on i.ProductID=o.ProductID
left join products p on i.ProductID=p.ProductID
where i.StockLevel<=o.Quantity
group by i.ProductID,p.ProductName
order by i.ProductID;

-- Calculate inventory turnover rate for each product category --

select i.productid as Product_ID ,p.productname as Product_name, round(sum(o.TotalOrderValue)/avg(i.StockLevel),2) as Inventory_Turnover_Rate
from inventory i
left join orders o on i.ProductID=o.ProductID
left join products p on i.ProductID=p.ProductID
group by i.ProductID,p.ProductName
order by i.ProductID;


