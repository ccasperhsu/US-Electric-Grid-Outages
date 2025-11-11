# US-Electricity-Outages 2010-2023 EDA

## Table of Contents
- [Introduction](#introduction)
- [Data](#data)
- [Key Takeaways](#key-takeaways)
- [Workflow Overview](#workflow-overview)


## Introduction
One of the most important roles in the nation is to balance the instantaneous changes of electricity demand with steady supply. What makes this difficult is not only the uncertain demand for electricity, especially with the increased contruction of data centers, but also outages caused by a mixture of natural, manmade events. This exploratory data analysis (EDA) project aims to explore the official outage reporting data from the Department of Energy (DOE). The insights derived from this analysis can benefit not only the government authorities in charge, but also end customers who may want to take proactive actions towards future outage events.

The North America Electric Reliability Corporation and its regional entities (RE), which together form the ERO Enterprise, are the main authorities that utilities and Balancing Authorities report to during an outage event.

*NERC was certified by the Federal Energy Regulatory Commission (FERC) to act as the Electric Reliability Organization (ERO) as designated in the Federal Power Act of 2005. NERC has delegated certain authority to its six Regional Entities to conduct activities such as proposing regional Reliability Standards, engaging in compliance monitoring and enforcement activities, and performing reliability assessments* -- [NERC](https://www.nerc.com/who-we-are/key-players)

#### Six Regional Entities of the Electric Reliability Organization (ERO) Enterprise

 <img width="786" height="413" alt="ERO Enterprise" src="https://github.com/user-attachments/assets/b7b1e47e-e972-4b96-92b7-862da01a06dc" />


## Data
The OE-417 Form is used by the DOE to stay updated with current energy crises and can subsequently create policy and infrastructure changes to prevent future outages from occurring. Utilities must either file through the Balancing Authority, such as California Independent System Operator (CAISO), or file independently ([Who Must Submit](https://doe417.pnnl.gov/instructions#:~:text=considered%20electric%20utilities.%29-,Who%20Must%20Submit,-Balancing%20Authorities%20%28BA)). Power outage data based on the OE-417 form from 2021 to 2023 (partial year) was manually downloaded and processed for the purpose of this analysis.

Cleaned data and data definitions can be found in the folder titled “data”. 
- **Key data definitions**: 
	- Demand Loss: The amount of the peak demand in megawatts (MW) involved over the entire incident.
	- Event Type: Cause of the incident.

A new field, *Category*, was created during the data cleaning stage based on event type and contains the following values.

<img width="750" height="170" alt="image" src="https://github.com/user-attachments/assets/90fb98b7-e93a-48cf-b45b-d1f6c1d45af0" />

## Key Takeaways
- 2018, 2019, 2020 were the top 3 years with the largest accumulated demand loss during the 2010-2023 period. Weather is the lead contributor to demand loss during those three years.
- Of the 1428 outages with known demand loss or number of people affected, weather caused close to 70% of the events.
- 60% of power outages are restored within one day, however, over 28% of outages last between 1 to 3 days, which can lead to serious consequences for those relying on medical, cooling, or refridgerating devices.
- While physical attacks / vandalism causes about 8% of outages, their total effect on demand loss is only 3.5%. 
- The records often do not include the number of people affected and/or loss of demand. Different methods of replacing missing values may be implemented to make the analysis more conclusive.
- The cause of the outage is not often not granular enough, which means external research may be required to fill the information gap. For example, about 65% of records within the "Weather" category only indicates "Severe Weather" in the description column, instead of "Severe Weather - Wildfire" or other types of natural disasters.

While the data collection process could be refined to reduce human error and preserve more detail, the direction of the analysis from this EDA project is clear - efforts to reduce carbon and bolster infrastructures must be prioritized to lessen the impacts of climate change on an aging grid.

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
