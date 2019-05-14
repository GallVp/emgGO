# How to Detect Onsets/Offsets?

## Contents:

<ul>
    <li>
        <a href="README.md">How to Use emgGO?</a>
    </li>
    <li>
        <a href="importTutorial.md">How to Import Data in emgGO?</a>
    </li>
</ul>

## Event Detection

<p><a href="importTutorial.md">Import data</a> and run <code class="mcode">[resultEmg, optimalParams] = emgEventsDetectTool(EMG);</code> function.</p>

<p align="center">
<img alt="emgEventsDetectTool_labelled PNG image" src="../docs/figs/emgEventsDetectTool_labelled.png" height="auto" width="75%"/><hr>
<em>Fig 1. Data loaded in the <code>emgEventsDetectTool</code>.</em>
</p>

The EMG signal contains *56* muscle activation bursts. The bottom left corner of the tool, also shows that the algorithm has detected 56 onset/offset pairs. However, some of the activations have been detected incorrectly.

### Tune Algorithm with live Preview

The algorithm parameters can be manually optimised with live preview by increasing (+) or decreasing (-) parameter value. The intermediary results of each operation can be visualisd by *unchecking* the *Show final results* check-box. However, this manual tuning can take a long time. The following section describes how to automatically find correct number (56) of onset/offset pairs.

### Auto Find Operation

To automatically find correct number of onset/offset pairs, hit *Auto Find* button. Enter the estimated number of onset/offset pairs to find and click *OK*. The *nOptim* optimiser runs in the background and its progress is shown on a dialog box. The results obtained at the end of optimisation are shown below. Now the algorithm has detected the estimated number of onsets and offsets and their quality has also improved.

<p align="center">
<img alt="emgEventsDetectTool_desired PNG image" src="../docs/figs/emgEventsDetectTool_desired.png" height="auto" width="50%"/><hr>
<em>Fig 2. Results of Auto Find operation.</em>
</p>

## Manual Event Adjustment

To manually adjust the onsets/offsets, hit the *Manual Adjust* button. This brings up the *emgEventsManageTool*. This tool can be used to insert, delete and move individual onsets/offsets.

<p align="center">
<img alt="emgEventsManageTool_example PNG image" src="../docs/figs/emgEventsManageTool_example.png" height="auto" width="50%"/><hr>
<em>Fig 3. <code>eventsManageTool</code> showing a single muscle activation interval with the onset, the offset and the selection highlighter.</em>
</p>

An onset or an offset can be deleted by first selecting it with a left mouse click and then hitting the *Delete* button. To insert an onset or an offset at a particular point, left click that point and it will show a pink colored highlighted event as shown below. *Insert Onset* or *Insert Offset* button can then be used to insert an onset or an offset respectively.

### Efficient Manual Event Adjustment

The above described method of select, delete and select, insert can be very slow. An efficient method for adjusting onsets is described in following steps. First, all detected onsets are adjusted. Second, all the detected offsets are adjusted. Then, missing onsets/offsets are inserted manually.
<ul>
        <li>
            Scroll through the onsets using <em>leftarrow</em> and <em>rightarrow</em> keyboard keys.
        </li>
        <li>
            Zoom in x-axis using <em>/</em> key and zoom out using <em>.</em> key. Zoom in and out y-axis using <em>uparrow</em> and <em>downarrow</em> keys respectively.
        </li>
        <li>
            Select the currently shown onset by hitting <em>spacebar</em>.
        </li>
        <li>
            Move the selected onset by using <em>leftarrow</em> and <em>rightarrow</em> keys. To move the onset at faster speed use <em>q</em> and <em>e</em> keys.
        </li>
        <li>
            To finialise the position of the selected onset hit <em>spacebar</em>. Or hit <em>Esc</em> to unselect the onset without changing its position.
        </li>
        <li>
            To delete the selected onset, hit <em>d</em>. Please note, if you have deleted an onset without inserting another one in its place you have to delete the corresponding offset. Otherwise, some of the features explained later in this tutorial will not work.
        </li>
        <li>
            After adjusting all the onsets, hit <em>Scan Offsets</em> button to start scrolling through the offsets. Follow the above steps and adjuest the offsets.
        </li>
        <li>
            Once all detected onsets/offsets have been adjusted, hit <em>Channel View</em> button to open a window which show a simplified plot of EMG data with adjusted onsets and offsets. Find the time points where the onsets/offsets are missing. Go to the <em>emgEventsManageTool</em> and manually insert onsets/offsets at those points. <em>i</em> or <em>o</em> keys can be used to insert onset or offset at the highlighted point.
        </li>
</ul>

Once satisfied with the results, close this tool to go back to *emgEventsDetectTool*. The process of detecting and adjusting onsets/offsets is complete and the tool can be closed with results returned to MATLAB workspace.

## Auto Tune Parameters from Adjusted Onsets/Offsets

However, before closing the *emgEventsDetectTool*, another operation can be applied to find optimal parameters from adjusted onsets/offsets. These parameters can then be used as the starting point for similar datasets. To do that, simply click *Auto Tune* button. An optimier will run and result in the parameters selected using the new information from the adjustment of onsets/offsets.