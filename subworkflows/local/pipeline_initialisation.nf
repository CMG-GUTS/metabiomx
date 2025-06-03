/*

    PIPELINE INITIALISATION
    
*/

include { paramsSummaryMap          } from 'plugin/nf-validation'
include { fromSamplesheet           } from 'plugin/nf-validation'

include { metapipeLogo              } from '../nf-core/nf_pipeline_utils.nf'
include { completionEmail           } from '../nf-core/nf_pipeline_utils.nf'
include { completionSummary         } from '../nf-core/nf_pipeline_utils.nf'
include { dashedLine                } from '../nf-core/nf_pipeline_utils.nf'
include { imNotification            } from '../nf-core/nf_pipeline_utils.nf'
include { UTILS_NEXTFLOW_PIPELINE } from '../nf-core/utils_nextflow_pipeline.nf'
include { UTILS_NFVALIDATION_PLUGIN } from '../nf-core/utils_nfvalidation_plugin.nf'


/*
========================================================================================
    SUBWORKFLOW TO INITIALISE PIPELINE
========================================================================================
*/

workflow PIPELINE_INITIALISATION {

    take:
    version           // boolean: Display version and exit
    help              // boolean: Display help text
    validate_params   // boolean: Boolean whether to validate parameters against the schema at runtime
    monochrome_logs   // boolean: Do not use coloured log outputs
    outdir            //  string: The output directory where the results will be saved

    main:

    ch_versions = Channel.empty()

    //
    // Print version and exit if required and dump pipeline parameters to JSON file
    //
    UTILS_NEXTFLOW_PIPELINE (
        version,
        true,
        outdir,
        false
    )

    //
    // Validate parameters and generate parameter summary to stdout
    //
    pre_help_text = metapipeLogo(monochrome_logs)
    post_help_text = """
    =============================================
    ${workflow.manifest.name.toUpperCase()} v${workflow.manifest.version}
    =============================================

    Usage:
        nextflow run ${workflow.manifest.mainScript} \\
            -profile <docker/singularity> \\
            -c nextflow.config \\
            -work-dir <workdir> \\
            --reads <*_{1,R1,2,R2}.{fq,fq.gz,fastq,fastq.gz}> \\
            --singleEnd \\
            --outdir <outdir>

    Description:
        ${workflow.manifest.description ?: "A Metagenomic pipeline for Microbiomics data"}

    Mandatory Arguments:
        --input         Path to samplesheet CSV file
        --reads         Path to input fastq files
        --outdir        Path to output directory
        --singleEnd     Using flag sets singleEnd to true

    Profiles:
        -profile        Configuration profile to use. 
                        Available: docker, singularity

    Other Options:
        --help          Show this help message and exit
        --version       Show the pipeline version and exit

    Example Command:
        nextflow run ${workflow.manifest.mainScript} -profile docker --reads *_{1,2}.fastq.gz --outdir results
        nextflow run ${workflow.manifest.mainScript} -profile singularity --input samplesheet.csv --outdir results

    For more information, visit: ${workflow.manifest.homePage}
    """.stripIndent()
    
    workflow_command = "nextflow run ${workflow.manifest.mainScript} -profile <docker/singularity/.../institute> --reads samplesheet.csv --outdir <OUTDIR>"
    UTILS_NFVALIDATION_PLUGIN (
        help,
        workflow_command,
        pre_help_text,
        post_help_text,
        validate_params,
        "nextflow_schema.json"
    )

    //
    // Custom validation for pipeline parameters
    //
    validateParameters()

    emit:
    versions    = ch_versions
}

/*
========================================================================================
    SUBWORKFLOW FOR PIPELINE COMPLETION
========================================================================================
*/

workflow PIPELINE_COMPLETION {

    take:
    email           //  string: email address
    email_on_fail   //  string: email address sent on pipeline failure
    plaintext_email // boolean: Send plain-text email instead of HTML
    outdir          //    path: Path to output directory where results will be published
    monochrome_logs // boolean: Disable ANSI colour codes in log output
    hook_url        //  string: hook URL for notifications

    main:

    summary_params = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")

    //
    // Completion email and summary
    //
    workflow.onComplete {
        if (email) {
            completionEmail(summary_params, email, email_on_fail, plaintext_email, outdir, monochrome_logs)
        }

        completionSummary(monochrome_logs)

        if (hook_url) {
            imNotification(summary_params, hook_url)
        }
    }

    workflow.onError {
        if (email_on_fail) {
            // placeholder
        }
        log.error "Pipeline failed. Please refer to troubleshooting docs: https://nf-co.re/docs/usage/troubleshooting"
    }
}

/*
========================================================================================
    FUNCTIONS
========================================================================================
*/
//
// Check and validate pipeline parameters
//
def validateParameters() {
    if ( !params.reads && !params.input) {
        error("Missing reads and input declaration, one is required.")
    }

    if ( !params.outdir ) {
        error("Missing output directory declaration: --outdir` is required.")
    }

    // Checking reference directories existence
    def bowtie_tmp = file(params.bowtie_db)
    if (!bowtie_tmp.isDirectory()) {
        error("Cannot find directory: ${params.bowtie_db}\n")
    }
    def metaphlan_tmp = file(params.metaphlan_db)
        if (!metaphlan_tmp.isDirectory()) {
        error("Cannot find directory: ${params.metaphlan_db}\n")
    }
    def humann_tmp = file(params.humann_db)
    if (!humann_tmp.isDirectory()) {
        error("Cannot find directory: ${params.humann_db}\n")
    }
    def catpack_tmp = file(params.cat_pack_db)
    if (!catpack_tmp.isDirectory()) {
        error("Cannot find directory: ${params.cat_pack_db}\n")
    }
}


//
// Generate methods description for MultiQC
//
def toolCitationText() {
    // TODO nf-core: Optionally add in-text citation tools to this list.
    // Can use ternary operators to dynamically construct based conditions, e.g. params["run_xyz"] ? "Tool (Foo et al. 2023)" : "",
    // Uncomment function in methodsDescriptionText to render in MultiQC report
    def citation_text = [
            "Tools used in the workflow included:",
            "FastQC (Andrews 2010),",
            "MultiQC (Ewels et al. 2016)",
            "."
        ].join(' ').trim()

    return citation_text
}

def toolBibliographyText() {
    // TODO nf-core: Optionally add bibliographic entries to this list.
    // Can use ternary operators to dynamically construct based conditions, e.g. params["run_xyz"] ? "<li>Author (2023) Pub name, Journal, DOI</li>" : "",
    // Uncomment function in methodsDescriptionText to render in MultiQC report
    def reference_text = [
            "<li>Andrews S, (2010) FastQC, URL: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).</li>",
            "<li>Ewels, P., Magnusson, M., Lundin, S., & Käller, M. (2016). MultiQC: summarize analysis results for multiple tools and samples in a single report. Bioinformatics , 32(19), 3047–3048. doi: /10.1093/bioinformatics/btw354</li>"
        ].join(' ').trim()

    return reference_text
}

def methodsDescriptionText(mqc_methods_yaml) {
    // Convert  to a named map so can be used as with familar NXF ${workflow} variable syntax in the MultiQC YML file
    def meta = [:]
    meta.workflow = workflow.toMap()
    meta["manifest_map"] = workflow.manifest.toMap()

    // Pipeline DOI
    if (meta.manifest_map.doi) {
        // Using a loop to handle multiple DOIs
        // Removing `https://doi.org/` to handle pipelines using DOIs vs DOI resolvers
        // Removing ` ` since the manifest.doi is a string and not a proper list
        def temp_doi_ref = ""
        String[] manifest_doi = meta.manifest_map.doi.tokenize(",")
        for (String doi_ref: manifest_doi) temp_doi_ref += "(doi: <a href=\'https://doi.org/${doi_ref.replace("https://doi.org/", "").replace(" ", "")}\'>${doi_ref.replace("https://doi.org/", "").replace(" ", "")}</a>), "
        meta["doi_text"] = temp_doi_ref.substring(0, temp_doi_ref.length() - 2)
    } else meta["doi_text"] = ""
    meta["nodoi_text"] = meta.manifest_map.doi ? "" : "<li>If available, make sure to update the text to include the Zenodo DOI of version of the pipeline used. </li>"

    // Tool references
    meta["tool_citations"] = ""
    meta["tool_bibliography"] = ""

    // TODO nf-core: Only uncomment below if logic in toolCitationText/toolBibliographyText has been filled!
    // meta["tool_citations"] = toolCitationText().replaceAll(", \\.", ".").replaceAll("\\. \\.", ".").replaceAll(", \\.", ".")
    // meta["tool_bibliography"] = toolBibliographyText()


    def methods_text = mqc_methods_yaml.text

    def engine =  new groovy.text.SimpleTemplateEngine()
    def description_html = engine.createTemplate(methods_text).make(meta)

    return description_html.toString()
}