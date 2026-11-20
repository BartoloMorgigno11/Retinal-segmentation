# Retinal Fundus Segmentation

MATLAB research pipeline for exploring retinal fundus-image segmentation. It produces masks and overlays for blood vessels, optic disc, exudates, and haemorrhages/microaneurysms. An optional pre-trained network can display an experimental severity-related output when an authorised local model is available.

> **Research and educational use only.** This project is not clinically validated and must not be used for diagnosis, screening, triage, treatment decisions, or any other medical purpose.

## Features

- Interactive selection of a local retinal fundus image.
- Vessel and optic-disc segmentation.
- Optional exudate and haemorrhage/microaneurysm segmentation.
- Automatic masks and overlays saved in `results/`.
- Optional local model hook; the core segmentation workflow does not require model weights.

## Requirements

- MATLAB R2023a or newer.
- Image Processing Toolbox.
- Statistics and Machine Learning Toolbox (for PCA-based vessel processing).
- Deep Learning Toolbox only when using the optional local severity model.

## Run from a clean clone

1. Clone the repository and open MATLAB in its root folder.
2. Add the project and helpers to the MATLAB path:

   ```matlab
   addpath(genpath(pwd));
   ```

3. Run:

   ```matlab
   Main
   ```

4. Choose an image you are authorised to use. Masks and overlays are written to `results/`.

## Data and model policy

No fundus images, annotations, generated results, or neural-network weights are distributed in this repository.

The original project used the [DIARETDB1](https://www.it.lut.fi/project/imageret/diaretdb1/) dataset. Its usage notice permits scientific research but forbids redistribution or modification without written permission. Obtain the data directly from its owners, comply with its licence and citation requirements, then place only your authorised local copies here:

```text
data/images/       % fundus images used as input
groundtruth/       % optional XML annotations for local evaluation
```

If you are authorised to use a compatible `dr_severity_regnet.mat`, place it in `models/` (or the project root). Without it, `Main` skips the optional model output and still runs the segmentation modules.

## Repository layout

- `Main.m` â€” interactive orchestration and optional local-model loading.
- `SegmentaVasi.m` â€” vessel segmentation.
- `SegmentaDiscoOttico.m` â€” optic-disc segmentation.
- `SegmentaEssudati.m` â€” exudate segmentation.
- `SegmentaEmorragieMicroaneurismi.m` â€” haemorrhage and microaneurysm segmentation.
- `XML/` â€” helpers for local XML annotations.
- `data/`, `groundtruth/`, `models/` â€” documented local-only asset locations.

## Limitations

- The thresholds and morphology settings are experimental and dataset-dependent.
- Outputs depend strongly on image quality, field of view, illumination, and camera/device characteristics.
- The optional model output is not a medical-grade severity assessment.

## License

The source code is released under the [MIT License](LICENSE). Dataset material, annotations, model weights, and generated clinical imagery remain subject to their own permissions and are deliberately excluded.
