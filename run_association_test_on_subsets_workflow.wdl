import "plink_workflow.wdl" as preprocess
import "tasks/preprocess_tasks.wdl" as preprocess_tasks

workflow run_assoication_test {
    
    File genotype_bed
    File genotype_bim
    File genotype_fam

    File genotype_samples_to_keep_file
    File imputed_samples_to_keep_file
    File imputed_list_of_vcfs_file
    
    File chain_file

    File covariate_tsv_file
    File variable_info_tsv_file
    File sample_sets_json_file
    File create_covar_files_by_set_Rscript_file

    
    call  preprocess_tasks.get_covar_subsets {
        input:
        covariate_tsv_file = covariate_tsv_file, 
        variable_info_tsv_file = variable_info_tsv_file, 
        sample_sets_json_file = sample_sets_json_file,
        create_covar_files_by_set_Rscript_file = create_covar_files_by_set_Rscript_file
    }

    scatter (covar_file in get_covar_subsets.covar_subsets_files) {
        call preprocess.run_preprocess {
            input:
            genotype_bed = genotype_bed,
            genotype_bim = genotype_bim,
            genotype_fam = genotype_fam,

            genotype_samples_to_keep_file = genotype_samples_to_keep_file,
            imputed_samples_to_keep_file = imputed_samples_to_keep_file,
            imputed_list_of_vcfs_file = imputed_list_of_vcfs_file,
            covar_file = covar_file,
    
            chain_file = chain_file
        }
    }

	output {
        Array[File] genotype_ready_bed = run_preprocess.genotype_ready_bed
        Array[File] genotype_ready_bim = run_preprocess.genotype_ready_bim
        Array[File] genotype_ready_fam = run_preprocess.genotype_ready_fam
 	}
    

    meta {
		author : "Wendy Wong"
		email : "wendy.wong@gmail.com"
		description : "Biobank scale association study with mutiple subsets (sample target variable)."
	}

}
