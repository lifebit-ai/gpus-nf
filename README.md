## gpu-nf

Minimal example to showcase use of GPU enabled machine with the google-lifesciences executor for Nextflow workflow


### Usage:

To test locally:

```bash
git clone https://github.com/cgpu/gpu-nf.git
cd gpu-nf
nextflow run . --gpu_mode false --executor 'local' --echo true --reps 4 --config conf/standard.config
```