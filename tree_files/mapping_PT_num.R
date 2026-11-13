tip_labels <- tree$tip.label
tip_labels_num_only <- str_remove(tip_labels, "^IDDLNTM")
tip_labels_num_only <- str_c("IDDL", tip_labels_num_only)
tip_labels_table <- tibble(
  tip_label = tip_labels,
  cleaned_tip_label = str_remove(tip_labels_num_only, "\\.[ABC]$")
)
planet_lab_IDs <- (meta %>% pull(`Planet Lab ID`))

count <- 0
tree_with_PT <- tree
for (ID in tip_labels_table$cleaned_tip_label) {
  if (ID %in% planet_lab_IDs) {
    # gets the real tip label that corresponds with the cleaned one (could be more than one because of A, B, C extensions)
    real_tip_labels <- pull(filter(tip_labels_table, cleaned_tip_label == ID), tip_label)
    for (label in real_tip_labels) {
      # get PT# from cleaned label - A, B, or C duplicates will share same PT#
      PT_num <- pull(filter(meta, `Planet Lab ID` == ID), `PT#`)
      tree_with_PT$tip.label[tree_with_PT$tip.label == label] <- paste(tree_with_PT$tip.label[tree_with_PT$tip.label == label], PT_num, sep = ".")
      count <- count + 1
    }
  }
}
print(count)
write.tree(tree_with_PT, file = "CHOP_ntm_with_PT_num.treefile")
