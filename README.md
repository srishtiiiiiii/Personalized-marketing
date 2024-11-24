📋 PROJECT OVERVIEW
This project involves customer segmentation and campaign assignment for a financial services use case. Using SAS OnDemand, we implemented a scoring system, assigned campaigns dynamically,
analyzed customer distributions, and visualized insights. The results were exported for further usage.

📂 PROJECT STRUCTURE

The repository contains the following files:

Program1.sas: SAS script for data cleaning, customer scoring, ranking, campaign assignment, visualization, and report generation.
test.csv: Sample input dataset used for analysis.
README.md: Documentation for the project.


🔧 FEATURES

Created a Cluster_Score based on financial parameters such as income, debt, and credit utilization.
Ensured scores were non-negative.
Dynamic Campaign Assignment

Assigned customers into four campaigns based on percentile rankings:
Savings Opportunities: Top 25% of customers.
Debt Management Support: 50-74% percentile.
Credit Improvement Plans: 25-49% percentile.
General Banking Services: Bottom 24% of customers.
