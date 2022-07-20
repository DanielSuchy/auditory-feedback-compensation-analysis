%pipeline for preprocessing the data
%run this first before any analysis
%the pipeline takes *.mat files in the curent (sub)directory
%and creates a single file with preprocessed F0 and extracted information
clear;

merge_files;
lowpass_extract_f0;
trim_f0;
get_pert_start;
get_mean_sd_f0;
get_f0_after_pert;
