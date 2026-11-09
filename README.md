# Do National Parties Struggle to Influence Public Opinion on Globalization?
### Public opinion on globalization in Germany, 1980–2021

Replication code for the term paper *"Do National Parties Struggle to Influence Public Opinion on Globalization? Evaluating Public Opinion on Globalization in the German Context from 1980 to 2021"* by Alexander Ott (University of Mannheim, International Political Economy, 2023).

The paper replicates the descriptive analysis of Walter (2021) for Germany. It examines how attitudes towards the economic, political and cultural dimensions of globalization differ between political camps (left / moderate / right), educational groups, (post-)materialists and voters of the Greens and the AfD, and whether these attitudes have become more polarized since the AfD was founded in 2013.

---

## Repository structure

```
.
├── README.md
├── analysis.R          # complete analysis: data preparation and all figures
├── data/               # place the GESIS files here (not included, see below)
└── output/             # created by the script: figures and group means
```

## Data

| Data set | Study number | Version | File | Used for |
|---|---|---|---|---|
| ALLBUS 2004 (incl. ISSP 2003 National Identity II) | ZA3762 | 2.0.0 | `ZA3762_v2-0-0.sav` | Figures 1–5 |
| ALLBUS 2014 (incl. ISSP 2013 National Identity III) | ZA5240 | 2.2.0 | `ZA5240_v2-2-0.sav` | Figures 1–5 |
| ALLBUS cumulation 1980–2018 | ZA5274 | 1.1.0 | `ZA5274_v1-1-0.dta` | Figures 6–7 |
| ALLBUS 2021 | ZA5280 | 2.0.0 | `ZA5280_v2-0-0.sav` | Figures 6–7 |

**The data are not included in this repository.** GESIS data may not be redistributed. They are free for academic use after registration at the [GESIS Data Archive](https://search.gesis.org/). Download the four files and place them in the `data/` folder with the file names listed above.

## Requirements

- R (≥ 4.1) — developed with RStudio
- R packages:

```r
install.packages(c("tidyverse", "haven", "gridExtra"))
```

## How to run

1. Clone the repository and open the folder as an RStudio project.
2. Put the four data files into `data/`.
3. Run `analysis.R`. All figures are written to `output/`.

| Output | Content |
|---|---|
| `fig1_walter_replication.png` | Replication of Walter's (2021) figure: 9 ISSP items, 2004 vs. 2014 |
| `fig2_left_right.png` | ISSP items by left / moderate / right |
| `fig3_education.png` | ISSP items by educational level |
| `fig4_materialism.png` | ISSP items by Inglehart index |
| `fig5_greens_afd.png` | ISSP items by vote intention (Greens / AfD / other) |
| `fig6_immigration_left_right.png` | ALLBUS immigration items 1980–2021 by left / moderate / right |
| `fig7_immigration_greens_afd.png` | ALLBUS immigration items 1980–2021 by vote intention |
| `issp_group_means.csv` | Means and number of respondents behind every point in figures 2–5 |

## Variables

### Dependent variables: ISSP National Identity items (following Walter 2021)

All items are reversed so that 1 = strongly disagree and 5 = strongly agree.

| Dimension | Item | ALLBUS 2004 | ALLBUS 2014 |
|---|---|---|---|
| Economic | Free trade means better products | V750 | V676 |
| Economic | International companies damage local businesses | V749 | V675 |
| Economic | Germany should limit imports | V744 | V670 |
| Political | International organizations should have the right to enforce solutions | V745 | V671 |
| Political | International organizations take too much power from government | V752 | V678 |
| Political | Germany should follow decisions of international organizations | V751 | V677 |
| Cultural | More national content on television | V748 | V674 |
| Cultural | Immigrants take jobs from natives | V760 | V685 |
| Cultural | Immigrants bring new ideas and cultures | V761 | V686 |

### ALLBUS immigration items (1980–2021)

| Variable | Item | Scale |
|---|---|---|
| `mp19` | Refugees: more opportunities or risks for the economy | 1 = risks ... 5 = opportunities |
| `mm01` | Limit the practice of Islam in Germany | 1 = strongly disagree ... 7 = strongly agree |
| `ma02` | Send immigrants back when jobs are scarce | 1–7 |
| `ma04` | Immigrants should marry among themselves | 1–7 |

### Grouping variables

| Group | Source (2004 / 2014 / cumulation) | Coding |
|---|---|---|
| Left / moderate / right | V188 / V215 / `pa01` (1–10) | 1–3 / 4–7 / 8–10 |
| Education | vocational degree dummies (2004: V61–V72, 2014: V87–V98) | highest degree: lower = none or semi-skilled training; intermediate = apprenticeship, vocational or technical school; higher = master craftsman, university of applied sciences, university |
| (Post-)materialists | Inglehart index V187 / V214 | 1 = post-materialist, 2–3 = mixed, 4 = materialist |
| Vote intention | V673 / V609 / `pv01` | Greens, AfD, other parties; non-voters excluded |

All means are weighted with the east-west person weight (V895 in 2004, V870 in 2014, `wghtpew` in the cumulation and 2021), because East Germans are oversampled in ALLBUS.

## Notes

- The ISSP module was only asked of part of the ALLBUS sample. Some groups are small (e.g. AfD voters in 2014: 86 respondents, right-wing respondents: about 90 per year). See `issp_group_means.csv`.
- The AfD was founded in 2013, so AfD voters can only be identified from 2014 on.
- ALLBUS 2021 was conducted as a self-administered survey (online/mail) instead of face-to-face interviews. Changes between 2018 and 2021 may partly reflect this change in survey mode.

## References

- Walter, S. (2021). The Backlash Against Globalization. *Annual Review of Political Science*, 24, 421–442.
- GESIS – Leibniz Institute for the Social Sciences. ALLBUS 2004 (ZA3762), ALLBUS 2014 (ZA5240), ALLBUS cumulation 1980–2018 (ZA5274), ALLBUS 2021 (ZA5280).
- ISSP Research Group. International Social Survey Programme: National Identity II (ISSP 2003) and National Identity III (ISSP 2013).

## Author

Alexander Ott
