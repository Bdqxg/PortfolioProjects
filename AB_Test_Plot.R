library(ggplot2)

# 1. create the dataframe
ab_data <- data.frame(
  group = c("A (Control)", "B (Treatment)"),
  conversion_rate = c(0.26, 0.24)
)

# 2. Z-Score and
z_value <- -0.23
std_error <- 0.08657

# 3. generate ggplot
ggplot(ab_data, aes(x = group, y = conversion_rate, fill = group)) +
  geom_bar(stat = "identity", width = 0.5) +
  geom_text(aes(label = sprintf("%.2f", conversion_rate)),
            vjust = -0.5, size = 5) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, 0.35)) +
  labs(
    title = "A/B Test Conversion Rate Comparison",
    subtitle = sprintf("Z = %.2f, Std. Error = %.5f (Difference not significant)", z_value, std_error),
    x = "Group",
    y = "Conversion Rate"
  ) +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle = element_text(size = 12))
