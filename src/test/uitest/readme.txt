
1.Install plugin selenium-ide-2.2.0.xpi to firefox

2.grunt develop

3.open http://localhost:3000/login.html in firefox

4.open selenium ide in firefox
  menu -> tools -> "Selenium IDE" (ctrl + alt +s)

5.open test case in "Selenium IDE"(ctrl + o) , for example open create_stack_test.html

6.run test case in "Selenium IDE"
  menu -> action -> play current test case

7.see result in firefox

------------------------------------------------

Usage:   http://docs.seleniumhq.org/docs/

1.record operation
Menu: Action -> Record


2.assert value of DOM element

Command: assertText
Target: //article[contains(@class,'property-app')]/section/div[2]/dl[1]/dd[1]
Value: i-a964efc9


3.assert value of javascript variable

Command: assertEval
Target: this.browserbot.getUserWindow().MC.canvas_data.component['7EFB712F-B113-495F-9882-303A94C33C49'].resource.InstanceId
Value: i-a964efc9


4.Get Commands for specified element

Right click an element in firefox, click "Show All Available Commands"


5.find DOM element

1)by css:

	css=div.fixedaccordion-head > span
	css=#dashboard-create-stack-list > li > a
	css=.AWS-VPC-Subnet > g.resizer-wrap > rect.group-resizer.resizer-bottomright

2)by id:

	id=login-user

3)by xpath:

//input[contains(@class,'enabled')]
//article[contains(@class,'property-app')]/section/div[2]/dl[1]/dd[1]
//div[contains(@data-option,'{"name": "RT"}')]

find <g>(component svg node):	//*[name()='g' and contains(@class, 'AWS-VPC-VPC')]
find <path>(port for svg node):	//*[name()='path' and contains(@class, 'port-instance-attach')]
find <rect>(resizer for vpc/subnet/az):	//*[name()='g' and contains(@class, 'AWS-VPC-Subnet')][2]/*[name()='g' and contains(@class, 'resizer-wrap')]/*[name()='rect' and contains(@class, 'resizer-bottomright')]

