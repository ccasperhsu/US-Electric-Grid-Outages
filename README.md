# US-Electricity-Outages 2010-2023 EDA

## Table of Contents
- [Introduction](#introduction)
	- [Background](#background)
- [Data](#data)
- [Key Takeaways](#key-takeaways)
- [Workflow Overview](#workflow-overview)


## Introduction
One of the most important roles in the nation is to balance the instantaneous changes of electricity demand with steady supply. What makes this difficult is not only the uncertain load for data centers, but also outages caused by a mixture of natural, manmade events. This exploratory data analysis (EDA) project aims to explore the official outage reporting data from the Department of Energy (DOE). The insights derived from this analysis can benefit not only the government authorities in charge, but also end customers who may take proactive actions towards future outage events.

### Background
There are multiple authorities involved in a major outage, which is an event that affect at least 50,000 customers. The North America Electric Reliability Corporation and its regional entities (RE), which together form the ERO Enterprise, are the main authorities that utilities and Balancing Authorities report to during such an outage event.

*NERC was certified by the Federal Energy Regulatory Commission (FERC) to act as the Electric Reliability Organization (ERO) as designated in the Federal Power Act of 2005. NERC has delegated certain authority to its six Regional Entities to conduct activities such as proposing regional Reliability Standards, engaging in compliance monitoring and enforcement activities, and performing reliability assessments* -- [NERC](https://www.nerc.com/who-we-are/key-players)

#### ERO (Electric Reliability Organization) Enterprise:
- NERC
- 6 RE (MRO, NPCC, RF, SERC, Texas RE, WECC)

 <img width="786" height="413" alt="ERO Enterprise" src="https://github.com/user-attachments/assets/b7b1e47e-e972-4b96-92b7-862da01a06dc" />


## Data
The OE-417 Form is used by the DOE to stay updated with current energy crises and can subsequently create policy and infrastructure changes to prevent future outages from occurring. Utilities must either file through the Balancing Authority, such as California Independent System Operator (CAISO), or file independently ([Who Must Submit](https://doe417.pnnl.gov/instructions#:~:text=considered%20electric%20utilities.%29-,Who%20Must%20Submit,-Balancing%20Authorities%20%28BA)). Power outage data based on the OE-417 form from 2021 to 2023 (partial year) was manually downloaded and processed for the purpose of this analysis.

Cleaned data and data definitions can be found in the folder titled “data”.


## Key Takeaways
- 2018, 2019, 2020 were the top 3 years with the most amount of demand loss during the 2010-2023 period. 
- Weather accounted for 95% of outages in the 160 events that affected more than 150 people examined during this time period, and together account for the largest demand loss. This highlights the importance of reducing carbon and strengthening grid infrastructures for the impacts of climate change.
- 70% of outages can last anywhere between 1 to 3 days, which can lead to serious consequences for those relying on medical, cooling, or refridgerating devices.    
- The records often do not include the number of people affected and/or loss of demand. Different methods of replacing missing values can be implemented to make the analysis more inclusive.
- The cause of the outage is not often not granular enough. For example, the record indicates the cause as "weather" instead of "weather - wildfire". This reduces the usability of the record. Individual outage event research may be required to fill the knowledge gap.

## Workflow Overview
- Preprocessing
	- Use Excel to combine downloaded data from multiple years.
	- Standardize data formats to import into the database.
- Database Data Cleaning
	- Import Excel export file into MySQL
	- Handle Null/Missing Values
	- Remove Duplicates
	- Create Categorical Variables
	- Remove Extremities and Incomplete Records
- Database EDA
	- Questions Explored:
		- What’s the trend of # of outages and total demand loss across time?
		- Explore the 5 most impactful events for each of the three years with the highest annual total loss.
		- Finding the most frequently occurred category for outages.
		- What category is the most impactful in terms of demand loss? What were the most common causes within that category?
		- Exploring the specific outage events with the greatest number of people affected.
		- Exploring the specific outage events with the largest demand losses.
		- What's the trend in the duration of outages? 
