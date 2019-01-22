# How to Use emgGO?

Following tutorials are available.
<ul>
    <li>
        <a href="importTutorial.md">How to import data in emgGO?</a>
    </li>
    <li>
        <a href="detectionTutorial.md">How to detect onsets/offsets?</a>
    </li>
</ul>

## Keyboard Shortcuts for emgEventsManageTool
<table class="tut-table">
        <tr>
            <th>Key</th>
            <th>Description</th>
        </tr>
        <tr>
            <td>&larr;, &rarr;</td>
            <td>Scroll through the onsets/offsets. Once an event is selected, these keys move the selection highlighter.</td>
        </tr>
        <tr>
            <td>&uarr;, &darr;</td>
            <td>Zoom in/out along the verticle direction.</td>
        </tr>
        <tr>
            <td>., /</td>
            <td>Zoom in/out along the horizontal direction.</td>
        </tr>
        <tr>
            <td>spacebar</td>
            <td>Select current onset/offset. Once an event is selected, it moves the event to the current poition of the selection highlighter.</td>
        </tr>
        <tr>
            <td>i, I</td>
            <td>Insert onset at the current poition of the selection highlighter.</td>
        </tr>
        <tr>
            <td>o, O</td>
            <td>Insert offset at the current poition of the selection highlighter.</td>
        </tr>
        <tr>
            <td>d, D</td>
            <td>Delete currently selected onset/offset.</td>
        </tr>
        <tr>
            <td>q, e</td>
            <td>Fast move selection highlighter.</td>
        </tr>
        <tr>
            <td>Esc</td>
            <td>Remove the selection highlighter.</td>
        </tr>
        <tr>
            <td>left-click</td>
            <td>Insert selection highlighter at current position of the mouse. Only works if emg plot or onset/offset is clicked.</td>
        </tr>
</table>
    
## Known Issues
Following problems are known and are being fixed.
<ol>
    <li>Keyboard shortcuts do not work after pressing a button in emgEventsManageTool.</li>
    <p>The solution is to click on the gray area in the window after pressing a button. The cause of the problem is that MATLAB does not return the focus back to the main window once a button is pressed. Hopefully, it will be fixed in a future version of MATLAB.</p>
</ol>