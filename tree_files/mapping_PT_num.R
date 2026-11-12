tip_labels <- tree$tip.label
tip_labels_num_only <- str_remove(tip_labels, "^IDDLNTM")
tip_labels_num_only <- str_c("IDDL", tip_labels_num_only)
tip_labels_table <- tibble(
  tip_label = tip_labels,
  cleaned_tip_label = str_remove(tip_labels_num_only, "\\.[AB]$")
)
planet_lab_IDs <- (meta %>% pull(`Planet Lab ID`))

count <- 0
tree_revised <- tree
for (ID in tip_labels_table$cleaned_tip_label) {
  if (ID %in% planet_lab_IDs) {
    # gets the real tip label that corresponds with the cleaned one
    real_tip_label <- pull(filter(tip_labels_table, cleaned_tip_label == ID), tip_label)
    # get PT# from cleaned label
    PT_num <- pull(filter(meta, `Planet Lab ID` == ID), `PT#`)
    real_tip_label_with_PT <- str_c(real_tip_label, PT_num)
    tree_revised$tiplabel[tree_revised$tip.label == real_tip_label] <- real_tip_label_with_PT
    count <- count + 1
  }
}
print(count)
view(tree_revised$tip.label)