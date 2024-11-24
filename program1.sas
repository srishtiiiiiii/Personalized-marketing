/* Generated Code (IMPORT) */
/* Source File: test.csv */
/* Source Path: /home/u64088875 */
/* Code generated on: 11/21/24, 6:30 PM */

%web_drop_table(WORK.IMPORT);

FILENAME REFFILE '/home/u64088875/test.csv';

PROC IMPORT DATAFILE=REFFILE
    DBMS=CSV
    OUT=WORK.IMPORT;
    GETNAMES=YES;
RUN;

PROC MEANS DATA=WORK.TEST N NMISS MEAN MIN MAX;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;

/*CLUSTER SCORE */
DATA WORK.CUSTOMER_SCORING;
    SET WORK.IMPORT;

 
    Cluster_Score = (Annual_Income / 1000) * 0.25 +
                    (Monthly_Inhand_Salary / 1000) * 0.25 +
                    (Total_EMI_per_month / 100) * (-0.2) +
                    (Credit_Utilization_Ratio * -0.2) +
                    (Outstanding_Debt / 1000) * (-0.1);

    /* Ensure no negative scores */
    IF Cluster_Score < 0 THEN Cluster_Score = 0;
RUN;

/* RANKING CUSTOMERS */
PROC RANK DATA=WORK.CUSTOMER_SCORING OUT=WORK.CUSTOMER_SCORING GROUPS=100;
    VAR Cluster_Score;
    RANKS Percentile_Rank;
RUN;

/* CAMPAIGN ASSIGNMENT */

DATA WORK.CUSTOMER_SCORING;
    SET WORK.CUSTOMER_SCORING;
    
    IF Percentile_Rank >= 75 THEN Campaign = 'Savings Opportunities';      /* Top 25% */
    ELSE IF Percentile_Rank >= 50 THEN Campaign = 'Debt Management Support'; /* 50-74% */
    ELSE IF Percentile_Rank >= 25 THEN Campaign = 'Credit Improvement Plans'; /* 25-49% */
    ELSE Campaign = 'General Banking Services';                            /* Bottom 24% */
RUN;

/* Add Dummy Rows for Missing Campaigns (if needed) */
DATA WORK.CUSTOMER_SCORING;
    SET WORK.CUSTOMER_SCORING;

    /* Original data output */
    OUTPUT;

    IF _N_ = 1 THEN DO;
        /* Add dummy rows for missing campaigns */
        Cluster_Score = .; /* No value for dummy rows */
        Campaign = 'Savings Opportunities'; OUTPUT;
        Campaign = 'Debt Management Support'; OUTPUT;
        Campaign = 'Credit Improvement Plans'; OUTPUT;
        Campaign = 'General Banking Services'; OUTPUT;
    END;
RUN;

/* CAMPAIGN DISTRIBUTION */
PROC FREQ DATA=WORK.CUSTOMER_SCORING;
    TABLES Campaign / NOCUM NOPERCENT;
    TITLE "Campaign Distribution After Dynamic Ranges";
RUN;

/* VISUALIZATION */

PROC SGPLOT DATA=WORK.CUSTOMER_SCORING;
    VBAR Campaign / RESPONSE=Cluster_Score STAT=MEAN FILLATTRS=(COLOR=CX4C72B0);
    TITLE "Average Cluster Score by Campaign (Adjusted)";
RUN;


PROC UNIVARIATE DATA=WORK.CUSTOMER_SCORING;
    VAR Cluster_Score;
    HISTOGRAM Cluster_Score;
    TITLE "Distribution of Cluster_Score";
RUN;


/* CAMPAIGN REPORT*/

PROC SQL;
    CREATE TABLE WORK.CAMPAIGN_REPORT AS
    SELECT 
        Campaign,
        COUNT(*) AS Customer_Count,
        AVG(Cluster_Score) AS Avg_Cluster_Score
    FROM WORK.CUSTOMER_SCORING
    GROUP BY Campaign;
QUIT;


PROC REPORT DATA=WORK.CAMPAIGN_REPORT NOWD;
    COLUMN Campaign Customer_Count Avg_Cluster_Score;
    DEFINE Campaign / 'Campaign' WIDTH=20;
    DEFINE Customer_Count / 'Number of Customers' WIDTH=20 FORMAT=8.;
    DEFINE Avg_Cluster_Score / 'Average Cluster Score' WIDTH=20 FORMAT=8.2;
    TITLE "Campaign Assignment Report with Customer Counts and Average Cluster Scores";
RUN;

/* EXPORTING CSV */
PROC EXPORT DATA=WORK.CUSTOMER_SCORING
    OUTFILE='/path/to/save/campaign_assignment_report.csv'
    DBMS=CSV REPLACE;
RUN;