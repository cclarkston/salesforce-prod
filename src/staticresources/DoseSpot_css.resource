html, body, div, h1, h2, h3, h4, h5, h6, ul, ol, dl, li, dt, dd, p, blockquote, pre, form, fieldset, table, th, td
{ margin: 0; padding: 0; font-family: Arial, Sans-Serif; border:none 0px; }

body {
	font-size: 1.05em;
	line-height:1.5em;
	/*background: #3b89c9;*/
	background: transparent;
	height: 100%;
	-moz-box-sizing: border-box;
	color: #000000;
    word-wrap: break-word;
	}

ol, ul        { margin: 1.12em 0; margin-left: 40px; }
ol            { list-style-type: decimal }
ol ul, ul ol,
ul ul, ol ol  { margin-top: 0; margin-bottom: 0 }

img
{
	border: none 0px;
}

#dosespotlogo
{
	width:180px;
	height: 74px;
}

a:hover
{
	color:#f58353;
}

h1
{
	font-size:1.5em;
	line-height:1.5em;
	display: inline;
	margin:  0px 10px 0px 15px;
}
h2
{
	font-size:1.3em;
	line-height:1.5em;
	display: inline;
	margin:  0px 10px 0px 10px;
}
h1.alert, h2.alert
{
	color: #ff7937;
}
.validationalert
{
    font-size:.9em;
    font-weight:bold;
    color: Red;
}
.medSearchError
{
    color:#444444;
    font-size:0.9em;
}

#main
{
	width: 1000px;
	margin-left: auto;
    margin-right: auto;
	/*background: #d2dee5;*/
	background: transparent;
	padding-bottom:200px;
}
#wrap
{
	/*background:#d2dee5;*/
	background: transparent;
	width:100%;
}
#blankpage
{
	background:#ffffff;
	padding: 20px;

}
#dosespot
{
	padding:10px 10px 0 10px;
}


#nav
{
	background-color:white;
	border-bottom:solid 3px #f58353;
}

#nav ul
{
	border:none 0px;
	list-style-type:none;
	margin:0;
    padding:0 0 0 0px;
}
.helplink
{
   padding-left:5px;
}
#nav li
{
	border:none 0px;
	list-style-type:none;
   margin:0px 0px 0px 0px;
    padding:0;
   vertical-align:top;
   height:28px;
   width:150px;
   display: inline;
}
#nav img
{
	top:2px;
	border:none 0px;
	margin:0;
	padding: 0;
}
#nav li a
{
   top:2px;
   margin:0;
   border:none 0px;
   padding:0;
   background:transparent url(/secure/images/DoseSpotNavigationSprite.png) no-repeat left top;
   vertical-align:bottom;
   height:28px;
   display:inline-table;
}
#nav li a.sprite-Dashboard {background-position: -330px 0;}
#nav li a.sprite-DashboardOn {background-position: -495px 0;}
#nav li a:hover.sprite-Dashboard {background-position: -495px 0;}

#nav li a.sprite-Patients { background-position: 0 0;}
#nav li a.sprite-PatientsOn { background-position: -165px 0; }
#nav li a:hover.sprite-Patients { background-position: -165px 0; }

#nav li a.sprite-Pharmacies { background-position: -660px 0; }
#nav li a.sprite-PharmaciesOn { background-position: -825px 0; }
#nav li a:hover.sprite-Pharmacies { background-position: -825px 0; }

#nav li a.sprite-FavoriteRx { background-position: -990px 0; }
#nav li a.sprite-FavoriteRxOn { background-position: -1155px 0; }
#nav li a:hover.sprite-FavoriteRx { background-position: -1155px 0; }

#nav li a.sprite-Logout { background-position: -1320px 0;}
#nav li a:hover.sprite-Logout { background-position: -1485px 0; }

#nav li a.sprite-Reports { background-position: -1650px 0; }
#nav li a.sprite-ReportsOn { background-position: -1815px 0; }
#nav li a:hover.sprite-Reports { background-position: -1815px 0; }

#locationbar
{
	margin-top: 1px;
	color:white;
	/*background-color:#125687;*/
	background-color: cornflowerblue;
	padding-left: 8px;
	padding-right: 8px;
	vertical-align:middle;
}
#locationtitle
{
	vertical-align:middle;
	font-size:1.3em;
	height:28px;
	padding-top:3px;
	padding-bottom:3px;
}

#backlink
{
	vertical-align:middle;
	text-align:right;
	font-size: .9em;
	float:right;
	height:28px;
	padding-top:3px;
	padding-bottom:3px;
}
#backlink a
{
	color:White;
}
#backlink a:hover
{
	color: #f58353;
}

#userBar
{
    background-color: #FFFFFF;
    border-bottom: 1px solid #125687;
    font-size: 0.9em;
    padding-left: 5px;
    padding-right: 5px;
}

#userBar .left
{
    float: left;
    text-align: left;
}

#userBar .right
{
    float: right;
    text-align: right;
}

.small
{
    font-size: 0.8em;
}

#userBar #UserClinics
{
    font-size: 0.5.em;
}

.findpatient
{
	margin: 0px 15px 5px 45px;
	border:solid 1px #abadb3;
}

#PatientAddEdit
{
 width :960px;
 border: solid 1px #3b89c9;
 margin: 0px 10px 10px 10px;
 padding-top: 10px;
 background-color:White;
}

.patientlist
{
	margin-left: 20px;
	margin-right: 20px;
	margin-bottom: 20px;
	margin-top: 5px;
	width:770px;
}
.patientlist td, .patientlist th
{
	padding: 7px 10px;
}
.patientlist td:first-child
{
	width: 370px;
}
.patientlist td:nth-child(2)
{
	width: 50px;
}
.patientlist td:nth-child(3)
{
	width: 50px;
}
.patientlist td:nth-child(4)
{
	width: 200px;
}
.patientlist td:nth-child(5)
{
	width: 100px;
}

#patientmedical, #patientcontact
{
	width:580px;
	margin: 5px 0px 5px 10px;
	border: solid 1px #b6b6b6;
}
#patientdetail
{
	width: 290px;
	float:left;

	margin-top: 69px;
}
#patientdetail .name
{
	font-size:1.1em;
	font-weight:bolder;
	padding-bottom: 10px;
	padding-left: 10px;
	padding-right: 8px;
}
#patientdetail .patientfacts
{
	padding-bottom: 13px;
		padding-top: 13px;
}
#patientdetail .left
{
	color: #666666;

	width: 4em;
	float:left;
	text-align:right;
}
#patientdetail .right
{
	font-weight:bold;
	text-align: left;
}
#patientdetail p.address, #patientdetail p.phone
{
	padding-bottom: 10px;
}

#patientdetail p span.title
{
	padding-left:0px;
	color: #666666;
}

#patientdetail .editlink, #patientdetail .pharmacyeditlink, #patientdetail .allergyeditlink, #patientdetail .patienteditlink
{
	background-color: #f3f9fb;
	border: solid 1px #92b1cd;
	border-top: solid 1px white;
	margin-left:78px;
	margin-top:-7px;
	width:205px;
	font-size: .8em;
	text-align:center;
}
#patientdetail .editlink a,#patientdetail .editlink a:visited, #patientdetail .editlink a:active,#patientdetail .pharmacyeditlink a,#patientdetail .pharmacyeditlink a:visited, #patientdetail .pharmacyeditlink a:active, #patientdetail .allergyeditlink a,#patientdetail .allergyeditlink a:visited, #patientdetail .allergyeditlink a:active, #patientdetail .patienteditlink a,#patientdetail .patienteditlink a:visited, #patientdetail .patienteditlink a:active
{
	color: #ff7937;
}
.passwordlink
{
    color: #ff7937;
    font-size: .8em;
}
#right
{
	margin : 5px 10px 5px 10px;
	float:right;
	width:350px;
	vertical-align:top;
}
#patientpharmacy
{
 width :75%;
 border: solid 1px #3b89c9;
}
.pharmacylistsearch
{
    font-weight: normal;
    padding-left: 5px;
}
#addnewprescriptionbuttondiv
{
	width: 100%;
	text-align: right;
	margin-top: -50px;
	display: block;
	margin-bottom: 10px;
}

legend    {
  padding: 0 2px;
  font-weight: bold;
}
#patinfo label, #allergies label, #patientpharmacy label {
  display: inline-block;
  line-height: 1.5;
  vertical-align: top;
  text-align:right;
  padding-right: 5px;
  width: 160px; /* Width of labels */
  color: #333333;
}
#patinfo ol, #allergies ol, #patientpharmacy ol {
  margin: 0;
  padding: 0;
  list-style: none;
}
#patinfo li, #allergies li, #patientpharmacy li {
  list-style: none;
  padding: 5px;
  margin: 0;
}
#patinfo h2
{
	font-size: 1em;
	font-weight:bold;
	margin:15px 5px 0px 10px;
}

.hidden
{
    display:none;
}

fieldset {
  border: none;
  margin: 3px 0 0;
}
#dentalalerts
{
    padding: 10px;
    text-align:left;
    margin-bottom:60px;
    font-size:1.3em;
	line-height:1.5em;
    margin-left:294px;
}
#dentalalertslink
{

    margin-left:15px;
    color:White;
}
#dentalalertslink:hover
{

    color:Black;
}
em {
  font-weight: bold;
  font-style: normal;
  color: #f00;
}
input[type="submit"]
{
	padding: 2px;
	margin: 5px 15px;
}

#patinfo input[type="submit"], #allergies input[type="submit"], textarea, input[type="checkbox"]
{
	margin-right:10px;
	margin-left:auto;
	font-size: 1.1em;
}

input[type="text"], select, textarea
{
	border: 2px solid #999999;
	font-size: 1.1em;
}

.loginTextBoxes
{
	border: 2px solid #999999;
	font-size: 1.1em;
	width: 300px;
}

.orangebuttonintense, .orangebuttoncreate, .orangebuttonedit,.savepatient, #loadMedicationHistoryButton, .pharmacyorangebuttonintense, .orangebuttonintenselink
{
	font-size: 1.1em;
	background-color: #ff7937;
	color: white;
	border: solid 1px #999999;
}
.orangebuttonaddnewscript
{
	text-align:center;
	/*font-size: 1.1em;*/
	font-size: 1.5em;
	/*background-color: #ff7937;*/
	background-color: cadetblue;
	color: white;
	/*border: solid 1px #999999;*/
	border: none;
	padding: .5em;
	font-weight: 200;
	letter-spacing: .1em;
}

.orangebuttonlight, .orangebuttoncreatedisabled, #add-self-reported, #add-detailed-self-reported
{
	font-size: .9em;
	background-color: #ffcb94;
	color: #333333;
	border: solid 1px #999999;
}

.orangealerts
{

    width:690px;
	background-color: white;
	border: solid 1px #999999;
    text-align:left;
    margin-bottom:60px;
    font-size:1.3em;
	line-height:1.5em;
    margin-left:294px;
    padding-bottom:10px;
}
.orangeheader
{
    width:683px;
    color:White;
    padding-left:7px;
	background-color: #ff7937;
    text-align:left;
    font-size:1.2em;
	line-height:1.4em;
}
.orangealerts a.severity3:visited, .orangealerts a.severity3:link, .orangealerts a.severity3:link
{
    font-size:1em;
    font-weight:bold;
    padding-left:10px;
}
.orangealerts a.severity2:visited, .orangealerts a.severity2:link, .orangealerts a.severity2:link
{
    font-size:.85em;
    padding-left:10px;

}
.orangealerts a.severity1:visited, .orangealerts a.severity1:link, .orangealerts a.severity1:link
{
    font-size:.7em;
    padding-left:10px;

}

.buttondelete
{
	font-size: .9em;
	background-color: #f5f5f5;
	color: #333333;
	border: solid 1px #999999;
}
input:focus, select:focus, textarea:focus
{
	border: solid 2px #f58353;
}
input[type="text"].unfocused, textarea.unfocused
{
	color: #C0C0C0;
}
li span.namecomma
{
	font-size:2em;
}

table.medicationlist, #medicationrefillrequestlist
{
	width:690px;
	padding:0px;
	color:#333333;
	border:none 0px;
	vertical-align:middle;
}

table.medicationhistory
{
    width: 690px;
    background-color: white;
    font-weight: bold;
    padding-left: 8px;
}

table.medicationlist tr th, #medicationrefillrequestlist tr th
{
	background-color:#5D7B9D;
	font-weight:bold;
	color: White;
	text-align:left;
	height: 2em;
	margin:0;
	padding:5px;
}
table.medicationlist tr th:first, #medicationrefillrequestlist tr th:first
{
	padding-left:10px;
}
table.medicationlist tr th:last, #medicationrefillrequestlist tr th:last
{
	padding-right:10px;
}
table.medicationlist tr td, #medicationrefillrequestlist tr td
{
	text-align:center;
}

#medicationlists, #dvmedicationadd, #actionpane
{
	width:686px;
	margin-left:294px;
}
#medicationlists
{
	margin-top:30px;
	padding-top: 30px;
}
#medicationlists .firstmedicationlist
{
	margin-top:3px;
}
#dvmedicationadd h3
{
	font-weight:normal;
	color: #000000;
	padding:0;
	margin:0;
	margin:.5em 0;
	text-align:left;
}
#tblMedicationAdd
{
    display: block;
    width: 100%;
}
#dvMedicationSearch
{
	padding: 0px  5px 5px 0px;
	margin: 3px 0px 5px 0px;
}
#divMedSelected
{
    float: right;
    width: 50%;
    display: block;
    padding: 7px;
    border: solid 1px #f58353;
    margin: 3px;
}
#divMedCoverageInfo
{
    float: right;
    width: 50%;
    display: block;
    padding: 7px;
    margin: 3px;
}
#selectedMedicationValue, #selectedStrengthValue
{
	color: #006bbb;
	font-size:.85em;
}
#selectedStrengthLabel, #selectedMedLabel
{
	color:#999999;
	font-size:.8em;
}
#SearchAgain
{
	font-size:.8em;
}
#dvFinalInfo
{
	width:45%;
	float:left;
}
#tbWrapMedicationAdd
{
    width:100%;
    display:table;
}
#tbWrapMedicationAdd td
{
    width:100%;
}
#divMedCoverageInfo
{
    font-size:0.9em;
    border:1px solid #92b1cd;
}

#medCoverageInfoDetails, #medCoverageTherapeuticAltDetails, #medCoverageTherapeuticAltLoading
{
    font-size:1.1em;
    line-height: 1.6em;
}

#medCoverageInfoDetails .heading, #medCoverageTherapeuticAltDetails .heading
{
    color:#888888;
    font-size:1em;
}

#medCoverageInfoDetails .headingDark
{
    color:#666666;
    font-size:1em;
}

#medCoverageInfoDetails .highlighted, #medCoverageTherapeuticAltDetails .highlighted
{
    color:#006bbb;
    font-size:1.05em;
}

#medCoverageInfoDetails .highlightedDark
{
    font-weight:bold;
    color:#125687;
    font-size:1em;
}

#medCoverageInfoDetails .grayBox, #medCoverageTherapeuticAltDetails .grayBox
{
    background:#ffffff;
    border:1px solid #d2dee5;
    padding:5px;
}

#medCoverageInfoDetails .whiteBox
{
    background:#eeeeee;
    border:1px solid #aaaaaa;
    padding:5px;
}

#medCoverageInfoDetails .hidden
{
    display:none;
}

#coverageRestrictionsDetails p
{
    margin-left:5px;
}

#medCoverageInfoDetails ul, #medCoverageInfoDetails ol
{
    color:#666666;
    margin-top:0;
    margin-bottom: 0;
    margin-right: 0;
    padding: 0;
}

#medCoverageInfoDetails a.rightLink
{
    float:right;
}

table.alternativeInfo
{
    background-color:#eeeeee;
    border:1px solid #aaaaaa;
}

table.alternativeInfo th
{
    color:#1771b3;
    background-color:#d4d4d4;
    border:1px solid #eeeeee;
    font-weight:normal;
    margin:1px;
    padding:2px;
}

table.alternativeInfo td
{
    padding:2px;
    margin:1px;
    font-size:0.95em;
}

table.alternativeInfo tr.even
{
    background-color:#eeeeee;
}

div#medCoverageTherapeuticAltDetails ol ul
{
    color:#125687;
    list-style:none;
    margin:0;
    padding:0;
}

#directions
{

}
#dispense
{
	float:left;
	width:300px;
	text-align:left;
	vertical-align:top;
}
#StandardDispenseUnits
{
	margin-left:5px;
}

#dayssupply
{
	float:right;
	width:120px;
	margin-left:100px;
	text-align:left;
	vertical-align:top;
}
#refills
{
	width:80px;
	margin-left:0px;
	margin-right:130px;
	margin-top: 0px;
	text-align:left;
	vertical-align:top;
}
#substitutions
{
	margin-top:1em;
}
#pharmacynotes
{
	margin-top:1em;
}
#pharmacysearchresults
{
    color:#333333;
    width:100%;
    margin-top:5px;
}
#pharmacysearchresults .pharmacyresults-odd
{
    background-color:#F7F6F3;
    color:#333333;
}
#pharmacysearchresults .pharmacyresults-even
{
    background-color:white;
    color:#284775;
}
#pharmacysearchresults .hover,
#PatientPharmacies .hover
{
    background-color: #ff9999;
}
#pharmacysearchresults tr td
{
	padding:10px;
}
#pharmacysearchresults thead
{
    color:White;
    background-color:#5D7B9D;
    font-weight:bold;
}
#tblPendingList
{
    width:690px;
    background-color:white;
    font-weight:bold;
    padding-left:8px;
}
.medname
{
	font-weight:bold;
}

a.mednamelink:visited, a.mednamelink:active, a.mednamelink:link
{
	color: Black;
	text-decoration:none;
}
a.mednamelink:hover
{
    color: #666666;
}
#showaddress
{
	font-weight:normal;
}
div.whitebox, table.whitebox
{
	border:solid 1px #92b1cd;
	background-color:white;
	color:black;
	margin:5px;
	margin-left:0px;
	margin-top:0px;
	padding-left:0px;
	padding-bottom:0px;
	font-weight:normal;
}

.alerttext
{
	color:maroon;
	text-align:right;
	float:right;
	padding-right:5px;
}
.alerttextoneline
{
	color:white;
	text-align:right;
	float:right;
	padding-right:10px;
	margin-top: 1px;
	/*background-color: rgb(18, 86, 135);*/
	background-color: transparent;
}

a.refillapprovelink,a.refilldenylink, .ui-widget-content a.refillrequestdispense,.ui-widget-content a.denyrequestreason,a.refillapprovelinkscheduled,a.refilldenylinkscheduled,  #refill0specialapprove, #skipdenyrefillcomments, #skipdenyrefillcomments:visited, #skipdenyrefillcomments:active, #skipapproverefillcomments, #skipapproverefillcomments:visited, #skipapproverefillcomments:active
{
	text-decoration:underline;
	color: #3B89C9;
	margin-bottom:4px;
}


a.refillapprovelink:hover,a.refilldenylink:hover, .ui-widget-content a.refillrequestdispense:hover,.ui-widget-content a.denyrequestreason:hover,a.refillapprovelinkscheduled:hover,a.refilldenylinkscheduled:hover,  #refill0specialapprove:hover, #skipdenyrefillcomments:hover, #skipapproverefillcomments:hover
{
	color: #f58353;
}
a.refillsingle, a.printlink
{
	padding-right:10px;
}
.odd
{
	background-color:#f7f6f3;
}
.even
{
	background-color:White;
}
input[type="submit"].left
{
    text-align:left;
    margin: 0;
}
div.single
{
	margin-top:-15px;
	padding-top:10px;
	padding-bottom:10px;
}

.footnote
{
    margin:5px;
    padding:5px;
    border:1px solid #AAAAAA;
    color:#444444;
    font-size:0.6em;
}

.footnote p
{
    line-height:normal;
}

div#systemMessages
{
    margin:10px;
}

div#systemMessages div
{
    margin:5px;
    padding:5px;
    text-align:center;
}

#systemMessages .success
{
    background-color:#CAFFCA;
    border:1px solid #00AA00;
}

#systemMessages .error
{
    background-color:#FFCACA;
    border:1px solid #AA0000;
}

#systemMessages .warning
{
    background-color:#FFFFCA;
    border:1px solid #AAAA00;
}

#drugAllergyList ul
{
    margin:5px;
    margin-left: 20px;
}

/* ========== DrugAllergyList.ascx ========== */
.buttonContainer
{
    margin: 5px;
    padding: 5px;
}

.orangeButton
{
	font-size: 1.1em;
	background-color: #FF7937;
	color: white;
	border: solid 1px #999999;
}

.right
{
    float: right;
}

.listContainer
{
    margin: 5px;
    padding: 5px;
}

.listContainer h2
{
    font-size: 1.25em;
}

.listContainer p, .drugAllergyAlerts p
{
    margin: 5px;
    padding: 5px;
}

.listContainer .allergy
{
    margin: 5px;
    padding: 5px;
}

.listContainer .allergy p
{
    color: #999999;
    margin: 0;
    padding: 0;
}

.listContainer .allergy .allergyName
{
    color: #000000;
    font-weight: bold;
}

.listContainer table.details
{
    border: 1px solid #555555;
}

#addAllergyDialog, #editAllergyDialog
{
    display: none;
}

.allergyDialog h1
{
    margin: 5px;
    margin-bottom: 10px;
}

.allergyDialog table
{
    margin: 5px;
}

.allergyDialog table th, .allergyDialog table td
{
    padding: 5px;
}

.allergyDialog table th
{
    text-align: right;
    vertical-align: top;
}

.allergyDialog table td
{
    width: 60%;
}

.allergyDialog table input, .allergyDialog table select, .allergyDialog table textarea
{
    width: 100%;
}

.ui-autocomplete-loading
{
    background: white url('/secure/images/smLoading.gif') right center no-repeat;
}

.ui-autocomplete-category {
	font-weight: bold;
	padding: .2em .4em;
	margin: .8em 0 .2em;
	line-height: 1.5;
}

#allergyInteractionAlerts
{
    margin-bottom: 20px;
    line-height: 1.25em;
}

.interactionType1
{
    color: #CC0000;
    font-size: 1em;
    font-weight: bold;
}

.interactionType2
{
    color: #999900;
    font-size: 0.85em;
}
#patientlistheader
{
    display:block;
    margin: 10px 0px 5px 20px;
}
#divShowMyRecentPatients
{
    display:inline;
    margin-top:8px;
    margin-bottom: 8px;
    margin-left:45px;
    font-size: .8em;
}
#divEditConfigurations
{
    padding-left: 10px;

}
.configurationLabel
{
    font-weight: bold;
}
.configurationalert
{
    color:maroon;
	text-align:left;
	padding-left:30px;
}

.gray-label
{
    font-size: .8em;
    color: gray;
    font-weight: normal;
}

/* Medication List Styles
------------------------------------------ */
.medication-list-title
{
    font-weight: bold;
    margin-bottom: 2px;
    padding: 5px;
    padding-left: 8px;
}

.medication-list-tab
{
    background-color: #F7F6F3;
    border: 1px solid #888;
    border-bottom: none;
    cursor: pointer;
    float: left;
    margin-left: 5px;
    padding: 0 5px;
    text-align: center;
    width: 100px;
}

.medication-list-tab.selected
{
    background-color: #9BAEC4;
    color: #FFF;
}

.medication-list
{
    border-collapse: collapse;
    width: 100%;
}

.medication-list th
{
    background-color: #5D7B9D;
    color: #FFF;
    font-weight: bold;
    padding: 5px;
    padding-left: 10px;
    text-align: left;
}

.medication-list td
{
    padding: 10px;
}

.medication-list .medication
{
    font-weight: bold;
}

.medication-list .medication a:link, .medication-list .medication a:active, .medication-list .medication a:visited
{
    color: #000;
    text-decoration: none;
}

.medication-list .medication a:hover
{
    color: #666;
}

.medication-list .substitutions, .medication-list .notes
{
    color: #999;
}

.medication-list .pharmacy a:link, .medication-list .pharmacy a:active, .medication-list .pharmacy a:visited,.prescriber a:link, .medicationdispensed a:link,
.medication-list .reprint-link a:link, .medication-list .reprint-link a:active, .medication-list .reprint-link a:visited,
.show-duplicates-container a:link
{
    color: #333;
    font-size: 0.7em;
}

.medication-list .pharmacy a:hover
{
    text-decoration: none;
}

.medication-list .status
{
    text-align: center;
}

.medication-list .refill a:link, .medication-list .refill a:active, .medication-list .refill a:visited
{
    color: #00E;
}

.medication-list .refill a:hover
{
    text-decoration: none;
}

.medication-list tfoot td
{
    border-top: 1px solid #5D7B9D;
    font-size: 0.8em;
    padding: 5px 10px;
}


#existing-interactions
{
    background-color: #FFC;
    border-bottom: 1px solid #FFEF68;
    color: #222;
    display: none;
    font-size: 0.8em;
    padding: 0;
    text-align: center;
}

#existing-interactions a:link, #existing-interactions a:active, #existing-interactions a:visited
{
    color: #222;
}

#existing-interactions a:hover
{
    text-decoration: none;
}

#existing-interactions-list
{
    display: none;
    text-align: left;
}

/* Self Reported Medications
---------------------------------------- */
#add-self-reported, #add-detailed-self-reported
{
    margin-top: 5px;
	display: none;
}

#self-reported-dialog
{

}

#self-reported-dialog table
{
    border:0;
    margin:0;
    width:100%;
}

#self-reported-search td
{
    padding:5px;
    vertical-align:top;
}

#self-reported-search #self-reported-search-text
{
    width:100%;
}

#self-reported-search .note
{
    color:#990000;
    font-size:0.75em;
    font-style:italic;
    padding-top:0;
    visibility:hidden;
}

#self-reported-list
{
    border-collapse:collapse;
    width:100%;
}

#self-reported-list thead th
{
    border-bottom:1px solid #888;
    font-weight:normal;
    text-align:left;
}

#self-reported-list tbody td
{
    border-bottom:1px solid #DDD;
    font-size:0.8em;
}

#self-reported-list .free-text
{
    font-style:italic;
}

#self-reported-list .remove
{
    text-align:right;
}

#self-reported-list .remove a:link, #self-reported-list .remove a:active, #self-reported-list .remove a:visited
{
    text-decoration:none;
}

#self-reported-list .remove a:hover
{
    text-decoration:underline;
}

#remove-medication-dialog p
{
    margin: 5px 0;
}

textarea.hint
{
    color: #AAA;
    font-style: italic;
}

textarea.remove-medication-note
{
    display: none;
    margin-left: 25px;
}

.medication-list-dialog a:link, .medication-list-dialog a:active, .medication-list-dialog a:visited
{
    color: #00F;
}

.medication-list-dialog a:hover
{
    text-decoration: none;
}

.medication-list-sort
{
    float: right;
    font-size: 1em;
    margin-right: 5px;
}

.medication-list-sort .sort-by
{
    border-bottom-width: 1px;
    font-size: 0.9em;
}

.legal-agreement
{
    width: 775px;
    height: 500px;
    overflow: auto;
}

#duppatienterror td
{
    vertical-align: top;
}

#dvPrescribersList
{
    text-align: center;
}

#dvWaitRedirect
{
    text-align: center;
    color: White;
}

.orangebackground
{
    background-color: #F58353;
}

.horizontal-rule
{
    height:2px;
    background-color:#ff7937;
    color:#ff7937;
    border: solid 1px #ff7937;
    padding-bottom:1px;
}

#reportlist ul
{

  list-style: none;
  padding: 5px;
  margin: 0;
}

#reportlist li
{
  display: inline;
  list-style: none;
  padding: 5px;
  margin: 0;
}

.reportViewer
{
    overflow: visible;
}

#report
{
    width: 99%;
    border:solid 1px #92b1cd;
	background-color:white;
	color:black;
	margin:5px;
	margin-left:0px;
	margin-top:0px;
	padding-left:0px;
	padding-bottom:0px;
	font-weight:normal;
	overflow: visible;
}

.cancelmedspan
{
    float:right;
    padding-right:10px;
}

.favoritespan
{
    vertical-align:middle;
}

#dvFavoritesList .header
{
    font-weight:bold;
    color:#5d7b9d;
}

#addnewrxfrompharmacies
{
    float:right;
    text-align:center;
	font-size: 1.1em;
	background-color: #ff7937;
	color: white;
	border: solid 1px #999999;
	text-decoration:none;
	padding:0px 5px 0px 5px;
	margin-right: 10px;
}
#dvmedicationadd h2,#dvmedicationadd h4
{
    color:#5d7b9d;
}
#mustpickpharmacy
{
    color:maroon;
    font-weight:bold;
    font-size:.95em;
    padding-top: 10px;
}
.holder a
{
    color:#333333;
    padding:0 5px 0 5px;
}
.holder a:hover
{
    color:#ff7937;
}
.jp-current
{
    color:#ff7937;
}

.placeholder
{
  color: #B8B8B8;
}

.rxbox
{
   width:70px;
   height:45px;
   border:1px solid #000;
}

p.dailydose
{
    width:70px;
    text-align:center;
    line-height:1.5em;
    font-size:0.8em;
}
