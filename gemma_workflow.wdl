workflow run_gemma {
       File genotype_bed
       File genotype_bim
       File genotype_fam

       File plink_bed
       File plink_bim
       File plink_fam


    call run_gemma_relatedness_matrix {
        input:
            genotype_bed = genotype_bed,
            genotype_bim = genotype_bim,
            genotype_fam = genotype_fam
    }

    call run_gemma_lmm {
        input: 
            plink_bed = plink_bed,
            plink_bim = plink_bim,
            plink_fam = plink_fam,
            gemma_relatedness_matrix_file = run_gemma_relatedness_matrix.gemma_relatedness_matrix_file
    }

}


task run_gemma_relatedness_matrix {

        File genotype_bed
        File genotype_bim
        File genotype_fam


        String genotype_prefix = basename(genotype_bed, ".bed")
    
	    Int? memory = 32
	    Int? disk = 200
        Int? threads = 32


	command {
        gemma \
        -bfile ${sub(genotype_bed,'.bed','')} -gk 2 -outdir ./ -o ${genotype_prefix}_relatedness_matrix
	}

	runtime {
		docker: "quay.io/shukwong/gemma:latest"
		memory: "${memory} GB"
		disks: "local-disk ${disk} HDD"
        cpu: "${threads}"
		gpu: false
	}

	output {
		File gemma_relatedness_matrix_file="./${genotype_prefix}_relatedness_matrix.sXX.txt"
	}
}

task run_gemma_lmm {

        File plink_bed
        File plink_bim
        File plink_fam
        File gemma_relatedness_matrix_file

        String plink_prefix = basename (plink_bed, ".bed")

        Int? memory = 16
	    Int? disk = 200
        Int? threads = 8

    command {
        gemma \
           -bfile ${sub(plink_bed,".bed",'')} \
           -k ${gemma_relatedness_matrix_file} \
           -lmm 4 \
           -outdir ./ \
           -o ${plink_prefix}_gemma_lmm4
    }

    runtime {
		docker: "quay.io/shukwong/gemma:latest"
		memory: "${memory} GB"
		disks: "local-disk ${disk} HDD"
        cpu: "${threads}"
		gpu: false
	}

	output {
		File gemma_association_file="${plink_prefix}_gemma_lmm4.assoc.txt"
        File gemma_log_file="${plink_prefix}_gemma_lmm4.log.txt"
	}
}