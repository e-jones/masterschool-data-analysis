SELECT 
	c.CustomerID, -- 1
	c.CustomerName, -- 2
	COUNT(o.CustomerID) AS total_orders -- 3
FROM [Customers] AS c
LEFT JOIN [Orders] AS o
	ON o.CustomerID = c.CustomerID
GROUP BY 
	c.[CustomerID],
	c.[CustomerName]
ORDER BY c.CustomerID