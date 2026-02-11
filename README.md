# CRM and ERP Sales Warehouse - Relational and Analytical
This project designs and builds a relational and analytical data model using CRM and ERP data representing customers, products, and sales. It demonstrates the implementation of an ETL pipeline and includes advanced querying for data exploration and analysis to pull business insights, all of which is implemented using PostgreSQL in VSCode.

### Tech Stack Used:
- PostgreSQL: For the DBMS, to design and implement the relational and analytical data model and ETL pipeline
- SQL: For querying and performing data exploration
- VSCode: The environment used to work with SQL files

### Objectives:
- Import data from CRM and ERP sources, provided as CSV files, into the database
- Perform data cleaning and resolve data quality issues
- Design a relational data model connecting all tables while preserving their original formats as much as possible
- Further design and implement an analytical data model to be used for data exploration and data analysis

### Dataset:
Source: https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main

This dataset is split into 6 CSV files, both CRM and ERP, containing information on a company's customers, products, and orders.

### Outputs:
- Raw schema: Created by importing the CSV files as is, one table per CSV file. Data was not changed in any way. Contains 6 tables, where all column data types are "text" to prevent loss of information on import.
- Relational schema: Contains the 7 table relational data model. The original tables were preserved as much as possible, with relationships between one another. Appropriate data types were applied.
- Analytical schema: Contains 3 tables organized in a fact-and-dimension model (specifically star schema), with sales as the fact and customers and products as the dimensions. Organized in a way to reduce the number of joins required during querying for efficiency purposes.

### Methodology:
Several .sql files were used throughout this project, which are meant to run in sequence. Therefore, data validation files were included when necessary to ensure that the required actions were performed on the data.

Notebook Sequence:
- 00_setup
  - Three separate schemas created: raw, relational, and analytical
- 01_load_raw
  - Tables created, with appropriate columns and data types, in the raw schema
  - After table creation, data in .csv files was loaded into the respecitve tables in PostgreSQL using the "Import" feature
- 02_validating_load_raw
  - Data validation checks performed such as correct number of rows and columns and correct data types
- 03_transformation
  - Data was transformed based on observations made during data explorations
    - Changes included but not limited to:
      - Conditional data transformation
      - String manipulation (using SUBSTRING and REPLACE)
      - Date correction (using LEAD and LAG)
      - Trimming leading/trailing spaces
      - Correcting data type
      - Handling NULLs and duplicates appropriately (using COALESCE)
  - Changes were saved as views as this was an intermediate stage and did not need to be stored long term
- 04_validating_transformation
  - Data validation checks performed such as correct number of rows and columns and correct data types
- 05_relational_model
  - Tables were created in the relational schema with appropriate columns, data types, primary keys, and foreign keys
  - Data from views was inserted into the tables after data was minorly restructured in order to reduce data redundancy and allow for cleaner table relationships
  - CRM and ERP data purposely kept separate as to preserve data sturcture for the company
- 06_validating_relational_model
  - Final validation checks were performed to ensure proper data types
  - Primary and foreign keys were viewed to ensure proper structure and relations
- 07_analytics_views
  - Relational data model was restructured into an analytics-friendly data model by combining tables with sales, customer, and product information
  - Views were created containing the combined relevant data, serving as the base for the analytical data model
- 08_analytical_tables
  - Fact (sales) and dimension (products and customers) tables were created with appropriate columns and populated with the data in the analytical views
  - Resulted in three final tables that are organized in a way that reduces the number of joins required during querying
- 09_data_exploration
  - Data in the analytical model was queried for exploration purposes, looking at:
    - KPIs such as Total Sales, Total Products Sold, Total Customers, Average Order Total...
    - Total products and average product cost and total revenue, all by category
    - Top 20 revenue generating products, and the percentage of revenue they create
    - Shipping time
  - Yearly and monthly sales trends were explored further to provide insights to the company as to how to maximize revenue
 
### Relational Data Model:
![Data Warehouse Architecture](documents/relational_data_model.png)

### Analytical Data Model:
![Data Warehouse Architecture](documents/analytical_data_model.png)

### Future Work:
This project focuses on creating a usable data infrastructure for the company while preserving for them the original structure of the data. This data was then reorganized and stored in a more condense way that better supports analysis, with tables for each customers, products, and sales. This model can be integrated with Tableau or PowerBI and used to build a dashboard, visualizing important business metrics such as KPIs, product performance, and sales trends. This dashboard is coming soon!
