//%attributes = {}
// Run with tool4d: --startup-method=test_Reflow --skip-onstartup --dataless
// The expected fixture was produced by the 4d-form-widen skill (list +50).

var $failures : Collection:=[]
var $tests : 4D.Folder:=Folder(fk resources folder).folder("tests")

// Horizontal: EMBEDDINGS form, listbox "list" +50, all pages
var $form : Object:=JSON Parse($tests.file("embeddings.4DForm").getText())
var $expected : Object:=JSON Parse($tests.file("embeddings-expected.4DForm").getText())
var $reflow:=cs.Reflow.new("horizontal")
var $anchor : Object:=OB Copy($form.pages[1].objects.list)
var $page : Object
For each ($page; $form.pages)
	If ($page#Null)
		$reflow.apply($page.objects; $reflow.classify($page.objects; "list"; $anchor); 50)
	End if
End for each
$reflow.applyToFormProperties($form; 50)

var $index : Integer
For ($index; 0; $form.pages.length-1)
	If ($form.pages[$index]#Null)
		var $name : Text
		For each ($name; $form.pages[$index].objects)
			var $got:=JSON Stringify($form.pages[$index].objects[$name])
			var $want:=JSON Stringify($expected.pages[$index].objects[$name])
			If ($got#$want)
				$failures.push("page "+String($index)+" "+$name+"\n  got:  "+$got+"\n  want: "+$want)
			End if
		End for each
	End if
End for
If ($form.windowMinWidth#$expected.windowMinWidth)
	$failures.push("windowMinWidth "+String($form.windowMinWidth))
End if

// Classification of the same form
var $plan:=cs.Reflow.new("horizontal").classify(JSON Parse($tests.file("embeddings.4DForm").getText()).pages[1].objects; "list")
If ($plan.center.orderBy().join(",")#"empty.box,empty.steps,empty.title")
	$failures.push("center: "+$plan.center.join(","))
End if
If ($plan.grow.orderBy().join(",")#"intro,schedulerFooterBar,schedulerFooterSep,schedulerStatus,schedulerStatusError")
	$failures.push("grow: "+$plan.grow.join(","))
End if

// Vertical, with an object using bottom instead of height
var $objects:={\
anchor: {top: 10; height: 100}; \
below: {top: 120; height: 20}; \
side: {top: 0; bottom: 200}; \
middle: {top: 50; height: 100}; \
above: {top: 0; height: 5}}
$reflow:=cs.Reflow.new("vertical")
$reflow.apply($objects; $reflow.classify($objects; "anchor"); 20)
var $vertical:=JSON Stringify($objects)
If ($vertical#"{\"anchor\":{\"top\":10,\"height\":120},\"below\":{\"top\":140,\"height\":20},\"side\":{\"top\":0,\"bottom\":220},\"middle\":{\"top\":60,\"height\":100},\"above\":{\"top\":0,\"height\":5}}")
	$failures.push("vertical: "+$vertical)
End if

If ($failures.length=0)
	LOG EVENT(Into system standard outputs; "test_Reflow: OK\n")
Else
	LOG EVENT(Into system standard outputs; "test_Reflow: FAILED\n"+$failures.join("\n")+"\n")
End if
