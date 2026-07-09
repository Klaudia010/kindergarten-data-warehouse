# Kindergarten Data Warehouse

Academic data warehouse group project developed by a two-person team, including me, as part of Data Engineering studies.

The project focuses on designing and implementing a data warehouse for kindergarten meal consumption analysis. The modeled process tracks meal preparation, meal distribution, leftovers, ingredient usage and food waste at group level.

## Preview

<img width="606" height="547" alt="image" src="https://github.com/user-attachments/assets/6d9a3eb6-755c-4fc7-8769-40553d03712d" />

## Project scope

The project included:

- requirements analysis for a kindergarten meal management process
- source data structure definition
- relational database and data warehouse design
- fact and dimension table modeling
- ETL process preparation
- cube/KPI configuration
- query and performance analysis for MOLAP, HOLAP and ROLAP storage models

## Technologies

- SQL
- SQL Server Management Studio
- SQL Server Integration Services / Analysis Services
- Visual Studio
- Data warehouse design
- ETL
- Dimensional modeling
- MDX queries

## Repository contents

- `docs/requirements-specification.md` – business process description, source data structures and analytical requirements
- `docs/data-warehouse-design.pdf` – fact/dimension model, measures, assumptions and analytical query feasibility
- `docs/data-warehouse-optimization-report.pdf` – MOLAP/HOLAP/ROLAP processing and query performance comparison
- `sql/` – selected SQL scripts used in the project
- `screenshots/` – selected screenshots of schema, ETL flow, cube/KPI configuration and query results

## Main analytical focus

The project was designed around questions such as:

- how meal waste changes across months
- which meal types generate the most leftovers
- how ingredient usage and meal portions affect waste
- how food expenditure can be analyzed through the data warehouse
- how storage model choice affects cube processing and query execution

## Notes

The repository is intended mainly as a documentation and SQL portfolio project.  
It may require recreating the original local SQL Server and environment to run fully.
