# =============================================================================
# Do National Parties Struggle to Influence Public Opinion on Globalization?
# Evaluating public opinion on globalization in Germany, 1980-2021
#
# Replication script. Run from the repository root.
# Data (not included): place the four GESIS files in ./data/
#   - ZA3762_v2-0-0.sav  (ALLBUS 2004, incl. ISSP 2003 National Identity II)
#   - ZA5240_v2-2-0.sav  (ALLBUS 2014, incl. ISSP 2013 National Identity III)
#   - ZA5274_v1-1-0.dta  (ALLBUS cumulation 1980-2018)
#   - ZA5280_v2-0-0.sav  (ALLBUS 2021)
# =============================================================================

library(tidyverse)
library(haven)

dir.create("output", showWarnings = FALSE)
theme_set(theme_gray())


# -----------------------------------------------------------------------------
# 1. ISSP National Identity items (ALLBUS 2004 and 2014)
# -----------------------------------------------------------------------------
# The same questions have different variable numbers in the two surveys.
# Codes 6 (not in ISSP split), 8 (can't choose) and 9 (no answer) are defined
# as missing values in the SPSS files and become NA when read with read_sav().

items <- tribble(
  ~item, ~v2004,  ~v2014, ~dimension,  ~label,
  "q1",  "V750",  "V676", "Economic",  "Free trade means\nbetter products",
  "q2",  "V749",  "V675", "Economic",  "Intl. companies damage\nlocal businesses",
  "q3",  "V744",  "V670", "Economic",  "Germany should limit\nimports",
  "q4",  "V745",  "V671", "Political", "IOs should have right to\nenforce solutions",
  "q5",  "V752",  "V678", "Political", "IOs take too much power\nfrom government",
  "q6",  "V751",  "V677", "Political", "Germany should follow\ndecisions of the IOs",
  "q7",  "V748",  "V674", "Cultural",  "More national content on\ntelevision",
  "q8",  "V760",  "V685", "Cultural",  "Immigrants take jobs from\nnatives",
  "q9",  "V761",  "V686", "Cultural",  "Immigrants bring new\nideas and cultures"
)

# Harmonize one survey year: rename to common names, keep grouping variables
prepare_issp <- function(file, year, vars, v_party, v_lr, v_ingle, v_weight, edu) {
  d <- read_sav(file)
  out <- tibble(
    year      = year,
    weight    = as.numeric(d[[v_weight]]),   # east-west weight (East is oversampled)
    party     = as.numeric(d[[v_party]]),
    lr        = as.numeric(d[[v_lr]]),
    inglehart = as.numeric(d[[v_ingle]])
  )
  for (i in seq_len(nrow(items))) {
    # Reverse the scale: originally 1 = strongly agree ... 5 = strongly disagree
    out[[items$item[i]]] <- 6 - as.numeric(d[[vars[i]]])
  }
  # Highest vocational qualification (the variables are 0/1 dummies)
  is1 <- function(v) as.numeric(d[[v]]) %in% 1
  out$education <- case_when(
    is1(edu$higher[1]) | is1(edu$higher[2]) | is1(edu$higher[3]) ~ "Higher",
    Reduce(`|`, lapply(edu$middle, is1))                         ~ "Intermediate",
    Reduce(`|`, lapply(edu$lower, is1))                          ~ "Lower"
  )
  out
}

# Education: lower = no vocational degree / semi-skilled training,
# intermediate = apprenticeship, vocational school, technical school,
# higher = master craftsman, university of applied sciences, university.
issp <- bind_rows(
  prepare_issp("data/ZA3762_v2-0-0.sav", 2004, items$v2004,
               v_party = "V673", v_lr = "V188", v_ingle = "V187", v_weight = "V895",
               edu = list(lower  = c("V61", "V62", "V65", "V72"),
                          middle = c("V63", "V64", "V66", "V67"),
                          higher = c("V68", "V69", "V70"))),
  prepare_issp("data/ZA5240_v2-2-0.sav", 2014, items$v2014,
               v_party = "V609", v_lr = "V215", v_ingle = "V214", v_weight = "V870",
               edu = list(lower  = c("V87", "V88", "V91", "V98"),
                          middle = c("V89", "V90", "V92", "V93"),
                          higher = c("V94", "V95", "V96")))
)

issp <- issp %>%
  mutate(
    # Left-right self-placement (1-10)
    ideology = case_when(lr <= 3 ~ "Left", lr <= 7 ~ "Moderate", lr <= 10 ~ "Right"),
    # Inglehart index: 1 = postmaterialist, 2-3 = mixed types, 4 = materialist
    values = case_when(inglehart == 1 ~ "Post-materialists",
                       inglehart %in% 2:3 ~ "Mixed",
                       inglehart == 4 ~ "Materialists"),
    # Vote intention. Non-voters (91) are excluded; AfD only exists in 2014.
    vote = case_when(party == 4  ~ "Greens",
                     party == 42 ~ "AfD",
                     party %in% c(1:3, 5:6, 20, 41, 90) ~ "Other")
  )


# -----------------------------------------------------------------------------
# 2. Figures: ISSP items by group (2004 vs. 2014)
# -----------------------------------------------------------------------------

issp_long <- issp %>%
  pivot_longer(all_of(items$item), names_to = "item", values_to = "answer") %>%
  filter(!is.na(answer)) %>%
  left_join(items %>% select(item, label, dimension), by = "item") %>%
  mutate(label = factor(label, items$label))

agree_scale <- scale_y_continuous(breaks = 1:5, limits = c(1, 5),
                                  labels = c("Strongly disagree", "Disagree", "Neither",
                                             "Agree", "Strongly agree"))
year_scale <- scale_x_continuous(breaks = c(2004, 2014), limits = c(2002, 2016))

group_means <- function(data, group) {
  data %>%
    filter(!is.na({{ group }})) %>%
    group_by(year, item, label, group = {{ group }}) %>%
    summarise(mean = weighted.mean(answer, weight), n = n(), .groups = "drop")
}

plot_groups <- function(data, group, title, colours) {
  ggplot(group_means(data, {{ group }}), aes(year, mean, colour = group)) +
    geom_line(linewidth = 1) + geom_point(size = 2.5) +
    facet_wrap(~ label, ncol = 3) +
    agree_scale + year_scale +
    scale_colour_manual(values = colours) +
    labs(x = "Year", y = NULL, colour = NULL, title = title)
}

# Figure 1: replication of Walter (2021)
fig1 <- issp_long %>%
  group_by(year, dimension, label) %>%
  summarise(mean = weighted.mean(answer, weight), .groups = "drop") %>%
  mutate(dimension = factor(dimension, c("Economic", "Political", "Cultural"),
                            c("Economic globalization", "Political globalization",
                              "Social/cultural globalization"))) %>%
  ggplot(aes(year, mean, colour = label)) +
  geom_line(linewidth = 1) + geom_point(size = 2.5) +
  facet_wrap(~ dimension) +
  agree_scale + year_scale +
  guides(colour = guide_legend(ncol = 3)) +
  labs(x = "Year", y = "Public opinion", colour = NULL) +
  theme(legend.position = "bottom")
ggsave("output/fig1_walter_replication.png", fig1, width = 12, height = 6)

fig2 <- plot_groups(issp_long, ideology, "Public opinion of Leftists/Moderates/Rightists",
                    c(Left = "darkorange", Moderate = "forestgreen", Right = "blue3"))
ggsave("output/fig2_left_right.png", fig2, width = 10, height = 9)

fig3 <- plot_groups(issp_long, education, "Public opinion of Higher/Intermediate/Lower Educated",
                    c(Higher = "darkorange", Intermediate = "forestgreen", Lower = "blue3"))
ggsave("output/fig3_education.png", fig3, width = 10, height = 9)

fig4 <- plot_groups(issp_long, values, "Public opinion of (Post-)Materialists",
                    c(`Post-materialists` = "darkorange", Mixed = "forestgreen",
                      Materialists = "blue3"))
ggsave("output/fig4_materialism.png", fig4, width = 10, height = 9)

fig5 <- plot_groups(issp_long, vote, "Public opinion of Greens/AfD/Other",
                    c(Greens = "forestgreen", AfD = "blue3", Other = "darkorange"))
ggsave("output/fig5_greens_afd.png", fig5, width = 10, height = 9)

# Number of respondents behind every point (check small groups, e.g. AfD 2014)
group_sizes <- bind_rows(
  group_means(issp_long, ideology)  %>% mutate(grouping = "ideology"),
  group_means(issp_long, education) %>% mutate(grouping = "education"),
  group_means(issp_long, values)    %>% mutate(grouping = "values"),
  group_means(issp_long, vote)      %>% mutate(grouping = "vote")
)
write_csv(group_sizes, "output/issp_group_means.csv")


# -----------------------------------------------------------------------------
# 3. ALLBUS immigration items, 1980-2021
# -----------------------------------------------------------------------------

immi_vars <- c("year", "mp19", "mm01", "ma02", "ma04", "pv01", "pa01", "wghtpew")

immi <- bind_rows(
  read_dta("data/ZA5274_v1-1-0.dta", col_select = all_of(immi_vars)) %>% zap_labels(),
  read_sav("data/ZA5280_v2-0-0.sav") %>% select(any_of(immi_vars)) %>%
    zap_labels() %>% mutate(year = 2021)
) %>%
  # All negative codes are missing values (no answer, don't know, not asked)
  mutate(across(c(mp19, mm01, ma02, ma04, pv01, pa01), ~ if_else(.x < 0, NA_real_, as.numeric(.x)))) %>%
  mutate(
    ideology = case_when(pa01 <= 3 ~ "Left", pa01 <= 7 ~ "Moderate", pa01 <= 10 ~ "Right"),
    # Vote intention; non-voters (91) excluded, as in the ISSP part
    vote = case_when(pv01 == 4 ~ "Greens", pv01 == 42 ~ "AfD", pv01 != 91 ~ "Other")
  )

immi_items <- tribble(
  ~item,  ~label,                                         ~scale_max,
  "mp19", "Refugees create more\nopportunities/risks",     5,
  "mm01", "Limit the practice of\nIslam in Germany",       7,
  "ma02", "Send immigrants back\nwhen jobs are scarce",    7,
  "ma04", "Immigrants should marry\namong themselves",     7
)

plot_immi <- function(group, title, colours) {
  plots <- pmap(immi_items, function(item, label, scale_max) {
    d <- immi %>%
      filter(!is.na(.data[[item]]), !is.na({{ group }})) %>%
      group_by(year, group = {{ group }}) %>%
      summarise(mean = weighted.mean(.data[[item]], wghtpew), n = n(), .groups = "drop")
    y <- if (scale_max == 5) {
      scale_y_continuous(breaks = 1:5, limits = c(1, 5),
                         labels = c("Risks ++", "Risks +", "Neither", "Opportunities +", "Opportunities ++"))
    } else {
      scale_y_continuous(breaks = c(1, 4, 7), limits = c(1, 7),
                         labels = c("Strongly disagree", "Neither", "Strongly agree"))
    }
    ggplot(d, aes(year, mean, colour = group)) +
      geom_line() + geom_point() + y +
      scale_x_continuous(limits = c(1980, 2021), breaks = seq(1980, 2020, 10)) +
      scale_colour_manual(values = colours) +
      labs(x = "Year", y = NULL, colour = NULL, title = label) +
      theme(plot.title = element_text(size = 10, face = "bold"))
  })
  gridExtra::arrangeGrob(grobs = plots, ncol = 2,
                         top = grid::textGrob(title, gp = grid::gpar(fontsize = 16)))
}

fig6 <- plot_immi(ideology, "Public opinion (immigration) of Leftists/Moderates/Rightists",
                  c(Left = "darkorange", Moderate = "forestgreen", Right = "blue3"))
ggsave("output/fig6_immigration_left_right.png", fig6, width = 11, height = 8)

fig7 <- plot_immi(vote, "Public opinion (immigration) of Greens/AfD/Other",
                  c(AfD = "blue3", Greens = "forestgreen", Other = "darkorange"))
ggsave("output/fig7_immigration_greens_afd.png", fig7, width = 11, height = 8)
