# emgGO

emgGO (electromyography, graphics and optimisation) is a toolbox for offline muscle activity onset/offset detection in multi-channel EMG data.

<p align="center">
<img alt="emgGO GUIs" src="./docs/figs/emgGO_a.png" height="auto" width="45%" style="margin-right:10px;"/><img alt="visualEEG main window" src="./docs/figs/emgGO_b.png" height="auto" width="45%"/><hr>
<em>Fig 1. The GUI tools of emgGo which allow interactive processing of data.</em>
</p>

## Related Publications

1. Optimal Automatic Detection of Muscle Activation Intervals, *Journal of Electromyography and Kinesiology*, doi: [10.1016/j.jelekin.2019.06.010](https://doi.org/10.1016/j.jelekin.2019.06.010)

## Compatibility

Currently emgGO is being developed on macOS Ventura, MATLAB 2022b. It is highly recommended to use MATLAB's Global Optimisation Toolbox and Parallel Computing Toolbox. In the absence of Global Optimisation Toolbox, a third party global optimisation algorithm is used which has not been fully tested. In the absence of Parallel Computing Toolbox, the optimisation algorithm uses a single core which results in significant speed reduction.

## Installation

1. Clone the git repository using git for the latest developmental version. Or, download a compressed copy of the latest stable release [here](https://github.com/GallVp/emgGO/archive/refs/tags/v2.0.zip).

```
git clone --recursive https://github.com/GallVp/emgGO
```

2. From MATLAB file explorer, enter the emgGO folder by double clicking it. Follow the [tutorials](https://github.com/GallVp/emgGO/tree/master/docs) to experiment with the sample data.

## Tutorials

<ul>
    <li>
        <a href="https://github.com/GallVp/emgGO/tree/master/docs/README.md">emgGO: An Overview</a>
    </li>
    <li>
        <a href="https://github.com/GallVp/emgGO/tree/master/docs/importTutorial.md">How to Import Data in emgGO?</a>
    </li>
    <li>
        <a href="https://github.com/GallVp/emgGO/tree/master/docs/detectionTutorial.md">How to Detect Onsets/Offsets?</a>
    </li>
    <li>
        <a href="https://github.com/GallVp/emgGO/tree/master/docs/pipelineTutorial.md">How to Create a Processing Pipeline?</a>
    </li>
    <li>
        <a href="https://github.com/GallVp/emgGO/tree/master/docs/edtaExplained.md">The Extended Double Thresholding Algorithm</a>
    </li>
</ul>

## Third Party Libraries

emgGO uses following third party libraries. The licenses for these libraries can be found next to source files in their respective libs/thirdpartlib folders.

1. `energyop` Copyright (c) 2014, Hooman Sedghamiz. Source is available [here](https://au.mathworks.com/matlabcentral/fileexchange/45406-teager-keiser-energy-operator-vectorized).
2. `PSOt` Copyright (c) 2005, Brian Birge. Source is available [here](https://au.mathworks.com/matlabcentral/fileexchange/7506-particle-swarm-optimization-toolbox).
