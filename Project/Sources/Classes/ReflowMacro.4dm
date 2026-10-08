// Form macro: give the selected object more room and reflow the others (see Reflow).
// formMacros.json properties:
//   axis: "horizontal" | "vertical"
//   mode: "resize" (ask new size, then apply) | "grow" | "shift" | "center" (select those objects)

property axis : Text
property mode : Text

Class constructor($macro : Object)
	This.axis:=String($macro.axis)
	This.mode:=String($macro.mode)

Function onInvoke($editor : Object) : Object
	var $selection : Collection:=$editor.editor.currentSelection
	If ($selection.length#1)
		ALERT("Select exactly one object: the one that needs more room.")
		return {}
	End if

	var $reflow:=cs.Reflow.new(This.axis)
	var $page : Object:=$editor.editor.currentPage
	var $anchorName : Text:=$selection[0]
	var $anchor : Object:=$page.objects[$anchorName]
	If (Not($reflow.hasGeometry($anchor)))
		ALERT("\""+$anchorName+"\" has no "+$reflow.size+".")
		return {}
	End if
	var $plan:=$reflow.classify($page.objects; $anchorName)

	If (This.mode#"resize")
		var $names : Collection:=$plan[This.mode]
		If ($names.length=0)
			ALERT("No object to "+This.mode+" if \""+$anchorName+"\" "+$reflow.size+" changes.")
			return {}
		End if
		return {currentSelection: $names}
	End if

	var $current : Real:=$reflow.length($anchor)
	var $answer : Text:=Request("New "+$reflow.size+" for \""+$anchorName+"\" (now "+String($current)+"):"; String($current))
	If ((OK=0) || (Num($answer)<=0))
		return {}
	End if
	var $delta : Integer:=Num($answer)-$current
	If ($delta=0)
		return {}
	End if

	var $message : Text:=$reflow.describe($plan; $delta)
	var $notMoved : Text:=This._page0Warning($editor.editor; $reflow; $anchorName; $anchor)
	If ($notMoved#"")
		$message+="\r\rPage 0 cannot be changed by a macro, adjust by hand: "+$notMoved
	End if
	CONFIRM($message; "Apply"; "Cancel")
	If (OK=0)
		return {}
	End if

	$reflow.apply($page.objects; $plan; $delta)
	var $result:={currentPage: $page; currentSelection: [$anchorName]}
	var $properties : Object:=$editor.editor.formProperties
	If ($properties#Null)
		$reflow.applyToFormProperties($properties; $delta)
		$result.formProperties:=$properties
	End if
	return $result

	// Names of page 0 objects the reflow would touch (a macro only returns the current page)
Function _page0Warning($editor : Object; $reflow : cs.Reflow; $anchorName : Text; $anchor : Object) : Text
	If ($editor.currentPageNumber=0)
		return ""
	End if
	var $pages : Collection:=$editor.form.pages
	If (($pages=Null) || ($pages.length=0) || ($pages[0]=Null) || ($pages[0].objects=Null))
		return ""
	End if
	var $plan:=$reflow.classify($pages[0].objects; $anchorName; $anchor)
	return $plan.grow.combine($plan.shift).combine($plan.center).join(", ")
