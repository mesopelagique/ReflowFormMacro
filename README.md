# ReflowFormMacro

Form macros to give an object more room in the 4D form editor and reflow the other objects.

Select one object (a listbox for instance), run **Reflow: resize width…**, type the new width, check the summary, apply.

## Rules

Relative to the original edges of the selected object (the anchor):

| Object | Change |
|---|---|
| the anchor | size + delta |
| starts at/after the anchor end | moved by delta |
| spans the anchor, or sizing set to "grow" | size + delta |
| starts inside the anchor and ends after it (centered) | moved by delta/2 |
| ends before the anchor end | unchanged |

For a listbox, the extra width goes to its widest column. The form `windowMinWidth` (or `windowMinHeight`) grows too.

## Macros

| Macro | |
|---|---|
| Reflow: resize width… / height… | ask for the new size, show what changes, apply |
| Reflow: select objects that grow in width / height | select the objects that will grow |
| Reflow: select objects moved right / down | select the objects that will move by delta |
| Reflow: select objects re-centered horizontally / vertically | select the objects that will move by delta/2 |

The select macros let you see in the editor what a resize will touch before doing it.

## Limitation

A form macro only returns the current page, so page 0 objects are not moved. The resize summary lists them so you can adjust them by hand.

## Installation

Add this project as a component (dependencies.json):

```json
{
	"dependencies": {
		"ReflowFormMacro": {
			"github": "mesopelagique/ReflowFormMacro"
		}
	}
}
```

## Tests

```bash
tool4d --project=Project/ReflowFormMacro.4DProject --startup-method=test_Reflow --skip-onstartup --dataless
```
