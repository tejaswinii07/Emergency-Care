# 🏥 EmergencyCare – Hospital Emergency Triage & Resource Allocation System

## 📌 Project Overview

**EmergencyCare** is an interactive R Shiny dashboard developed as an academic project to simulate hospital emergency triage and resource allocation.

The system processes patient information such as severity, waiting time, and bed requirements. It classifies patient priority, allocates available beds, detects resource shortages, and generates emergency alerts.

> **Note:** This project is an academic simulation. The priority rules and resource-allocation logic are project-defined and are not intended for real-world clinical decision-making.

---

## 🎯 Objectives

* Read patient data from a CSV file using R.
* Classify patients based on severity and waiting time.
* Demonstrate functions and nested `if-else` conditions.
* Process multiple patients using loops.
* Simulate hospital bed allocation.
* Detect bed shortages.
* Generate emergency alerts.
* Provide an interactive dashboard for analyzing patient data.

---

## 🛠️ Technologies Used

* R
* R Shiny
* shinydashboard
* dplyr
* ggplot2
* DT
* CSV

---

## 📊 Input Dataset

The project uses `patients_100.csv`.

The dataset contains:

| Column       | Description                        |
| ------------ | ---------------------------------- |
| Patient_ID   | Unique patient identifier          |
| Severity     | Severity level from 1 to 10        |
| Waiting_Time | Waiting time in minutes            |
| Bed_Required | Whether the patient requires a bed |

---

## 🚨 Priority Classification

The project uses the following academic simulation rules:

| Severity | Priority |
| -------- | -------- |
| 9–10     | Critical |
| 7–8      | High     |
| 4–6      | Moderate |
| 1–3      | Low      |

Waiting time can modify the priority for lower severity categories.

For example, a moderate-severity patient waiting for more than 60 minutes can be flagged as **High Attention**.

---

## 🛏️ Resource Allocation

The system simulates a hospital with a limited number of beds.

Patients requiring beds are processed sequentially and assigned a bed when one is available.

When no beds remain, the patient is marked:

`WAITING - NO BED`

The system then calculates the additional number of beds required.

---

## 🚨 Emergency Alerts

The dashboard generates alerts for:

* Critical patients
* Patients requiring special attention because of long waiting times
* Patients waiting because no bed is available

---

## 📈 Dashboard Features

The EmergencyCare dashboard contains:

### Dashboard

* Total patients
* Critical patients
* Total beds
* Patients waiting for beds
* Priority distribution
* Bed resource status
* Severity distribution
* Waiting-time analysis

### Patient Records

* Patient search
* Priority filtering
* Bed-status filtering
* Interactive patient table

### Analytics

* Severity vs waiting time
* Average waiting time
* Critical patient count
* High-priority patient count
* Waiting-time analysis

### Alerts

* Emergency alerts
* Patients waiting for beds

---

## 📁 Project Structure

```text
EmergencyCare-R-Triage-System/
│
├── EmergencyCare_App.R
├── patients_100.csv
└── README.md
```

---

## ▶️ How to Run

### 1. Install R

Install R and RStudio on your computer.

### 2. Download the repository

Download or clone this repository.

### 3. Open the R application

Open:

```text
EmergencyCare_App.R
```

in RStudio.

### 4. Install required packages

Run:

```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "dplyr",
  "ggplot2",
  "DT"
))
```

### 5. Make sure the CSV is in the same folder

The application expects:

```text
patients_100.csv
```

to be in the same working directory as the R script.

### 6. Run the application

Open `EmergencyCare_App.R` in RStudio and click:

**Run App**

---

## 👩‍💻 Author

**Tejaswini B**

B.Tech – Artificial Intelligence and Data Science

---

## 📚 Project Type

Academic Mini Project – R Programming / Data Analytics / Shiny Dashboard
