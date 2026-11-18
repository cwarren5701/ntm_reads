for (g in NTM_thresher_meta$genome) {
  planet_lab_id <- pull(filter(tip_labels_table, tip_label == g), cleaned_tip_label)
  # print(planet_lab_id)
  # print(pull(filter(meta, `Planet Lab ID` == planet_lab_id), `Collection Date`))
  # print(length(NTM_thresher_meta$collection_date[genome = g]))
  date = pull(filter(meta, `Planet Lab ID` == planet_lab_id), `Collection Date`)
  if (length(date) > 0) {
    NTM_thresher_meta$collection_date[NTM_thresher_meta$genome == g] <- date
  }
  NTM_thresher_meta$PT_id[NTM_thresher_meta$genome == g] <- pull(filter(tip_labels_table, `tip_label` == g), PT_num_col)
}

NTM_thresher_meta$accession = "new"
NTM_thresher_meta$collection_date <- mdy(NTM_thresher_meta$collection_date)
NTM_thresher_meta$PT_id <- str_remove(NTM_thresher_meta$PT_id, "CHOP")

write_tsv(NTM_thresher_meta, "NTM_thresher_meta.txt", col_names = FALSE)