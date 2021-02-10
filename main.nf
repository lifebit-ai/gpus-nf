// Header log info
log.info "\nPARAMETERS SUMMARY"
log.info "gpu_mode\t\t : ${params.gpu_mode}"
log.info "config\t\t\t : ${params.config}"
log.info "reps\t\t\t : ${params.reps}"
log.info "echo\t\t\t : ${params.echo}"
log.info "memory\t\t : ${params.memory}"
log.info "cpus\t\t\t : ${params.cpus}"
log.info "errorStrategy\t : ${params.errorStrategy}"
log.info "maxForks\t\t : ${params.maxForks}"
log.info "container\t\t : ${params.container}"
log.info "queueSize\t\t : ${params.queueSize}"
log.info "executor\t\t : ${params.executor}"
if(params.gpu_mode) log.info "accelerator\t\t : ${params.accelerator}"
if(params.gpu_mode) log.info "n_accelerators\t : ${params.n_accelerators}"
if(params.config == 'conf/google.config') log.info "gls_bootDiskSize : ${params.gls_bootDiskSize}"
if(params.config == 'conf/google.config') log.info "gls_preemptible : ${params.gls_preemptible}"
if(params.config == 'conf/google.config') log.info "zone\t\t\t : ${params.zone}"
if(params.config == 'conf/google.config') log.info "network\t\t : ${params.network}"
if(params.config == 'conf/google.config') log.info "subnetwork\t : ${params.subnetwork}"
log.info ""

if (!params.gpu_mode) {

ch_reps = Channel.from(1..params.reps)

    process with_cpus {
        tag "cpus: ${task.cpus},mem: ${task.memory} | rep: ${rep}, ${task.container}"
        label 'with_cpus'
        publishDir "${params.outdir}/cpu_mode/task_${rep}/", mode: "copy"

        input:
        val(rep) from ch_reps

        output:
        file("cpu_compute_metadata.json") optional true into my_output_files
        file("*") optional true

        script:
        if ( params.executor == 'google-lifesciences' )
        """
        echo "executor : ${params.executor}"
        echo "rep: ${rep}"
        curl "http://169.254.169.254/computeMetadata/v1/?recursive=true&alt=json" -H "Metadata-Flavor: Google" > "${rep}_cpu_compute_metadata.json"
        """
        else
        """
        cat .command.run > command.run
        echo "executor : ${params.executor}"
        echo "rep: ${rep}"
        ${params.script}
        """
    }
}

if (params.gpu_mode) {

ch_reps = Channel.from(1..params.reps)

    process gpu_mode {
        tag "cpus: ${task.cpus},mem: ${task.memory} | rep: ${rep}, ${task.container}"
        label (params.gpu_mode ? 'with_gpus': 'with_cpus')
        publishDir "${params.outdir}/gpu_mode/task_${rep}/", mode: "copy"

        input:
        val(rep) from ch_reps

        output:
        file("*") optional true

        script:
        """
        cat .command.run > command.run
        echo "executor : ${params.executor}"
        echo "rep: ${rep}"
        ${params.script}
        """
    }
}