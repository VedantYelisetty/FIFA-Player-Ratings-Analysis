/*******************************************************************
 FIFA Player Ratings: Age, Overall Rating, and Potential Analysis
 Author: Vedant Yelisetty

 Purpose:
   Explore the relationship between player age and overall rating,
   engineer a "potential" and "experience" score for each player,
   and test whether experience level is associated with potential
   classification, using descriptive statistics, one-sample and
   paired t-tests, chi-square, ANOVA, and correlation.

 Data:
   fifa_cleaned.csv, columns: index, full_name, age, overall_rating
   (n = 20 players)
*******************************************************************/

/* 1. Import data --------------------------------------------------- */
FILENAME roster "fifa_cleaned.csv";
DATA fifa;
    INFILE roster DSD FIRSTOBS=2 TRUNCOVER;
    INPUT
        index
        full_name :$40.
        age
        overall_rating;
RUN;

/* 2. Descriptive statistics and data-quality checks ----------------- */
PROC MEANS DATA=fifa N MEAN STD MIN MAX;
    VAR age overall_rating;
    TITLE "Descriptive Statistics: Age and Overall Rating";
RUN;

PROC FREQ DATA=fifa;
    TABLES full_name / NOCUM NOPERCENT;
    TITLE "Frequency Check: Player Names (confirms no duplicates)";
RUN;

PROC UNIVARIATE DATA=fifa NORMAL PLOT;
    VAR age overall_rating;
    ID full_name;
    TITLE "Distribution Diagnostics: Age and Overall Rating";
RUN;

/* 3. Mean-centering and one-sample t-tests -------------------------- */
DATA fifa_centered;
    SET fifa;
    centered_overall = overall_rating - 70;
    centered_age = age - 25;
RUN;

PROC MEANS DATA=fifa_centered N MEAN STD T PRT;
    VAR centered_overall centered_age;
    TITLE "One-Sample t-Tests: Overall Rating = 70 and Age = 25";
RUN;

/* 4. Feature engineering: potential and experience score ------------ */
DATA fifa_potential;
    SET fifa;
    potential = overall_rating + (30 - age);
    experience_rating = (age - 18);
RUN;

DATA fifa_potential_classes;
    SET fifa_potential;
    IF experience_rating >= 12 THEN experience_group = 'High';
    ELSE IF experience_rating >= 6 THEN experience_group = 'Mid';
    ELSE experience_group = 'Low';
    IF potential >= 90 THEN potential_class = 'Elite';
    ELSE IF potential >= 80 THEN potential_class = 'High';
    ELSE IF potential >= 70 THEN potential_class = 'Mid';
    ELSE potential_class = 'Low';
RUN;

PROC PRINT DATA=fifa_potential_classes;
    VAR full_name age overall_rating potential potential_class experience_rating experience_group;
    TITLE "FIFA Dataset with Potential and Experience Categories";
RUN;

/* 5. Visualizations --------------------------------------------------- */
TITLE "Bar Chart of Potential";
PROC CHART DATA=fifa_potential;
    VBAR potential;
RUN; QUIT;

TITLE "Bar Chart of Experience Rating";
PROC CHART DATA=fifa_potential;
    VBAR experience_rating;
RUN; QUIT;

TITLE "Histogram of Potential with Normal Fit";
PROC UNIVARIATE DATA=fifa_potential NOPRINT;
    VAR potential;
    HISTOGRAM potential / NORMAL;
RUN;

TITLE "Histogram of Experience Rating with Normal Fit";
PROC UNIVARIATE DATA=fifa_potential NOPRINT;
    VAR experience_rating;
    HISTOGRAM experience_rating / NORMAL;
RUN;

TITLE "Frequency Table of Potential";
PROC FREQ DATA=fifa_potential;
    TABLES potential / NOCUM;
RUN;

TITLE "Frequency Table of Experience Rating";
PROC FREQ DATA=fifa_potential;
    TABLES experience_rating / NOCUM;
RUN;

TITLE "Tabulation of Potential Class by Experience Group";
PROC TABULATE DATA=fifa_potential_classes;
    CLASS potential_class experience_group;
    TABLE potential_class ALL,
          experience_group*(N ROWPCTN) ALL;
RUN;

TITLE "Box Plot of Potential";
PROC SGPLOT DATA=fifa_potential;
    VBOX potential / BOXWIDTH=0.5;
RUN;

TITLE "Scatter Plot of Potential vs. Experience Rating";
PROC PLOT DATA=fifa_potential;
    PLOT potential*experience_rating;
RUN; QUIT;

/* 6. Cross-tabulation with Chi-Square test --------------------------- */
PROC FREQ DATA=fifa_potential_classes;
    TABLES experience_group * potential_class / CHISQ EXPECTED NOCOL NOPERCENT;
    TITLE "Cross-Tabulation of Experience Group and Potential Class with Chi-Square Test";
RUN;
/* Null: experience group and potential class are independent
   Alt:  experience group and potential class are associated
   Result: chi-square test is NOT statistically significant. */

/* 7. ANOVA: does mean potential differ across experience groups? ---- */
PROC ANOVA DATA=fifa_potential_classes;
    CLASS experience_group;
    MODEL potential = experience_group;
    MEANS experience_group / TUKEY;
    TITLE "ANOVA: Comparing Mean Potential Across Experience Groups";
RUN;
QUIT;
/* Null: Mean(low) = Mean(mid) = Mean(high)
   Alt:  at least one mean differs
   Result: ANOVA is NOT statistically significant. */

/* 8. Paired t-test on a random split of the sample ------------------- */
DATA fifa_pair_samples;
    SET fifa_potential_classes;
    CALL STREAMINIT(123);
    r = RAND('UNIFORM');
RUN;

PROC SORT DATA=fifa_pair_samples; BY r; RUN;

DATA fifa_pair_samples;
    SET fifa_pair_samples;
    RETAIN potential_A;
    IF MOD(_N_,2)=1 THEN potential_A = potential;
    ELSE DO;
        potential_B = potential;
        OUTPUT;
    END;
RUN;

PROC TTEST DATA=fifa_pair_samples;
    PAIRED potential_A*potential_B;
    TITLE "Paired T-Test for Potential Between Two Random Samples";
RUN;
/* Null: no difference between the sample means
   Alt:  there is a difference between the sample means
   Result: fail to reject the null hypothesis. */

/* 9. Correlation among key variables ---------------------------------- */
PROC CORR DATA=fifa_potential;
    VAR age overall_rating potential experience_rating;
    TITLE "Pearson Correlation Among FIFA Variables";
RUN;
/* Note: potential and experience_rating are partly derived from age
   and overall_rating by construction, so strong correlations among
   these four variables are expected and not evidence of an
   independent relationship. */

PROC CORR DATA=fifa_potential_classes PLOTS=SCATTER(NVAR=2 ELLIPSE=CONFIDENCE);
    VAR age overall_rating;
    TITLE "Correlation and Scatter Plot: Age vs. Overall Rating";
RUN;
/* Null: no linear relationship between age and overall rating
   Alt:  there is a linear relationship between age and overall rating
   Result: fail to reject the null hypothesis (not significant). */
