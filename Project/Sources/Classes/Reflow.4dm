// Reflow the objects of a form page when one object (the anchor) gets bigger
// along one axis. Rules, relative to the anchor's original edges:
//   anchor                                        -> size + delta
//   starts at/after the anchor end                -> shift: moved by delta
//   spans the anchor, or sizing "grow"            -> grow: size + delta
//   starts inside the anchor and ends after it    -> center: moved by delta/2
//   ends before the anchor end                    -> unchanged

property axis : Text
property pos : Text
property size : Text
property end : Text
property sizing : Text
property minKey : Text
property column : Text  // listbox column receiving the extra width ("" = widest)

Class constructor($axis : Text; $column : Text)
	This.axis:=($axis="vertical") ? "vertical" : "horizontal"
	var $horizontal : Boolean:=(This.axis="horizontal")
	This.pos:=$horizontal ? "left" : "top"
	This.size:=$horizontal ? "width" : "height"
	This.end:=$horizontal ? "right" : "bottom"
	This.sizing:=$horizontal ? "sizingX" : "sizingY"
	This.minKey:=$horizontal ? "windowMinWidth" : "windowMinHeight"
	This.column:=String($column)

	// Size of an object along the axis, from its size or its end coordinate
Function length($object : Object) : Real
	If ($object[This.size]#Null)
		return $object[This.size]
	End if
	If ($object[This.end]#Null)
		return $object[This.end]-$object[This.pos]
	End if
	return 0

Function hasGeometry($object : Object) : Boolean
	return ($object#Null) && ($object[This.pos]#Null) && (($object[This.size]#Null) || ($object[This.end]#Null))

	// Sort the objects into grow/shift/center lists.
	// $anchor defaults to $objects[$anchorName]; pass it to classify another page (page 0).
Function classify($objects : Object; $anchorName : Text; $anchor : Object) : Object
	If ($anchor=Null)
		$anchor:=$objects[$anchorName]
	End if
	var $plan:={anchor: $anchorName; grow: []; shift: []; center: []}
	var $anchorStart : Real:=$anchor[This.pos]
	var $anchorEnd : Real:=$anchorStart+This.length($anchor)

	var $name : Text
	For each ($name; $objects)
		var $object : Object:=$objects[$name]
		If (($name#$anchorName) && This.hasGeometry($object))
			var $start : Real:=$object[This.pos]
			var $end : Real:=$start+This.length($object)
			Case of
				: ($start>=$anchorEnd)
					$plan.shift.push($name)
				: ($end<=$anchorEnd)
					// left/above the anchor end: unchanged
				: (($start<=$anchorStart) || ($object[This.sizing]="grow"))
					$plan.grow.push($name)
				Else
					$plan.center.push($name)
			End case
		End if
	End for each
	return $plan

	// Apply a plan from classify(). The anchor is resized only if it is in $objects.
Function apply($objects : Object; $plan : Object; $delta : Integer)
	var $anchor : Object:=$objects[$plan.anchor]
	If ($anchor#Null)
		This._resize($anchor; $delta)
		If ((This.axis="horizontal") && ($anchor.type="listbox"))
			This._resizeColumn($anchor; $delta)
		End if
	End if

	var $name : Text
	For each ($name; $plan.grow)
		This._resize($objects[$name]; $delta)
	End for each
	For each ($name; $plan.shift)
		This._move($objects[$name]; $delta)
	End for each
	For each ($name; $plan.center)
		This._move($objects[$name]; $delta\2)
	End for each

	// Grow the window minimum (and fixed size if any) of the form
Function applyToFormProperties($properties : Object; $delta : Integer)
	var $key : Text
	For each ($key; [This.minKey; This.size])
		If ($properties[$key]#Null)
			$properties[$key]:=$properties[$key]+$delta
		End if
	End for each

	// Human readable summary of a plan
Function describe($plan : Object; $delta : Integer) : Text
	var $sign : Text:=($delta>0) ? "+" : ""
	var $text : Text:=This.size+" of \""+$plan.anchor+"\": "+$sign+String($delta)
	$text+="\rGrow ("+$sign+String($delta)+"): "+This._names($plan.grow)
	$text+="\rMove ("+$sign+String($delta)+"): "+This._names($plan.shift)
	$text+="\rCenter ("+$sign+String($delta\2)+"): "+This._names($plan.center)
	return $text

Function _names($names : Collection) : Text
	return ($names.length=0) ? "-" : $names.join(", ")

Function _resize($object : Object; $delta : Integer)
	If ($object[This.size]#Null)
		$object[This.size]:=$object[This.size]+$delta
	End if
	If ($object[This.end]#Null)
		$object[This.end]:=$object[This.end]+$delta
	End if

Function _move($object : Object; $delta : Integer)
	$object[This.pos]:=$object[This.pos]+$delta
	If ($object[This.end]#Null)
		$object[This.end]:=$object[This.end]+$delta
	End if

	// The extra width goes to This.column, or to the widest column
Function _resizeColumn($listbox : Object; $delta : Integer)
	var $columns : Collection:=$listbox.columns
	If (($columns=Null) || ($columns.length=0))
		return
	End if
	var $column : Object
	If (This.column#"")
		$column:=$columns.query("name = :1"; This.column).first()
	End if
	If ($column=Null)
		$column:=$columns.orderBy("width desc").first()
	End if
	$column.width:=Num($column.width)+$delta
