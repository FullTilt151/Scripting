$smtpserver = 'pobox.humana.com'
$from = 'Enterprise Information Protection <Enterprise_Information_Protection@humana.com>'

$userdata = ''
$userdatasplit = $userdata.Split(';')
$wkid = $userdatasplit[0]
$email = $userdatasplit[1]

$to = 'dratliff@humana.com'
$bcc = 'dratliff@humana.com'
$subject = "Your workstation will recieve a required reboot on the 25th of this month $email"

if ( -eq 15) {
    $RebootStatement = 'Your workstation will receive a required reboot within the next couple of weeks.'
} elseif(  -eq 30) {
    $RebootStatement = 'Your workstation will receive a required reboot within the next day(s).'
}

$body = @"
<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns="http://www.w3.org/TR/REC-html40"><head><meta http-equiv=Content-Type content="text/html; charset=us-ascii"><meta name=Generator content="Microsoft Word 14 (filtered medium)"><!--[if !mso]><style>v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style><![endif]--><style><!--
/* Font Definitions */
@font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	line-height:150%;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#046AB2;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#046AB2;
	text-decoration:underline;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-priority:99;
	mso-style-link:"Balloon Text Char";
	margin:0in;
	margin-bottom:.0001pt;
	font-size:8.0pt;
	font-family:"Tahoma","sans-serif";}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{mso-style-priority:34;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.5in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
span.BalloonTextChar
	{mso-style-name:"Balloon Text Char";
	mso-style-priority:99;
	mso-style-link:"Balloon Text";
	font-family:"Tahoma","sans-serif";}
span.EmailStyle20
	{mso-style-type:personal;
	font-family:"Arial","sans-serif";
	color:#484641;}
span.EmailStyle21
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	font-variant:normal !important;
	color:#79756D;
	text-transform:none;
	font-weight:normal;
	font-style:normal;
	text-decoration:none none;
	vertical-align:baseline;}
span.EmailStyle22
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
span.EmailStyle23
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
span.EmailStyle24
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
span.EmailStyle25
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:#1F497D;
	font-weight:normal;
	font-style:normal;}
span.EmailStyle26
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
span.EmailStyle27
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:#1F497D;
	font-weight:normal;
	font-style:normal;}
span.EmailStyle28
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
span.EmailStyle29
	{mso-style-type:personal-reply;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
/* List Definitions */
@list l0
	{mso-list-id:98262087;
	mso-list-type:hybrid;
	mso-list-template-ids:-1202312704 -1178166584 67698705 67698715 67698703 67698713 67698715 67698703 67698713 67698715;}
@list l0:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:12.0pt;
	font-family:Symbol;
	color:#5C9A1B;
	mso-style-textfill-fill-color:#5C9A1B;
	mso-style-textfill-fill-alpha:100.0%;
	position:relative;
	top:0pt;
	mso-text-raise:0pt;}
@list l0:level2
	{mso-level-text:"%2\)";
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level3
	{mso-level-number-format:roman-lower;
	mso-level-tab-stop:none;
	mso-level-number-position:right;
	text-indent:-9.0pt;}
@list l0:level4
	{mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level5
	{mso-level-number-format:alpha-lower;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level6
	{mso-level-number-format:roman-lower;
	mso-level-tab-stop:none;
	mso-level-number-position:right;
	text-indent:-9.0pt;}
@list l0:level7
	{mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level8
	{mso-level-number-format:alpha-lower;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level9
	{mso-level-number-format:roman-lower;
	mso-level-tab-stop:none;
	mso-level-number-position:right;
	text-indent:-9.0pt;}
@list l1
	{mso-list-id:206113654;
	mso-list-template-ids:-947997140;}
@list l1:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l1:level2
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l1:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l1:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l1:level5
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l1:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l1:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l1:level8
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l1:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l2
	{mso-list-id:696199045;
	mso-list-type:hybrid;
	mso-list-template-ids:2011182118 -1222971162 67698691 67698693 67698689 67698691 67698693 67698689 67698691 67698693;}
@list l2:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:12.0pt;
	font-family:Symbol;
	color:#5C9A1B;}
@list l2:level2
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Courier New";}
@list l2:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Wingdings;}
@list l2:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l2:level5
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Courier New";}
@list l2:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Wingdings;}
@list l2:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l2:level8
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Courier New";}
@list l2:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Wingdings;}
@list l3
	{mso-list-id:1053236972;
	mso-list-template-ids:-312949100;}
@list l3:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l3:level2
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l3:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l3:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l3:level5
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l3:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l3:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l3:level8
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l3:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l4
	{mso-list-id:1115564679;
	mso-list-type:hybrid;
	mso-list-template-ids:-1085220574 -1222971162 67698691 67698693 67698689 67698691 67698693 67698689 67698691 67698693;}
@list l4:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:12.0pt;
	font-family:Symbol;
	color:#5C9A1B;}
@list l4:level2
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Courier New";}
@list l4:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Wingdings;}
@list l4:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l4:level5
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Courier New";}
@list l4:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Wingdings;}
@list l4:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l4:level8
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Courier New";}
@list l4:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Wingdings;}
@list l5
	{mso-list-id:1145857620;
	mso-list-template-ids:-1127991666;}
@list l5:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l5:level2
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:"Courier New";
	mso-bidi-font-family:"Times New Roman";}
@list l5:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l5:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l5:level5
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l5:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l5:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l5:level8
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l5:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l6
	{mso-list-id:2021541041;
	mso-list-template-ids:396890080;}
@list l6:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l6:level2
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l6:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l6:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l6:level5
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l6:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l6:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l6:level8
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l6:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext="edit" spidmax="1027" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext="edit">
<o:idmap v:ext="edit" data="1" />
</o:shapelayout></xml><![endif]-->
</head>
<body bgcolor="#EEEEEE" lang=EN-US link="#046AB2" vlink="#046AB2">
<div class=WordSection1><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style='width:100.0%;background:white;border-collapse:collapse'>
<tr style='height:50.85pt'>
<td width="100%" style='width:100.0%;border-top:none;border-left:solid #484641 2.25pt;border-bottom:solid #5C9A1B 2.25pt;border-right:solid #484641 2.25pt;background:#484641;padding:.2in .2in .2in .2in;height:50.85pt'>
<p class=MsoNormal style='line-height:115%'>
<span style='font-size:22.0pt;line-height:115%;font-family:"Arial","sans-serif";color:white'>Click the Go Home Icon Daily<o:p></o:p></span>
</p><p class=MsoNormal style='line-height:115%'>
<span style='font-size:18.0pt;line-height:115%;font-family:"Arial","sans-serif";color:white'>Ensure Your Workstations &amp; Laptops Receive Necessary Updates</span>
<span style='font-size:20.0pt;line-height:115%;font-family:"Arial","sans-serif";color:#1F497D'><o:p></o:p></span>
</p>
</td>
</tr>
<tr style='height:.05in'>
<td width="100%" valign=top style='width:100.0%;border:solid #D9D9D9 1.0pt;border-top:none;padding:.2in .2in .2in .2in;height:.05in'>
<p class=MsoNormal>
<span style='font-size:18.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#5C9A1B'>$RebootStatement</span><o:p></o:p></p>
<p class=MsoNormal><!--[if gte vml 1]><v:shapetype id="_x0000_t75" coordsize="21600,21600" o:spt="75" o:preferrelative="t" path="m@4@5l@4@11@9@11@9@5xe" filled="f" stroked="f">
<v:stroke joinstyle="miter" />
<v:formulas>
<v:f eqn="if lineDrawn pixelLineWidth 0" />
<v:f eqn="sum @0 1 0" />
<v:f eqn="sum 0 0 @1" />
<v:f eqn="prod @2 1 2" />
<v:f eqn="prod @3 21600 pixelWidth" />
<v:f eqn="prod @3 21600 pixelHeight" />
<v:f eqn="sum @0 0 1" />
<v:f eqn="prod @6 1 2" />
<v:f eqn="prod @7 21600 pixelWidth" />
<v:f eqn="sum @8 21600 0" />
<v:f eqn="prod @7 21600 pixelHeight" />
<v:f eqn="sum @10 21600 0" />
</v:formulas>
<v:path o:extrusionok="f" gradientshapeok="t" o:connecttype="rect" />
<o:lock v:ext="edit" aspectratio="t" />
</v:shapetype><v:shape id="Picture_x0020_3" o:spid="_x0000_s1026" type="#_x0000_t75" alt="image003" style='position:absolute;margin-left:43.5pt;margin-top:364.1pt;width:94.7pt;height:108pt;z-index:251658240;visibility:visible;mso-width-percent:0;mso-height-percent:0;mso-wrap-distance-left:4.5pt;mso-wrap-distance-top:0;mso-wrap-distance-right:4.5pt;mso-wrap-distance-bottom:0;mso-position-horizontal:right;mso-position-horizontal-relative:text;mso-position-vertical:absolute;mso-position-vertical-relative:line;mso-width-percent:0;mso-height-percent:0;mso-width-relative:page;mso-height-relative:page' o:allowoverlap="f" filled="t" fillcolor="#eee">
<v:imagedata src="cid:GoHome.jpg@01D15909.DA714890" o:title="" cropright="-104f" />
<w:wrap type="square" anchory="line"/>
</v:shape><![endif]--><![if !vml]>
<!--<img width=158 height=180 src="cid:GoHome.jpg@01D15909.DA714890" align=right hspace=6 alt=image003 v:shapes="Picture_x0020_3">-->
<![endif]><span style='font-family:"Arial","sans-serif";color:#484641'>Over the past several months, workstations &amp; laptops that have not been rebooted regularly have been receiving warning prompts from the system that indicate a need to reboot. Humana&#8217;s policy is that associates with a workstation or laptop click the <b>Go Home</b> icon on your desktop daily to reboot and ensure that necessary updates are received. Reboot your workstation or laptop daily using Go Home to avoid forced reboots in the future and allow the reboot to happen on your schedule.<br><br>Workstation ID: $wkid</span><span style='font-family:"Arial","sans-serif";color:#1F497D'><o:p></o:p></span></p><p class=MsoNormal><span style='color:#1F497D'><o:p>&nbsp;</o:p></span></p>
<p class=MsoNormal><span style='font-size:16.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#5CAA1B'>Questions?<o:p></o:p></span></p><p class=MsoNormal><span style='font-family:"Arial","sans-serif";color:#484641'>Visit </span><span style='font-family:"Arial","sans-serif"'><a href="http://go/reboot">go/reboot</a> <span style='color:#484641'>for details on Humana&#8217;s policy regarding workstation and laptop reboots. Contact <a href="mailto:eip@humana.com">eip@humana.com</a> with additional questions or concerns. &nbsp;<o:p></o:p></span></span></p><p class=MsoNormal><span style='font-family:"Arial","sans-serif";color:#484641'><o:p>&nbsp;</o:p></span></p><p class=MsoNormal>
<span style='font-family:"Arial","sans-serif";color:#484641'>Thank you for your attention to this matter and working to protect Humana&#8217;s information and systems.</span><o:p></o:p></p></td></tr></table></div>
<p class=MsoNormal align=center style='text-align:center'><i><span style='font-size:9.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#484641'><o:p>&nbsp;</o:p></span></i></p>
<p class=MsoNormal align=center style='text-align:center'>
<i><span style='font-size:9.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#676767'>This communication is sent by Enterprise Information Protection (EIP)</span></i>
<i><span style='font-size:9.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#1F497D'>. </span></i>
<i><span style='font-size:9.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#676767'>Contact EIP at <a href="mailto:eip@humana.com">eip@humana.com</a>. </span></i><i><span style='font-size:9.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#1F497D'><br></span></i>
<i><span style='font-size:9.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#676767'>Join the <a href="https://buzz.humana.com/groups/958-cybersecurityawareness">Cyber Security Awareness group</a> on Buzz! for more information to help you </span></i><b><span style='font-size:9.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#5C9A1B'>Protect Yourself.&nbsp;Protect Humana.</span></b><b><span style='font-size:9.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#676767'><o:p></o:p></span></b></p><p class=MsoNormal><span style='font-family:"Arial","sans-serif"'>
<!--<img border=0 width=135 height=59 id="Picture_x0020_4" src="cid:Humana.png@01D11D3A.8A60BF80" alt="Description: Description: Humana Logo">-->
</span><i><span style='font-size:9.0pt;line-height:150%;font-family:"Arial","sans-serif";color:#676767'><o:p></o:p></span></i></p></div>
</body>
</html>
"@

Send-MailMessage  -SmtpServer $smtpserver -Subject $subject -Body $body -BodyAsHtml -From $from -To $to -Bcc $bcc -Attachments "f:\source\GoHome.jpg"