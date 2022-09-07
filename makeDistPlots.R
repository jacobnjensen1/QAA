library(tidyverse)

data_3_1 = read_table("trimmed/3_filtered_1P_lengths.txt", col_names = c("count", "length"))
data_3_2 = read_table("trimmed/3_filtered_2P_lengths.txt", col_names = c("count", "length"))
data_17_1 = read_table("trimmed/17_filtered_1P_lengths.txt", col_names = c("count", "length"))
data_17_2 = read_table("trimmed/17_filtered_2P_lengths.txt", col_names = c("count", "length"))

data_3_1 = cbind(data_3_1, Dir=c(1))
data_3_2 = cbind(data_3_2, Dir=c(2))
data_17_1 = cbind(data_17_1, Dir=c(1))
data_17_2 = cbind(data_17_2, Dir=c(2))

data_3 = rbind(data_3_1, data_3_2)
data_17 = rbind(data_17_1, data_17_2)

ggplot(data_3) +
  geom_line(aes(x=length, y=count, color=factor(Dir)), stat="identity", size=1) +
  scale_color_manual(values=c("#D55E00", "#56B4E9")) +
  scale_y_log10() +
  xlab("Trimmed Read Length") +
  ylab("Read Count (log10 scaled)") +
  ggtitle("Trimmed read length distribution for 3_2B_control_S3_L008_R*_001")

ggplot(data_17) +
  geom_line(aes(x=length, y=count, color=factor(Dir)), stat="identity",  size=1) +
  scale_color_manual(values=c("#D55E00", "#56B4E9")) +
  scale_y_log10() +
  xlab("Trimmed Read Length") +
  ylab("Read Count (log10 scaled)") +
  ggtitle("Trimmed read length distribution for 17_3E_fox_S13_L008_R2_001")

